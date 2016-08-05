% lteTurboEncode - Encode a codeblock with the LTE turbo encoder.
%
% Usage:
%   outBits = lteTurboEncode(inBits)
%
% Input:
%   inBits:  the block of bits to encode as a column vector
%
% Output:
%   outBits:  the encoded input bits as a 3*(length(inBits)+4) column vector;
%             this corresponds to the 1/3 code rate of the turbo coder plus
%             four tailbits for each of the three output streams.
%
% Understanding LTE With Matlab, Chap. 4, p. 88

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function outBits = lteTurboEncode(inBits)

persistent Encoder
if isempty(Encoder)
  % Convert the polynomial description of the two convolutional encoders to a
  % trellis description. The polynomial description consists of (as specified
  % by the LTE standard):
  %   - Constraint length: 4
  %   - Generator polynomial matrix: [13 15]
  %   - Feedback connection polynomial: 13
  % This is the default trellis structure of comm.TurboEncoder.
  trellis = poly2trellis(4, [13 15], 13);
  % Create turbo encoder
  Encoder = comm.TurboEncoder('TrellisStructure', trellis, ...
                              'InterleaverIndicesSource', 'Input port');
end

% Interleaver indices (i.e. permutation of input bits) for the interleaver
interleaverIndices = getInterleaverIndices(length(inBits));

% Encode
outBits = Encoder.step(inBits, interleaverIndices);
