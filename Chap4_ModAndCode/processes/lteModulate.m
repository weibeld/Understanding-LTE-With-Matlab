% lteModulate - Modulate a bit string with QPSK, 16QAM, or 64QAM
%
% Usage:
%   symb = modulate(bits, scheme)
%
% Input:
%   bits:    column vector of bits
%   scheme:  modulation scheme, 'QPSK'|'16QAM'|'64QAM'
%
% Output:
%   symb:  complex vector representing sequence of modulation symbols
%
% Understandig LTE With Matlab, Chap. 4, p. 74

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function symb = lteModulate(bits, scheme)

persistent qpsk qam16 qam64

% Set up the modulators. Note that the demodulators must use the same custom
% symbol mappings, otherwise the demodulated bits don't match the original bits.
if isempty(qpsk)
  % Set up QPSK modulator according to the LTE standard. Note that there would
  % also be the system object comm.QPSKModulator.
  Qpsk  = comm.PSKModulator(4, ...
                            'BitInput', true, ...
                            'PhaseOffset', pi/4, ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [0 2 3 1]);
  % Set up 16QAM modulator according to the LTE standard.
  Qam16 = comm.RectangularQAMModulator(16, ...
                            'BitInput', true, ...
                            'NormalizationMethod', 'Average power', ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [11 10 14 15 9 8 12 13 1 ...
                                                    0 4 5 3 2 6 7]);
  % Set up 64QAM modulator according to the LTE standard.
  Qam64 = comm.RectangularQAMModulator(64, ...
                            'BitInput', true, ...
                            'NormalizationMethod', 'Average power', ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [47 46 42 43 59 58 62 63 ...
                            45 44 40 41 57 56 60 61 37 36 32 33 49 48 52 53 ...
                            39 38 34 35 51 50 54 55 7 6 2 3 19 18 22 23 5 4 ...
                            0 1 17 16 20 21 13 12 8 9 25 24 28 29 15 14 10  ...
                            11 27 26 30 31]);
end

switch scheme
  case 'QPSK'
    symb = step(Qpsk, bits);
  case '16QAM'
    symb = step(Qam16, bits);
  case '64QAM'
    symb = step(Qam64, bits);
  otherwise
    error('Invalid modulation scheme. Use ''QPSK'', ''16QAM'', or ''64QAM''.');
end
