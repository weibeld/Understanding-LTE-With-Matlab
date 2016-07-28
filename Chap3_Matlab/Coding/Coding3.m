% Communication system consisting of:
%   - Turbo encoder
%   - QPSK modulator
%   - AWGN channel
%   - QPSK demodulator with soft-decision output
%   - Turbo decoder with 6 iterations
%
% The system transmits messages of size 2048 bits until either a max. number
% of bit errors or a max. number of transmitted bits has been reached. After
% each transmitted message, the bit error rate (BER) is calculated and updated.
% The function returns the total BER.

% Arguments:
%   EbNo:     Desired Eb/No in dB
%   maxErrs:  Max. number of bit errors at which to stop sending messages
%   maxBits:  Max. number of transmitted bits at which to stop sending messages
% Returns:
%   ber:   The total bit error rate (i.e. scalar between 0 and 1)
%   bits:  The total number of transmitted bits (scalar)
%
% Note: this function interface (including the names of the return variables) is
% required to make the function compatible with the BERTool ('bertool').
%
% Understanding LTE with Matlab, Chap. 03 Ex. 05.
%------------------------------------------------------------------------------%

function [ber, bits] = Coding3(EbNo, maxErrs, maxBits)

%% Constants
FRM     = 2048;                          % Message size in bits
R       = FRM/(3*FRM + 4*3);             % R = 0.3327
Trellis = poly2trellis(4, [13 15], 13);
Indices = randperm(FRM);                 % Random permutation of integers 1:FRM
M       = 4;                             % Number of modulation symbols?
k       = log2(M);                       % Number of bits per modulation symbol?

persistent TurboEncoder TurboDecoder Mod Demod AWGN BitError
if isempty(TurboEncoder)
  TurboEncoder = comm.TurboEncoder('TrellisStructure', Trellis, ...
                                   'InterleaverIndices', Indices);
  TurboDecoder = comm.TurboDecoder('TrellisStructure', Trellis, ...
                                   'InterleaverIndices', Indices, ...
                                   'NumIterations', 6);
  Mod          = comm.QPSKModulator('BitInput', true);
  Demod        = comm.QPSKDemodulator('BitOutput', true, ...
                                      'DecisionMethod', 'Log-likelihood ratio', ...
                                      'VarianceSource', 'Input port');
  AWGN         = comm.AWGNChannel;
  BitError     = comm.ErrorRate;
end

% Set up AWGN channel according to EbNo value:
% Multiply value represented by EbNo (which is in dB) by 'k' and by 'R'
% (which are bot linear). This is achieved by converting 'k' and 'R' to 
% dB and adding them to EbNo.
snr = EbNo + 10*log10(k) + 10*log10(R);
AWGN.EbNo = snr;
% Convert the inverse values of 'snr' (e.g. -10 dB instead of 10 dB) to linear.
% For example, 10 dB -> -10 dB -> 0.1, 20 dB -> -20 dB -> 0.01
noiseVar = 10.^(-snr/10);  % Noise variance

errs = 0;  % Total number of bit errors (wrong bits)
bits = 0;  % Total number of transmitted bits
i    = 0;  % Number of transmitted messages

while ((errs < maxErrs) && (bits < maxBits))
  i = i + 1;
  % Transmitter
  txBits      = randi([0 1], FRM, 1);
  txBitsCoded = TurboEncoder.step(txBits);
  txSymb      = Mod.step(txBitsCoded);
  % Channel
  rxSymb      = AWGN.step(txSymb);
  % Receiver
  rxBitsCoded = Demod.step(rxSymb, noiseVar);     % Soft-decision demodulation
  rxBits      = TurboDecoder.step(-rxBitsCoded);
  rxBits      = rxBits(1:FRM);                    % Discard superfluous bits
  % Compare received bits with transmitted bits
  berResult   = BitError.step(txBits, rxBits);
  % Extract components of BER analysis
  ber  = berResult(1);  % New total bit error rate (=berResult(2)/berResult(3))
  errs = berResult(2);  % New total number of bit errors
  bits = berResult(3);  % Net total number of compared bits
end

% Clear accumulated state from object, because same object will be used in
% future invocatios of this function.
reset(BitError);
