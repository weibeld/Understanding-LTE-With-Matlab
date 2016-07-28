% Communication system consisting of:
%   - QPSK modulator
%   - AWGN channel
%   - QPSK demodulator
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
% Understanding LTE with Matlab, Chap. 03 Ex. 02.
%------------------------------------------------------------------------------%

function [ber, bits] = Coding0(EbNo, maxErrs, maxBits)

%% Constants
FRM      = 2048;     % Message size in bits
M        = 4;        % Number of distinct symbols?
k        = log2(M);  % Number of bits per symbol?

persistent CodeConvol DecodeViterbi Mod Demod AWGN BitError
if isempty(CodeConvol)
  Mod           = comm.QPSKModulator('BitInput', true);
  Demod         = comm.QPSKDemodulator('BitOutput', true);
  AWGN          = comm.AWGNChannel;
  BitError      = comm.ErrorRate;
end

% Set up AWGN channel according to EbNo:
% Multiply the value represented by EbNo (in dB) by k. This is achieved by
% converting k to dB (10*log10(k)) and adding it to EbNo.
AWGN.EbNo = EbNo + 10*log10(k);

errs = 0;  % Total number of bit errors (wrong bits)
bits = 0;  % Total number of transmitted bits
i    = 0;  % Number of transmitted messages

while ((errs < maxErrs) && (bits < maxBits))
  i = i + 1;
  % Transmitter
  txBits    = randi([0 1], FRM, 1);
  txSymb    = Mod.step(txBits);
  % Channel
  rxSymb    = AWGN.step(txSymb);
  % Receiver
  rxBits    = Demod.step(rxSymb);
  % Compare received bits with transmitted bits
  berResult = BitError.step(txBits, rxBits);
  % Extract components of BER analysis
  ber  = berResult(1);  % New total bit error rate (=berResult(2)/berResult(3))
  errs = berResult(2);  % New total number of bit errors
  bits = berResult(3);  % Net total number of compared bits
end

% Clear accumulated state from object, because same object will be used in
% future invocatios of this function.
reset(BitError);
