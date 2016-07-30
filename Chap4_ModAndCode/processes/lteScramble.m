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
%
% Understanding LTE with Matlab, Chap. 4, p. 81

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function outBits = lteScramble(inBits, iSubframe)

% Get the scrambling sequence. Parameters that influence the scrambling
% sequence, such as PCI and RNTI, are hardcoded in function "getScramblingSeq".
seq = getScramblingSeq(length(inBits), iSubframe);

% Scramble (i.e. bitwise XOR) codeword with scrambling sequence
outBits = xor(inBits, seq);
