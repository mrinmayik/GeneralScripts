#!/bin/tcsh

#This script is got from the afni demos distributed at the Milwaukee AFNI Bootcamp.

# ======================================================================
# inputs: SID INDATA_ROOT RUN_SCRIPT OUTDATA_ROOT ...
#
# if SLURM:
#    setenv OMP_NUM_THREADS
#    set outdir = scratch dir
#    create outdir
# mkdir OUTDATA_ROOT/$subj
# cd $outdir
# ... run script ... save status
# if SLURM: rsync . OUTDATA_ROOT/$subj/
# ======================================================================

# ----------------------------------------------------------------------
# modify per command

set nneeded = 4
set use_args = "SID INDATA_ROOT RUN_SCRIPT OUTDATA_ROOT ..."

set subj = "$1"
set indata_root = "$2"
set run_script = "$3"
set outdata_root = "$4"

# allow use of SLURM temp directory
set temp_ok = 0

# ----------------------------------------------------------------------
# static test

if ( $#argv < $nneeded ) then
    set script = `basename $0`
    echo $script : need $nneeded parameters
    echo ""
    echo "usage: $script $use_args"
    echo ""
    echo "command : $argv"
    echo ""
    exit 1
endif

# note any trailing args to pass along
if ( $#argv > $nneeded ) then
   @ tbase = $nneeded + 1
   set trailers = ( $argv[$tbase-] )
else
   set trailers = ()
endif

# ================== Optional: Biowulf cluster =========================


# This section for possibly running on Biowulf cluster.

# Set thread count
if( $?SLURM_CPUS_PER_TASK )then
  setenv OMP_NUM_THREADS $SLURM_CPUS_PER_TASK
endif

# Set temporary output directory; then requires using something like
# this on the swarm command line: --sbatch '--gres=lscratch:100'.
# These variables used again *after* afni_proc.py command, if Biowulfing.
if( $?SLURM_JOBID && $temp_ok )then
  set outdir = /lscratch/$SLURM_JOBID/${subj}
  set usetemp = 1
  mkdir -p $outdir
  if ( $status ) then
     echo "** failed to make swarm tempdir, $outdir"
     exit 1
  endif
else
  set outdir = $outdata_root/$subj
  set usetemp = 0
endif

# for naming the text output file
set sfile = $run_script:t

# may or may not exist
mkdir -p $outdata_root/$subj
cd $outdir
tcsh -x $run_script $subj $indata_root $trailers |& tee out.$sfile
set rv = $status
echo $rv >! out.status.$sfile

if( $usetemp && -d $outdir ) then
   rsync -av . $outdata_root/$subj/
endif

echo "++ finished $sfile for subj $subj, status = $rv"
time
