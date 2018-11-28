// MuscleForceDirection.cpp

// ========= INCLUDES ===========
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <OpenSim/Simulation/Model/Model.h>
#include <OpenSim/Simulation/SimbodyEngine/SimbodyEngine.h>
#include <OpenSim/Simulation/Model/BodySet.h>
#include <OpenSim/Simulation/Model/Muscle.h>
#include <OpenSim/Simulation/Model/PointForceDirection.h>
#include <OpenSim/Simulation/Model/PathPointSet.h>
#include "MuscleForceDirection.h"

using namespace OpenSim;
using namespace std;

// ============= CONSTANTS =============
// ========= CONSTRUCTORS AND DESTRUCTOR ======
// DESTRUCTOR
MuscleForceDirection::~MuscleForceDirection()
{
	//deleteStorage();
}
// CONSTRUCTORS
MuscleForceDirection::MuscleForceDirection(Model *aModel) :
	Analysis(aModel),_expressInLocalFrame(_expressInLocalFrameProp.getValueBool()),
	_printAttachPoints(_boolPrintAttachPointProp.getValueBool()),_bodyNames(_strArrayBodyProp.getValueStrArray()),
	_effectInsertion(_boolEffectiveInsertionsProp.getValueBool())
	
{
	// make sure members point to NULL if not valid. 
	setNull();
	if(_model==NULL) return;

	// DESCRIPTION AND LABELS
	constructDescription();
	constructColumnLabels();
	constructDescriptionAttachments();
}

// CONSTRUCTOR FROM FILE
MuscleForceDirection::MuscleForceDirection(const std::string &aFileName):
	Analysis(aFileName, false),	_expressInLocalFrame(_expressInLocalFrameProp.getValueBool()),
	_printAttachPoints(_boolPrintAttachPointProp.getValueBool()),_bodyNames(_strArrayBodyProp.getValueStrArray()),
	_effectInsertion(_boolEffectiveInsertionsProp.getValueBool())
	
{
	setNull();
	
	// Read properties from XML
	updateFromXMLNode();
}

// COPY CONSTRUCTOR
MuscleForceDirection::MuscleForceDirection(const MuscleForceDirection &aMuscleForceDirection):
	Analysis(aMuscleForceDirection),_expressInLocalFrame(_expressInLocalFrameProp.getValueBool()),
	_printAttachPoints(_boolPrintAttachPointProp.getValueBool()),_bodyNames(_strArrayBodyProp.getValueStrArray()),
	_effectInsertion(_boolEffectiveInsertionsProp.getValueBool())
{
	setNull();
	// COPY TYPE AND NAME
	*this = aMuscleForceDirection;
}

// CLONE CONSTRUCTOR
Object* MuscleForceDirection::copy() const
{
	MuscleForceDirection *object = new MuscleForceDirection(*this);
	return(object);
}

//============  OPERATORS  ============
// ASSIGNMENT: Assign this object to the values of another.@return Reference to this object.

MuscleForceDirection& MuscleForceDirection:: operator=(const MuscleForceDirection &aMuscleForceDirection)
{
	// Base Class
	Analysis::operator=(aMuscleForceDirection);

	// Member Variables
	_expressInLocalFrame	= aMuscleForceDirection._expressInLocalFrame;
	_printAttachPoints      = aMuscleForceDirection._printAttachPoints;
	_bodyNames 				= aMuscleForceDirection._bodyNames;
	_effectInsertion		= aMuscleForceDirection._effectInsertion;

	return(*this);
}


// setNull()
void MuscleForceDirection:: setNull()
{
	setType("MuscleForceDirection");
	setupProperties();

	// Property Default Values
	_expressInLocalFrame	= true;
	_effectInsertion		= false;
	_printAttachPoints		= false;

	_bodyNames.setSize(1);
	_bodyNames[0] = "all";

	/*---------SEE NOTE ON HEADER FILE-----------
	_muscleNames.setSize(1);
	_muscleNames[0] = "auto";
	-------------------------------------------*/

}

//setupProperties: defines the user interaction/inputs

