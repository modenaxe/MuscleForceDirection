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
% This function replicates in MATLAB the functionalities of the
% MuscleForceDirection OpenSim plugin available at 
% https://simtk.org/projects/force_direction
%
% Given an OpenSim model, a body of interest and a pre-computed kinematics 
% the script will return the lines of action of the muscles.
%
% The output a matrix with frames as rows 
%
% TODO: comment
% TODO: deal with joints
% TODO: test script
%
% created: 
% 29 Nov 2018: created based on functions for other purposes and added to
%              MFD Matlab toolbox.
% ------------------------------------------------------------------------%
%    Edition by Ke Song (Washington University), email: ksong23@wustl.edu
% last modified:
% 18 Sep 2019: modified and updated for OpenSim 4.0 Matlab API (KS).
% ------------------------------------------------------------------------%
function [MFD, MFDSumStruct] = getMuscleForceDirection(osimModel_name,...
                                                                IK_mot_file,...
                                                                results_directory,...
                                                                bodyOfInterest_name,...
                                                                bodyExpressResultsIn_name,...
                                                                effective_attachm,...
                                                                print_attachm,...
                                                                visualise,...
                                                                step_interval)

% Load Library
import org.opensim.modeling.*;

% read model
osimModel = Model(osimModel_name);

% current state. It will change according to kinematics
if strcmpi(visualise, 'true')
    osimModel.setUseVisualizer(true);
end
curr_state = osimModel.initSystem();

% import kinematics as mat structure
IKStruct = sto2Mat(IK_mot_file);

% check feasibility of the requested operation
isBodyInModel(osimModel, bodyOfInterest_name);

% get body (or ground) of interest
bodyOfInterest = getBodyorGround(osimModel,bodyOfInterest_name);

% get body used to express results (if different from body of interest)
if strcmp(bodyExpressResultsIn_name, bodyOfInterest_name)==1
    bodyExpressResultsIn = bodyOfInterest;
else
    if isempty(bodyExpressResultsIn_name)==1
        bodyExpressResultsIn_name = bodyOfInterest_name;
        bodyExpressResultsIn      = bodyOfInterest;
    else
        isBodyInModel(osimModel, bodyExpressResultsIn_name)
        bodyExpressResultsIn = getBodyorGround(osimModel,bodyExpressResultsIn_name);
    end
end

