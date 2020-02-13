function transVec = transformVec(osimModel,s,localVec,localBody,transBody)
%-------------------------------------------------------------------------%
% transformVec converts a 3D numerical vector from one specified frame to %
% another, using transformPosition function from the Simbody engine.      %
%                                                                         %
% INPUTS:                                                                 %
%           - osimModel: the OpenSim model object.                        %
%           - s:         current OpenSim model state.                     %
%           - localVec:  3D numerical vector to transform.                %
%           - localBody: current Body where localVec is expressed in.     %
%           - transBody: target Body where localVec will be expreseed in. %
%                                                                         %
% OUTPUTS:                                                                %
%           - transVec:  3D numerical vector converted from localVec, now %
%                        expressed in transBody.                          %
%                                                                         %
% code edition log:                                                       %
% 18 Sep 2019: created (KS).                                              %
% ----------------------------------------------------------------------- %
%    Author:   Ke Song (Washington University in St. Louis)               %
%    E-mail:   ksong23@wustl.edu                                          %
% ----------------------------------------------------------------------- %

% load Library
import org.opensim.modeling.*;

% ensure localVec is 1x3 vector
if all(size(localVec) == [3,1])
    localVec = localVec';
elseif numel(localVec) ~= 3
    error('numerical vector for Simbody transformPosition must be in 3D.')
end

% Vec3 object to store localVec values
localVec3 = Vec3(localVec(1),localVec(2),localVec(3));

% Vec3 object to store transVec values
transVec3 = Vec3(0);

% transformation using SimBody engine
osimModel.getSimbodyEngine.transformPosition(...
    s, localBody, localVec3, transBody, transVec3);

% extract transVec values back from Vec3
transVec = [transVec3.get(0), transVec3.get(1), transVec3.get(2)];

end