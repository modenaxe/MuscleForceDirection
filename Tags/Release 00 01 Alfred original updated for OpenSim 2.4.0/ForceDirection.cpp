// ForceDirection.cpp

//=============================================================================
// INCLUDES
//=============================================================================
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
#include "ForceDirection.h"


using namespace OpenSim;
using namespace std;

// CONSTANTS

// CONSTRUCTOR(S) AND DESTRUCTOR
//Destructor.Delete any variables allocated using the "new" operator.  You will not necessarily have any of these.
ForceDirection::~ForceDirection()
{	//deleteStorage();
}

//_____________________________________________________________________________
/*
 * Construct an ForceDirection instance.
 *
 * @param aModel Model for which the analysis is to be run.
 */
ForceDirection::ForceDirection(Model *aModel) :
	Analysis(aModel),
	_boolref(_boolProp.getValueBool()),
	_boolcsv(_boolPropcsv.getValueBool()),
	//_boolArray(_boolArrayProp.getValueBoolArray()),
	//_int(_intProp.getValueInt()),
	//_intArray(_intArrayProp.getValueIntArray()),
	//_dbl(_dblProp.getValueDbl()),
	//_dblArray(_dblArrayProp.getValueDblArray()),
	//_vec3(_vec3Prop.getValueDblVec3()),
	//_str(_strProp.getValueStr()),
	_bodyNames(_strArrayProp.getValueStrArray())
{
	// make sure members point to NULL if not valid. 
	setNull();
	if(_model==NULL) return;

	// DESCRIPTION AND LABELS
	constructDescription();
	constructColumnLabels();

	// MARKER
	_firstrecord = 0;

	_muscleNames.setSize(0);
	_muscleNames.append("all");

}
//_____________________________________________________________________________
/*
 * Construct an object from file.
 *
 * The object is constructed from the root element of the XML document.
 * The type of object is the tag name of the XML root element.
 *
 * @param aFileName File name of the document.
 */
ForceDirection::ForceDirection(const std::string &aFileName):
	Analysis(aFileName, false),
	_boolref(_boolProp.getValueBool()),
	_boolcsv(_boolPropcsv.getValueBool()),
	//_boolArray(_boolArrayProp.getValueBoolArray()),
	//_int(_intProp.getValueInt()),
	//_intArray(_intArrayProp.getValueIntArray()),
	//_dbl(_dblProp.getValueDbl()),
	//_dblArray(_dblArrayProp.getValueDblArray()),
	//_vec3(_vec3Prop.getValueDblVec3()),
	//_str(_strProp.getValueStr()),
	_bodyNames(_strArrayProp.getValueStrArray())
{
	setNull();

	// Read properties from XML
	updateFromXMLNode();

	// MARKER
	_firstrecord = 0;

	_muscleNames.setSize(0);
	_muscleNames.append("all");
}

// Copy constrctor and virtual copy 
//_____________________________________________________________________________
/*
 * Copy constructor.
 *
 */
ForceDirection::ForceDirection(const ForceDirection &aForceDirection):
	Analysis(aForceDirection),
	_boolref(_boolProp.getValueBool()),
	_boolcsv(_boolPropcsv.getValueBool()),
	//_boolArray(_boolArrayProp.getValueBoolArray()),
	//_int(_intProp.getValueInt()),
	//_intArray(_intArrayProp.getValueIntArray()),
	//_dbl(_dblProp.getValueDbl()),
	//_dblArray(_dblArrayProp.getValueDblArray()),
	//_vec3(_vec3Prop.getValueDblVec3()),
	//_str(_strProp.getValueStr()),
	_bodyNames(_strArrayProp.getValueStrArray())
{
	setNull();
	// COPY TYPE AND NAME
	*this = aForceDirection;

	// MARKER
	_firstrecord = 0;

	_muscleNames.setSize(0);
	_muscleNames.append("all");
}
//_____________________________________________________________________________
/**
 * Clone
 *
 */
Object* ForceDirection::copy() const
{
	ForceDirection *object = new ForceDirection(*this);
	return(object);

}
//=============================================================================
// OPERATORS
//=============================================================================
//-----------------------------------------------------------------------------
// ASSIGNMENT
//-----------------------------------------------------------------------------
//_____________________________________________________________________________
/*
 * Assign this object to the values of another.
 *
 * @return Reference to this object.
 */
