% modQpskSoft - Run bit error rate evaluation on simple communication system.
%
% The communication system consists of:
%   - QPSK modulator
%   - AWGN channel
%   - QPSK demodulator with soft-decision demodulation
%
% Usage:
%   [ber, nBits] = modQpskHard(EbNo, maxErrs, maxBits):  transmit random
%     transport blocks of a fixed size over the described communication system
%     until one of the two stopping conditions is reached (maxErrs or maxBits).
%     Calculate and return the total bit error rate of the simulation, as well
%     as the total number of transmitted bits.
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
% Understanding LTE With Matlab, Chap. 04, Ex. 01

% Daniel Weibel <danielmartin.weibel@polimi.it> July 2016
%------------------------------------------------------------------------------%

function [ber, nBits] = modQpskSoft(EbNo, maxErrs, maxBits)

args.EbNo      = EbNo;
args.maxErrs   = maxErrs;
args.maxBits   = maxBits;
args.scheme    = 'QPSK';
args.demodType = 'soft';

[ber nBits] = sysMod(args);
