% lteDemodulate - Demodulate signal with QPSK, 16QAM, or 64QAM.
%
% Usage:
%   out = lteDemodulate(signal, scheme, method, noiseVar)
%
% Input:
%   signal:   received signal as a complex vector (in-phase vs. quadrature)
%   scheme:   demodulation scheme, 'QPSK'|'16QAM'|'64QAM'
%   method:   demodulation decision method, 'hard'|'soft'
%   noiseVar: only needed if method=='soft', noise variance as a scalar
%
% Output:
%   out:  if method=='hard', the demodulated bits; if method=='soft', the
%         log-likelihood ratio (LLR) for received each bit
%
% Understandig LTE With Matlab, Chap. 4, p. 75-76 

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function out = lteDemodulate(signal, scheme, method, noiseVar)

persistent Qpsk Qam16 Qam64
% Initialise the demodulators with the properties that are common to the two
% demodulation methods 'hard' or 'soft'. This setup matches the LTE standard.
% Note that the custom signal mappings need to be the same for the modulator
% and demodulator for correct results.
if isempty(Qpsk)
  % Note that there would also be the system object comm.QPSKDemodulator.
  Qpsk  = comm.PSKDemodulator('ModulationOrder', 4, ...
                            'BitOutput', true, ...
                            'PhaseOffset', pi/4, ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [0 2 3 1]);
  Qam16 = comm.RectangularQAMDemodulator('ModulationOrder', 16, ...
                            'BitOutput', true, ...
                            'NormalizationMethod', 'Average power', ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [11 10 14 15 9 8 12 13 1 ...
                                                    0 4 5 3 2 6 7]);
  Qam64 = comm.RectangularQAMDemodulator('ModulationOrder', 64, ...
                            'BitOutput', true, ...
                            'NormalizationMethod', 'Average power', ...
                            'SymbolMapping', 'Custom', ...
                            'CustomSymbolMapping', [47 46 42 43 59 58 62 63 ...
                            45 44 40 41 57 56 60 61 37 36 32 33 49 48 52 53 ...
                            39 38 34 35 51 50 54 55 7 6 2 3 19 18 22 23 5 4 ...
                            0 1 17 16 20 21 13 12 8 9 25 24 28 29 15 14 10  ...
                            11 27 26 30 31]);
end

% Set demodulation method specific properties of the demodulators
release(Qpsk);
release(Qam16);
release(Qam64);
switch method
  case 'hard'
    Qpsk.DecisionMethod  = 'Hard decision';
    Qam16.DecisionMethod = 'Hard decision';
    Qam64.DecisionMethod = 'Hard decision';
  case 'soft'
    % Note: property "VarianceSource" only takes effect if "DecisionMethod" is 
    % 'Approximate log-likelihood ratio' or 'Log-likelihood ratio'.
    Qpsk.DecisionMethod  = 'Approximate log-likelihood ratio';
    Qpsk.VarianceSource  = 'Input port';
    Qam16.DecisionMethod = 'Approximate log-likelihood ratio';
    Qam16.VarianceSource = 'Input port';
    Qam64.DecisionMethod = 'Approximate log-likelihood ratio';
    Qam64.VarianceSource = 'Input port';
  otherwise
    error('Argument "method" must be ''hard'' or ''soft''.');
end

% Demodulate with appropriate demodulator
switch scheme
  case 'QPSK'
    if strcmp(method, 'hard')
      out = Qpsk.step(signal);
    else
      out = Qpsk.step(signal, noiseVar);
    end
  case '16QAM'
    if strcmp(method, 'hard')
      out = Qam16.step(signal);
    else
      out = Qam16.step(signal, noiseVar);
    end
  case '64QAM'
    if strcmp(method, 'hard')
      out = Qam64.step(signal);
    else
      out = Qam64.step(signal, noiseVar);
    end
  otherwise
    error('Argument "scheme" must be ''QPSK'', ''16QAM'', or ''64QAM''.');
end
