#!/bin/tcsh -f

########################################################################################################################################################################
# This is a general purpose script meant to reconstruct DICOMs. It takes in information about the paths, and the number of functionals etc
# Written by Mrinmayi (mrinmayi@uwm.edu)
########################################################################################################################################################################

#module load /sharedapps/LS/psych_imaging/modulefiles/afni/07.17.2019

set doc = "This script is meant to convert DICOMs to NIFTI using the dcm2niix_afni tool and save the output in a BIDs structure. \n\n To use this script type \ntcsh ReconstructDICOMs PARTICIPANT PROJECT_PATH RAW_DATA_PATH OUTPUT_PATH T1DATA T2DATA FUNCDATA [NUMBER_OF_T1 NUMBER_OF_T2 NUMBER_OF_TASKS 'NAME_OF_TASK' NUMBER_OF_RUNS_PER_TASK]\n PARTICIPANT: Participant ID to make BIDs folder\n\n PROJECT_PATH: Path for project folder\n\n RAW_DATA_PATH: Path where the raw data is kept in project folder\n\n OUTPUT_PATH: Path where converted NIFTIs should be stored in subject folders\n\n NUMBER_OF_ANATS: How many anats were collected\n\n NUMBER_OF_TASKS: Number of tasks with functional runs. e.g. If you have Encoding and Test scans the answer is 2\n\n 'NAME_OF_TASK' NUMBER_OF_RUNS_PER_TASK: What you have named your task in your raw folder, followed by number of runs for that task. e.g. If you have 3 encoding runs called *_enc_* and 2 test runs called *_test_* type enc 3 test 2\n"

if ( $#argv < 7 ) then
	printf "******ERROR******\n The number of arguments do not match \n %b" "$doc"
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
if( $T1DATA == 1 )
	set NUMBEROFT1 = $argv[8]

	#Count how many anat folders are in raw path
	set T1Paths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "T1w_*" `
	if ( $#T1Paths != ${NUMBEROFT1} ) then
		echo "ERROR: Only $#T1Paths found. You indicated ${NUMBEROFT1} anats. Something wrong!"
		exit 1
	endif
	
	foreach T1Num ( `seq 1 $#T1Paths` )

		echo "\n**Working on $T1Paths[${T1Num}]**\n"
		cd $T1Paths[${T1Num}]
	
		if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${T1Num}.nii ) then
			echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${T1Num}.nii already exists! Not overwriting!"
			echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ -type f -name *.nii -delete to delete all NIFTIs in one go."
		else
			dcm2niix_afni -f anat_${T1Num} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ .
		endif
	
	end
endif


#####Deal with T2s, if any
if( $T2DATA == 1 )
	set NUMBEROFT2 = $argv[9]

	#Count how many anat folders are in raw path
	set T2Paths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "T2w_*" `
	if ( $#T2Paths != ${NUMBEROFT2} ) then
		echo "ERROR: Only $#T2Paths found. You indicated ${NUMBEROFT2} anats. Something wrong!"
		exit 1
	endif
	
	foreach T2Num ( `seq 1 $#T2Paths` )

		echo "\n**Working on $T2Paths[${T2Num}]**\n"
		cd $T2Paths[${T2Num}]
	
		if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${T2Num}.nii ) then
			echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${T2Num}.nii already exists! Not overwriting!"
			echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ -type f -name *.nii -delete to delete all NIFTIs in one go."
		else
			dcm2niix_afni -f anat_${T2Num} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ .
		endif
	
	end
endif


exit
#####Deal with functionals, if any
set NUMBEROFTASKS = $argv[6]
#Count how many anat folders are in raw path
set TaskInfo = ` expr $#argv - 6 `
if ( ${TaskInfo} != `expr ${NUMBEROFTASKS} \* 2` ) then
	echo "ERROR: You didn't enter the right number of task information. You said there are ${NUMBEROFTASKS} but you only provided ${TaskInfo} parameters with func information."
	exit 1
endif


foreach FuncNum ( `seq 1 ${NUMBEROFTASKS}` )

	cd ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/
	
	set TaskNameIdx = `expr 6 + $FuncNum`
	set TaskNumIdx = `expr 6 + $FuncNum + 1`
	set FuncName = ${argv[${TaskNameIdx}]}
	
	set FuncPaths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "*${FuncName}_*" `
	if ( $#FuncPaths != $argv[${TaskNumIdx}] ) then
		echo "ERROR: $#FuncPaths found for $FuncName. You indicated $argv[${TaskNumIdx}] funcs for this task. Something wrong!" #`expr 6 + $FuncNum`
		exit 1
	endif

end


echo "Done checking on stuff! Good luck having your shit together!"

#################################### Do the actual conversion now! ####################################
### On Anats
foreach AnatNum ( `seq 1 $#AnatPaths` )

	echo "\n**Working on $AnatPaths[${AnatNum}]**\n"
	cd $AnatPaths[${AnatNum}]
	
	if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${AnatNum}.nii ) then
		echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/anat_${AnatNum}.nii already exists! Not overwriting!"
		echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ -type f -name *.nii -delete to delete all NIFTIs in one go."
	else
		dcm2niix_afni -f anat_${AnatNum} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ .
	endif
	
end

### On funcs, if any

foreach FuncNum ( `seq 1 ${NUMBEROFTASKS}` )
	cd ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/

	set TaskNameIdx = `expr 6 + $FuncNum`
	set TaskNumIdx = `expr 6 + $FuncNum + 1`
	set FuncName = ${argv[${TaskNameIdx}]}

	set FuncPaths = ` find ${PROJECTPATH}/${RAWDATAPATH}/${PARTICIPANT}/ -type d -name "*${FuncName}_*" `
	
	foreach FuncNum ( `seq 1 $#FuncPaths`)
		echo "\n**Working on $FuncPaths[${FuncNum}]**\n"
		cd $FuncPaths[${FuncNum}]
	
		if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/${FuncName}_${FuncNum}.nii ) then
			echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/${FuncName}_${FuncNum}.nii already exists! Not overwriting!"
			echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ -type f -name *.nii -delete to delete all NIFTIs in one go."
		else
			dcm2niix_afni -f ${FuncName}_${FuncNum} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/ .
		endif
	end
	
end




