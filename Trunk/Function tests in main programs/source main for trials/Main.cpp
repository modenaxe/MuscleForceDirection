#include<iostream>
#include <OpenSim/OpenSim.h>
bool IsMuscleAttachedAnywhereToBody(OpenSim::Muscle &aMuscle, std::string aBodyName);
bool IsMuscleAttachedToBody(OpenSim::Muscle &aMuscle, std::string aBodyName);
void GetMusclesSetForBody(OpenSim::Model & _model, OpenSim::Body & aBody, OpenSim::Array<bool> & MuscleArray);
void GetMusclesIndexForBody(OpenSim::Model * _model, std::string aBodyName, OpenSim::Array<int> & MusclesIndexForBody);
void GetMusclesIndexForBody(OpenSim::Model * _model, OpenSim::Array<std::string> aBodyNameSet, OpenSim::Array<int>  & MusclesIndexForBody );

int main()
{
	try{
		int n_bod, nbody, n_mus;
		double start_time=0;
		
		//--------- UPLOAD THE MODEL --------------
		OpenSim::Model osimModel("LegModel.osim");

		//--------- list of bodies ----------------
		OpenSim::BodySet bodies = osimModel.getBodySet();
		std::cout<<"Please choose a body\n";
		for (n_bod = 0; n_bod<bodies.getSize();n_bod++)
		{
			std::cout<<"("<<n_bod+1<<") "<<bodies[n_bod].getName()<<std::endl;
		}
		std::cout<<"Please specify the number of the segment (avoid ground body): \n";
		// import select body*/
		std::cin>>nbody; 
		OpenSim::Body ChosenBody = bodies.get(nbody-1);
		
		//Get the muscles
		int Nmuscles = osimModel.getMuscles().getSize();
		
		// Get the muscles attached to the selected body 
		OpenSim::Array<bool> AttachedMuscles;
		AttachedMuscles.setSize(Nmuscles);

		OpenSim::Array<int>  Prova, DoubleCheck;
		GetMusclesIndexForBody(&osimModel, ChosenBody.getName(), Prova);

		OpenSim::Array<std::string> aBodyNameSet;
		//OpenSim::BodySet b = osimModel.getBodySet();
		//aBodyNameSet.set(0,b[nbody-1].getName());
		aBodyNameSet.set(0,ChosenBody.getName());
		aBodyNameSet.set(1,ChosenBody.getName());
		//std::cout<<aBodyNameSet[0];
		//aBodyNameSet.set(1,b[nbody].getName());
		//std::cout<<aBodyNameSet;
		std::cout<<"Array of names "<< aBodyNameSet<<std::endl;

		GetMusclesIndexForBody(&osimModel,  aBodyNameSet, DoubleCheck);

		// OK: etMusclesIndexForBody validata!!
		std::cout<<Prova<<"\n";
		
		// getting a bool set wich contains the muscles attached to the selected body
		GetMusclesSetForBody(osimModel,ChosenBody,AttachedMuscles);
		std::cout<<"The attached muscles are (Body string function):\n";

		for (n_mus = 0;n_mus<Nmuscles ;n_mus++)
		{	if (AttachedMuscles[n_mus])
			{
				std::cout<<osimModel.getMuscles()[n_mus].getName()<<std::endl;
			}
		}
		
		
		std::cout<<"Double checking with array names function "<< DoubleCheck<<std::endl;
		
		return 0;
	}
catch (OpenSim::Exception ex)
{
	std::cout<<ex.getMessage()<<std::endl;
	return 1;
}
}


// function that answers to the question: Is aMuscle attached to aBody?
bool IsMuscleAttachedAnywhereToBody(OpenSim::Muscle &aMuscle, std::string aBodyName)

{
	bool Attached = false;
	OpenSim::GeometryPath  aGeometryPath = aMuscle.getGeometryPath();
	OpenSim::PathPointSet  aPointSet = aGeometryPath.getPathPointSet();
	int N_point = aPointSet.getSize();
	for (int n_point=0; n_point<N_point;n_point++)
	{
		if(aPointSet.get(n_point).getBodyName()==aBodyName)
		{
			Attached = true;
			break;
		}
	}
	return Attached;
}



