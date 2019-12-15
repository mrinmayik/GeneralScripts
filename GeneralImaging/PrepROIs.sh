#!/bin/tcsh

########################################################################################
#This is a general purpose script to prepare Freesurfer segmentations to extract parameter 
########################################################################################

# the location of processing scripts (use full path)
set script_dir = `pwd`
set redo = 0

# --------------------------------------------------
# variables specifiec to this script

# the name of this script
set prog = `basename $0`

# list of subjects to process
set subj_proc_list = ()
set project = 0
set input_dir = 0
set fsdata = aseg.mgz

# processing directory that goes under derivatives
set out_dir = ParameterEstimates


