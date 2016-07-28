% Send 'NumMsg' random  bit-string messages of size 'MsgSize' over a channel
% with 'EbNo' Eb/No (in dB) and AWGN.
% Returns:
%   1) Three-element column vector with the following elements:
%     1) total bit error rate
%     2) total number of wrong bits (errors)
%     3) total number of sent bits
%   2) Received QPSK symbols of the last transmitted message
%------------------------------------------------------------------------------%

function [ber, rxSymb] = AWGNChannel(EbNo, NumMsg, MsgSize)

% System objects as persistent variables
persistent Mod AWGN DeMod ERate
% If function is called for the first time, create system objects
if isempty(Mod)
  Mod   = comm.QPSKModulator('BitInput', true);
  AWGN  = comm.AWGNChannel;
  DeMod = comm.QPSKDemodulator('BitOutput', true);
  ERate = comm.ErrorRate;
end

% Set up AWGN channel according to Eb/No:
% Multiply the value represented by EbNo (in dB) by 2. This is achieved by 
% converting 2 to dB (10*log10(2)) and adding it to EbNo. Why 2? Probably,
% because with QPSK one symbol carries 2 bits.
snr = EbNo + 10*log10(2);
AWGN.EbNo = snr;

% Transmit 'NumMsg' messages (bit strings) of size 'MsgSize'
for j = 1:NumMsg
  % Transmitter
  txBits = randi([0 1], MsgSize, 1);  % Generate random bits to transmit
  txSymb = step(Mod, txBits);         % Modulate bits
  % Channel
  rxSymb = step(AWGN, txSymb);        % Change amplitude and phase of symbols
  % Receiver
  rxBits = step(DeMod, rxSymb);       % Demodulate symbols

  % Compare demodulated bits with transmitted bits.
  % An ErrorRate object keeps a state between incovations, in particular, the
  % total number of compared bits, the total number of detected wrong bits,
  % and the error rate (wrong bits / total number of compared bits).
  % Output of step: column vector of size 3 with the following elements:
  %  1) total error rate (may change across invocations)
  %  2) total number of wrong bits detected (may increase across invocations)
  %  3) total number of compared bits (increases across invocations)
  % Note that (1) = (2)/(3)
  ber = step(ERate, txBits, rxBits);
end

% Clear ErrorRate system object (same object will be used in next invocation)
reset(ERate);
