%-------------------------------------------------------------------------%
% Copyright (c) 2018 Modenese L.                                          %
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
%
% Function that allows to retrieve the value of a specified variable whose
% name is specified in var_name.
%
% INPUTS
% struct:   is a structure with fields 'colheaders', the headers, and 'data'
%           that is a matrix of data.
% var_name: the name of the variable to extract.
%
% OUTPUTS
% var_value: the column of the matrix correspondent to the header specified
%               in input as var_name.
%
%
% written: Luca Modenese, July 2014
% last modified:
% Header (February 2018, LM)
% 29 Nov 2018: renamed, recommented, added to MFD Matlab version (LM).
% ----------------------------------------------------------------------- %
function var_value = getMatStructColumn(struct, var_name)

% gets the index of the desired variable name in the colheaders of the
% structure from where it will be extracted
var_index = strncmp(struct.colheaders, var_name, length(var_name));

if sum(var_index) == 0
    %error(['getValueColumnForHeader.m','. No header in structure is matching the name ''',var_name,'''.'])
    display(['getValueColumnForHeader.m','. No header in structure is matching the name ''',var_name,''''])
    var_value = [];
    return
end

% uses the index to retrieve the column of values for that variable.
var_value = struct.data(:,var_index);

end
