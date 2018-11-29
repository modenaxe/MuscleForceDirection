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

% looping thought coordinates to assign them a value
for n_StateCoord = 0:N_coordsModel-1
    
    %%%%%% updating pose of the model %%%%%
    %extracting the column for the state variable of interest
    coordName =  char(coordsModel.get(n_StateCoord).getName());
    
    % check if the coordinates as an equivalent in storage.
    CoordInd_in_kinStorage = getMatStructColumn(kinStruct, coordName);
    
    if isempty(CoordInd_in_kinStorage)
        % this is the case when a coordinate is not in the storage file
        if n_frame==0
            warndlg([coordName,' not found in storage. Default value will be assigned.'])
        end
        % assign default value
        currentCoordValue =  coordsModel.get(coordName).getDefaultValue;
    else
        coordColumValues = getMatStructColumn(kinStruct, coordName);
        % Value of the state variable at that frame
        currentCoordValue = coordColumValues(n_frame);
    end
    
    % assigning the coordinates depending on their motion type
    switch char(coordsModel.get(n_StateCoord).get_motion_type())
        case 'rotational'
            % transform to radiant for angles
            coordsModel.get(n_StateCoord).setValue(state,currentCoordValue*pi/180);
        case 'translational'
            % not changing linear distances
            coordsModel.get(n_StateCoord).setValue(state,currentCoordValue);
        case 'coupled'
            error('motiontype ''coupled'' is not managed by this function');
        otherwise
            error('motion type not recognized. Error due to OpenSim update?')
    end
end

end