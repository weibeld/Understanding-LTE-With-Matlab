% Bit error rate testbench of an AWGN channel with QPSK modulation.
%------------------------------------------------------------------------------%

%% Constants
EbNoVector = 0:10;  % Eb/No (in dB) for which to evaluate BER
MsgSize    = 2048;  % Number of bits of a single transmission
NumMsg     = 1000;  % Number of messages to send for each Eb/No value

% Always clear variables that are filled element-by-element rather than assigned
% as a whole, because they might still contain a value from a previous run.
clear BERVector

% Initialise figure for Rx signal plots
figure;

%% Loop through all the Eb/No value
i = 1;
for EbNo = EbNoVector

  % Transmit messages and determine the bit error rate
  [ber, rxSymb] = AWGNChannel(EbNo, NumMsg, MsgSize);

  % Save bit error rate for current Eb/No value
  BERVector(i) = ber(1);

  % Plot received signal of a single example msg in a subplot of a 3x4 array.
  subplot(3, 4, i);
  plot(rxSymb, '.');
  xlim([-2, 2]);
  ylim([-2, 2]);
  axis square;
  xlabel('In-Phase');
  ylabel('Quadrature');
  title(['Eb/No=', num2str(EbNo), 'dB']);

  i = i + 1;
end

% Save Rx signal figure
savePDF('RxSignal');

% Plot and save bit error rate figure
figure;
EbNoLin = 10.^(EbNoVector/10);  % Convert each EbNo value from dB to linear
BERVectorTheoretical = 0.5 * erfc(sqrt(EbNoLin));
semilogy(EbNoVector, BERVector); hold on;
semilogy(EbNoVector, BERVectorTheoretical, 'd');
title('BER vs. Eb/No - QPSK Modulation');
xlabel('Eb/No (dB)');
ylabel('Bit Error Rate');
legend('Simulation', 'Theoretical');
grid;
%plot(EbNoVector, BERVector);
savePDF('BER');
