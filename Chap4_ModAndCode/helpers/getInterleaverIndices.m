% getInterleaverIndices - Get permutation vector for LTE turbo code interleaver.
%
% Usage:
%  indices = getInterleaverIndices(blockLength)
%
% Input:
%   blockLength: length of the input block to the coder; this must be one of
%                the 188 accepted block sizes between 40 and 6144 bits.
%
% Output:
%   indices: the inteleaver indices (i.e. a permutation of the numbers in
%            1:blockLength) as a column vector
%
% Understanding LTE With Matlab, Chap. 4, p. 89

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function indices = getInterleaverIndices(blockLength)

% Get the f1 and f2 parameters for the specified block length
[f1 f2] = getf1f2(blockLength);

% Create column vector 0:blockLength-1
indices = (0:blockLength-1)';

% Calculate interleaver indices, i.e. a permutation of 1:blockLength
indices = mod(f1*indices + f2*(indices.^2), blockLength) + 1;
