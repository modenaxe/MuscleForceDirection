%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% This script writes an OpenSim storage file using a Matlab structure as
% input.
%
% INPUTS:
%       - MatStruct: matlab structure with the following fields:
%               a) MatStruct.colheaders: cell array of headers of the
%                                           .sto file.
%               b) MatStruct.data: matrix containing the data that
%                                        will be printed in the .sto file.
%
%       - sto_file: a string with the name (and path) of the .sto file to print.
%
%       - str_data_description: a string that described the data. It will
%               be included in the file in a sentence starting with: 
%                "This file contains..."
%
% OUTPUT:
%       - no output.
%
% ----------------------------------------------------------------------- %
function Mat2sto(MatStruct, sto_file, str_data_description)

% check on the data structure
if ~isfield(MatStruct,'data') || ~isfield(MatStruct,'colheaders') 
    error(['The function writeStorageFile needs as input a dataStruct with fields ''colheaders'' and ''data''.',...
        'The number of columns of DataStruct.data has to equalize the number of headers.']);
end

% defines local variables and their size
colheaders  = MatStruct.colheaders;
data        = MatStruct.data;

% sizes of data
[N_rows, N_columns] = size(data);

% check on consistency of the structure data
if size(colheaders,2)~=N_columns
    error('The number of column headers is not consistent with the number of data rows.')
end

% file name
[~,name,ext] = fileparts(sto_file);
sto_file_name = [name,ext];

% open file
fid = fopen(sto_file,'w');

% % Write Header
fprintf(fid,'%s\n',sto_file_name);
fprintf(fid,'%s\n','version=1');
fprintf(fid,'%s\n',['nRows=',num2str(N_rows)]);
fprintf(fid,'%s\n',['nColumns=',num2str(N_columns)]);
fprintf(fid,'%s\n','inDegrees=no');
fprintf(fid,'\n');
fprintf(fid,'%s\n',['This file contains ',str_data_description, '.']);
fprintf(fid,'\n');
fprintf(fid,'%s\n','endheader');

% writing the column headers while generating the format for printing the
% data
format_string ='';
for n_headers = 1:N_columns
    if n_headers == N_columns
        % prints header
        fprintf(fid,'%s\n',colheaders{N_columns});
        % builds up format string
        format_string = [format_string,'%-14.14f\n']; %#ok<*AGROW>
    else
        fprintf(fid,'%s\t', colheaders{n_headers});
        format_string = [format_string,'%-14.14f\t'];
    end
end

% writing the data in OpenSim format
fprintf(fid, format_string, data');
fclose all;

end