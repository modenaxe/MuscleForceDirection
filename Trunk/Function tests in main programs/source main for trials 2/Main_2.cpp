#include<iostream>
#include <OpenSim/OpenSim.h>
#include <OpenSim\Common\Mtx.h>
void EffectiveAttachments(const OpenSim::PathPointSet& aPointSet, int & effecInsertProx, int & effecInsertDist);
inline void NormVec3(SimTK::Vec3 & v1, SimTK::Vec3 & Normv1);

int main()
{
	try
	{
		double start_time=0;
		
		//--------- UPLOAD THE MODEL --------------
		OpenSim::Model osimModel("arm26.osim");
		std::cout<<"Loading model....\n";
		//--------- list of bodies ----------------
		const OpenSim::Set<OpenSim::Muscle> muscles = osimModel.getMuscles();
		int effecInsertProx, effecInsertDist;

		//for (int m=0; m<muscles.getSize(); m++)
		//{
		int m = 1;
			std::cout<<"Muscle "<< muscles[m].getName()<<std::endl;
			const OpenSim::PathPointSet pathpointset = muscles[m].getGeometryPath().getPathPointSet();
			EffectiveAttachments(pathpointset,effecInsertProx, effecInsertDist);
			std::cout<<effecInsertProx;
			std::cout<<"DOUBLE CHECK proximal: "<<effecInsertProx<<std::endl;
			std::cout<<"DOUBLE CHECK distal: "<<effecInsertDist<<std::endl;
			
			// TEST NORMALIZZAZIONE
			SimTK::Vec3 LineOfAction = muscles[m].getGeometryPath().getPathPointSet()[effecInsertProx].getLocation()-muscles[m].getGeometryPath().getPathPointSet()[effecInsertDist].getLocation();
			SimTK::Vec3 LineOfAction_norm, LineOfAction_norm2;
			OpenSim::Mtx::Normalize(3,LineOfAction,LineOfAction_norm2);
			NormVec3(LineOfAction, LineOfAction_norm);

			std::cout<<"Original vector "<<LineOfAction<<std::endl;
			std::cout<<"Normalized vector (mine) "<<LineOfAction_norm<<std::endl;
			std::cout<<"Normalized vector (OpenSim) "<<LineOfAction_norm2<<std::endl;
		//}

		return 0;
	}
catch (OpenSim::Exception ex)
{
	std::cout<<ex.getMessage()<<std::endl;
	return 1;
}
}

void EffectiveAttachments(const OpenSim::PathPointSet& aPointSet, int & effecInsertProx, int & effecInsertDist)
{
			int N_points = aPointSet.getSize();
			
			std::string InitialBody = aPointSet[0].getBodyName();
			
			//int effecInsertProx;
			for(int n=0;n<N_points;n++)
			{
				if(InitialBody!=aPointSet[n].getBodyName())
				{
					effecInsertProx = n-1;
					std::cout<<"Effective proximal origin is point nr: "<<effecInsertProx<<std::endl;

					break;
				}
			}
			//EffectInsertions.append(effecInsertProx);


			//int effecInsertDist;
			std::string FinalBody = aPointSet[N_points-1].getBodyName();
			for(int n=N_points-1;n>=0;n--)
			{
				if(FinalBody!=aPointSet[n].getBodyName())
				{
					effecInsertDist = n+1;
					std::cout<<"Effective distal origin is point nr: "<<effecInsertDist<<std::endl;
					break;
				}
			}
			//EffectInsertions.append(effecInsertDist);
}


inline void NormVec3(SimTK::Vec3 & v1, SimTK::Vec3 & Normv1) 
{
	double Magnitude = sqrt(pow(v1[0],2.0)+pow(v1[1],2.0)+pow(v1[2],2.0));
	Normv1 = v1/Magnitude;
}