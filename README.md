# General Preprocessing Scripts
This repository contains scripts that are built to be project-independent. They can be used for general utilities like intialising ggplot defaults, or reconstructing DICOMs and preprocessing fMRI data.

## fMRIPreprocessing folder
This folder contains scripts that will implement general preprocessing of task-based and resting state fMRI data using AFNI and Freesurfer. These scripts check input, process data and organise it into BIDS-compliant folders. All default paths in the folders are setup to use the BIDS format. You can, of course change these defaults using apporpriate flags.

I have scripts to run the following four preprocessing steps:
 * **STEP 1:** Reconstruct NIFTIs from functional, anatomical and field map DICOMs using AFNI's dcm2niix_afni (ReconstructDICOMs.sh)
 * **STEP 2:** Preprocess anatomical data using AFNI's @SSwarper (p.1.sswarper)
 * **STEP 3:** Segment T1 anatomical scan using Freesurfer's recon_all (p.2.freesurfer)
 * **STEP 4:** Preprocess functional data using AFNI's afni_proc.py (p.3.run.AP; see note below)
 * **Optional STEP 5:** Extract ROIs from individual participant's Freesurfer segmentation (p.5.prepROIs)

**Note about STEP 4:** afni_proc.py produces really helpful quality control reports. These can only be generated if the final regression block is conducted. For this reason, the afni_proc.py command used here performs regression (using 3dDeconvolve) on the functional data without any task-based regressors (i.e., it pretends like you have a resting state dataset). This regression model however *does* contain motion and linear drift regressors. This is helpful to see how many degrees of freedom you have left over after censoring noisy time points and including these "regressors of no interest".


These scripts can be run somewhat independently (e.g., you can run SSwarper and Freesurfer outside these scripts and then switch to using these scripts for preprocessing). If you do this, make sure you're providing appropriate input paths to these scripts.

Basic demos for how to use these scripts are in the file UsageDemonstration.sh. These scripts are adapted from those distributed by AFNI during their bootcamp.  Scripts implementing steps 2-5 are setup in following manner: p.* scripts verify that input folders and files specified by the user exist. These scripts will also create the necessary output folders where required, and ultimately call and pass some information to the c.* scripts. The c.* scripts contain the AFNI/Freesurfer steps to perform the actual preprocessing. ReconstructDICOMs.sh performs these two functions within one script. 

Additional information about the options/flags available can be accessed using the -help flag with the p.* scripts, for instance:
`tcsh p.1.sswarper -help`
(Use `tcsh ReconstructDICOMs.sh -help` for help on the reconstructing DICOMs script). Also, yes, these are all written in tcsh, because that's what the AFNI folks seem to prefer. Please don't hate me!!

**DISCLAIMER: I am NOT a software developer, so there is a good chance that there are some errors/duplications/inefficiencies in these scripts. I first built them for my personal use, so that I wouldn't have to duplicate preprocessing scripts across fMRI projects. Since I found them useful, I decided to share them out. Please use these scripts at your own discretion! And please feel free to report errors, breaks over email or comments on GitHub.com. Also feel free to initiate pull requests if you want to fix stuff yourself or add new functionality!**

## InitialiseR folder
This folder contains some R scripts I've written for personal use. The scripts are called in other R scripts to initialise functions, etc. that can be used across projects. I've built some custom functions here for my use. Feel free to use them if you find them helpful!

