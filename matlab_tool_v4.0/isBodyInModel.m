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
% This script checks if a body of interest is included in an OpenSim model.
%
% INPUTS:
%       - osimModel:        an OpenSim model as API object.
%       - bone_of_interest: a string with the name of the body of interest.
%
% OUTPUT:
%       - out: a flag. Flag value 1 means test is passed, otherwise the
%              script throws an error.
%
% last modified: 
% 23 Jun 2017: comments (LM).
% 16 Feb 2018: changed function name (LM). 
% 29 Nov 2018: changed name, recommented, included in MFD toolbox (LM). 
% 18 Sep 2019: modified for OpenSim 4.0 model Body/Ground format (KS).
% ----------------------------------------------------------------------- %
function out = isBodyInModel(osimModel, aBodyName)

% load Library
import org.opensim.modeling.*;

% check if a body (or ground) with the specified name is part of model.
if osimModel.getBodySet.getIndex(aBodyName)<0 && ~strcmp(aBodyName, char(osimModel.getGround.getName()))
    
    % throws error if body is not part of the model
    error(['isBodyInModel.m  The body ',aBodyName,' is not included in the OpenSim model.'])

else
    
    out = 1;
    return
end

end