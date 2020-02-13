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
function [out, missing_coords_list] = isKinMatchingModelCoords(osimModel, headers_in_struct)

% OpenSim suggested settings
import org.opensim.modeling.*
OpenSimObject.setDebugLevel(3);

% getting model coordinates and their number
coordsModel = osimModel.updCoordinateSet();
N_coordsModel = coordsModel.getSize();

% check if coordinates are the same (sometimes time is also here)
if any(strcmp('time', headers_in_struct))
    coordsNames_in_struct = headers_in_struct(~strcmp('time', headers_in_struct));
else
    coordsNames_in_struct = headers_in_struct;
end
n_miss = 0;
n_matched = 0;
coordNames = {};
missing_coords_list = {};

for n = 0:N_coordsModel-1
    %extracting the column for the state variable of interest
    cur_coordName =  char(coordsModel.get(n).getName());
    if find(strcmp(cur_coordName, coordsNames_in_struct)) == n+1
        coordNames{n_matched+1} = cur_coordName;
        n_matched = n_matched+1;
    else
        missing_coords_list{n_miss+1} = cur_coordName;
        n_miss = n_miss+1;
    end
end

if length(coordNames) == length(coordsNames_in_struct)
    disp('Coordinate structure and model are properly matched (coordinates and their order).');
    out = 1;
    return
else
    out = 0;
    
end

end