ForceDirection& ForceDirection::
operator=(const ForceDirection &aForceDirection)
{
	// Base Class
	Analysis::operator=(aForceDirection);

	// Member Variables
	_bodyNames = aForceDirection._bodyNames;
	_muscleNames = aForceDirection._muscleNames;
	_groundname = aForceDirection._groundname;
	_firstrecord = aForceDirection._firstrecord;
	_boolref = aForceDirection._boolref;
	_boolcsv = aForceDirection._boolcsv;

	return(*this);
}

//_____________________________________________________________________________
/**
 * SetNull().
 */
void ForceDirection::
setNull()
{
	setType("ForceDirection");
	setupProperties();

	// Property Default Values
	_boolref = true;
	_boolcsv = false;
	//_boolArray.setSize(0);
	//_int = 0;
	//_intArray.setSize(0);
	//_dbl = 0.0;
	//_dblArray.setSize(0);
	//_vec3[0] = _vec3[1] = _vec3[2] = 0.0;
	//_str = "";
	_bodyNames.setSize(1);
	_bodyNames[0] = "all";
	_muscleNames.setSize(1);
	_muscleNames[0] = "all";
}
//_____________________________________________________________________________
/*
 * Set up the properties for your analysis.
 *
 * You should give each property a meaningful name and an informative comment.
 * The name you give each property is the tag that will be used in the XML
 * file.  The comment will appear before the property in the XML file.
 * In addition, the comments are used for tool tips in the OpenSim GUI.
 *
 * All properties are added to the property set.  Once added, they can be
 * read in and written to file.
 */
void ForceDirection::
setupProperties()
{
	// Uncomment and rename the properties required for your analysis

	_boolProp.setName("local reference system");
	_boolProp.setComment("Flag if the reference systems are local to the bodies");
	_propertySet.append(&_boolProp);

	_boolPropcsv.setName("csv file");
	_boolPropcsv.setComment("Flag if you want an additionnal csv file to the storage file");
	_propertySet.append(&_boolPropcsv);

	//_boolArrayProp.setName("array_of_bool_params");
	//_boolArrayProp.setComment("Array of flags indicating whether or not to ...");
	//_propertySet.append(&_boolArrayProp);

	//_intProp.setName("integer_parameter");
	//_intProp.setComment("Number of ...");
	//_propertySet.append(&_intProp);

	//_intArrayProp.setName("array_of_integer_paramters");
	//_intArrayProp.setComment("Array of numbers per ...");
	//_propertySet.append(&_intArrayProp);

	//_dblProp.setName("double_precision_parameter");
	//_dblProp.setComment("A double precision value for...");
	//_propertySet.append(&_dblProp);

	//_dblArrayProp.setName("array_of_doubles");
	//_dblArrayProp.setComment("Array of double precision parameters ...");
	//_propertySet.append(&_dblArrayProp);

	//_vec3Prop.setName("vec3_parameter");
	//_vec3Prop.setComment("Vector in 3 space.");
	//_propertySet.append(&_vec3Prop);

	//_strProp.setName("string_parameter");
	//_strProp.setComment("String parameter identifying ...");
	//_propertySet.append(&_strProp);

	_strArrayProp.setName("body_names");
	_strArrayProp.setComment("Names of the bodies on which to perform the analysis."
		"The key word 'All' indicates that the analysis should be performed for all bodies.");
	_propertySet.append(&_strArrayProp);

}

//=============================================================================
// CONSTRUCTION METHODS
//=============================================================================
//_____________________________________________________________________________
/**
 * Construct a description for the body kinematics files.
 */
void ForceDirection::
constructDescription()
{
	string descrip;

	descrip = "\nThis file contains  muscles directions\n\n";
	descrip += "\n The bodies linked to the muscles are given on a separate file";
	descrip += "\n\n";

	setDescription(descrip);
}

//_____________________________________________________________________________
/**
 * Construct column labels for the output results.
 *
 * For analyses that run during a simulation, the first column is almost
 * always time.  For the purpose of example, the code below adds labels
 * appropriate for recording the translation and orientation of each
 * body in the model.
 *
 * This method needs to be called as necessary to update the column labels.
 */
