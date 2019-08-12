#!/bin/tcsh -f

########################################################################################################################################################################
# This is a general purpose script meant to reconstruct DICOMs. It takes in information about the paths, and the number of functionals etc
# Written by Mrinmayi (mrinmayi@uwm.edu)
########################################################################################################################################################################

module load /sharedapps/LS/psych_imaging/modulefiles/afni/07.17.2019

set doc = "This script is meant to convert DICOMs to NIFTI using the dcm2niix_afni tool and save the output in a BIDs structure. \n\n To use this script type \ntcsh ReconstructDICOMs PARTICIPANT PROJECT_PATH RAW_DATA_PATH OUTPUT_PATH T1DATA T2DATA FUNCDATA [NUMBER_OF_T1 NUMBER_OF_T2 NUMBER_OF_TASKS 'NAME_OF_TASK' NUMBER_OF_RUNS_PER_TASK]\n PARTICIPANT: Participant ID to make BIDs folder\n\n PROJECT_PATH: Path for project folder\n\n RAW_DATA_PATH: Path where the raw data is kept in project folder\n\n OUTPUT_PATH: Path where converted NIFTIs should be stored in subject folders\n\n T1DATA: 1 if there are T1s that need to be reconstructed, 0 if no T1s\n\n T2DATA: 1 if there are T2s that need to be reconstructed, 0 if no T2s\n\n FUNCDATA:  1 if there are functionals that need to be reconstructed, 0 if no functionals\n\n [Optional parameters: NUMBER_OF_T1: How many T1s were collected (set to 0 if you have T2s/funcs but not T1s)\n\n NUMBER_OF_T2: How many T2s were collected (set to 0 if you have funcs but not T2s) \n\n NUMBER_OF_TASKS: Number of tasks with functional runs. e.g. If you have Encoding and Test scans the answer is 2\n\n 'NAME_OF_TASK' NUMBER_OF_RUNS_PER_TASK: What you have named your task in your raw folder, followed by number of runs for that task. e.g. If you have 3 encoding runs called *_enc_* and 2 test runs called *_test_* type enc 3 test 2\n"

#Check if all the required arguments are passed
if ( $#argv < 7 ) then
	printf "******ERROR******\n The number of arguments do not match \n %b" "$doc"
	exit 
endif

set PARTICIPANT = $argv[1]
set PROJECTPATH = $argv[2]
set RAWDATAPATH = $argv[3]
set OUTPUTPATH = $argv[4]

set T1DATA = $argv[5]
set T2DATA = $argv[6]
set FUNCDATA = $argv[7]

#Making sure all the paths exist
if ( ! -d ${PROJECTPATH} ) then
	echo "ERROR: ${PROJECTPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH} ) then
	echo "ERROR: ${PROJECTPATH}/${RAWDATAPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH} ) then
	echo "ERROR: ${PROJECTPATH}/${RAWDATAPATH} does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ ) then
	echo "ERROR: ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ does not exist!"
	exit 1
endif
if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ ) then
	echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ does not exist! Making it!"
	mkdir ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/
endif

cd ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/

#####Deal with T1s, if any
if( $T1DATA == 1 ) then
	echo "\n\t\t\t************Working on T1s ************\n"
	#How many T1s do we have?
	set NUMBEROFT1 = $argv[8]

	#Count how many anat folders are in raw path
	set T1Paths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "T1w_*" `
	#Do they match up with how many are expected based on user-input?
	if ( $#T1Paths != ${NUMBEROFT1} ) then
		echo "\nERROR: Only $#T1Paths found. You indicated ${NUMBEROFT1} T1(s). Something wrong!\n"
		exit 1
	endif
	
	foreach T1Num ( `seq 1 $#T1Paths` )
		echo "\n**Working on $T1Paths[${T1Num}]**\n"
		cd $T1Paths[${T1Num}]
		#Reconstruct if NIFTIs don't already exist
		if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/sub-${PARTICIPANT}_T1w_${T1Num}.nii ) then
			echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/sub-${PARTICIPANT}_T1w_${T1Num}.nii already exists! Not overwriting!"
			echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ -type f -name *.nii -delete to delete all NIFTIs in one go."
		else
			if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ ) then
				echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ does not exist! Making it!"
				mkdir ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/
			endif
			
			dcm2niix_afni -f sub-${PARTICIPANT}_T1w_${T1Num} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ .
		endif
	
	end
