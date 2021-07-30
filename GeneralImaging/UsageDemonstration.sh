#!/bin/tcsh

#####################################################################################
#This script is a demonstration for using project-independent preprocessing scripts
#in this folder. Not all available options are demo'ed here. Type e.g., 
#tcsh p.1.sswarper -help
#to get a list of all available options and defaults.
#####################################################################################

#Set some paths
set ProjectPath = ~/Data/
set ScriptPath = ~/Scripts/

set subj_id = sub-001


#STEP 1: Reconstruct DICOMs
tcsh ${ScriptPath}/ReconstructDICOMs.sh                 \
    -project ${ProjectPath}                             \
    -redo                                               \
    -T1Data 2                                           \
    -func encode 6                                      \
    -fmap 4                                             \
    ${subj_id}

#STEP 2: Process structural data using @SSwarper
tcsh ${ScriptPath}/p.1.sswarper                         \
    -project ${ProjectPath}                             \
    -script_dir ${ScriptPath}                           \
    -redo                                               \
    -anat_name ${subj_id}_run-01_T1w.nii                \
    ${subj_id}

#STEP 3: Do Freesurfer segmentations on output from @SSwarper
tcsh ${ScriptPath}/p.2.freesurfer                       \
    -project ${ProjectPath}                             \
    -script_dir ${ScriptPath}                           \
    -redo                                               \
    -anat_name anatUA.${subj_id}.nii                    \
    -input_dir derivatives/AFNI_01_SSwarper             \
    ${subj_id}

#STEP 4: Preprocess functional data
#Actually run the script
tcsh ${ScriptPath}/p.3.run.AP                           \
    -project ${ProjectPath}                             \
    -script_dir ${ScriptPath}                           \
    -redo                                               \
    -taskname encode 6                                  \
    -dummy_scans 4                                      \
    -alignment_move giant_move                          \
    -tlrc Y                                             \
    -DC N                                               \
    -smoothing Y 4                                      \
    -SSW_dir AFNI_01_SSwarper                           \
    ${subj_id}

#Optional STEP 5: Extract ROIs from each participant's Freesurfer segmentation
tcsh ${ScriptPath}/p.5.prepROIs                         \
    -project ${ProjectPath}                             \
    -numrois 8                                          \
    -ROIs 1027 ${sid}_L_dlPFC 2027 ${sid}_R_dlPFC 1012 ${sid}_L_lOFC 1014 ${sid}_L_mOFC 2012 ${sid}_R_lOFC 2014 ${sid}_R_mOFC 1028 ${sid}_L_dmPFC 2028 ${sid}_R_dmPFC                           \
    -redo                                               \
    -out_dir ROIs                                       \
    -fsdata aparc+aseg.mgz                              \
    $sid