void MuscleForceDirection::setupProperties()
{
	_expressInLocalFrameProp.setName("local_ref_system");
	_expressInLocalFrameProp.setComment("Flag (true or false)indicating whether the results will be express in the segment local reference systems or not.");
	_propertySet.append(&_expressInLocalFrameProp);
	
	_boolEffectiveInsertionsProp.setName("effective_attachments");
	_boolEffectiveInsertionsProp.setComment("Flag (true or false) specifying whether the muscle force directions are desired at the effective muscle attachments.");
	_propertySet.append(&_boolEffectiveInsertionsProp);
	
	_boolPrintAttachPointProp.setName("print_attachments");
	_boolPrintAttachPointProp.setComment("Flag (true or false)specifying whether a storage file with the position of the muscle attachments will be printed.");
	_propertySet.append(&_boolPrintAttachPointProp);
	
	_strArrayBodyProp.setName("body_names");
	_strArrayBodyProp.setComment("Names of the bodies whose attached muscles will be included in the analysis."
		"The key word 'all' indicates all bodies.");
	_propertySet.append(&_strArrayBodyProp);

	/* -------SEE NOTE IN HEADER FILE-----------------------------------------
	_strArrayMuscleProp.setName("muscle_names");
	_strArrayMuscleProp.setComment("Names of the muscles to be considered in the analysis."
		"The key word 'auto' indicates that the analysis will be performed on the muscles attached to the specified bodies.");
	_propertySet.append(&_strArrayMuscleProp);
	---------------------------------------------------------------------------*/
}

// ---------CONSTRUCTION METHODS------------------

// Construct a description for the muscle direction file.
// Header is consistent with JointReactionAnalyses in OpenSim 2.4.0
void MuscleForceDirection::constructDescription()
{
	string descrip;
	if (_expressInLocalFrame)
	{descrip = "\nThis file contains the normalized muscle lines of actions expressed in the segment reference system.";}
	else
	{descrip = "\nThis file contains the normalized muscle lines of actions expressed in the global reference system.";}
	descrip += "\n The muscle attachments (anatomical or effective) can be printed in a separate file if desired.";
	descrip += "\n";
	descrip += "\nUnits are S.I. units (seconds, meters, Newtons, ...)";

	setDescription(descrip);
}


// Construct a description for the muscle attachment file.
// Header is consistent with JointReactionAnalyses in OpenSim 2.4.0
void MuscleForceDirection::constructDescriptionAttachments()
{
	string descripAttach;

	descripAttach = "\n This file contains the position of the muscle attachments.";
	// description consistent with choice of reference system
	if (_expressInLocalFrame)
	{descripAttach += "\n The positions are expressed in the segment reference system.";}
	else
	{descripAttach += "\n The positions are expressed in the global reference system.";}

	descripAttach += "\n";
	descripAttach += "\nUnits are S.I. units (seconds, meters, Newtons, ...)";

	setDescription(descripAttach);
}

//constructColumnLabels() for the output results
void MuscleForceDirection::constructColumnLabels()
{
	if(_model==NULL) return;
	const Set<Muscle> muscleSet = _model->getMuscles();

	// Get the indexes of the muscles attached to the specified bodies.
	GetMusclesIndexForBody(_model,  _bodyNames, _muscleIndices);
	int j;
// ============= LABELS ======================
	Array<string> labels;
	labels.append("time");

	// for GLOBAL reference frames
	if (!_expressInLocalFrame)
	{
		// get ground body name
		OpenSim::Body groundbody = _model->getGroundBody();
		std::string GroundName = groundbody.getName();
		
		// creates labels for muscles in global reference frame
		for(int i=0; i<_muscleIndices.getSize(); i++) 
		{
			j = _muscleIndices[i];
			labels.append(muscleSet[j].getName() + "_X1_on_" + GroundName);
			labels.append(muscleSet[j].getName() + "_Y1_on_" + GroundName);
			labels.append(muscleSet[j].getName() + "_Z1_on_" + GroundName);
			labels.append(muscleSet[j].getName() + "_X2_on_" + GroundName);
			labels.append(muscleSet[j].getName() + "_Y2_on_" + GroundName);
			labels.append(muscleSet[j].getName() + "_Z2_on_" + GroundName);
		}
	}
	else

	// labels in LOCAL (segment)reference frame
	{
		for (int i=0; i<_muscleIndices.getSize(); i++)
		{
			j = _muscleIndices[i];

			const PathPointSet & pathpointSet = muscleSet[j].getGeometryPath().getPathPointSet();
			int SetLast = pathpointSet.getSize()-1;
			
			// first and last points
			std::string FirstBodyName = pathpointSet[0].getBodyName();
			std::string LastBodyName = pathpointSet[SetLast].getBodyName();
			

			// columns
			labels.append(muscleSet[j].getName() + "_X1_on_" + FirstBodyName);
			labels.append(muscleSet[j].getName() + "_Y1_on_" + FirstBodyName);
			labels.append(muscleSet[j].getName() + "_Z1_on_" + FirstBodyName);
			labels.append(muscleSet[j].getName() + "_X2_on_" + LastBodyName);
			labels.append(muscleSet[j].getName() + "_Y2_on_" + LastBodyName);
			labels.append(muscleSet[j].getName() + "_Z2_on_" + LastBodyName);
		}
		
	}
	
	// set the column labels
	setColumnLabels(labels);
}

