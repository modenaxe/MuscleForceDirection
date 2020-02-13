%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %

clear;clc
import org.opensim.modeling.*

% TO DO: add the possibility of following states
%%%%%%%%%%%%% SET UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General model
ModelFile = 'arm26.osim';
% read model
osimModel = Model(ModelFile);
muscles = osimModel.getMuscles();
aOsimMuscleNameSet = 'all';%{'BRA'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% setting which muscles will be followed
muscleNames = ArrayStr;
if strcmp(aOsimMuscleNameSet,'all')
    % getmuscles
    muscles.getNames(muscleNames);
else
    % assign given muscle names to the set to be analyzed
    for n_mn = 1:length( aOsimMuscleNameSet )
        muscleNames.append(aOsimMuscleNameSet{n_mn})
    end
end

for n_mus = 0:muscleNames.getSize()-1
    
    % current muscle
    curr_muscle = muscles.get(muscleNames.getitem(n_mus));
    
    % EXTRACTING THE WRAPPING POINTS
    si = osimModel.initSystem();
    
    % get the geometry path for the current state
    PathpointArray = curr_muscle.getGeometryPath().getCurrentPath(si);
    
    % normal pathpoints attached to bodies
    ModelPathpoint = curr_muscle.getGeometryPath().getPathPointSet();
    
    % check if there are wrapping points
    NrOfWrappingPoints = PathpointArray.getSize()-ModelPathpoint.getSize();
   
    % header
    display(['Muscle ',char(curr_muscle.getName()), ' (',num2str(NrOfWrappingPoints),' wrapping points)']);
    
    for n_p = 0:PathpointArray.getSize()-1
        
        % get the coordinates of the current pathpoint
        curr_point_loc_OS = Vec3(PathpointArray.getitem(n_p).getLocation);
        curr_point_loc = [curr_point_loc_OS.get(0),curr_point_loc_OS.get(1),curr_point_loc_OS.get(2)];
        
        % body where the body is attached to
        display(['Point ',num2str(n_p+1), ' attached to body ',char(PathpointArray.getitem(n_p).getBodyName())]);
        display([num2str(curr_point_loc_OS.get(0)),' ',num2str(curr_point_loc_OS.get(1)),' ',num2str(curr_point_loc_OS.get(2))])
        
    end
    display('-----------------------------------');
end