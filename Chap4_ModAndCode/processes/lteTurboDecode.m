% lteTurboDecode - Decode a coded block with an LTE turbo decoder.
%
% Usage:
%   decodedBits = lteTurboDecode(llr, interleaverIndices, maxIterations)
%
% Input:
%   llr:                 the log-likelihood ratios for the received bits as
%                        produced by a soft-decision demodulator
%   interleaverIndices:  
%   maxIterations:
%
% Output:
%   decodedBits:  the best estimate of the transmitted bits
%
% Understanding LTE With Matlab, Chap. 4, p. 88

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function decodedBits = lteTurboDecode(llr, interleaverIndices, maxIterations)

persistent Decoder
if isempty(Decoder)
  % Convert the polynomial description of the two a posteriori probability (APP)
  % decoders to a trellis description. The polynomial description includes (as
  % specified by the LTE standard):
  %   - Constraint length: 4
  %   - Generator polynomial matrix: [13 15]
  %   - Feedback connection polynomial: 13
  % Note that the APP decoders in the turbo decoder use have the same trellis
  % structure as the convolutional encoders in the turbo encoder.
  trellis = poly2trellis(4, [13 15], 13);
  % Create a turbo encoder according to the LTE specifications
  Encoder = comm.TurboEncoder('TrellisStructure', trellis, ...
                              'InterleaverIndicesSource', 'Input port', ...
                              'NumIterations', maxIterations);
end

decodedBits = Encoder.step(llr, interleaverIndices);
