% TEST1
% 
% 1) Load
% 2) Runs from GUI
% 3) Runs from GUI in a sequence of analyses
% 4) Runs from GUI loading the setting from xml
% 5) Runs from command line
% 
% //  Results
% 
% 6) Runs with one body selected
% 7) Runs with two bodies selected
% 8) Runs with all.

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
%    Author:   Luca Modenese, May 2019                                    %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% This script runs the test implemented in the test folder.
% ----------------------------------------------------------------------- %
clear
runtests('TEST_plugin.m')