void ForceDirection::
constructColumnLabels()
{
	if(_model==NULL) return;

	Array<string> labels;
	labels.append("time");

	


	const Set<Muscle>& muscleSet = _model->updMuscles();

	if(_muscleNames[0] == "all"){
		_muscleIndices.setSize(muscleSet.getSize());
		// Get indices of all the muscles.
		for(int j=0;j<muscleSet.getSize();j++)
			_muscleIndices[j]=j;
	}
	else{
		_muscleIndices.setSize(_muscleNames.getSize());
		// Get indices of just the muscles listed.
		for(int j=0;j<_muscleNames.getSize();j++)
			_muscleIndices[j]=muscleSet.getIndex(_muscleNames[j]);
	}

	//Do the analysis on the muscles that are in the indices list
	string labref;
	if (_boolref && _bodyNames.getSize()==1 && _bodyNames[0]!="all"){
		labref=_bodyNames[0];
	}
	else if (_boolref /*&& _bodyNames.getSize()!=1*/){
		labref="Local";
	}
	else{
		labref="Ground";
	}

	for(int i=0; i<_muscleIndices.getSize(); i++) {
		
		const OpenSim::Muscle& muscle = muscleSet.get(_muscleIndices[i]);
		//%%
		PathPointSet path=muscle.getGeometryPath().getPathPointSet();
		Body body1 = path[0].getBody();
		Body body2 = path[path.getSize()-1].getBody();
		
		bool testbod1 = false;
		bool testbod2 = false;
		if (_bodyNames[0]=="all"){
			testbod1=true;
			testbod2=true;
		}
		else{
			for (int j=0;j<_bodyNames.getSize();j++){
				if (body1.getName()==_bodyNames[j]){
					testbod1=true;
				}
				if (body2.getName()==_bodyNames[j]){
					testbod2=true;
				}
			}
		}

		//%%
		if (testbod1){
			labels.append(muscle.getName() + "_X1"+"_on_"+labref);
			labels.append(muscle.getName() + "_Y1"+"_on_"+labref);
			labels.append(muscle.getName() + "_Z1"+"_on_"+labref);
		}
		if (testbod2){
			labels.append(muscle.getName() + "_X2"+"_on_"+labref);
			labels.append(muscle.getName() + "_Y2"+"_on_"+labref);
			labels.append(muscle.getName() + "_Z2"+"_on_"+labref);
		}
	}
	if (_labels[0]!="time"){
		_labels.append("time");
		for(int i=0; i<_muscleIndices.getSize(); i++) {
			const Muscle& muscle = muscleSet.get(_muscleIndices[i]);
			_labels.append(muscle.getName() + "_X1");
			_labels.append(muscle.getName() + "_Y1");
			_labels.append(muscle.getName() + "_Z1");
			_labels.append(muscle.getName() + "_X2");
			_labels.append(muscle.getName() + "_Y2");
			_labels.append(muscle.getName() + "_Z2");
		}
	}

	setColumnLabels(labels);

}

//_____________________________________________________________________________
/**
 * Set up storage objects.
 *
 * In general, the storage objects in your analysis are used to record
 * the results of your analysis and write them to file.  You will often
 * have a number of storage objects, each for recording a different
 * kind of result.
 */
void ForceDirection::
setupStorage()
{
	// Directions

	_storeDir.reset(0);
	_storeDir.setName("Directions");
	_storeDir.setDescription(getDescription());
	_storeDir.setColumnLabels(getColumnLabels());
}


//=============================================================================
// GET AND SET
//=============================================================================
//_____________________________________________________________________________
/**
 * Set the model for which this analysis is to be run.
 *
 * Sometimes the model on which an analysis should be run is not available
 * at the time an analysis is created.  Or, you might want to change the
 * model.  This method is used to set the model on which the analysis is
 * to be run.
 *
 * @param aModel Model pointer
 */
void ForceDirection::
setModel(Model& aModel)
{
	// SET THE MODEL IN THE BASE CLASS
	Analysis::setModel(aModel);

	// UPDATE VARIABLES IN THIS CLASS
	constructDescription();
	constructColumnLabels();
	setupStorage();

	//Setup size of work array to hold body positions

	int numMuscles = _muscleIndices.getSize();
	_muscledir.setSize(0);
}