% define muscles to include in the analysis
% get muscles
muscleSet = osimModel.getMuscles();
n_keep = 1;
target_mus_names = {};
colheaders_MFD_vec = {}; colheaders_MFD_attach = {};
colheaders_MFDSumStruct = {};
for n_m = 0:muscleSet.getSize()-1
    
    % extract muscle
    curr_mus      = muscleSet.get(n_m);
    curr_mus_name = char(muscleSet.get(n_m).getName());
    
    % check if muscle is attached (1) or not (0) to bone of interest
    % left in internal loop to handle conditional viapoints, if
    % necessary. They might be active only at certain states, therefore
    % it is risky to exclude muscles a priori.
    % NO! CANNOT CHANGE ORIGIN OR INSERTION
    musc_attach = isMuscleConnectedToBody(curr_mus, bodyOfInterest_name);
    
    if musc_attach == 1
        target_mus_names{n_keep} = curr_mus_name;
        
        % defining headers as well
        store_range = 1+3*(n_keep-1):3+3*(n_keep-1);
        % vectors: muscle_vxyz_from_body1_expressed_in_body2 ('from' = start from bone out)
        colheaders_MFD_vec(store_range)      = {  ...
            [curr_mus_name,'_vx_from_',bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_vy_from_',bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_vz_from_',bodyOfInterest_name,'_in_',bodyExpressResultsIn_name]};
        % attachments: muscle_pxyz_on_body1_expressed_in_body2
        colheaders_MFD_attach(store_range)   = {  ...
            [curr_mus_name,'_px_on_',  bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_py_on_',  bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_pz_on_',  bodyOfInterest_name,'_in_',bodyExpressResultsIn_name]};
        % advanced MATLAB summary containing all outputs
        colheaders_MFDSumStruct(store_range) = {  ...
            [curr_mus_name,'_x_',      bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_y_',      bodyOfInterest_name,'_in_',bodyExpressResultsIn_name],...
            [curr_mus_name,'_z_',      bodyOfInterest_name,'_in_',bodyExpressResultsIn_name]};
        n_keep = n_keep +1;
    end
end

N_target_muscles = length(target_mus_names);

% reduce processed kinematics frames when developing related functions
if isempty(step_interval)
    % number of frames
    N_frames = size(IKStruct.data,1);
    % frames (rows of data) in sto file to process
    frames   = 1:size(IKStruct.data,1);
elseif step_interval <= 0 || mod(step_interval,1) ~= 0
    % check if step_interval is correctly given, throw error if not. it
    % must be a positive integer.
    error('input step_interval must be a positive integer.')
else % if step_interval is correctly specified:
    % skip every specified steps of frames
    N_frames = ceil(size(IKStruct.data,1)/step_interval);
    frames   = 1:step_interval:size(IKStruct.data,1);
    % make sure last frame is included
    if frames(end) ~= size(IKStruct.data,1)
        frames   = [frames, size(IKStruct.data,1)];
        N_frames = N_frames+1;
    end
end

% pre-allocate results storage matrix
mus_info_mat = zeros(N_frames,3*N_target_muscles,5);

% extract time stamps if found in IKStruct
if any(strcmp('time',IKStruct.colheaders))
    IKStruct.time = IKStruct.data(:,strcmp('time',IKStruct.colheaders));
    % add 'time' to colheaders as the first entry
    colheaders_MFD_vec      = [{'time'},colheaders_MFD_vec];
    colheaders_MFD_attach   = [{'time'},colheaders_MFD_attach];
    colheaders_MFDSumStruct = [{'time'},colheaders_MFDSumStruct];
    % add a column to results matrix
    mus_info_mat = [zeros(N_frames,1,5) , mus_info_mat];
end

% Variables could be preallocated for speed, but I didn't like to have all
% zeros, which might be confused with actual values from the analysis.
% mus_info_mat = zeros(muscleSet.getSize(),12, N_frames);
for n_frame = 1:N_frames
    
    % realize kinematics
    state_new = realizeMatStructKinematics( ...
        osimModel, curr_state, IKStruct.colheaders, IKStruct.data(frames(n_frame),:) );
    if strcmp(visualise, 'true')
        osimModel.updVisualizer().show(state_new);
    end
    
    % counter for muscles to be kept at each frame
    n_keep = 1;
    
    % display time progression (also display time if found in sto)
    disp('--------------------');
    if any(strcmp('time',IKStruct.colheaders))
        disp(['FRAME: ',num2str(frames(n_frame)),'/',num2str(frames(N_frames)), ...
              ' ( time = ',num2str(IKStruct.time(frames(n_frame))),'s ).']);
        % fill time stamp for processed frame into first columns of results matrix
        mus_info_mat(n_frame, 1, 1:5) = IKStruct.time(frames(n_frame));
    else
        disp(['FRAME: ',num2str(frames(n_frame)),'/',num2str(frames(N_frames)),'.']);
    end
    disp('--------------------');
    
    for n_m = 0:N_target_muscles-1
        
        % extract muscle
        curr_mus_name = target_mus_names{n_m+1};
        curr_mus      = muscleSet.get(curr_mus_name);
        
        % loop through the points
        
        disp(['Processing muscle (',num2str(n_m+1),'/',num2str(N_target_muscles),'): ', curr_mus_name]);
        
            % make available info about the muscle pointSet (body names 
            % and points coordinates)
            [mus_bodyset_list, mus_pointset_mat] = getCurrentMusclePathAsMat(curr_mus, state_new);
            
            % the vector allows 3 cases:
            % 1) muscle STARTS from bone if interest,
            % 2) muscle has via point through the bone of interest but no attachments
            % 3) muscle ENDS at the bone of interest
            % ALL VECTORS FROM BONE OUT!
            
            % vector of muscle attachments in the bone of interest
            attach_vec   = strcmp(mus_bodyset_list, bodyOfInterest_name);
            ind_attachms = find(attach_vec);
            
            % proximal and distal attachments on body of interest
            % NB ASSUMPTION THAT THE MUSCLE POINTS ARE NUMBERED FROM
            % PROXIMAL TO DISTAL
            prox_attach = min(ind_attachms);
            dist_attach = max(ind_attachms);
            
            % CASE 1
            if attach_vec(1)==0 && attach_vec(end)==0
                %  This case is for multi-articular muscles that jump the
                %  body and can be attached with a viapoint.
                disp(['Muscle has only viapoints (no bone attachments) on ',bodyOfInterest_name,'. Skipping...']);
                continue
            end
            
            % CASE 2: muscle that starts at bone of interest
            if attach_vec(1)==1 && attach_vec(end)==0 % muscle starts here
                ori             = mus_pointset_mat(1, :);
                lastAttach      = mus_pointset_mat(dist_attach, :);
                bone_attachment = ori;
                
                % first body outside the body of interest
                % anatomical
                ana_bodyFrom = getBodyorGround(osimModel,mus_bodyset_list{2});
                % effective
                eff_bodyFrom = getBodyorGround(osimModel,mus_bodyset_list{dist_attach+1});
                
                % vector in BodyFrom ref system
                % anatomical
                ana_p_bFrom  = mus_pointset_mat(2,:);
                % effective
                eff_p_bFrom  = mus_pointset_mat(dist_attach+1,:);
            end
            
            % CASE 3: muscle that ends at bone of interest
            if attach_vec(1)==0 && attach_vec(end)==1 % muscle starts here
                ins             = mus_pointset_mat(end, :);
                lastAttach      = mus_pointset_mat(prox_attach,:);
                bone_attachment = ins;
                
                % first body outside the body of interest
                % anatomical
                ana_bodyFrom = getBodyorGround(osimModel,mus_bodyset_list{end-1});
                % effective
                eff_bodyFrom = getBodyorGround(osimModel,mus_bodyset_list{prox_attach-1});
                
                % vector in BodyFrom ref system
                % anatomical
                ana_p_bFrom  = mus_pointset_mat(end-1,:);
                % effective
                eff_p_bFrom  = mus_pointset_mat(prox_attach-1,:);
            end
            
            % transforming everything in body of interest ref system
            % anatomical
            ana_p_bOI = transformVec(osimModel, state_new, ana_p_bFrom, ana_bodyFrom, bodyOfInterest);
            % effective
            eff_p_bOI = transformVec(osimModel, state_new, eff_p_bFrom, eff_bodyFrom, bodyOfInterest);
            
            % normalized force direction
            % anatomical
            ana_f_dir_norm  = (ana_p_bOI-bone_attachment)/norm(ana_p_bOI-bone_attachment);
            % effective
            eff_f_dir_norm  =      (eff_p_bOI-lastAttach)/norm(eff_p_bOI-lastAttach);
            
            % computing transport moment at bone attachment
            % (anatomical force_dir always from bone_attachment, so there
            % is no 'anatomical' transport moment)
            bone_to_lastAttach_vec = lastAttach-bone_attachment;
            transp_mom_norm        = cross(eff_f_dir_norm', bone_to_lastAttach_vec')';
            
            % transforming in body where results should be expressed
            % anatomical attachments:
            ana_attach_res = transformVec(osimModel, state_new, bone_attachment, bodyOfInterest, bodyExpressResultsIn);
            % effective  attachments:
            eff_attach_res = transformVec(osimModel, state_new, lastAttach,      bodyOfInterest, bodyExpressResultsIn);
            % anatomical force directions:
            ana_f_dir_res  = transformVec(osimModel, state_new, ana_f_dir_norm,  bodyOfInterest, bodyExpressResultsIn);
            % effective  force directions:
            eff_f_dir_res  = transformVec(osimModel, state_new, eff_f_dir_norm,  bodyOfInterest, bodyExpressResultsIn);
            % transport moments:
            transp_mom_res = transformVec(osimModel, state_new, transp_mom_norm, bodyOfInterest, bodyExpressResultsIn);
            
            % fill the matrix with the calculated values
            col_ind = 1+3*(n_keep-1):3+3*(n_keep-1);
            % shift 1 column if 'time' exists
            if any(strcmp('time',IKStruct.colheaders))
                col_ind = col_ind+1;
            end
            mus_info_mat(n_frame, col_ind, 1)   = ana_attach_res;
            mus_info_mat(n_frame, col_ind, 2)   = eff_attach_res;
            mus_info_mat(n_frame, col_ind, 3)   = ana_f_dir_res ;
            mus_info_mat(n_frame, col_ind, 4)   = eff_f_dir_res ;
            mus_info_mat(n_frame, col_ind, 5)   = transp_mom_res;
            
            n_keep = n_keep + 1;
            % clear variables to avoid surprises
            clear bone_attachment ana_attach_res ana_bodyFrom ana_p_bFrom ana_p_bOI ana_f_dir_norm ana_f_dir_res
            clear lastAttach      eff_attach_res eff_bodyFrom eff_p_bFrom eff_p_bOI eff_f_dir_norm eff_f_dir_res
            clear transp_mom_norm transp_mom_res
            
    end
