Project(MuscleForceDirection)


link_directories(${OPENSIM_LIBS_DIR})

set(MuscleForceDirection_HEADERS
                        MuscleForceDirection.h RegisterTypes_osimPlugin.h osimPluginDLL.h)
                        
set(MuscleForceDirection_SOURCES
                        MuscleForceDirection.cpp RegisterTypes_osimPlugin.cpp)

source_group("MuscleForceDirection_headers" FILES ${MuscleForceDirection_HEADERS})
source_group("MuscleForceDirection_sources" FILES ${MuscleForceDirection_SOURCES})


# Define target
add_library(MuscleForceDirection SHARED
  ${MuscleForceDirection_HEADERS}
  ${MuscleForceDirection_SOURCES}
)

target_include_directories(MuscleForceDirection 
                                             PUBLIC
                                             ${OPENSIM_INCLUDE_DIRS}
                                             ${SIMTK_INCLUDE_DIRS}
                                    )
target_link_libraries(MuscleForceDirection ${OPENSIM_LIBRARIES})

set_target_properties(
	MuscleForceDirection PROPERTIES
	DEFINE_SYMBOL OSIMPLUGIN_EXPORTS
	PROJECT_LABEL "Libraries - MuscleForceDirection")

#INSTALL_TARGETS(/plugins RUNTIME_DIRECTORY /plugins  MuscleForceDirection)

