#ifndef _MuscleForceDirection_h_ 
#define _MuscleForceDirection_h_

// MuscleForceDirection.h
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//	AUTHOR: Frank C. Anderson, Ajay Seth
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
* Copyright (c)  2005, Stanford University. All rights reserved. 
* Use of the OpenSim software in source form is permitted provided that the following
* conditions are met:
* 	1. The software is used only for non-commercial research and education. It may not
*     be used in relation to any commercial activity.
* 	2. The software is not distributed or redistributed.  Software distribution is allowed 
*     only through https://simtk.org/home/opensim.
* 	3. Use of the OpenSim software or derivatives must be acknowledged in all publications,
*      presentations, or documents describing work in which OpenSim or derivatives are used.
* 	4. Credits to developers may not be removed from executables
*     created from modifications of the source.
* 	5. Modifications of source code must retain the above copyright notice, this list of
*     conditions and the following disclaimer. 
* 
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
*  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
*  SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
*  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
*  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
*  OR BUSINESS INTERRUPTION) OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
*  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Plugin written by Luca Modenese

#include <OpenSim/Common/PropertyBool.h>
#include <OpenSim/Common/PropertyBoolArray.h>
#include <OpenSim/Common/PropertyInt.h>
#include <OpenSim/Common/PropertyIntArray.h>
#include <OpenSim/Common/PropertyDbl.h>
#include <OpenSim/Common/PropertyDblArray.h>
#include <OpenSim/Common/PropertyDblVec.h>
#include <OpenSim/Common/PropertyStr.h>
#include <OpenSim/Common/PropertyStrArray.h>
#include <OpenSim/Simulation/Model/Analysis.h>
#include <OpenSim/Simulation/Model/Muscle.h>
#include "osimPluginDLL.h"// Header to define plugin (DLL) interface

namespace OpenSim { 

class Model;

class OSIMPLUGIN_API MuscleForceDirection : public Analysis 

{
// =======================   DATA    ============================

private:

protected:
	
	// Lines of action in local or global frame.
	PropertyBool _expressInLocalFrameProp;
	bool &_expressInLocalFrame;
	
	// Print or not a .sto file with the muscle attachments.
	PropertyBool _boolPrintAttachPointProp;
	bool &_printAttachPoints;
	
	// Anatomical muscle insertions or effective muscle insertions.
	PropertyBool _boolEffectiveInsertionsProp;
	bool &_effectInsertion;
	
	// string array with the bodies to analyze
	PropertyStrArray _strArrayBodyProp;
	Array<std::string> &_bodyNames;
	
	/*-------------- NOTE ---------------
	The original idea was to include the option for the user of 
	deciding a single muscle to analyze. 
	This option has been removed as for finite element applications
	is generally an entire body (or more) and the forces connected to it
	to be of interest.
	//string array with the muscles to analyze
	//PropertyStrArray _strArrayMuscleProp;
	//Array<std::string> &_muscleNames;
	--------------------------------------*/
	

	//========== INTERNAL USE ==============
	// Indices of bodies for kinematics to be reported and muscle for direction
	Array<int> _muscleIndices;

	// Storage for recording muscle direction
	Storage _storeDir;

	// Storage for recording attachment position
	Storage _storeAttachPointPos;
	
	// Internal work arrays to hold muscle directions at each time step.
	Array<double> _muscledir;
	Array<double> _attachpointpos;

// =====================================  METHODS   ==================================
public:
	// CONSTRUCTORS 
	MuscleForceDirection(Model *aModel=0);
	MuscleForceDirection(const std::string &aFileName);
	// COPY CONSTRUCTOR
	MuscleForceDirection(const MuscleForceDirection& aObject);
	// DESTRUCTOR
	virtual ~MuscleForceDirection();
	// CLONE
	virtual Object* copy() const;
	
private:
	// ZERO DATA AND NULL POINTERS
	void setNull();
	// SETUP PROPERTIES
	void setupProperties();

public:

#ifndef SWIG
	//Assign this object to the values of another.@return Reference to this object.
	MuscleForceDirection& operator=(const MuscleForceDirection &aMuscleForceDirection);
#endif

//========================== Required Methods =============================
	virtual void setModel(Model& aModel);
	// INTEGRATION
	virtual int	begin(SimTK::State& s);
	virtual int	step(const SimTK::State& s, int stepNumber);
	virtual int	end(SimTK::State& s);
	// IO
	virtual int	printResults(const std::string &aBaseName,const std::string &aDir="",double aDT=-1.0,const std::string &aExtension=".sto");

protected:
	//========================== Internal Methods =============================
	int record(const SimTK::State& s);
	void constructDescription();
	void constructColumnLabels();
	void setupStorage();
	
	// Utilities implemented by Luca Modenese (check on 15th March 2012).
	void constructDescriptionAttachments();
	void setupStorageAttachments();
	bool IsMuscleAttachedToBody(OpenSim::Muscle &aMuscle, std::string aBodyName);
	void GetMusclesIndexForBody(OpenSim::Model * _model, Array<std::string> aBodyNameSet, Array<int>  & MusclesIndexForBody );
	void MuscleForceDirection::EffectiveAttachments(Array<PointForceDirection*> & aPFDs, int & effecInsertProx, int & effecInsertDist);
	inline void NormalizeVec3(SimTK::Vec3 & v1, SimTK::Vec3 & rNormv1);

}; // END of class MuscleForceDirection

}; //namespace
#endif // #ifndef __AnalysisPlugin_Template_h__