end

%----------- OUTPUT FILES ------------
% Output files are the same as the C++ plugin.
% Names and descriptions are taken from the manual
MFD=struct;
%
%-----------------------------------
% MuscleForceDirection_vectors.sto | 
%-----------------------------------
% this file contains the normalized vectors representing the directions 
% of the muscle lines of action. The vector is always pointing from the 
% selected body (reported as the middle part of column header) where the
% attachment is located outwards. The body in whose reference system the
% vector is expressed is always reported as the final part of the column
% header of each muscle.

MFD.anatom_vectors.colheaders = colheaders_MFD_vec;
MFD.anatom_vectors.data       = mus_info_mat(:, :, 3);

MFD.effect_vectors.colheaders = colheaders_MFD_vec;
MFD.effect_vectors.data       = mus_info_mat(:, :, 4);

% construct output filename: get prefix from IK file
[~,OUT_prefix,~]      = fileparts(IK_mot_file);

% print MFD ANATOMICAL or EFFECTIVE force vectors into a sto file based on
% specified input. default is ANATOMICAL.
OUTvectors_file       = [results_directory,'/',OUT_prefix,'_MuscleForceDirection_vectors.sto'];
disp('Printing MuscleForceDirection_vectors file:');
if strcmpi(effective_attachm, 'true')
    % printing EFFECTIVE:
    OUTvectors_header = 'Muscle Force Directions (EFFECTIVE)';
    OUTvectors_info   = [' This file contains normalized EFFECTIVE muscle lines of actions expressed in ',...
                         bodyExpressResultsIn_name,' reference system.',sprintf('\r\n'),...
                         ' The muscle attachments can be printed in a separate file if desired.'];
    printtoSTO(MFD.effect_vectors,OUTvectors_file,OUTvectors_header,OUTvectors_info);
    disp(['MFD EFFECTIVE force directions results printed to file ',OUTvectors_file,'.']);
