% Run example Simulink model "doc_softdecision" for a range of Eb/N0 values and
% plot resulting bit error rates.
%
% The communication system in this model includes:
%   - Convolutional rate-1/2 encoding
%   - BPSK modulation
%   - AWGN channel
%   - BPSK demodulation with 3-bit soft-decision output
%   - Viterbi decoding of 3-bit soft-decision input
%
% The Simulink model is at /Applications/MATLAB_R2016a.app/help/toolbox/comm/
% examples/doc_softdecision.slx

% Daniel Weibel <danielmartin.weibel@polimi.it> 3 August 2016
%------------------------------------------------------------------------------%

EbNoVec = 1:0.5:4;
berVec = [];

figure;

i = 1;
for EbNo = EbNoVec
  % Required input to Simulink model
  EbNodB = EbNo;

  % Run Simulink model. The model creates the variable BER_Data which is a
  % three-element row vector with 1) BER; 2) number of bit errors; 3) number
  % of transmitted bits.
  sim('doc_softdecision');

  % Add BER for current Eb/N0 value to plot ('r*' = red star)
  semilogy(EbNo, BER_Data(1), 'r*');
  hold on;  % Note: for "semilogy", "hold on" must not be before "semilogy"
  drawnow;  % Update figure immediately

  % Save output of Simulink model (BER_Data) to array
  berVec(i, :) = BER_Data;
  i = i + 1;
end

hold off;
