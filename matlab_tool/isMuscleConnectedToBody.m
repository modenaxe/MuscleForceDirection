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
% Script checking if an OpenSim muscle and a given body in an MSK model
% are connected, i.e. if the muscle path has at least one point attached 
% to that body.
% Note that:
% 1) osimMuscle is used to avoid passing in the model. That is the reason 
%    why function isBodyInModel was not used (requires model).
% 2) if a BodyName not belonging to the model if specified, flag will be 0.
%
% INPUTS:
%       -osimMuscle: a muscle from an OpenSim model (API object).
%       -osimBodyName: name of a body included in the OpenSim model.
%
% OUTPUT:
%       -flag: variable of value 1 or 0, depending if the muscle is
%       attached to the body (1) or not (0).
%
%
% written: 2014 (Griffith University)
% last modified: 
% 26 Jun 2017: comments (LM)
% 29 Nov 2018: renamed, recommented, added to MFD Matlab tool (LM).
% ----------------------------------------------------------------------- %
function flag = isMuscleConnectedToBody(osimMuscle, osimBodyName)

% initialise answ
flag = 0;

% check name
if isjava(osimBodyName)
    osimBodyName = char(osimBodyName);
end

% extract muscle pathpointset
muspathpointset = osimMuscle.getGeometryPath.getPathPointSet();

% looping through the pathpoints of a muscle to check if any of those is
% attached to the body of interest
for n_p = 0:muspathpointset.getSize-1
    % current attachment body of the muscle point
    curr_attach_body = char(muspathpointset.get(n_p).getBodyName);
    % check if this is the specified body
    if strcmp(curr_attach_body, osimBodyName)
        flag = 1;
        display(['Muscle ', char(osimMuscle.getName),' is attached to body ', osimBodyName]);
        return
    end
end

% give feedback also if muscle does not attached to specified body
if flag == 0
    display(['Muscle ', char(osimMuscle.getName),' does NOT attach to body ', char(osimBodyName)]);
end

end