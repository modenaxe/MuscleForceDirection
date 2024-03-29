%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %

%% TEST1: use model built on purpose to test 

% Load Library
import org.opensim.modeling.*;

% verification
osimModel_name = '../tests/MFD_tests/testModel.osim'; 
IK_mot_file = '../tests/MFD_tests/testKinematics_file.mot';
MFD_sto_file = './test_results/test1.sto';
bodyOfInterest_name = 'MovingBody';
bodyExpressResultsIn_name = 'ground';
effec_att = 'false';
test_input = [];
vis_on = 'false';

validated_results_folder = '../_test_data/MFD_tests/validated_res';

res_anatAttach_local = getMuscleForceDirection(osimModel_name,...
    IK_mot_file,...
    MFD_sto_file,...
    bodyOfInterest_name,...
    bodyExpressResultsIn_name,...
    effec_att,...
    vis_on,...
    []);

% res_effectAttach_local = getMuscleForceDirection(osimModel_name,...
%     IK_mot_file,...
%     bodyOfInterest_name,...
%     bodyExpressResultsIn_name,...
%     'true',...
%     vis_on,...
%     []);
% 
% res_effectAttach_ground = getMuscleForceDirection(osimModel_name,...
%     IK_mot_file,...
%     bodyOfInterest_name,...
%     'ground',...
%     'true',...
%     vis_on,...
%     []);
% 
% res_anatAttach_ground = getMuscleForceDirection(osimModel_name,...
%     IK_mot_file,...
%     bodyOfInterest_name,...
%     'ground',...
%     'false',...
%     vis_on,...
%     []);


% res_anatAttach_local
% res_anatAttach_ground
% res_effectAttach_ground
% res_effectAttach_local
% 
% res_anatAttach_local_val = sto2Mat(fullfile(validated_results_folder,'LOCAL_ANATOM_MuscleForceDirection_vectors.sto'));
% 
% res_anatAttach_ground.rowheaders
% res_effectAttach_ground
% res_effectAttach_local
%--------------------------------------------------------------------------
%% TEST3: simple arm26 model
osimModel_name = '../test_data/Arm26/arm26.osim';
IK_mot_file = '../test_data/Arm26/elbow_flexion.mot';
bodyOfInterest_name = 'r_humerus';
bodyExpressResultsIn_name = 'ground';
effective_attachm = 'false';
test_input = [];
% 
% 
% N_frame_test = 5;
muscleLinesOfActionStruct = getMuscleForceDirection(osimModel_name,...
                                                                IK_mot_file,...
                                                                bodyOfInterest_name,...
                                                                bodyExpressResultsIn_name,...
                                                                effective_attachm,...
                                                                'true',...
                                                                []);
                                    
%% TEST3: gait2392 model                                       
                                                            
osimModel_name              = '../tests/gait2392/subject01.osim';
IK_mot_file                 = '../tests/gait2392/subject01_walk1_ik.mot';
bodyOfInterest_name         = 'femur_r';
bodyExpressResultsIn_name   = [];
effective_attachm           = 'true';
test_input = [];
N_frame_test = 5;
muscleLinesOfActionStruct = getMuscleForceDirection(osimModel_name,...
                                                                IK_mot_file,...
                                                                bodyOfInterest_name,...
                                                                bodyExpressResultsIn_name,...
                                                                effective_attachm,...
                                                                'true',...
                                                                 []);