//=============================================================================
// ANALYSIS
//=============================================================================
//_____________________________________________________________________________
/**
 * Compute and record the results.
 *
 * This method, for the purpose of example, records the position and
 * orientation of each body in the model.  You will need to customize it
 * to perform your analysis.
 *
 * @param aT Current time in the simulation.
 * @param aX Current values of the controls.
 * @param aY Current values of the states: includes generalized coords and speeds
 */
int ForceDirection::
record(const SimTK::State& s)
{
	// VARIABLES
	SimTK::Vec3 vec1,vec2,vec3,vec4;
	int firstrecord = 1;
	if (_firstrecord == 0){
		firstrecord = 0;
	}

	_muscledir.setSize(0);

	// GROUND BODY
	const Body& ground = _model->getGroundBody();
	_groundname = ground.getName();

	// MUSCLE DIRECTIONS
	
	Set<Muscle>& muscleSet = _model->updMuscles();

	_datagroundref.append(s.getTime());
	_databodyref.append(s.getTime());

	for(int i=0;i<_muscleIndices.getSize();i++) {
		const Muscle& muscle = muscleSet.get(_muscleIndices[i]);
		const GeometryPath& path = muscle.getGeometryPath();
		Array<PointForceDirection*> PFDs;
		path.getPointForceDirections(s, &PFDs);

		// Here each entry in the PFD array has a point, body & direction (in ground frame)
		// Points
		SimTK::Vec3 point1 = PFDs[0]->point();
		SimTK::Vec3 point2 = PFDs[1]->point();
		SimTK::Vec3 point3 = PFDs[PFDs.getSize()-2]->point();
		SimTK::Vec3 point4 = PFDs[PFDs.getSize()-1]->point();


		// Bodies
		const Body& body1 = PFDs[0]->body();
		const Body& body2 = PFDs[1]->body();
		const Body& body3 = PFDs[PFDs.getSize()-2]->body();
		const Body& body4 = PFDs[PFDs.getSize()-1]->body();

		// get the position of the points in the ground frame
		_model->getSimbodyEngine().getPosition(s,body1,point1,vec1);
		_model->getSimbodyEngine().getPosition(s,body2,point2,vec2);
		_model->getSimbodyEngine().getPosition(s,body3,point3,vec3);
		_model->getSimbodyEngine().getPosition(s,body4,point4,vec4);

		
		// calculating the directions in the ground frame
		SimTK::Vec3 dirrefground1 = vec2-vec1;
		SimTK::Vec3 dirrefground2 = vec3-vec4;

		// calculating the directions in the bodies frame
		// each direction is in the body where the muscle extremity is attached
		SimTK::Vec3 dirrefbody1;
		SimTK::Vec3 dirrefbody2;
		_model->getSimbodyEngine().transform(s,ground,dirrefground1,body1,dirrefbody1);
		_model->getSimbodyEngine().transform(s,ground,dirrefground2,body4,dirrefbody2);

		// normalizing the vectors
		double normground1 = sqrt(pow(dirrefground1[0],2)+pow(dirrefground1[1],2)+pow(dirrefground1[2],2));
		double normground2 = sqrt(pow(dirrefground2[0],2)+pow(dirrefground2[1],2)+pow(dirrefground2[2],2));
		double normbody1 = sqrt(pow(dirrefbody1[0],2)+pow(dirrefbody1[1],2)+pow(dirrefbody1[2],2));
		double normbody2 = sqrt(pow(dirrefbody2[0],2)+pow(dirrefbody2[1],2)+pow(dirrefbody2[2],2));

		for (int j=0;j<3;j++){
			dirrefground1[j] /=normground1;
		}
		for (int j=0;j<3;j++){
			dirrefground2[j] /=normground2;
		}
		for (int j=0;j<3;j++){
			dirrefbody1[j] /=normbody1;
		}
		for (int j=0;j<3;j++){
			dirrefbody2[j] /=normbody2;
		}

		// adding the bodies where the muscle are attached
		if (firstrecord==0){
			//const Body& body1 = PFDs[0]->body();
			//const Body& body2 = PFDs[PFDs.getSize()-1]->body();
			_musclebodies.append(body1.getName());
			_musclebodies.append(body4.getName());
			
		}

		// Looking if the data are asked
		bool testbod1 = false;
		bool testbod2 = false;
		if (_bodyNames[0]=="all"){
			testbod1=true;
			testbod2=true;
		}
		else{
			for (int j=0;j<_bodyNames.getSize();j++){
				if (body1.getName()==_bodyNames[j]){
					testbod1=true;
				}
				if (body4.getName()==_bodyNames[j]){
					testbod2=true;
				}
			}
		}
		
		if (testbod1){
			if (_boolref){
				_muscledir.append(dirrefbody1[0]);
				_muscledir.append(dirrefbody1[1]);
				_muscledir.append(dirrefbody1[2]);
			}
			else{
				_muscledir.append(dirrefground1[0]);
				_muscledir.append(dirrefground1[1]);
				_muscledir.append(dirrefground1[2]);
			}
		}
		if (testbod2){
			if (_boolref){
				_muscledir.append(dirrefbody2[0]);
				_muscledir.append(dirrefbody2[1]);
				_muscledir.append(dirrefbody2[2]);
			}
			else{
				_muscledir.append(dirrefground2[0]);
				_muscledir.append(dirrefground2[1]);
				_muscledir.append(dirrefground2[2]);
			}
		}
		//%%
		for(int i=0; i < PFDs.getSize(); i++){
        delete PFDs[i];
		}

		_storeDir.append(s.getTime(),_muscledir.getSize(),&_muscledir[0]);

		// Data for the .csv (more flexible)
		_datagroundref.append(dirrefground1[0]);
		_datagroundref.append(dirrefground1[1]);
		_datagroundref.append(dirrefground1[2]);
		_datagroundref.append(dirrefground2[0]);
		_datagroundref.append(dirrefground2[1]);
		_datagroundref.append(dirrefground2[2]);

		_databodyref.append(dirrefbody1[0]);
		_databodyref.append(dirrefbody1[1]);
		_databodyref.append(dirrefbody1[2]);
		_databodyref.append(dirrefbody2[0]);
		_databodyref.append(dirrefbody2[1]);
		_databodyref.append(dirrefbody2[2]);

	}
	
