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
function [MFD, MFDSumStruct] = getMuscleForceDirection(osimModel_name,...
                                                                IK_mot_file,...
                                                                MFD_sto_file,...
                                                                bodyOfInterest_name,...
                                                                bodyExpressResultsIn_name,...
                                                                effective_attachm,...
                                                                visualise,...
                                                                test_input)

% Load Library
import org.opensim.modeling.*;

% read model
osimModel = Model(osimModel_name);

% import kinematics as mat structure
IKStruct = sto2Mat(IK_mot_file);

% check feasibility of the requested operation
isBodyInModel(osimModel, bodyOfInterest_name);

% get body of interest
bodyOfInterest   = osimModel.getBodySet.get(bodyOfInterest_name);

% get body where results will be expressed
% (if different from body of interest)
if strcmp(bodyExpressResultsIn_name, bodyOfInterest_name)==1
    bodyExpressResultsIn = bodyOfInterest;
else
    if isempty(bodyExpressResultsIn_name)==1
        bodyExpressResultsIn_name = bodyOfInterest_name;
        bodyExpressResultsIn = bodyOfInterest;
    else
        isBodyInModel(osimModel, bodyExpressResultsIn_name)
        bodyExpressResultsIn = osimModel.getBodySet.get(bodyExpressResultsIn_name);
    end
end

% define muscles to include in the analysis
% get muscles
muscleSet = osimModel.getMuscles();
n_keep = 1;
for n_m = 0:muscleSet.getSize()-1
    
    % extract muscle
    curr_mus = muscleSet.get(n_m);
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
        rowheaders{n_keep,1} = curr_mus_name;
        store_range = 1+3*(n_keep-1):3+3*(n_keep-1);
        colheaders_MFD_vec(store_range)    = {  [curr_mus_name,'_vx_in_',bodyExpressResultsIn_name],...
                                                [curr_mus_name,'_vy_in_',bodyExpressResultsIn_name],...
                                                [curr_mus_name,'_vz_in_',bodyExpressResultsIn_name]};
        colheaders_MFD_attach(store_range) = {  [curr_mus_name,'_px_in_',bodyExpressResultsIn_name],...
                                                [curr_mus_name,'_py_in_',bodyExpressResultsIn_name],...
                                                [curr_mus_name,'_pz_in_',bodyExpressResultsIn_name]};
        n_keep = n_keep +1;
    end
end

N_target_muscles = length(target_mus_names);

% current state. It will change according to kinematics
if strcmp(visualise, 'true')
    osimModel.setUseVisualizer(true);
end
curr_state = osimModel.initSystem();

% number of frames
N_frames = size(IKStruct.data,1);
% this is a testing option to reduce processed kinematics frames when 
% developing related functions
if ~isempty(test_input)
    N_frames = test_input;
end

% Variables could be preallocated for speed, but I didn't like to have all
% zeros, which might be confused with actual values from the analysis.
% mus_info_mat = zeros(muscleSet.getSize(),12, N_frames);
for n_frame = 1:N_frames
    
    % realize kinematics
    state_new = realizeMatStructKinematics(osimModel, curr_state, IKStruct, n_frame);
    if strcmp(visualise, 'true')
        osimModel.updVisualizer().show(state_new);
    end
    
    % counter for muscles to be kept at each frame
    n_keep = 1;
    
    % display time progression
    %disp('--------------------');
    disp(['FRAME: ',num2str(n_frame),'/',num2str(N_frames)]); 
    %disp('--------------------');
    
    for n_m = 0:N_target_muscles-1
        
        % extract muscle
        curr_mus_name = target_mus_names{n_m+1};
        curr_mus = muscleSet.get(curr_mus_name);
        
        % loop through the points
        % this print is too fast to be useful apart from debugging
        % disp(['Processing muscle (',num2str(n_m+1),'/',num2str(N_target_muscles),'): ', curr_mus_name]);
        
            % make available info about the muscle pointSet (body names 
            % and points coordinates)
            [mus_bodyset_list, mus_pointset_mat] = getCurrentMusclePathAsMat(curr_mus, state_new);
            
            % the vector allows 3 cases:
            % 1) muscle STARTS from bone if interest,
            % 2) muscle has via point through the bone of interest but no attachments
            % 3) muscle ENDS at the bone of interest
            % ALL VECTORS FROM BONE OUT!
            
            % vector of muscle attachments in the bone of interest
            attach_vec = strcmp(mus_bodyset_list, bodyOfInterest_name);
            ind_attachms = find(attach_vec);
            
            
            % proximal and distal attachments on body of interest
            % NB ASSUMPTION THAT THE MUSCLE POINTS ARE NUMBERED FROM
            % PROXIMAL TO DISTAL
            prox_attach = min(ind_attachms);
            dist_attach = max(ind_attachms);
            
            % setting for transform operation later on
            otherBodyAttach = Vec3(0);
            
            % CASE 1
            if attach_vec(1)==0 && attach_vec(end)==0
                %  This case is for multi-articular muscles that jump the
                %  body and can be attached with a viapoint.
                display(['Muscle has only viapoints (no bone attachments) on ',bodyOfInterest_name,'. Skipping...']);
                continue
            end
            
            % CASE 2: muscle that starts at bone of interest
            if attach_vec(1)==1 && attach_vec(end)==0 % muscle starts here
                ori         = mus_pointset_mat(1, :);
                lastAttach  = mus_pointset_mat(dist_attach, :);
                bone_attachment = ori;
                
                % first body outside the body of interest
                bodyFrom = osimModel.getBodySet.get(mus_bodyset_list{dist_attach+1});
                
                % vector in bodyFrom ref system
                p = Vec3(mus_pointset_mat(dist_attach+1, 1),...
                         mus_pointset_mat(dist_attach+1, 2),...
                         mus_pointset_mat(dist_attach+1, 3));                
                
            end
            
            % CASE 3: muscle that ends at bone of interest
            if attach_vec(1)==0 && attach_vec(end)==1 % muscle starts here
                ins         = mus_pointset_mat(end, :);
                lastAttach  = mus_pointset_mat(prox_attach,:);
                bone_attachment = ins;
                
                % first body outside the body of interest
                bodyFrom = osimModel.getBodySet.get(mus_bodyset_list{prox_attach-1});
                % vector in bodyFrom ref system
                p = Vec3(   mus_pointset_mat(prox_attach-1, 1),...
                            mus_pointset_mat(prox_attach-1, 2),...
                            mus_pointset_mat(prox_attach-1, 3));

            end
            
            % transformating everything in body of interest ref system
            osimModel.getSimbodyEngine.transformPosition(state_new, bodyFrom, p, bodyOfInterest, otherBodyAttach)
            otherBodyAttach_vec = [otherBodyAttach.get(0), otherBodyAttach.get(1), otherBodyAttach.get(2)];

            % normalized force direction
            force_dir_norm  = (otherBodyAttach_vec-lastAttach)/norm(otherBodyAttach_vec-lastAttach);
            
            % computing transport moment at bone attachment
            bone_to_lastAttach_vec = lastAttach-bone_attachment;
            transp_mom_norm = cross(force_dir_norm', bone_to_lastAttach_vec');
            
            % transforming force directions in body where results should be
            % expressed
            transf_force_dir_norm = Vec3(0);
            force_dir_norm_Vec3 = Vec3(force_dir_norm(1), force_dir_norm(2), force_dir_norm(3));
            osimModel.getSimbodyEngine.transform(state_new, bodyOfInterest, force_dir_norm_Vec3, bodyExpressResultsIn, transf_force_dir_norm);
            force_dir_res = [transf_force_dir_norm.get(0), transf_force_dir_norm.get(1), transf_force_dir_norm.get(2)];
            
            % fill the matrix with the calculated values            
            col_ind = 1+3*(n_keep-1):3+3*(n_keep-1);
            mus_info_mat(n_frame, col_ind, 1)   = bone_attachment;
            mus_info_mat(n_frame, col_ind, 2)   = lastAttach;
            mus_info_mat(n_frame, col_ind, 3)   = force_dir_res;
            mus_info_mat(n_frame, col_ind, 4)   = transp_mom_norm;
            
            n_keep = n_keep + 1;
            % clear variables to avoid surprises
            clear attachment force_dir_norm transp_mom_norm lastAttach otherBodyAttach_vec force_dir_res
            
