function printtoSTO(varargin)
%-------------------------------------------------------------------------%
% printtoSTO prints structured results in OpenSim .sto text format.       %
%                                                                         %
% INPUTS:                                                                 %
%           - structData: structure with 'data' and 'colheaders' arrays.  %
%           - outFile: full path filename where output will be written in.%
%           - topheader (optional): header text at top row of sto file.   %
%           - info (optional): informational text within sto file header. %
%                                                                         %
% code edition log:                                                       %
% 18 Sep 2019: created (KS).                                              %
% ----------------------------------------------------------------------- %
%    Author:   Ke Song (Washington University in St. Louis)               %
%    E-mail:   ksong23@wustl.edu                                          %
% ----------------------------------------------------------------------- %
    
    % evaluate required & optional inputs; provide defaults for optional
    switch nargin
        case 2
            structData = varargin{1};
            outFile = varargin{2};
            topheader = '';
            info = '';
        case 3
            structData = varargin{1};
            outFile = varargin{2};
            topheader = varargin{3};
            if isempty(topheader), topheader=''; end
            info = '';
        case 4
            structData = varargin{1};
            outFile = varargin{2};
            topheader = varargin{3};
            if isempty(topheader), topheader=''; end
            info = varargin{4};
            % if isempty(info), info=''; end
        otherwise
            error('incorrect number of inputs to printMFDtoSTO.m.')
    end
    
    % find nRows and nColumns (for header)
    nrc = size(structData.data);
    
    % get directory; if do not exist, create one
    [outDir,~,~] = fileparts(outFile);
    if exist(outDir,'dir')~=7, mkdir(outDir); end
    
    % open sto file to write in (discard existing contents, if any)
    fid = fopen(outFile,'w');
    
    % print headers
    fprintf(fid,'%s\r\n',topheader);
    fprintf(fid,'version=1\r\n'); % set version here
    fprintf(fid,'nRows=%d\r\n',nrc(1));
    fprintf(fid,'nColumns=%d\r\n',nrc(2));
    fprintf(fid,'inDegrees=no\r\n\r\n'); % set to 'yes' for angles in deg
    if ~isempty(info), fprintf(fid,'%s\r\n\r\n',info); end
    fprintf(fid,'Data in S.I. units (seconds, meters, Newtons, ...)\r\n');
    fprintf(fid,'endheader\r\n');
    
    % print array headers
    fmth = repmat('%s\t',1,length(structData.colheaders));
    fmth = [fmth(1:end-2) , '\r\n'];
    fprintf(fid,fmth,structData.colheaders{:});
    
    % print data
    % format: 8 digits after decimal point (spacing: field width = 16)
    fmtd = repmat('%16.8f\t',1,nrc(2));
    fmtd = [fmtd(1:end-2) , '\r\n'];
    for i = 1 : nrc(1)
        fprintf(fid,fmtd,structData.data(i,:)); % print one row at a time
    end
    
    fclose(fid);
end