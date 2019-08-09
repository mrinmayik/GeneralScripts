#!/bin/tcsh -f

########################################################################################################################################################################
# This is a general purpose script meant to reconstruct DICOMs. It takes in information about the paths, and the number of functionals etc
# Written by Mrinmayi (mrinmayi@uwm.edu)
########################################################################################################################################################################

#module load /sharedapps/LS/psych_imaging/modulefiles/afni/07.17.2019

set doc = "This script is meant to convert DICOMs to NIFTI using the dcm2niix_afni tool and save the output in a BIDs structure. \n\n To use this script type \ntcsh ReconstructDICOMs PARTICIPANT PROJECT_PATH RAW_DATA_PATH OUTPUT_PATH NUMBER_OF_ANATS NUMBER_OF_TASKS NAME_OF_TASK NUMBER_OF_RUNS_PER_TASK\n PARTICIPANT: Participant ID to make BIDs folder\n\n PROJECT_PATH: Path for project folder\n\n RAW_DATA_PATH: Path where the raw data is kept in project folder\n\n OUTPUT_PATH: Path where converted NIFTIs should be stored in subject folders\n\n NUMBER_OF_ANATS: How many anats were collected\n\n NUMBER_OF_TASKS: Number of tasks with functional runs. e.g. If you have Encoding and Test scans the answer is 2\n\n NAME_OF_TASK NUMBER_OF_RUNS_PER_TASK: What you have named your task in your raw folder, followed by number of runs for that task. e.g. If you have 3 encoding runs called *_enc_* and 2 test runs called *_test_* type enc 3 test 2\n"

if ( $#argv != 8 ) then
	printf "******ERROR******\n The number of arguments do not match \n %b" "$doc"
endif

set PARTICIPANT = $argv[1]
set PROJECTPATH = $argv[2]
set RAWDATAPATH = $argv[3]
set OUTPUTPATH = $argv[4]
set NUMBEROFANATS = $argv[5]
set NUMBEROFTASKS = $argv[6]

#Making sure all the paths exist
if ( ! -d ${PROJECTPATH} ) then
	echo "${PROJECTPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH} ) then
	echo "${PROJECTPATH}/${RAWDATAPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH} ) then
	echo "${PROJECTPATH}/${RAWDATAPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ ) then
	echo "${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ ) then
	echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ does not exist! Making it!"
	mkdir ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/
endif

cd ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/

#Count how many anat folders are in raw path
set AnatPaths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "anat_*" `
if ( $#AnatPaths != ${NUMBEROFANATS} ) then
	echo "Only $#AnatPaths found. You indicated ${NUMBEROFANATS} anats. Something wrong!"
	exit 1
endif

#Count how many anat folders are in raw path
set TaskInfo = ` expr $#argv - 6 `
if ( ${TaskInfo} != `expr ${NUMBEROFTASKS} \* 2` ) then
	echo "You didn't enter the right number of task information. You said there are ${NUMBEROFTASKS} but you only provided ${TaskInfo} parameters with func information."
	exit 1
endif

#set AnatPaths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "anat_*" `
foreach AnatNum ( `seq 1 $#AnatPaths` )

	echo "\n**Working on $AnatPaths[${AnatNum}]**\n"
	cd $AnatPaths[${AnatNum}]
	
	if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${AnatNum}.nii ) then
		echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${AnatNum}.nii already exists! Not overwriting!"
		echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ -type f -name *.nii -delete to delete all NIFTIs in one go."
	else
		dcm2niix_afni -f anat_${AnatNum} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ .
	endif
	
end

foreach 