// ---------SET UP STORAGE OBJECTS---------
// Set up the storage for muscle lines of action
void MuscleForceDirection::setupStorage()
{
	// Muscle lines of action.
	_storeDir.reset(0);
	_storeDir.setName("MuscleDirections");
	_storeDir.setDescription(getDescription());
	_storeDir.setColumnLabels(getColumnLabels());

}

// Set up the storage for muscle attachments
void MuscleForceDirection::setupStorageAttachments()
{
	// Muscle attachments
	_storeAttachPointPos.reset(0);
	_storeAttachPointPos.setName("Muscle attachment positions");
	_storeAttachPointPos.setDescription(getDescription());
	_storeAttachPointPos.setColumnLabels(getColumnLabels());
}


// GET AND SET: setModel, description, column labels and storage
void MuscleForceDirection::setModel(Model& aModel)
{
	// SET THE MODEL IN THE BASE CLASS
	Analysis::setModel(aModel);

	// UPDATE VARIABLES IN THIS CLASS
	constructDescription();
	constructColumnLabels();
	setupStorage();
	
	// If required the muscle attachment storage is defined.
	if(_printAttachPoints)
	{
		// The columns of the previous storage object 
		// can be used also for the attachment points
		constructDescriptionAttachments();
		setupStorageAttachments();

		// initialization of the work array to hold muscle attachments
		_attachpointpos.setSize(_muscleIndices.getSize()*6);
	}

	//Setup size of work array to hold muscle directions
	int numMuscles = _muscleIndices.getSize();
	_muscledir.setSize(6*numMuscles);	
}



// RECORD: THE CORE OF THE ANALYSIS
int MuscleForceDirection::record(const SimTK::State& s)
{

	// Muscles
	const BodySet& bodySet = _model->getBodySet();
	const Set<Muscle> &muscleSet = _model->getMuscles();

	// the analysis to be performed is defined within the for loop.
	for(int i=0;i<_muscleIndices.getSize();i++) 
	{
		// Extract the path of selected muscle 
		Muscle& muscle = muscleSet.get(_muscleIndices[i]);
		const GeometryPath& path = muscle.getGeometryPath();

		/* ----------NOTE-------------------------------------------
		GetCurrentPath doesn't work as well as PointForceDirection.
		The latter gets the point of the path (presumably from getCurrentPath) and express them in LOCAL
		reference system of the body where they are connected.
		------------------------------------------------------------ */
		// Extracting PointForceDirections.
		Array<PointForceDirection*> PFDs;
		path.getPointForceDirections(s,&PFDs);
		
		//-----  TO DO: improve EffectiveAttachments in order to include this selection ----------------

		// Selection of attachments to consider: anatomical (false) or effective (true).
		// The attachment and following point are selected to identify the direction.
		int FirstIndex, LastIndex;

		if (_effectInsertion==false)
		{
			FirstIndex = 0;
			LastIndex = PFDs.getSize()-1;
		}
		else
		{	// Indexes identify as described in the body of function (below).		
			EffectiveAttachments(PFDs,  FirstIndex, LastIndex);		
		}

		// creation of a convenient array to store the indexes
		Array<int> AttachIndex;
		//NB: if line "AttachIndex.setSize(4);" was included I should have used .set(). TOOK A WHILE TO SPOT THE ERROR 
		AttachIndex.append(FirstIndex);
		AttachIndex.append(FirstIndex+1);
		AttachIndex.append(LastIndex-1);
		AttachIndex.append(LastIndex);
		//-------------------------------------------------------------------------------------------------

		// GLOBAL REF SYSTEM: POSITIONS AND DIRECTIONS
		Array<SimTK::Vec3> GlobPos;
		GlobPos.setSize(AttachIndex.getSize());
		SimTK::Vec3 pos;

		for (int ind = 0; ind<AttachIndex.getSize();ind++)
		{
			// The position of the points extracted from PFD are expressed in the global ref system.
			int n_att = AttachIndex.get(ind);
			_model->getSimbodyEngine().transformPosition(s,PFDs[n_att]->body(),PFDs[n_att]->point(),pos);
			GlobPos.set(ind,pos);
		}

		// Directions
		SimTK::Vec3 dir1 = GlobPos.get(1)-GlobPos.get(0);
		SimTK::Vec3 dir2 = GlobPos.get(2)-GlobPos.get(3);	

		//------------- TO DO: avoid assignation through a conditional sentence when not required----
		// (if required) positions of the muscle attachments
		SimTK::Vec3 pos1 = GlobPos.get(0);
		SimTK::Vec3 pos2 = GlobPos.get(3);	
		//-------------------------------------------------------------------------------------------

		// If requested, transform in local coordinate system the global muscle lines of action
		if(_expressInLocalFrame==true)
		{
			// transforming muscle directions in local reference system
			_model->getSimbodyEngine().transform(s,_model->getGroundBody(),dir1, PFDs[FirstIndex]->body(),dir1);
			_model->getSimbodyEngine().transform(s,_model->getGroundBody(),dir2, PFDs[LastIndex]->body() ,dir2);

			if (_printAttachPoints)
			{
				// attachment points in local reference system
				pos1 = PFDs[FirstIndex]->point();
				pos2 = PFDs[LastIndex]->point();
			}
		}
		
		// Normalizing the direction vectors
		SimTK::Vec3 NormDir1, NormDir2;
		NormalizeVec3(dir1,NormDir1);
		NormalizeVec3(dir2,NormDir2); 

		// copying the data from the direction vectors to the storage through _muscledir
		int I = 6*i;		
		memcpy(&_muscledir[I],&NormDir1[0],3*sizeof(double));
		memcpy(&_muscledir[I+3],&NormDir2[0],3*sizeof(double));
		_storeDir.append(s.getTime(),_muscledir.getSize(),&_muscledir[0]);
		
		// (if required) copying the data from the position vectors to the storage through _attachpointpos
		if (_printAttachPoints)
		{
		memcpy(&_attachpointpos[I], &pos1[0],3*sizeof(double));
		memcpy(&_attachpointpos[I+3], &pos2[0],3*sizeof(double));
		_storeAttachPointPos.append(s.getTime(),_attachpointpos.getSize(),&_attachpointpos[0]);
		}
	
		// deleting PFDs pointers after use
		for(int k=0; k<PFDs.getSize();k++)		{delete PFDs[k];}

	}

	return(0);
}

