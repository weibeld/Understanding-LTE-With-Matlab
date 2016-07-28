% lteScramble - Scramble a codeword.
%
% Usage:
%   outBits = lteScramble(inBits, iSubframe)
%
% Input:
%   inBits:     the codeword as a column vector
%   iSubframe:  index of the current subframe
%
% Output:
%   outBits:  the scrambled codeword as a column vector

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function outBits = lteScramble(inBits, iSubframe)

seq     = getScramblingSeq(length(inBits), iSubframe);
outBits = xor(inBits, seq);
