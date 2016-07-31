% lteTurboDecode - Decode a coded block with the LTE turbo decoder.
%
% Usage:
%   outBits = lteTurboDecode(llr, blockLength, maxIter)
%
% Input:
%   llr:         column vector of log-likelihood ratios for the received bits,
%                as calculated by the soft-decision demodulator
%   blockLength: length of the originally encoded block
%   maxIter:     max. number of decoding iterations
%
% Output:
%   outBits: best estimate of the transmitted bits
%
% Understanding LTE With Matlab, Chap. 4, p. 88

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function outBits = lteTurboDecode(llr, blockLength, maxIter)

persistent Decoder
if isempty(Decoder)
  % Convert the polynomial description of the two a posteriori probability (APP)
  % decoders to a trellis description. The polynomial description consists of
  % (as specified by the LTE standard):
  %   - Constraint length: 4
  %   - Generator polynomial matrix: [13 15]
  %   - Feedback connection polynomial: 13
  % Note that the APP decoders in the turbo decoder have the same trellis
  % structure as the convolutional encoders in the turbo encoder.
  trellis = poly2trellis(4, [13 15], 13);
  % Create turbo decoder
  Decoder = comm.TurboDecoder('TrellisStructure', trellis, ...
                              'InterleaverIndicesSource', 'Input port', ...
                              'NumIterations', maxIter);
end

% Get interleaver indices (i.e. bit permutation) for the interleaver
interleaverIndices = getInterleaverIndices(blockLength);

% Decode
outBits = Decoder.step(llr, interleaverIndices);
