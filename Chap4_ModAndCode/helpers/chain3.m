% chain3 - Simple communication system for bit error rate evaluation.
%
% The communication system consists of:
%   - Coding 
%   - Scrambling
%   - Modulation
%   - AWGN channel
%   - Demodulation
%   - Descrambling
%   - Decoding
%
% The modulation scheme can be one of:
%   - QPSK
%   - 16QAM
%   - 64QAM
%
% Each modulation scheme can use one of the following demodulation methods:
%   - Soft-decision demodulation
%
% Usage:
%   [ber, nBits] = chain3(args)
%
% Input:
%   args: structure with the following elements:
%         args.EbNo:       desired Eb/N0 value in dB
%         args.maxErrs:    number of bit errors after which to stop simulation
%         args.maxBits:    number of sent bits after which to stop simulation
%         args.modScheme:  modulation scheme, 'QPSK'|'16QAM'|'64QAM'
%         args.demodType:  demodulation output type, 'hard'|'soft'; must be
%                          'soft' if coding=='turbo'
%         args.coding:     coding type, 'turbo'|'convolutional'
%         args.decodeIter: max. number of iterations of turbo decoding; only
%                          required if coding=='turbo'
%
% Output:
%   ber:   the total bit error rate of the entire simulation
%   nBits: the total number of transmitted bits during the simulation
%
% Understanding LTE with Matlab, Chap. 04 Ex. 02

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function [ber, nBits] = chain3(args)

%------------------------------------------------------------------------------%
% Function arguments
%------------------------------------------------------------------------------%
EbNo       = args.EbNo;       % Scalar real
maxErrs    = args.maxErrs;    % Scalar integer
maxBits    = args.maxBits;    % Scalar integer
modScheme  = args.modScheme;  % String 'QPSK'|'16QAM'|'64QAM'
demodType  = args.demodType;  % String 'hard'|'soft'
coding     = args.coding;     % String 'turbo'|'convolutional'
decodeIter = args.decodeIter; % Scalar integer

%------------------------------------------------------------------------------%
% Parameters
%------------------------------------------------------------------------------%
% Message size (must be one of the code block sizes accepted by the turbo coder)
msgSize = 2432;

% Number of bits per modulation symbols
switch modScheme 
  case 'QPSK',  bitsPerSymb = 2;
  case '16QAM', bitsPerSymb = 4;
  case '64QAM', bitsPerSymb = 6;
  otherwise
    error('Argument "modScheme" must be ''QPSK'', ''16QAM'', or ''64QAM''.');
end

% Code rate = # input bits / # output bits
switch coding
  case 'turbo'
    % Turbo coder has three output streams plus 4 tail bits on each stream
    codeRate = msgSize/(3*(msgSize+4));
  case 'convlutional'
    % Convolutional coder with three output streams and 6 tail bits per stream
    codeRate = msgSize/(3*(msgSize+6));
  otherwise
    error('Argument "coding" must be ''turbo'' or ''convolutional''.');
end

% Multiply EbNo (in dB) with bitsPerSymb to get the "energy per symbol/N0", and
% by codeRate to account for the additional bits due to coding.
snr = EbNo + lin2db(bitsPerSymb) + lin2db(codeRate);

% If demodulation decision method is 'soft', estimate noise variance
switch demodType
  case 'hard'
  case 'soft'
    noiseVar = db2lin(-snr);
  otherwise
    error('Argument "demodType" must be ''hard'' or ''soft''.');
end

% Turbo coding requires soft-decision demodulation, i.e. demodulate to LLRs for
% all bits rather than bits themselves.
if strcmp(coding, 'turbo') && strcmp(demodType, 'hard')
  error('Cannot use hard-decision demodulation output with turbo coding.');
end

%------------------------------------------------------------------------------%
% AWGN channel
%------------------------------------------------------------------------------%
persistent AWGNChannel
if isempty(AWGNChannel)
  AWGNChannel = comm.AWGNChannel;
end
AWGNChannel.EbNo = snr;

%------------------------------------------------------------------------------%
% Data transmission
%------------------------------------------------------------------------------%
% Counters of number of bit errors and number of transmitted bits
nErrs = 0;
nBits = 0;

% Index of the current message, which influences the scrambling sequence
iSubframe = 0;

% Transmit messages until max. number of bit errors or max. numbrer of
% transmitted bits is reached.
while ((nErrs < maxErrs) && (nBits < maxBits))
  %----------------------------------------------------------------------------%
  % Transmitter
  %----------------------------------------------------------------------------%
  % Generate random bit string
  txBits = getBits(msgSize);
  % Encode bits
  switch coding
    case 'turbo'
      txBitsCoded = lteTurboEncode(txBits);
    case 'convolutional'
  end
  % Scramble coded bits with scrambling sequence
  txBitsCodedScram = lteScramble(txBitsCoded, iSubframe);
  % Modulate scrambled bit string
  txSymb = lteModulate(txBitsCodedScram, modScheme);

  %----------------------------------------------------------------------------%
  % Channel
  %----------------------------------------------------------------------------%
  rxSignal = AWGNChannel.step(txSymb);

  %----------------------------------------------------------------------------%
  % Receiver
  %----------------------------------------------------------------------------%
  switch demodType
    % Demodulation with hard-decision output (output bits)
    case 'hard'
      % Demodulate (to bit string)
      rxBitsCodedScram = lteDemodulate(rxSignal, modScheme, demodType);
      % Descramble bits with same scrambling sequence as scrambling was done
      rxBitsCoded = lteDescramble(rxBitsCodedScram, iSubframe, demodType);
      % Decode bits with convolutional decoder
      %rxBits = 

    % Demodulation with soft-decision output (output LLRs)
    case 'soft'
      % Demodulate to log-likelihood ratio vector (one LLR for each bit)
      llrScram = lteDemodulate(rxSignal, modScheme, demodType, noiseVar);
      % Descramble LLR vector
      llr = lteDescramble(llrScram, iSubframe, demodType);
      % Decode LLR vector
      switch coding
        case 'turbo'
          rxBits = lteTurboDecode(llr, msgSize, decodeIter);
        case 'convolutional'
      end
  end

  % Determine number of bit errors and add to total
  nErrs = nErrs + sum(txBits ~= rxBits);
  nBits = nBits + msgSize;

  % Increment subframe index and wrap index around at 20
  iSubframe = mod(iSubframe+2, 20);
end

% Calculate total bit error rate
ber = nErrs/nBits;
