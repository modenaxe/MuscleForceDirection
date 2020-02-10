clear; clc;

cd('C:\OpenSim2.4.0\Model\Arm26')

[~,result]=dos('analyze –L MuscleForceDirection –S SetupFile.xml','-echo');
