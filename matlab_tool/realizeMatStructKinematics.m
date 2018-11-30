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
% A function to realize the kinematic state of a model. It is currently
% slow but robust.
%
% TODO: write comments
%
% written: 2014/2015 (Griffith University)
% last modified: 
% February 2017 (comments)
% 29/11/2018 renamed and added to MFD Matlab version.
% ----------------------------------------------------------------------- %
function state = realizeMatStructKinematics(osimModel, state, kinStruct, n_frame)
% TO DO
% this function is slow. I should find a way of passing in only a row of
% coordinates! That would eliminate the need of a n_frame as well.

% OpenSim suggested settings
import org.opensim.modeling.*
OpenSimObject.setDebugLevel(3);

% getting model coordinates and their number
coordsModel = osimModel.updCoordinateSet();
N_coordsModel = coordsModel.getSize();

% checking is kinematics matches coordinates order
[out, missing_coords_list] = isKinMatchingModelCoords(osimModel, kinStruct.colheaders);

% correct if there are generalised coordinates not computed in IK (e.g.
% models modified after running IK)
% NB: not tested!!
if ~out
    for n_m = 1:length(missing_coords_list)
        missing_coords_vals(n_m) =  coordsModel.get(coordName).getDefaultValue;
    end
else
    missing_coords_vals = [];
end
% if needed
% kinStruct.colheader = [kinStruct.colheaders, missing_coords_list];

% account for time column in data structure
if any(strcmp('time', kinStruct.colheaders))    
    kin_state_angles = [kinStruct.data(n_frame, 2:end), missing_coords_vals];
else
    kin_state_angles = [kinStruct.data(n_frame, :), missing_coords_vals];
end

% looping thought coordinates to assign them a value
for n_modelCoords = 0:N_coordsModel-1
    
    % Value of the state variable at that frame
    cur_coordValue = kin_state_angles(n_modelCoords+1);
    
    % assigning the coordinates depending on their motion type
    switch char(coordsModel.get(n_modelCoords).get_motion_type())
        case 'rotational'
            % transform to radiant for angles
            coordsModel.get(n_modelCoords).setValue(state,cur_coordValue*pi/180);
        case 'translational'
            % not changing linear distances
            coordsModel.get(n_modelCoords).setValue(state,cur_coordValue);
        case 'coupled'
            error('motiontype ''coupled'' is not managed by realizeMatStructKinematics.m');
        otherwise
            error('motion type not recognized. Please check OpenSim model (maybe update error?')
    end
end

end