else % printing ANATOMICAL:
    OUTvectors_header = 'Muscle Force Directions (ANATOMICAL)';
    OUTvectors_info   = [' This file contains normalized ANATOMICAL muscle lines of actions expressed in ',...
                         bodyExpressResultsIn_name,' reference system.',sprintf('\r\n'),...
                         ' The muscle attachments can be printed in a separate file if desired.'];
    printtoSTO(MFD.anatom_vectors,OUTvectors_file,OUTvectors_header,OUTvectors_info);
    disp(['MFD ANATOMICAL force directions results printed to file ',OUTvectors_file,'.']);
end

%---------------------------------------
% MuscleForceDirection_attachments.sto |
%---------------------------------------
% this file is optional and prints the coordinates of the muscle 
% attachments. If the user choice is to express the anatomical muscle 
% attachments in the local reference system, the file will contain the 
% first and last muscle points specified for that muscle in the original
% model file.

MFD.anatom_attach.colheaders = colheaders_MFD_attach;
MFD.anatom_attach.data       = mus_info_mat(:, :, 1);

MFD.effect_attach.colheaders = colheaders_MFD_attach;
MFD.effect_attach.data       = mus_info_mat(:, :, 2);

MFD.transp_mom.colheaders    = colheaders_MFD_vec;
MFD.transp_mom.data          = mus_info_mat(:, :, 5);

% print MFD attachments into a sto file only if print_attachm specified as
% 'true'. default is false (only print vectors results).
if strcmpi(print_attachm, 'true')
    % print ANATOMICAL or EFFECTIVE attachments based on specified input.
    % default is ANATOMICAL.
    OUTattach_file       = [results_directory,'/',OUT_prefix,'_MuscleForceDirection_attachments.sto'];
    disp('Printing MuscleForceDirection_attachments file:');
    if strcmpi(effective_attachm, 'true')
        % printing EFFECTIVE:
        OUTattach_header = 'Muscle Attachment Positions (EFFECTIVE)';
        OUTattach_info   = [' This file contains the positions of EFFECTIVE muscle attachments.',sprintf('\r\n'),...
                            ' The positions are expressed in the ',bodyExpressResultsIn_name,' reference system.'];
        printtoSTO(MFD.effect_attach,OUTattach_file,OUTattach_header,OUTattach_info);
        disp(['MFD EFFECTIVE attachments results printed to file ',OUTattach_file,'.']);
    else % printing ANATOMICAL:
        OUTattach_header = 'Muscle Attachment Positions (ANATOMICAL)';
        OUTattach_info   = [' This file contains the positions of ANATOMICAL muscle attachments.',sprintf('\r\n'),...
                            ' The positions are expressed in the ',bodyExpressResultsIn_name,' reference system.'];
        printtoSTO(MFD.anatom_attach,OUTattach_file,OUTattach_header,OUTattach_info);
        disp(['MFD ANATOMICAL attachments results printed to file ',OUTattach_file,'.']);
    end
else
    disp('MFD attachments results not printed to file.')
end

%--------------------------
% Advanced MATLAB summary |
%--------------------------
% The idea is to have a matrix with frames as rows and in column bone
% attachments, effective attachments, lines of action and transport
% moments.
MFDSumStruct=struct;
% this is an advanced summary for Matlab use
MFDSumStruct.colheaders            = colheaders_MFDSumStruct;
MFDSumStruct.rowheaders            = arrayfun(@(r) sprintf('Frame %d/%d', frames(r),frames(N_frames)), 1:N_frames, 'un',0)';
MFDSumStruct.layerheaders(1,1,1:5) = {'bone_attach','effect_attach','anatom_act_line','effect_act_line','trans_mom'};
MFDSumStruct.data                  = mus_info_mat;

% to free the memory
osimModel.disownAllComponents();

end