%         end
    end
end

%----------- OUTPUT FILES ------------
% Output files are the same as the C++ plugin.
% Names and descriptions are taken from the manual
[p, n, e] = fileparts(MFD_sto_file);
MFD_sto_file_vec = fullfile(p, [n,'_MuscleForceDirection_attachments', e]);
MFD_sto_file_att = fullfile(p, [n,'_MuscleForceDirection_vectors', e]);

%-----------------------------------
% MuscleForceDirection_vectors.sto | 
%-----------------------------------
% this file contains the normalized vectors representing the directions 
% of the muscle lines of action. The vector is always pointing from the 
% selected body where the attachment is located outwards. The body in whose
% reference system the vector is expressed is always reported as the final 
% part of the column header of each muscle.
MFD.vectors.colheaders = colheaders_MFD_vec;
MFD.vectors.data = mus_info_mat(:, :, 3);
MFD_vec_descr = ["the normalized muscle lines of actions expressed in ",...
                bodyExpressResultsIn_name, ...
                " reference system"];
Mat2sto(MFD.vectors, MFD_sto_file_vec, MFD_vec_descr)

%---------------------------------------
% MuscleForceDirection_attachments.sto |
%---------------------------------------
% this file is optional and prints the coordinates of the muscle 
% attachments. If the user choice is to express the anatomical muscle 
% attachments in the local reference system, the file will contain the 
% first and last muscle points specified for that muscle in the original model file.

MFD.attach.colheaders = colheaders_MFD_attach;

if strcmp(effective_attachm, 'true')
    % anatomical
    MFD.anatom_attach.data = mus_info_mat(:, :, 1);
else
    % effective
    MFD.effect_attach.data = mus_info_mat(:, :, 2);
end

MFD_attach_descr = ["the position of the muscle attachments expressed in ",...
                bodyExpressResultsIn_name, ...
                " reference system"];
Mat2sto(MFD.vectors, MFD_sto_file_att, MFD_attach_descr)

%----------------------------------------
% MuscleForceDirection_transp_moment.sto |
%----------------------------------------
% this will write a sto file for transport moment.
% MFD.transp_mom.colheaders = colheaders_MFD_vec;
% MFD.transp_mom.data = mus_info_mat(:, :, 4);


%--------------------------
% Advanced MATLAB summary |
%--------------------------
% The idea is to have a matrix with frames as rows and in column bone
% attachments, effective attachments, lines of action and transport
% moments.
colheaders = {'bone_attach_X', 'bone_attach_Y', 'bone_attach_Z', 'effect_attach_X', 'effect_attach_Y', 'effect_attach_Z', ...
                'act_line_X',   'act_line_Y',    'act_line_Z',    'trans_mom_X',   'trans_mom_Y',   'trans_mom_Z'};
% this is an advanced summary for Matlab use
MFDSumStruct.colheaders = colheaders;
MFDSumStruct.rowheaders = rowheaders;
MFDSumStruct.data       = mus_info_mat;

% free the memory
osimModel.disownAllComponents();

end