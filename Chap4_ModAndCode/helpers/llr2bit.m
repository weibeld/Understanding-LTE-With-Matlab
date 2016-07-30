% llr2bit - Convert log likelihood ratios (LLR) to bits.
%
% Usage:
%   bits = llr2bit(llr, mode)
%
% Input:
%   llr:   column vector of LLR (as produced by a soft-decision demodulator)
%   mode:  translation mode, 'PosTo0NegTo1'|'PosTo1NegTo0'; the first one
%          translates positive LLR to 0 and negative ones to 1, the second one
%          translates positive LLR to 1 and negative ones to 0. An LLR of 0
%          is translated to 0.
%
% Output:
%   bits:  the bits as a column vector

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function bits = llr2bit(llr, mode)

switch mode
  case 'PosTo0NegTo1'
    llr(llr > 0) = 0;
    llr(llr < 0) = 1;
  case 'PosTo1NegTo0'
    llr(llr > 0) = 1;
    llr(llr < 0) = 0;
  otherwise
    error('Argument "mode" must be ''PosTo0NegTo1'' or ''PosTo1NegTo0''.');
end

bits = llr;