// BEGIN
int MuscleForceDirection::begin(SimTK::State& s)
{
	if(!proceed()) return(0);

	// RESET STORAGE
	_storeDir.reset(s.getTime());  //->reset(s.getTime());
	
	// reset attachment positions storage if needed
	if ( _printAttachPoints)	
	{			_storeAttachPointPos.reset(s.getTime());	}

	// RECORD
	int status = 0;
	if(_storeDir.getSize()<=0) 
	{
		status = record(s);
	}

	return(status);
}
// STEP

int MuscleForceDirection::step(const SimTK::State& s, int stepNumber)
{
	if(!proceed(stepNumber)) return(0);

	record(s);

	return(0);
}

// END
int MuscleForceDirection::end(SimTK::State& s)
{
	if(!proceed()) return(0);

	record(s);

	return(0);
}


// Print results.
  
 /* The file names are constructed as
 * aDir + "/" + aBaseName + "_" + ComponentName + aExtension
 *
 * @param aDir Directory in which the results reside.
 * @param aBaseName Base file name.
 * @param aDT Desired time interval between adjacent storage vectors.  Linear
 * interpolation is used to print the data out at the desired interval.
 * @param aExtension File extension.
 *
 * @return 0 on success, -1 on error.
 */
int MuscleForceDirection::printResults(const string &aBaseName,const string &aDir,double aDT,
				 const string &aExtension)
{
	// Print muscle directions
	Storage::printResult(&_storeDir,aBaseName+"_"+getName()+"_vectors",aDir,aDT,aExtension);
	
	// Print muscle attachments
	if ( _printAttachPoints)	
	{
		Storage::printResult(&_storeAttachPointPos,aBaseName+"_"+getName()+"_attachments",aDir,aDT,aExtension);
	}

	return(0);
}

// UTILITIES Utilities implemented by Luca Modenese (check on 15th March 2012).

// IsMuscleAttachedToBody:  the function tells if a given Muscle is connected to a Body (specified by a BodyName)
bool MuscleForceDirection::IsMuscleAttachedToBody(Muscle &aMuscle, string aBodyName)
{
	bool Attached = false;
	OpenSim::GeometryPath  aGeometryPath = aMuscle.getGeometryPath();
	OpenSim::PathPointSet  aPointSet = aGeometryPath.getPathPointSet();
	int FinalPointIndex = aPointSet.getSize()-1;

	/* ---------NOTE--------------------------------------------
	The check is just on the first and last point of the muscle.
	It is assumed that for FE analyses this will be of interest.
	-----------------------------------------------------------*/

	if(aPointSet[0].getBodyName()==aBodyName  ||  aPointSet[FinalPointIndex].getBodyName()==aBodyName)
		{
			Attached = true;
		}

	return Attached;
}

