#ifndef _MuscleForceDirection_h_
#define _MuscleForceDirection_h_

#include "osimPluginDLL.h" // Header to define plugin (DLL) interface

#include <OpenSim/Common/PropertyBool.h>
#include <OpenSim/Common/PropertyBoolArray.h>
#include <OpenSim/Common/PropertyDbl.h>
#include <OpenSim/Common/PropertyDblArray.h>
#include <OpenSim/Common/PropertyDblVec.h>
#include <OpenSim/Common/PropertyInt.h>
#include <OpenSim/Common/PropertyIntArray.h>
#include <OpenSim/Common/PropertyStr.h>
#include <OpenSim/Common/PropertyStrArray.h>
#include <OpenSim/Simulation/Model/Analysis.h>
#include <OpenSim/Simulation/Model/Muscle.h>

namespace OpenSim {

class Model;

class OSIMPLUGIN_API MuscleForceDirection : public Analysis {
    OpenSim_DECLARE_CONCRETE_OBJECT(MuscleForceDirection, Analysis);

 protected:
    // Lines of action in local or global frame.
    PropertyBool _expressInLocalFrameProp;
    bool& _expressInLocalFrame;

    // Print or not a .sto file with the muscle attachments.
    PropertyBool _boolPrintAttachPointProp;
    bool& _printAttachPoints;

    // Anatomical muscle insertions or effective muscle insertions.
    PropertyBool _boolEffectiveInsertionsProp;
    bool& _effectInsertion;

    // string array with the bodies to analyze
    PropertyStrArray _strArrayBodyProp;
    Array<std::string>& _bodyNames;

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

    // =====================================  METHODS
    // ==================================
 public:
    // CONSTRUCTORS
    MuscleForceDirection(Model* aModel = 0);
    MuscleForceDirection(const std::string& aFileName, bool aUpdateFromXMLNode);
    // COPY CONSTRUCTOR
    MuscleForceDirection(const MuscleForceDirection& aObject);
    // DESTRUCTOR
    ~MuscleForceDirection();
    // CLONE
    Object* copy() const;

 private:
    // ZERO DATA AND NULL POINTERS
    void setNull();
    // SETUP PROPERTIES
    void setupProperties();

 public:
#ifndef SWIG
    // Assign this object to the values of another.@return Reference to this
    // object.
    MuscleForceDirection&
    operator=(const MuscleForceDirection& aMuscleForceDirection);
#endif

    //========================== Required Methods =============================
    void setModel(Model& aModel) override;
    // INTEGRATION
    int begin(SimTK::State& s);
    int step(const SimTK::State& s, int stepNumber) override;
    int end(SimTK::State& s);
    // IO
    int printResults(const std::string& aBaseName, const std::string& aDir = "",
                     double aDT = -1.0,
                     const std::string& aExtension = ".sto") override;

 protected:
    //========================== Internal Methods =============================
    int record(const SimTK::State& s);
    void constructDescription();
    void constructColumnLabels();
    void setupStorage();

    // Utilities implemented by Luca Modenese (check on 15th March 2012).
    void constructDescriptionAttachments();
    void setupStorageAttachments();
    static Array<int>
    getMusclesIndexForBody(Model* model, const Array<std::string>& bodyNames);
    static bool isMuscleAttachedToBody(const OpenSim::Muscle& aMuscle,
                                       const std::string& aBodyName);
    static void
    getEffectiveAttachments(const Array<PointForceDirection*>& aPFDs,
                            int& effecInsertProx, int& effecInsertDist);
    void NormalizeVec3(SimTK::Vec3& v1, SimTK::Vec3& rNormv1);
}; // END of class MuscleForceDirection

};     // namespace OpenSim
#endif // #ifndef __AnalysisPlugin_Template_h__
