clear;clc;
RotAngle = -90:2:90;

GLOBAL_ANAT = importdata('GLOBAL_ANATOM_MuscleForceDirection_vectors.sto');
LOCAL_ANAT = importdata('LOCAL_ANATOM_MuscleForceDirection_vectors.sto');
GLOBAL_EFFECT = importdata('GLOBAL_EFFECT_MuscleForceDirection_vectors.sto');
LOCAL_EFFECT = importdata('LOCAL_EFFECT_MuscleForceDirection_vectors.sto');

%% Muscle 1: MuscleStraight
%P1(0,0,0) in ground to P2(0.3, 0 ,0) in body1
MUS1.v1_Global_Anat_Matlab = [cosd(RotAngle)', sind(RotAngle)',zeros(length(RotAngle),1)];
% in the sto file, v1 = data(:,2:4) and v2 = -v1 = data(:,5:7)
MUS1.v1_Global_Anat_OpenSim =GLOBAL_ANAT.data(:,2:4);
MUS1.DiffGlobalAnat = MUS1.v1_Global_Anat_Matlab-MUS1.v1_Global_Anat_OpenSim;

%% Muscle 2: MuscleViaPoint
% Effective: the effective attachments of muscle 2 are the same as muscle 1
v1_Global_Effect_Matlab = MUS1.v1_Global_Anat_Matlab;
% in the sto file, v1 = data(:,8:10) and v2 = -v1 = data(:,11:13)
v1_Global_Effect_OpenSim = GLOBAL_EFFECT.data(:,8:10);
DiffGlobalEffect = v1_Global_Effect_Matlab-v1_Global_Effect_OpenSim;

%% Muscle 3: MuscleWrap
%P1(0.30000, 0.0 ,0.0) in ground to P2(-0.30000, 0.0 ,0.0)
P1 = [0.30000*ones(length(RotAngle),1), 0.0*ones(length(RotAngle),1) ,0.0*ones(length(RotAngle),1)];
P2 = -0.3*[cosd(RotAngle)', sind(RotAngle)',zeros(length(RotAngle),1)];
 
% [L,T1_glob,T2_glob,contact] = Wrapping2([0 0 0]',0.05,P1,P2,1,'on')

count = 0;
for k =1:length(P1)
    [L(k,:),T1_glob(k,:),T2_glob(k,:),contact(k,:)] = Wrapping2([0 0 ],0.05,P1(k,1:2),P2(k,1:2),1,'on');
    v1(k,:) = (T1_glob(k,:)-P1(k,1:2))/norm(T1_glob(k,:)-P1(k,1:2));
end

v1_GlobalAnat = [v1, zeros(length(P1),1)];
v1_GlobalAnat_OpenSim = GLOBAL_ANAT.data(:,14:16);
v1_GlobalAnat-v1_GlobalAnat_OpenSim