endif


#####Deal with T2s, if any
if( $T2DATA == 1 ) then
	echo "\n\t\t\t************Working on T2s ************\n"
	set NUMBEROFT2 = $argv[9]

	#Count how many anat folders are in raw path
	set T2Paths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "T2w_*" `
	#Do they match up with how many are expected based on user-input?
	if ( $#T2Paths != ${NUMBEROFT2} ) then
		echo "\nERROR: Only $#T2Paths found. You indicated ${NUMBEROFT2} T2(s). Something wrong!\n"
		exit 1
	endif
	
	foreach T2Num ( `seq 1 $#T2Paths` )

		echo "\n**Working on $T2Paths[${T2Num}]**\n"
		cd $T2Paths[${T2Num}]
		#Reconstruct if NIFTIs don't already exist	
		if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/sub-${PARTICIPANT}_T2w_${T1Num}.nii ) then
			echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/sub-${PARTICIPANT}_T2w_${T1Num}.nii already exists! Not overwriting!"
			echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ -type f -name *.nii -delete to delete all NIFTIs in one go."
		else
			if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ ) then
				echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/ does not exist! Making it!"
				mkdir ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat/
			endif
			
			dcm2niix_afni -f sub-${PARTICIPANT}_T2w_${T1Num} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat .
		endif
	
	end
endif



#####Deal with functionals, if any
if( $FUNCDATA == 1 ) then
	echo "\n\t\t\t************Working on funcs ************\n"
	set NUMBEROFTASKS = $argv[10]
	
	set TaskInfo = ` expr $#argv - 10 `
	if ( ${TaskInfo} != `expr ${NUMBEROFTASKS} \* 2` ) then
		echo "ERROR: You didn't enter the right number of task information. You said there are ${NUMBEROFTASKS} and provided ${TaskInfo} parameters with func information."
		exit 1
	endif

	foreach FuncNum ( `seq 1 ${NUMBEROFTASKS}` )

		cd ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/
		#Set numbers and names for the tasks we're on
		set TaskNameIdx = `expr 10 + $FuncNum`
		set TaskNumIdx = `expr 10 + $FuncNum + 1`
		set FuncName = ${argv[${TaskNameIdx}]}
		#Count how many task folders are in raw path
		set FuncPaths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "*${FuncName}_*" `
		#Do they match up with how many are expected based on user-input?
		if ( $#FuncPaths != $argv[${TaskNumIdx}] ) then
			echo "ERROR: $#FuncPaths found for $FuncName. You indicated $argv[${TaskNumIdx}] funcs for this task. Something wrong!" #`expr 6 + $FuncNum`
			exit 1
		endif

		#Reconstruct if NIFTIs don't already exist
		foreach FuncNum ( `seq 1 $#FuncPaths`)
			echo "\n**Working on $FuncPaths[${FuncNum}]**\n"
			cd $FuncPaths[${FuncNum}]
	
			if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/sub-${PARTICIPANT}_${FuncName}_${FuncNum}.nii ) then
				echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/sub-${PARTICIPANT}_${FuncName}_${FuncNum}.nii already exists! Not overwriting!"
				echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ -type f -name *.nii -delete to delete all NIFTIs in one go."
			else
				if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ ) then
					echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ does not exist! Making it!"
					mkdir ${PROJECTPATH}/${OUTPUTPATH	}/${PARTICIPANT}/func/
				endif
				
				dcm2niix_afni -f sub-${PARTICIPANT}_${FuncName}_${FuncNum} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func .
			endif
		end
	end
	
endif




