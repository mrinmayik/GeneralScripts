#!/bin/tcsh -f

########################################################################################################################################################################
# This is a general purpose script meant to reconstruct DICOMs. It takes in information about the paths, and the number of functionals etc
# Written by Mrinmayi (mrinmayi@uwm.edu)
########################################################################################################################################################################

module load /sharedapps/LS/psych_imaging/modulefiles/afni/07.17.2019


#Initialise some stuff
set project = 0
set input_dir = sourcedata
set output_dir = rawdata

set T1Data = 0
set T2Data = 0
set fmap = 0
set func = 0
set T1Num = 0
set T2Num = 0
set fmapNum = 0
set funcName = 0
set funcNum = 0

set dcm_string = .dcm

set redo = 0
#The name of this script
set prog = `basename $0`
#List of subjects to reconstruct
set subj_proc_list = ()


# ======================================================================
# process command-line arguments
set ac = 1
while ( $ac <= $#argv )
   if ( "$argv[$ac]" == "-help" ) then
      echo "$prog       - Convert dcms and puts them in BIDs compliant format"
      echo ""
      echo "usage: $prog [options...] subj subj ..."
      echo ""
      echo "options specific to this script"
      echo ""
	  echo "  -project PATH     : path to project folder that you're working on"
      echo "  -input_dir DIR    : folder in project path where DICOM folders are stored"
	  echo "						default: [project]/sourcedata"
      echo "  -output_dir DIR   : folder in project path where you want the NIFTIs"
	  echo "						default: [project]/rawdata"
	  echo "  -T1Data NUM    	: how many T1s you have"
	  echo "						Note: make sure your T1 folders are called *T1w*"
	  echo "						Note: T1s will be named [participant_id]_[T1_folder_name].nii"
	  echo "  -T2Data NUM  		: how many T2s you have"
	  echo "						Note: make sure your T2 folders are called *T2w*"
	  echo "						Note: T2s will be named [participant_id]_[T2_folder_name].nii"
  	  echo "  -fmap NUM  		: how many fieldmaps you have"
	  echo "						Note: make sure your fmap folders are called *fmap*"
	  echo "						Note: T2s will be named [participant_id]_[fmap_folder_name].nii"
	  echo "  -func NAME NUM    : name of the task you're converting followed by how many runs you have"
      echo "  -dcm_string NAME  : string in DICOM directory that will be used for looking for dicoms"
	  echo "						default: *dcm"
      echo ""
      echo "general options"
      echo ""
      echo "  -help             : show help and exit"
      echo "  -redo             : (delete previous and) re-create results"
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
   else if ( "$argv[$ac]" == "-output_dir" ) then
      @ ac ++
      if ( $ac > $#argv ) then
         echo "** -output_dir: missing argument"
         exit 1
      endif
      set output_dir = $argv[$ac]
   else if ( "$argv[$ac]" == "-T1Data" ) then
      set T1Data = 1 #do T1
	  @ ac ++
      if ( $ac > $#argv ) then
         echo "** -T1Data: missing argument"
         exit 1
      endif
      set T1Num = $argv[$ac]
   else if ( "$argv[$ac]" == "-T2Data" ) then
      set T2Data = 1 #do T2
	  @ ac ++
      if ( $ac > $#argv ) then
         echo "** -T2Data: missing argument"
         exit 1
      endif
      set T2Num = $argv[$ac]
   else if ( "$argv[$ac]" == "-fmap" ) then
      set fmap = 1 #do fmap
	  @ ac ++
      if ( $ac > $#argv ) then
         echo "** -fmap: missing argument"
         exit 1
	  endif
      set fmapNum = $argv[$ac]
   else if ( "$argv[$ac]" == "-func" ) then
      set func = 1 #do func

	  @ ac ++
      if ( $ac > $#argv ) then
         echo "** -func: missing argument"
         exit 1
      endif      
      set funcName = $argv[$ac]
	  
	  @ ac ++
      if ( $ac > $#argv ) then
         echo "** -func: missing argument"
         exit 1
      endif
      set funcNum = $argv[$ac]
   else if ( "$argv[$ac]" == "-dcm_string" ) then
      @ ac ++
      if ( $ac > $#argv ) then
         echo "** -dcm_string: missing argument"
         exit 1
      endif
      set dcm_string = $argv[$ac]
   else if ( "$argv[$ac]" == "-redo" ) then
      set redo = 1
   else
      # everything else should be a subject
      set subj_proc_list = ( $argv[$ac-] )
      break
   endif
   @ ac ++
end
echo $dcm_string
echo "subj_proc_list: $subj_proc_list"

#Making sure all the paths exist
if ( ! -d $project/$input_dir ) then
	echo "**ERROR: $project/$input_dir does not exist!"
	exit 1
endif
set study_root_in = $project/$input_dir
echo "study_root_in: $study_root_in\n"
if ( ! -d $project/$output_dir ) then
	echo "$project/$output_dir does not exist! Making it!"
	mkdir -p $project/$output_dir
endif
set study_root_out = $project/$output_dir
echo "study_root_out: $study_root_out\n"

#Check that participant list is provided
if ( $subj_proc_list == all ) then
	cd $study_root_in
	set $subj_proc_list = ( sub-* )
else if ( $#subj_proc_list == 0 ) then
	echo "**ERROR: no subject list provided"
	echo "** if you want to do all subjects enter all"
	echo "      and make sure folders are named sub-* in $study_root_in"
	exit 1
endif
echo "==Made it here=="

#Setup some arrays so that you can loop over T1, T2, fmap reconstruction
set moddo = ( $T1Data $T2Data $fmap $func )
set modnames = ( T1w T2w fmap $funcName )
set modnums = ( $T1Num $T2Num $fmapNum $funcNum )
set modoutpaths = ( anat anat fmap func )


###Actually start dealing with subjects
foreach subj ( $subj_proc_list )
	cd $study_root_in/$subj
	foreach modc ( `seq 1 $#moddo` )
		#Did the user turn on this modality?
		if ( $moddo[$modc] == 1 ) then
			set modpaths = ` find $study_root_in/$subj -type d -name "*$modnames[$modc]*" `
			echo "\t\tmodpaths: $modpaths\n"
			#Do they match up with how many are expected based on user-input?
			if ( $#modpaths < $modnums[$modc] ) then
				echo "\nERROR: Only $#modpaths found. You indicated $modnums[$modc] for $modnames[$modc]. Something wrong!\n"
				exit 1
			endif
			
			set runnum = 1
			#Go through each folder
			foreach rundir ( $modpaths )
				#Get the name of the folder. This will be used to name in the NIFTI
				set rundirname = `basename $rundir`
				echo "\t\trundirname: $rundirname\n"
				echo "NIFTI will be called ${subj}_run-${runnum}_$modnames[$modc].nii"
				
				cd $rundir
				#new scanner saves dcms 2 folders deep in the run folder, so look for the actual dcms
				#if you give the whole path in find, it'll return the whole path
				set dcmpath = `find $rundir -type f -name "*$dcm_string*" | head -n 1` #$study_root_in/$subj/$rundir
				echo "\t\tdcmpath: $dcmpath\n"
				#get just the name oft he folder
				set dcmdir = `dirname $dcmpath`
				echo "\t\tdcmdir: $dcmdir\n"
				cd $dcmdir

				#Reconstruct if NIFTIs don't already exist
				if ( -f  $study_root_out/$subj/$modoutpaths[$modc]/$subj-$modnames[$modc]_$rundirname.nii ) then
					echo "Warning: $study_root_out/$subj/$modoutpaths[$modc]/$subj-$modnames[$modc]_$rundirname.nii already exists! Not overwriting!"
					echo "Use find $study_root_out/$subj/$modoutpaths[$modc]/ -type f -name *.nii -delete to delete all NIFTIs in one go."
				else
					if ( ! -d $study_root_out/$subj/$modoutpaths[$modc] ) then
						echo "$study_root_out/$subj/$modoutpaths[$modc] does not exist! Making it!"
						mkdir -p $study_root_out/$subj/$modoutpaths[$modc]
					endif #check if output folder exists
					
					dcm2niix_afni -f ${subj}_run-${runnum}_$modnames[$modc] -o $study_root_out/$subj/$modoutpaths[$modc] $dcmdir
				endif #check if NIFTIs already exist
				@ runnum ++ #increment run number
			end #go through runs of modality
		endif #check whether the user turned conversion of this modality on
	end #go through all modalities
end #go through all subjects
	
	
exit

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
	
	if ( ! -d ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ ) then
		echo "${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ does not exist! Making it!"
		mkdir ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/
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
		foreach FuncNumber ( `seq 1 $#FuncPaths`)
			echo "\n**Working on $FuncPaths[${FuncNumber}]**\n"
			cd $FuncPaths[${FuncNumber}]
	
			if ( -f  ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/sub-${PARTICIPANT}_${FuncName}_${FuncNumber}.nii ) then
				echo "Warning: ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/sub-${PARTICIPANT}_${FuncName}_${FuncNumber}.nii already exists! Not overwriting!"
				echo "Use find ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func/ -type f -name *.nii -delete to delete all NIFTIs in one go."
			else
				dcm2niix_afni -f sub-${PARTICIPANT}_${FuncName}_${FuncNumber} -o ${PROJECTPATH}/${OUTPUTPATH}/${PARTICIPANT}/func .
			endif
		end
	end
	
endif