	if (_firstrecord == 0){
		_firstrecord = 1;
	}

	return(0);
}
//_____________________________________________________________________________
/**
 * This method is called at the beginning of an analysis so that any
 * necessary initializations may be performed.
 *
 * This method is meant to be called at the begining of an integration in
 * Model::integBeginCallback() and has the same argument list.
 *
 * @param aStep Step number of the integration.
 * @param aDT Size of the time step that will be attempted.
 * @param aT Current time in the integration.
 * @param aX Current control values.
 * @param aY Current states.
 * @param aYP Current pseudo states.
 * @param aDYDT Current state derivatives.
 *
 * @return -1 on error, 0 otherwise.
 */
int ForceDirection::
begin(SimTK::State& s)
{
	if(!proceed()) return(0);

	// RESET STORAGE
	_storeDir.reset(s.getTime());

	// RECORD
	int status = 0;

	if(_storeDir.getSize()<=0) {
		status = record(s);
	}

	return(status);
}
//_____________________________________________________________________________
/**
 * This method is called to perform the analysis.  It can be called during
 * the execution of a forward integrations or after the integration by
 * feeding it the necessary data.
 *
 * When called during an integration, this method is meant to be called in
 * Model::integStepCallback(), which has the same argument list.
 *
 * @param aXPrev Controls at the beginining of the current time step.
 * @param aYPrev States at the beginning of the current time step.
 * @param aYPPrev Pseudo states at the beginning of the current time step.
 * @param aStep Step number of the integration.
 * @param aDT Size of the time step that was just taken.
 * @param aT Current time in the integration.
 * @param aX Current control values.
 * @param aY Current states.
 * @param aYP Current pseudo states.
 * @param aDYDT Current state derivatives.
 *
 * @return -1 on error, 0 otherwise.
 */
