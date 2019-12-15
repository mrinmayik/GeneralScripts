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
set project = 0
set input_dir = FSOutput
set fsdata = aseg.mgz

# processing directory that goes under derivatives
set out_dir = ParameterEstimates

# ======================================================================
# process command-line arguments
set ac = 1
while ( $ac <= $#argv )
    if ( "$argv[$ac]" == "-help" ) then
        echo "$prog       - prepare ROIs from Freesurfer to extract parameter estimates"
        echo ""
        echo "usage: $prog [options...] subj subj ..."
        echo ""
        echo "options specific to this script"
        echo ""
        echo "  -project PATH     : path to project folder that you're working on" # modified
        echo "						Note: the output path will also be set to this folder"
        echo "  -input_dir DIR    : directory in [project] where raw data is stored"
        echo "                      default: $input_dir"
        echo "  -out_dir DIR      : root directory under 'derivates' for results"
        echo "                      default: $out_dir"
        echo "  -fsdata NAME	  : Name of file from which ROIs are to be extracted" # modified
        echo "                      default: $fsdata"
        echo "  -numrois NUM      : Number of ROIs that should be extracted"
        echo "  -ROIs LIST        : The labels of ROIs each followed by the name that will be"
        echo "                      used for filenames"
        echo ""
        echo "general options"
        echo ""
        echo "  -help             : show help and exit"
        echo "  -redo             : (delete previous and) re-create results"
        echo "  -script_dir DIR   : specify directory of processing scripts"
        echo "                      default: $script_dir"
        echo ""
        exit 0
        # modified

