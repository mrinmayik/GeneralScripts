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
set input_dir = derivatives/FSOutput
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
    else if ( "$argv[$ac]" == "-project" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -project: missing argument"
            exit 1
        endif
        set project = $argv[$ac]
    else if ( "$argv[$ac]" == "-input_dir" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -input_dir: missing argument"
            exit 1
        endif
        set input_dir = $argv[$ac]
    else if ( "$argv[$ac]" == "-out_dir" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -out_dir: missing argument"
            exit 1
        endif
        set out_dir = $argv[$ac]
    else if ( "$argv[$ac]" == "-fsdata" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -fsdata: missing argument"
            exit 1
        endif
        set fsdata = $argv[$ac]
    else if ( "$argv[$ac]" == "-numrois" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -numrois: missing argument"
            exit 1
        endif
        set numrois = $argv[$ac]
    else if ( "$argv[$ac]" == "-ROIs" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -ROIs: missing argument"
            exit 1
        endif
        set roilabels = ( )
        set roinames = ( )
        foreach roinum ( $numrois )
            @ ac ++
            set roilabels = ( $roilabels $argv[$ac] )
            @ ac ++
            set roinames = ( $roinames $argv[$ac] )
		end
    else if ( "$argv[$ac]" == "-redo" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -redo: missing argument"
            exit 1
        endif
        set redo = $argv[$ac]
    else if ( "$argv[$ac]" == "-script_dir" ) then
        @ ac ++
        if ( $ac > $#argv ) then
            echo "** -script_dir: missing argument"
            exit 1
        endif
        set script_dir = $argv[$ac]
    else
       # everything else should be a subject
       set subj_proc_list = ( $argv[$ac-] )
       break
    endif

    @ ac ++
 end


 # check that necessary arguments have been passed
 # project path is needed because this path needs to be passed to c.0.int_vars
 # taskname is required to set output directory name etc
 set neededargs = ( $project )
 set neededvars = ( project )
 foreach ac ( `seq 1 $#neededargs` )
    if ( ${neededargs[${ac}]} == 0 ) then
 	   echo "made it here4"
 	   echo "-${neededvars[${ac}]} is missing"
 	   exit 1
    endif
 end

 echo $project

 # source the variable init file (to keep them mostly in one place)
 # sets: study_root_in, study_root_out, deriv_dir, all_subjects, nsubj
 source $script_dir/c.0.init_vars -project $project -input_dir $input_dir
        
 # ======================================================================
 # do some work...

 echo "== time == starting : `date`"

 # if subj_proc_list was not initialized, process everyone
 if ( $#subj_proc_list == 0 ) then
    set subj_proc_list = ( $all_subjects )
    echo "++ $prog : processing all subjects"
 endif
 echo "-- $prog : processing $#subj_proc_list subjects"
 echo "-- $prog : processing the following subjects $subj_proc_list" # modified
 echo "" # modified

 # output directory will be derivates/$proc_dir
 set res_dir = $deriv_dir/$out_dir
 echo "-- $prog : results will go under $res_dir"


 # for each subject, mask sure they exist
 set missing = 0
 set done    = 0
 set todo    = 0
 set nredo   = 0
 set subjs_todo = ()
 foreach sid ( $subj_proc_list )
    # if redo, delete old
    if ( $redo &&  -d $res_dir/$sid ) then
       echo "-- deleting subject $sid for re-run"
       @ nredo += 1
       \rm -fr $res_dir/$sid
    endif

    if ( ! -f $in_dir/$sid/mri/$fsdata ) then # modified
       @ missing += 1
    else if ( -d $res_dir/$sid ) then
       echo "-- yay, already done with subject $sid"
       @ done += 1
    else
       set subjs_todo = ( $subjs_todo $sid )
       @ todo += 1
    endif
 end
 echo "$in_dir/$sid/mri/$fsdata"
 echo ""
 echo "-- $prog subjects: $missing missing, $done already done, $todo todo"
 echo "                   $nredo redo"
 echo ""
    


