# Overview

The Muscle Force Direction plugin extends the functionalities of [OpenSim]() by making convenient to extract the muscle lines of action.
It is provided as a C++ plugin that can be loaded through the main OpenSim user interface or called by MATLAB.
Leveraging the OpenSim Application Programming Interface (API) it is also provided as MATLAB toolbox.

# Background

If you are using the internal forces estimated by musculoskeletal models as load sets in finite element models you find that you have few options:
1. use a PointKinematics analysis on the points of interest of your line of action, compute the force versor for the kinematic frame of interest
2. use the PointForceDirection class and search for the segment of the muscle line of action that you are interested in.

The MuscleForceDirection plugin (MFD plugin for short) tries to streamline this operations and make easier to extract muscle forces and apply them to finite element models.

# Plugin options
Using the plugin setup you can decide:
1. the body/bodies of interest on which to run the MFD analysis
2. the reference system in which you want to express the line of actions
3. choose if you want to extract the "anatomical" lines of action or the effective lines of action.

## "Anatomical" versus "Effective" lines of action
Anatomical muscle lines of actions are those whose attachments are on the bones.

Effective muscle lines of actions are those determining the effective mechanical effect of the muscle action on the equilibrium of the bone when considering its free body diagram.

A typical example is a muscle including _via points_ or _wrapping surface_, for example the gastronemius, that can alter the muscle lines of action substantially between the first segment of the muscle and the last segment attached to a certain bone.
[!image](PATH_TO_IMAGE)

# Installation
* For compiling the C++ plugin, follow the instructions available on the OpenSim Developers' Guide, where you can also find some examples.
* For installing the MFD plugin for use in the OpenSim GUI follow the same procedure to install other plugins:
	* place the plugin in the `plugins` folder
	* restart OpenSim
* For using the MATLAB toolbox, include the **REVISE** MATLAB folder in your path.


# License (REVISE -> I WANT THE MODIFICATIONS TO BE SHARED BACK!)
Apache 2.0 license making it suitable for any use commercial, government, academic, or personal.  

# How to Acknowledge Us
Please cite the following publication:

```bibtex
**INCLUDE CITATION HERE**
```

# Limitations
* The C++ plugin has not been updated in a while, and it is not compatible with OpenSim 4.0.

# How to contribute
Feel free of contributing as by standard [GitHub workflow](LINK_TO_GITHUB_WORKFLOW):
1. fork this repository
2. create your own branch, where you make your modifications and improvements
3. once you are happy with the new feature you have implemented create a pull request

# Resources
* If you want to contribute but you are not familiar with [Git](), the [Software Carpentry Lessons](CARPENTRY_LINK) are a perfect place to start with Git and GitHub.
* If you know how to use git but you are not familiar with GitHub, you can check resources like ["My First Contribution"](LINK_TO_FIRST_CONTRIB) to learn how to contribute to existing projects.

# To Do List
These are some of the points of development
[ ] make the C++ plugin compatible with OpenSim 4.0
[ ] port the scripting toolbox in Python
[ ] finalise the Matlab Toolbox
[ ] implement proper interfaces with the main finite element packages, e.g. Abaqus, Ansys, FEBio.

# Additional Resources
* OpenSim Webinar on interfacing musculoskeletal and finite element models.
* Yamaguchi book 

# Contributors
In various moment several people contributed to the package:
* Alfred Thibon
* Friedl DeGroote
* Claudio Pizzolato
* Ke Son
