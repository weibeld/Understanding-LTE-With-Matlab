% getScramblingSeq - Generate a scrambling sequence of a specific length.
%
% Usage:
%   seq = lteScramble(len, iSubframe):  returns the scrambling sequence of
%           length "len" depending on subframe index "iSubframe" and other
%           (hardcoded) context-specific parameters. This function can be used
%           by both, the transmitter and the receiver, to generate the same
%           scrambling sequence.
%
% Input:
%   len:        length of the scrambling sequence to generate
%   iSubframe:  index of the current subframe
%
% Output:
%   outBits:  the scrambling sequence as a column vector

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function seq = getScramblingSeq(len, iSubframe)

persistent SequenceGenerator Int2Bit
% Initialise a Gold sequence generator for generating the scrambling sequence
if isempty(SequenceGenerator)
  maxG  = 43200;                     % Max output size
  p1    = [1 zeros(1, 27) 1 0 0 1];  % First polynomial (LTE stanard)
  p2    = [1 zeros(1, 27) 1 1 1 1];  % Second polynomial (LTE standard)
  init1 = [zeros(1, 30) 1];          % Initial condition for p1 (LTE standard)
  SequenceGenerator = comm.GoldSequence(...
                        'FirstPolynomial',                p1, ...
                        'FirstInitialConditions',         init1, ...
                        'SecondPolynomial',               p2, ...
                        'SecondInitialConditionsSource', 'Input port', ...
                        'Shift',                          1600, ...
                        'VariableSizeOutput',             true, ...
                        'MaximumOutputSize',              [maxG 1]);
  % This object simply converts decimal numbers to their binary representation.
  % If e.g. 'BitsPerInteger' is 4, then Int2Bit.step(7) returns a column vector
  % with the elements "0", "1", "1", "1".
  % I.e. with 'BitsPerInteger' = 31, the step method accepts as input a number
  % between 0 and (2^31)-1 and returns a 31-element column vector of 0 and 1.
  Int2Bit = comm.IntegerToBit('BitsPerInteger', 31);
end

% Context-specific parameters for initial condition of 2nd polynomial
rnti = 1;  % Radio Network Temporary identifier
pci  = 0;  % Physical cell ID?
q    = 0;  % ?

% Initial condition for 2nd polynomial: 31-element col. vector of "0" and "1"
init2 = rnti*(2^14) + q*(2^13) + floor(iSubframe/2)*(2^9) + pci;
init2 = Int2Bit.step(init2);

% Generate scrambling sequence as a column vector
seq = SequenceGenerator.step(init2, len);
