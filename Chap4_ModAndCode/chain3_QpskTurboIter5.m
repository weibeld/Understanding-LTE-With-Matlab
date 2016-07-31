% chain3_QpskTurboIter5 - Run BER evaluation on simple communication system.
%
% The communication system consists of:
%   - Turbo encoding
%   - Scrambling
%   - QPSK modulation
%   - AWGN channel
%   - QPSK demodulation with soft-decision (LLR output)
%   - Descrambling of LLRs
%   - Turbo decoding with 5 iterations
%
% Usage:
%   [ber, nBits] = chain3_QpskTurboIter5(EbNo, maxErrs, maxBits)
%
%   Transmit random bit strings of a fixed size over the described communication
%   system until either the stop condition "maxErrs" (max. number of bit errors)
%   or "maxBits" (max. number of transmitted bits) is reached. In the end,
%   calculate and return the total bit error rate and the total nubmer of trans-
%   mitted bits. The Eb/N0 of the channel is set to "EbNo".
%
% Input:
%   EbNo:     the desired Eb/N0 value in dB
%   maxErrs:  number of bit errors after which to stop the simulation
%   maxBits:  number of transmitted bits after which to stop the simulation
%
% Output:
%   ber:   the total bit error rate of the entire simulation
%   nBits: the total number of transmitted bits during the simulation
%
% Note: the interface of this function is compatible with the BERTool of the
% Communication System Toolbox.
%
% Understanding LTE With Matlab, Chap. 04, Ex. 03

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function [ber, nBits] = chain3_QpskTurboIter5(EbNo, maxErrs, maxBits)

args.EbNo       = EbNo;
args.maxErrs    = maxErrs;
args.maxBits    = maxBits;
args.modScheme  = 'QPSK';
args.demodType  = 'soft';
args.coding     = 'turbo';
args.decodeIter = 5;


[ber nBits] = chain3(args);
