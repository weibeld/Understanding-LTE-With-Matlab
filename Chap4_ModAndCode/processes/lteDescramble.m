% lteDescramble- Descramble a column vector of bits or log-likelihood ratios.
%
% Usage:
%   out = lteDescrambleHard(in, iSubframe, method)
%
% Input:
%   in:         if method=='hard', a column vector of bits as produced by the
%               hard-decision demodulator; if method=='soft', a column vector
%               of log-likelihood ratios (LLR) as produced by the soft-decision
%               demodulator.
%   iSubframe:  index of the current subframe
%   method:     either 'hard' or 'soft'
%
% Output:
%   out:  if method=='hard', a column vector of bits; if method=='soft', a
%         column vector of log-likelihood ratios (LLR).

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function out = lteDescrambleHard(in, iSubframe, method)

% Generate scrambling sequence (column vector of bits)
seq = getScramblingSeq(length(in), iSubframe);

switch method
  case 'hard'
    % XOR input bits with scrambling sequence (descrambles scrambled input)
    out = xor(in, seq);
  case 'soft'
    % Translate scrambling sequence: change all 0's to 1's and all 1's to -1's
    seq(seq == 0) =  1;
    seq(seq == 1) = -1;
    % Multply input LLRs with translated scrambling sequence
    out = in .* seq
  otherwise
    error('Argument "method" must be ''hard'' or ''soft''.');
end
