# Overview

The Muscle Force Direction plugin extends the functionalities of [OpenSim](https://simtk.org/projects/opensim/) providing a straighforward interface to extract the muscle lines of action.
The source code of the plugin is provided in the main repository and a dll that can be loaded through the main OpenSim user interface is available through the `Releases` tab. 
Leveraging the OpenSim Application Programming Interface (API), we also provide MATLAB scripts that replicate the plugin functionalities.

# Background

If you are using the internal forces estimated by musculoskeletal models as load sets in finite element models you find that you have few options to compute the direction of each force vector:
1. use a PointKinematics analysis on the points of interest of your line of action, compute the force versor for the kinematic frame of interest
2. use the PointForceDirection class and search for the segment of the muscle line of action that you are interested in.

The `MuscleForceDirection plugin` (`MFD` plugin for short) tries to streamline this operations and make easier to extract muscle forces and apply them to finite element models.

![FE_workflow](https://github.com/modenaxe/MuscleForceDirection/blob/master/images/plugin_workflow.png)

## "Anatomical" versus "Effective" lines of action

Anatomical muscle lines of actions are those whose attachments are on the bones.

Effective muscle lines of actions are those determining the effective mechanical
effect of the muscle action on the equilibrium of the bone when considering its
free body diagram.

A typical example is a muscle including _via points_ or _wrapping surface_, for
example the gastronemius, that can alter the muscle lines of action
substantially between the first segment of the muscle and the last segment
attached to a certain bone.
![anat_vs_effect](https://github.com/modenaxe/MuscleForceDirection/blob/master/images/anatomical_vs_effective.png)

A good explanation of this difference is available in section 5.4.3 of Yamaguchi's book `Dynamic Modeling of Musculoskeletal Motion: A Vectorized Approach for Biomechanical Analysis in Three Dimensions` entitled `EFFECTIVE ORIGIN AND INSERTION POINTS`.

# Plugin options

Using the plugin setup you can decide:

1. the body/bodies of interest on which to run the MFD analysis
2. the reference system in which you want to express the line of actions
3. choose if you want to extract the "anatomical" lines of action or the "effective" lines of action.

# Installation
* For compiling the C++ plugin, follow the instructions available on the [OpenSim Developers' Guide](https://simtk-confluence.stanford.edu/display/OpenSim/Developer%27s+Guide), where you can also find some examples.
* For installing the MFD plugin for use in the OpenSim GUI follow the same procedure to install other plugins:
	* place the plugin in the `plugins` folder
	* restart OpenSim
* For using the MATLAB scripts (OpenSim version ), you need to:
	* ensure that the OpenSim API are correctly installed. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).
	* include the MATLAB folder in your path.
	* check the provided examples.

# [WORK IN PROGRESS] Examples of use 

There will be examples of how to call the plugin from Matlab etc.


# Publications

The plugin was originally described in the Appendix of [this open access publication](https://github.com/modenaxe/MuscleForceDirection/blob/master/doc/papers/van%20Arkel%20et%20al.%20J%20Orthop%20Res%202013.pdf):

```bibtex
@article{van2013hip,
title={Hip abduction can prevent posterior edge loading of hip replacements},
author={van Arkel, Richard J and Modenese, Luca and Phillips, Andrew TM and Jeffers, Jonathan RT},
journal={Journal of Orthopaedic Research},
volume={31},
number={8},
pages={1172--1179},
year={2013},
publisher={Wiley Online Library}
}
```

but a better example of use is provided in this other open access [paper](https://github.com/modenaxe/MuscleForceDirection/blob/master/doc/papers/Phillips%20et%20al.%20Inter%20Biomech%202015.pdf):

```bibtex
@article{phillips2015femoral,
title={Femoral bone mesoscale structural architecture prediction using musculoskeletal and finite element modelling},
author={Phillips, Andrew TM and Villette, Claire C and Modenese, Luca},
journal={International Biomechanics},
volume={2},
number={1},
pages={43--61},
year={2015},
publisher={Taylor \& Francis}
}
```

# How to contribute

Feel free of contributing as by standard [GitHub
workflow](https://guides.github.com/activities/forking/):

1. forking this repository
2. creating your own branch, where you make your modifications and improvements
3. once you are happy with the new feature you have implemented create a pull
   request

## Resources for learning how to contribute
* If you want to contribute but you are not familiar with [Git](https://git-scm.com/), the [Software Carpentry Lessons](https://swcarpentry.github.io/git-novice/) are a perfect place to start with Git and GitHub.
* If you know how to use git but you are not familiar with GitHub, you can check resources like ["First Contributions"](https://github.com/firstcontributions/first-contributions) to learn how to contribute to existing projects.

# Resource on combining finite element and musculoskeletal models
* OpenSim Webinar: ["Interfacing Musculoskeletal and Finite Element Models to Study Bone Structure & Adaptation"](https://www.youtube.com/watch?v=0e6vQV_ioCI)

# Contributors
Several researchers have contributed to this package:
* [Luca Modenese](https://github.com/modenaxe): C++, Matlab
* [John J. Davis IV](https://github.com/johnjdavisiv): Plugin Matlab demo updated to OpenSim 4.2
* [Ke Song](https://github.com/KSongGitHub): Matlab update to OpenSim 4.0
* [Dimitar Stanev](https://github.com/mitkof6): C++ update to OpenSim 4.0
* [Claudio Pizzolato](https://github.com/cpizzolato): C++ makefiles
* [Friedl De Groote](https://github.com/FriedlDeGroote): C++ legacy [version](https://github.com/modenaxe/MuscleForceDirection/tree/master/CPP/legacy_code/OpenSim2.4_KULeuven) of v1.0
* Alfred Thibon: C++