int ForceDirection::
step(const SimTK::State& s, int stepNumber)
{
	if(!proceed(stepNumber)) return(0);

	record(s);

	return(0);
}
//_____________________________________________________________________________
/**
 * This method is called at the end of an analysis so that any
 * necessary finalizations may be performed.
 *
 * This method is meant to be called at the end of an integration in
 * Model::integEndCallback() and has the same argument list.
 *
 * @param aStep Step number of the integration.
 * @param aDT Size of the time step that was just completed.
 * @param aT Current time in the integration.
 * @param aX Current control values.
 * @param aY Current states.
 * @param aYP Current pseudo states.
 * @param aDYDT Current state derivatives.
 *
 * @return -1 on error, 0 otherwise.
 */
int ForceDirection::
end(SimTK::State& s)
{
	if(!proceed()) return(0);

	record(s);

	return(0);
}




//=============================================================================
// IO
//=============================================================================
//_____________________________________________________________________________

/**
 * Print results.
 * 
 * The file names are constructed as
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
int ForceDirection::
printResults(const string &aBaseName,const string &aDir,double aDT,
				 const string &aExtension)
{

	// DIRECTIONS
	// 26-3-2012 THIS NEEDS TO BE CHECKED!
	//_storeDir.scaleTime(_model->getTimeNormConstant());
	Storage::printResult(&_storeDir,aBaseName+"_"+getName()+"_dir",aDir,aDT,aExtension);

	// MORE COMPLETE FILES
	if (_boolcsv){
		int mm=6*_muscleIndices.getSize()+1;
		Array<bool> test;
		test.append(true);
		for (int i=0;i<_musclebodies.getSize();i++){
			bool testint = false;
			if (_bodyNames[0]=="all"){
				testint=true;
			}
			else{
				for (int j=0;j<_bodyNames.getSize();j++){
					if (_musclebodies[i]==_bodyNames[j]){
						testint=true;
					}
				}
			}
			if (testint){
				test.append(true);
				test.append(true);
				test.append(true);
			}
			else{
				test.append(false);
				test.append(false);
				test.append(false);
			}
		}

		Array<double> time;
		_storeDir.getTimeColumnWithStartTime(time);

		//// File for the direction in the ground reference system
		if (!_boolref){
			string filetxtground = aDir + "/" + aBaseName + "_" + getName()+"_dir.csv";
			ofstream fileground(filetxtground.c_str());

			fileground << " ; ; ;This file gives the directions and the tendon force for the muscles in the ground reference system." << endl;
			fileground << " ; ; ;It gives also the bodies on which the muscles are attached."<<endl<<endl;
			fileground << " ;";
			for (int i=1;i<_labels.getSize();i++){
				if (test[i]){
					fileground << _labels[i] << " ; ";
				}
			}
			fileground << endl;
			fileground << "Bodies;";
			for (int i=0;i<_musclebodies.getSize();i++){
				if (test[3*i+2]){
					fileground << " ;" << _musclebodies[i] << "; ;";
				}
			}
			fileground << endl;

			fileground <<_labels[0]<<endl;

			for (int i=0;i<_datagroundref.getSize();i++){
				if (i%mm==0 && i!=0){
					fileground << endl;
				}
				if (test[i%mm]){
					fileground << _datagroundref[i] << " ; ";
				}
			}
		}

		//// File for the direction in the bodies reference system
		else {
			string filetxtbody = aDir + "/" + aBaseName + "_" + getName()+"_dir.csv";
			ofstream filebody(filetxtbody.c_str());

			filebody << " ; ; ;This file gives the directions and the tendon force for the muscles in the bodies reference system." << endl;
			filebody << " ; ; ;It gives also the bodies on which the muscles are attached. The directions are relative to these bodies."<<endl<<endl;
			filebody << " ;";
			for (int i=1;i<_labels.getSize();i++){
				if (test[i]){
					filebody << _labels[i] << " ; ";
				}
			}
			filebody << endl;
			filebody << "Bodies(ref system);";
			for (int i=0;i<_musclebodies.getSize();i++){
				if (test[3*i+2]){
					filebody << " ;" << _musclebodies[i] << "; ;";
				}
			}
			filebody << endl << _labels[0]<<endl;

			for (int i=0;i<_databodyref.getSize();i++){
				if (i%mm==0 && i!=0){
					filebody << endl;
				}
				if (test[i%mm]){
					filebody << _databodyref[i] << " ; ";
				}
			}
		}
	}

	return(0);
}


