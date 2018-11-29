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
%    Author:   Luca Modenese,  2017                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Given a state, this script collects info about the path of a muscle. 
% Bodies of muscle attachments and point coordinates are made available as
% a list and a matrix respectively.
% 
% INPUTS: 
%           - osimMuscle: an OpenSim model (API object).
%           - s: state, used to update the current muscle path and get
%               active conditional viapoints.
%
% OUTPUTS: 
%           - mus_bodyset_list: matrix where each row is a muscle point and
%           columns are its [X Y Z] coordinates in the reference system of 
%           the body they belong to (as in .osim file).
%           - mus_pointset_mat: cell array of body names, same length as
%           the PathPointSet, with the name of the Body for each point.
%           
%
% last modified: 
% 2017: created.
% 26 Jun 2018: comments (LM)
% 29 Nov 2018: renamed, recommented, modified, added to MFD Matlab version.
% ----------------------------------------------------------------------- %
function [mus_bodyset_list, mus_pointset_mat] = getCurrentMusclePathAsMat(osimMuscle, s)

% load libraries
import org.opensim.modeling.*;

% get pathpointset
curr_PathPointSet = osimMuscle.getGeometryPath.getPathPointSet();

n_pp = 1;
for n_p = 0:curr_PathPointSet.getSize-1
    
    % point under examination
    curr_point = curr_PathPointSet.get(n_p);
    attachBody = char(curr_point.getBodyName());
    
    % if pathpoint is conditional, then check if it is active
    if strcmp(char(curr_point.getConcreteClassName), 'ConditionalPathPoint')
        cond_viapoint = ConditionalPathPoint.safeDownCast(curr_point);
        % is it active?
        if cond_viapoint.isActive(s)
            % if yes add it to point set
            mus_pointset_mat(n_pp, 1:3) = [curr_point.getLocation.get(0), curr_point.getLocation.get(1), curr_point.getLocation.get(2)]; %#ok<*AGROW>
            mus_bodyset_list(n_pp) = {attachBody};
            n_pp = n_pp+1;
        else
            continue
        end
    else
        % if not conditional add it
        mus_pointset_mat(n_pp, 1:3) = [curr_point.getLocation.get(0), curr_point.getLocation.get(1), curr_point.getLocation.get(2)];
        mus_bodyset_list(n_pp) = {attachBody};
        n_pp = n_pp+1;
    end
end

end