// Given a pointer to a model and a string array of Body names, the indexes of the attached muscles are returned.
void MuscleForceDirection::GetMusclesIndexForBody(Model * _model, Array<std::string> aBodyNameSet, Array<int>  & MusclesIndexForBody )
{
	// Entire muscleset
	const Set<Muscle>  muscles = _model->getMuscles();

	// CASE 1: the 'all' flag is considered: all muscles will be analyzed.
	if	(_bodyNames[0]=="all")
	{
		// Get all the muscles and their number
		MusclesIndexForBody.setSize(muscles.getSize());	
		// Get indices of all the muscles.
		for(int j=0;j<muscles.getSize();j++)
			MusclesIndexForBody[j]=j;
	}

	// CASE 2: choice of subset of segments
	else
	{
		int k=0, n=0;
		
		OpenSim::Array<int> MusclesIndexForBody_temp;
		//OpenSim::Set<OpenSim::Muscle>  muscles = _model->getMuscles();
		for (int n_body = 0; n_body<aBodyNameSet.getSize(); n_body++)
		{
			std::string aBodyName = aBodyNameSet.get(n_body);

			/*----------------NOTE------------------------------------------------------------
			Here an array of indexes MusclesIndexForBody_temp is created checking all the muscles
			versus all the bodies contained in the Bodyset.
			NB: The array containes double indexes.
			----------------------------------------------------------------------------------*/
				
				for(int n_mus = 0; n_mus<muscles.getSize(); n_mus++)		
				{
					if (IsMuscleAttachedToBody(muscles[n_mus], aBodyName))
					{
						MusclesIndexForBody_temp.set(k,muscles.getIndex(muscles[n_mus].getName()));
						k++;
					}

				}
		}

		/*----------------NOTE------------------------------------------------------------
		The previously created array of muscle indexes MusclesIndexForBody_temp is modified 
		in order to contained unique indexes.
		The check consists in comparing an index with the following indexes.
		If no index in the following components is found then the index is saved.
		Each muscle is counted only once here!
		----------------------------------------------------------------------------------*/
		for (int n_ind = 0; n_ind<MusclesIndexForBody_temp.getSize();n_ind++)
		{
			bool check=false;
			for (int n_ind2 = n_ind+1; n_ind2<MusclesIndexForBody_temp.getSize(); n_ind2++)
			{
				if (MusclesIndexForBody_temp[n_ind]==MusclesIndexForBody_temp[n_ind2])
				{
					check = true;
					break;
				}

			}

			// The check consists in comparing an index with the following indexes.
			// If no index in the following components is found then the index is saved.
			if (!check)
			{
					MusclesIndexForBody.set(n,MusclesIndexForBody_temp[n_ind]);
					n++;
			}
		}
	}	
}



// EffectiveAttachments:
void MuscleForceDirection::EffectiveAttachments(Array<PointForceDirection*> & aPFDs, int & effecInsertProx, int & effecInsertDist)
{
		int N_points = aPFDs.getSize();

		/*---------------NOTE----------------------- 
		From the first body a check is performed on the following
		pathpoints until the point attached to a different segment 
		is found. The previous point is the effective origin.
		--------------------------------------------*/

		Body InitialBody = aPFDs[0]->body();
		std::string InitialBodyName = InitialBody.getName();
			//int effecInsertProx;
			for(int n=0;n<N_points;n++)
			{
				Body FollowBody = aPFDs[n]->body();
				if(InitialBodyName!=FollowBody.getName())
				{
					effecInsertProx = n-1;
					break;
				}
			}

			/*---------------NOTE----------------------- 
			From the last body a check is performed on the previous
			pathpoints until the point attached to a different segment
			is found. The previous point is the effective insertion.
			--------------------------------------------*/
			Body FinalBody = aPFDs[N_points-1]->body();
			std::string FinalBodyName = FinalBody.getName();
			for(int n=N_points-1;n>=0;n--)
			{
				Body PreviousBody = aPFDs[n]->body();
				if(FinalBodyName!=PreviousBody.getName())
				{
					effecInsertDist = n+1;
					break;
				}
			}
}

// NormalizeVec3 is an inline function to calculate the norm of a vector Vec3.
inline void MuscleForceDirection::NormalizeVec3(SimTK::Vec3 & v1, SimTK::Vec3 & rNormv1) 
{
	double Magnitude = sqrt(pow(v1[0],2.0)+pow(v1[1],2.0)+pow(v1[2],2.0));
	rNormv1 = v1/Magnitude;
}
