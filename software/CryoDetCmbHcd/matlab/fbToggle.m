function [ output_args ] = fbToggle( configFileName, dwell, exceptions )
%function [ output_args ] = fbToggle( configFileName, dwell )
%toggles feedback off/on at interval dwell
%with parameters coming from configuration file given by configFileName

% if defined , exceptions specifies that this list of channels DOES NOT get
% reconfigured. e.g. for a demo turn all line FB on/off except for example
% the 8th line, which can be kept in feedback.

if nargin < 1
    configFileName = 'configOffRes2.mat'
end

if nargin < 3
    exceptions = [];
end

if nargin < 2
    dwell = 5
end

fbEn = 0;

while true
    loadConfig(configFileName, 12, fbEn, exceptions);
    pause(dwell);
    fbEn =  1- fbEn;
end

