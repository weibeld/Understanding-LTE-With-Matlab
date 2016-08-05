% Implementation of convolutional encoding and soft-decision Viterbi decoding
% with low-level functions.
%
% Simple communication system consisting of:
%   - Convolutional encoder
%   - AWGN channel
%   - Viterbi decoder with soft-decision input

% Daniel Weibel <danielmartin.weibel@polimi.it> 2 August 2016
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
% Transmitter
%------------------------------------------------------------------------------%
% Message
msg = ones(100, 1);

% Polynomial description of convolutional encoder
constraintLengths = [4 3];
generatorPoly     = [4 5 17; 7 4 2];
% Convert polynomial description to trellis description
trellis = poly2trellis(constraintLengths, generatorPoly);

% Number of input and output streams of encoder
k = log2(trellis.numInputSymbols);   % ...or length of "constraingLengths"
n = log2(trellis.numOutputSymbols);  % ...or number of colums of "generatorPoly"

% Encode
y = convenc(msg, trellis);

%------------------------------------------------------------------------------%
% Channel
%------------------------------------------------------------------------------%
snr = 20; 
% Add random noise to the 0's and 1's according to SNR
yWithNoise = awgn(y, snr);

%------------------------------------------------------------------------------%
% Receiver
%------------------------------------------------------------------------------%
% Create soft-decision input for Viterbi decoder: classify noise-altered bits
% into 8 categories reflecting the confidence of classifying them as 0 or 1.
% 0=most confident        0
% 1=second-most confident 0
% 2=third-most confident  0
% 3=least confident       0
% 4=least confident       1
% 5=third-most confident  1
% 6=second-most confident 1
% 7=most confident        1
decisionPoints = [0.001,.1,.3,.5,.7,.9,.999];
yQuantized = quantiz(yWithNoise, decisionPoints);

% Decode the quantization of the received coded bits
tracebackDepth = 2;
opMode         = 'cont';
decType        = 'soft';
nQuantizBits = log2(length(decisionPoints)+1);
yDecoded = vitdec(yQuantized, trellis, tracebackDepth, opMode, decType,...
                  nQuantizBits);

if strcmp(opMode, 'cont')
  % Because of the traceback delay, the first "k*tracebackDepth" decoded bits
  % can be discarded. The remaining N bits correspond to the first N bits of
  % the transmitted message. Extract these N bits.
  yDecodedS = yDecoded((k*tracebackDepth)+1:end);
  msgS      = x(1:end-(k*tracebackDepth));
else
  yDecodedS = yDecoded;
  msgS      = msg;
end

% Determine bit error rate
nErr = sum(msgS ~= yDecodedS);
ber  = nErr/length(msgS);
