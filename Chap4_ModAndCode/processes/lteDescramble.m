% lteDescramble - Descramble a column vector of bits or log-likelihood ratios.
%
% Usage:
%   out = lteDescramble(in, iSubframe, method)
%
% Input:
%   in:         if method=='hard', a column vector of bits (output of hard-
%               decision demodulator); if method=='soft', a column vector
%               of log-likelihood ratios (output of soft-decision demodulator).
%   iSubframe:  index of current subframe
%   method:     descrambling method, 'hard'|'soft'
%
% Output:
%   out:  if method=='hard', a column vector of bits; if method=='soft', a
%         column vector of log-likelihood ratios (LLR).
%
% Understanding LTE With Matlab, Chap. 4, p. 82

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function out = lteDescramble(in, iSubframe, method)

% Get the same scrambling sequence that was used for scrambling.
seq = getScramblingSeq(length(in), iSubframe);

switch method
  % If input is from a hard-decision demodulator, i.e. vector of bits
  case 'hard'
    % Descramble (i.e. bitwise XOR) scrambled codeword with scrambling sequence
    out = xor(in, seq);

  % If input is from soft-decision demodulator, i.e. vector of LLRs
  case 'soft'
    % Translate scrambling sequence: change all 0's to 1's and all 1's to -1's
    seq(seq == 1) = -1;
    seq(seq == 0) =  1;
    % Descramble LLRs by element-wise multiplication with scrambling sequence
    out = in .* seq;

  otherwise
    error('Argument "method" must be ''hard'' or ''soft''.');
end
