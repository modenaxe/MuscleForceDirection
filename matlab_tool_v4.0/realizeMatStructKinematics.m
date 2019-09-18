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
%
% A function to realize the kinematic state of a model.
%
% TODO: write comments
%
% written: 2014/2015 (Griffith University)
% last modified: 
% February 2017 (comments)
% 29/11/2018 renamed and added to MFD Matlab version.
% 18/09/2019 added functionality to assign linear coupled coordinates (KS).
% ----------------------------------------------------------------------- %
function state = realizeMatStructKinematics(osimModel, state, KinColHeaders, KinRowData)
% only a row of kinematic coordinates is passed in this function. columns
% of data MUST match that of colheaders.

% OpenSim suggested settings
import org.opensim.modeling.*
OpenSimObject.setDebugLevel(3);

% getting model coordinates and their number
coordsModel = osimModel.updCoordinateSet();
N_coordsModel = coordsModel.getSize();

% checking is kinematics matches coordinates order
[out, missing_coords_list] = isKinMatchingModelCoords(osimModel, KinColHeaders);

% correct if there are generalised coordinates not computed in IK (e.g.
% models modified after running IK)
if ~out
    for n_m = 1:length(missing_coords_list)
        coordName = missing_coords_list{n_m};
        missing_coords_vals(n_m) =  coordsModel.get(coordName).getDefaultValue;
    end
else
    missing_coords_vals = [];
end

% account for time column in data structure
% append missing coordinates at end of colheaders & data
if any(strcmp('time', KinColHeaders))    
    kin_state_angles     = [KinRowData(2:end),    missing_coords_vals];
    kin_state_colheaders = [KinColHeaders(2:end), missing_coords_list];
else
    kin_state_angles     = [KinRowData,    missing_coords_vals];
    kin_state_colheaders = [KinColHeaders, missing_coords_list];
end

% extract coordinate couplers in model (for coupled joints)
ct_set = osimModel.getConstraintSet();
for n_ct = 0:ct_set.getSize()-1
    ct_class{n_ct+1} = char(ct_set.get(n_ct).getConcreteClassName());
    % extract properties from CoordinateCouplerConstraint
    if ~strcmp(ct_class{n_ct+1},'CoordinateCouplerConstraint') 
        ct{n_ct+1} = [];
    else
        ct{n_ct+1} = CoordinateCouplerConstraint.safeDownCast(ct_set.get(n_ct));
        ct_dcn{n_ct+1} = char(ct{n_ct+1}.getDependentCoordinateName());
    end
end

% looping thought coordinates to assign them a value
for n_modelCoords = 0:N_coordsModel-1
    
    % Value of the state variable at that frame
    cur_coordValue = kin_state_angles(n_modelCoords+1);
    
    % assigning the coordinates depending on their motion type
    switch lower(char(coordsModel.get(n_modelCoords).getMotionType()))
        case 'rotational'
            % transform to radiant for angles
            coordsModel.get(n_modelCoords).setValue(state,cur_coordValue*pi/180);
        case 'translational'
            % not changing linear distances
            coordsModel.get(n_modelCoords).setValue(state,cur_coordValue);
        case 'coupled'
            % in case of coupled joint, search independent coordinate and
            % coupler function, then compute dependent angle
            % search current dependent in coupler definitions (must be unique)
            cctid=find(strcmp(char(coordsModel.get(n_modelCoords).getName()),ct_dcn));
            if length(cctid)~=1
                error(['CoordinateCouplerConstraint for ',...
                    char(coordsModel.get(n_modelCoords).getName()),...
                    ' is not found, OR not uniquely defined, in model ',...
                    char(osimModel.getName()),'.'])
            elseif ~strcmp(char(ct{cctid}.getFunction().getConcreteClassName()),'LinearFunction')
                % if coupler function is not linear, throw error
                % (edit to expand code compatibility to nonlinear functions)
                error('non-linear coordinate coupler function is not managed by realizeMatStructKinematics.m')
            else % unique dependent coupled with LinearFunction found:
                % for linear fn only 1 independent coord should be specified
                ct_icn         = char(ct{cctid}.getIndependentCoordinateNames().get(0));
                ct_fn          = LinearFunction.safeDownCast(ct{cctid}.getFunction());
                % compute dependent coordinate based on independent coord and coupler fn
                ct_icv         = strcmp(kin_state_colheaders,ct_icn);
                cur_coordValue = ct_fn.getSlope() * kin_state_angles(ct_icv) + ct_fn.getIntercept();
                % transform to radiant for angles
                coordsModel.get(n_modelCoords).setValue(state,cur_coordValue*pi/180);
            end
        otherwise
            error('motion type not recognized. Please check OpenSim model (maybe update error?)')
    end
end

end