function Body = getBodyorGround(osimModel,BodyName)
%-------------------------------------------------------------------------%
% getBodyorGround gets a Body or Ground by name from an OpenSim model     %
% (version 4.0 and up).                                                   %
%                                                                         %
% INPUTS:                                                                 %
%           - osimModel: the OpenSim model object.                        %
%           - BodyName:  name pf body to get, a character string.         %
%                                                                         %
% OUTPUTS:                                                                %
%           - Body: target PhysicalFrame object, either a Body or Ground. %
%                                                                         %
% code edition log:                                                       %
% 18 Sep 2019: created for OpenSim 4.0 model Body/Ground format (KS).     %
% ----------------------------------------------------------------------- %
%    Author:   Ke Song (Washington University in St. Louis)               %
%    E-mail:   ksong23@wustl.edu                                          %
% ----------------------------------------------------------------------- %

% load Library
import org.opensim.modeling.*;

% get name of Ground in model
osimGroundName = char(osimModel.getGround.getName());

% get Ground or Body based on name
if strcmp(BodyName,osimGroundName)
    Body = osimModel.getGround(); %Ground
else
    Body = osimModel.getBodySet.get(BodyName);
end

end