%-------------------------------------------------------------------------%
% Copyright (c) 2018 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% Load Library
import org.opensim.modeling.*;


osimModel_name = '../_test_data/Arm26/arm26.osim';
IK_mot_file = '../_test_data/Arm26/elbow_flexion.mot';
bodyOfInterest_name = 'r_humerus';
bodyExpressResultsIn_name = [];
effective_attachm = 'true';
test_input = [];

N_frame_test = 5;
muscleLinesOfActionStruct = muscleForceDirection_plugin(osimModel_name,...
                                                                IK_mot_file,...
                                                                bodyOfInterest_name,...
                                                                bodyExpressResultsIn_name,...
                                                                effective_attachm,...
                                                                'true',...
                                                                []);
                                                            
                                                            
                                                            
% osimModel_name = '../_test_data/gait2392/subject01.osim';
% IK_mot_file = '../_test_data/gait2392/subject01_walk1_ik.mot';
% bodyOfInterest_name = 'femur_r';
% bodyExpressResultsIn_name = [];
% effective_attachm = 'true';
% test_input = [];
% 
% N_frame_test = 5;
% muscleLinesOfActionStruct = muscleForceDirection_plugin(osimModel_name,...
%                                                                 IK_mot_file,...
%                                                                 bodyOfInterest_name,...
%                                                                 bodyExpressResultsIn_name,...
%                                                                 effective_attachm,...
%                                                                 'true',...
%                                                                 []);