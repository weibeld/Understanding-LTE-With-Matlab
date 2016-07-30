% lteTurboEncode - Code a codeblock with an LTE turbo encoder.
%
% Usage:
%   codedBits = lteTurboEncode(bits, interleaverIndices)
%
% Input:
%   bits:                the block of bits to encode
%   interleaverIndices:  
%
% Output:
%   codedBits:  the encoded input bits
%
% Understanding LTE With Matlab, Chap. 4, p. 88

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function codedBits = lteTurboEncode(bits, interleaverIndices)

persistent Encoder
if isempty(Encoder)
  % Convert the polynomial description of the two convolutional encoders to a
  % trellis description. The polynomial description includes (as specified by
  % the LTE standard):
  %   - Constraint length: 4
  %   - Generator polynomial matrix: [13 15]
  %   - Feedback connection polynomial: 13
  trellis = poly2trellis(4, [13 15], 13);
  % Create a turbo encoder according to the LTE specifications
  Encoder = comm.TurboEncoder('TrellisStructure', trellis, ...
                              'InterleaverIndicesSource', 'Input port');
end

codedBits = Encoder.step(bits, interleaverIndices);