// function that answers to the question: Is aMuscle attached to aBody?
bool IsMuscleAttachedToBody(OpenSim::Muscle &aMuscle, std::string aBodyName)

{
	bool Attached = false;
	OpenSim::GeometryPath  aGeometryPath = aMuscle.getGeometryPath();
	OpenSim::PathPointSet  aPointSet = aGeometryPath.getPathPointSet();
	int FinalPointIndex = aPointSet.getSize()-1;

	if(aPointSet[0].getBodyName()==aBodyName  ||  aPointSet[FinalPointIndex].getBodyName()==aBodyName)
		{
			Attached = true;
		}

	return Attached;
}



// functions that returns the MuscleArray of bools attached to the selected body
void  GetMusclesSetForBody(OpenSim::Model & _model, OpenSim::Body & aBody, OpenSim::Array<bool> & MuscleArray)
{
		// Get all the muscles and their number
		OpenSim::Set<OpenSim::Muscle> MUS = _model.getMuscles();
		int N_MUS = MUS.getSize();

		for(int n_mus = 0; n_mus<N_MUS; n_mus++)		
		{
			MuscleArray.set(n_mus, IsMuscleAttachedToBody(MUS[n_mus], aBody.getName()));
		}

}

void GetMusclesIndexForBody(OpenSim::Model * _model, std::string aBodyName, OpenSim::Array<int>  & MusclesIndexForBody )
{
		// Get all the muscles and their number
		OpenSim::Set<OpenSim::Muscle>  muscles = _model->getMuscles();
		int k=0;
		for(int n_mus = 0; n_mus<muscles.getSize(); n_mus++)		
		{
			if (IsMuscleAttachedToBody(muscles[n_mus], aBodyName))
			{
				MusclesIndexForBody.set(k,muscles.getIndex(muscles[n_mus].getName()));
				k=k+1;
			}

		}
}

void GetMusclesIndexForBody(OpenSim::Model * _model, OpenSim::Array<std::string> aBodyNameSet, OpenSim::Array<int>  & MusclesIndexForBody )
{

	if	(aBodyNameSet[0]=="all")
	{
		OpenSim::Set<OpenSim::Muscle>  muscles = _model->getMuscles();
		MusclesIndexForBody.setSize(muscles.getSize());

		// Get indices of all the muscles.
		for(int j=0;j<muscles.getSize();j++)
			MusclesIndexForBody[j]=j;
	}
	else
	{
		// Get all the muscles and their number
		int k=0, n=0;
		
		OpenSim::Array<int> MusclesIndexForBody_temp;
		OpenSim::Set<OpenSim::Muscle>  muscles = _model->getMuscles();
		for (int n_body = 0; n_body<aBodyNameSet.getSize(); n_body++)
		{
			std::string aBodyName = aBodyNameSet.get(n_body);
				
				for(int n_mus = 0; n_mus<muscles.getSize(); n_mus++)		
				{

					if (IsMuscleAttachedToBody(muscles[n_mus], aBodyName))
					{
						MusclesIndexForBody_temp.set(k,muscles.getIndex(muscles[n_mus].getName()));
						k++;
						std::cout<<"---->"<<muscles[n_mus].getName()<<" attached\n";
					}

				}
		}

		//MusclesIndexForBody = MusclesIndexForBody_temp;
		// Check double muscles
		//std::cout<<"In ingresso alla funzione "<<MusclesIndexForBody_temp<<std::endl;
		for (int n_ind = 0; n_ind<MusclesIndexForBody_temp.getSize();n_ind++)
		{
			bool check=false;
			//int index = MusclesIndexForBody[n_ind];
			//std::cout<<"index checked"<<index<<std::endl;
			for (int n_ind2 = n_ind+1; n_ind2<MusclesIndexForBody_temp.getSize(); n_ind2++)
			{
				if (MusclesIndexForBody_temp[n_ind]==MusclesIndexForBody_temp[n_ind2])
				{
					check = true;
					break;
				}

			}
			if (!check)
			{
					MusclesIndexForBody.set(n,MusclesIndexForBody_temp[n_ind]);
					n++;
			}
		}
	}
		//std::cout<<"In uscita dalla funzione: "<<MusclesIndexForBody<<std::endl;		
}