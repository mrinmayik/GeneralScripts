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
	  echo "						Note: fmaps will be named [participant_id]_[fmap_folder_name].nii"
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

echo "subj_proc_list: $subj_proc_list"
echo ""

#Making sure all the paths exist
if ( ! -d $project/$input_dir ) then
	echo "**ERROR: $project/$input_dir does not exist!"
	exit 1
endif
set study_root_in = $project/$input_dir

if ( ! -d $project/$output_dir ) then
	echo "$project/$output_dir does not exist! Making it!"
	mkdir -p $project/$output_dir
endif
set study_root_out = $project/$output_dir

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
			set modpaths = `echo $modpaths | fmt -1 | sort -n`
			set outpath = $study_root_out/$subj/$modoutpaths[$modc]
			
			#Do they match up with how many are expected based on user-input?
			if ( $#modpaths < $modnums[$modc] ) then
				echo "\nWARNING: Only $#modpaths found. You indicated $modnums[$modc] for $modnames[$modc]."
				echo "           Only the first $modnums[$modc] will be processed!\n"
			endif
			
			#Set how much zero-padding needs to be done based on how many runs are available
			#This is importantt to do because not having leading zeros messes up the order that
			#files are listed in. E.g. run10, run11 will be listed before run1, run2 etc.
			if ( $modnums[$modc] <= 9 ) then
				set d = 2
			else if ( $modnums[$modc] > 9 ) then
				set d = 2
			else if ( $modnums[$modc] > 99 ) then
				set d = 3
			endif

			#Print out a warning for how files will be converted. Let the user make an informed decision
			echo "\nWARNING: The files are sorted in this this way:"
			echo ${modpaths[*]} | tr " " "\n"
			echo "Make sure you don't need to zero-pad your filenames!"

			#Go through each folder
			foreach runnum ( `count -digits $d 1 $modnums[$modc] ` ) #$modpaths
				
				echo "\n************************* Now on ${modnames[${modc}]}: run ${runnum} *************************" #
				
				set rundir = $modpaths[$runnum]
				echo "Converting $rundir"
                
				#new scanner saves dcms 2 folders deep in the run folder, so look for the actual dcms
				#if you give the whole path in find, it'll return the whole path
				set dcmpath = `find $rundir -type f -name "*$dcm_string*" | head -n 1` #$study_root_in/$subj/$rundir
                #get just the name oft he folder
                set dcmdir = `dirname $dcmpath`
                
				set niidirname = `basename $rundir`
								
                #Set name of NIFTI based on whether we are working with funcs or not
                if ( $modnames[$modc] == $funcName ) then
                    set nii_name = ${subj}_task-${funcName}_run-${runnum}_bold
                else if ( $modnames[$modc] == fmap ) then
                    set nii_name = ${subj}_task-${niidirname}_run-${runnum}_bold
                else				
					set nii_name = ${subj}_run-${runnum}_$modnames[$modc]
				endif
					
				echo "NIFTI will be called ${nii_name}.nii"
				
				cd $rundir
				
				cd $dcmdir
				
				#Reconstruct if NIFTIs don't already exist
				if ( -f  $outpath/${nii_name}.nii ) then
					if ( $redo == 0 ) then 
						echo "Warning: $outpath/${nii_name}.nii already exists! Not overwriting!"
						echo "Use find $outpath/ -type f -name *.nii -delete to delete all NIFTIs in one go."
						set convert = 0 #should dcm2niix be run?
					else if ( $redo == 1 ) then
						echo "Warning: $outpath/${nii_name}.nii already exists and redo set to 1! Deleting NIFTI!"
						rm $outpath/${nii_name}.*
						set convert = 1
					endif
				else if ( ! -f  $outpath/${nii_name}.nii ) then
					if ( ! -d $outpath/ ) then
						echo "$outpath/ does not exist! Making it!"
						mkdir -p $outpath/
					endif #check if output folder exists
					set convert = 1
				endif #check if NIFTIs already exist
				if ( $convert == 1 ) then 
					dcm2niix_afni -f ${nii_name} -o $outpath/ $dcmdir
				endif #check if all the conditions are right to run dcm2niix
				@ runnum ++ #increment run number
			end #go through runs of modality
		endif #check whether the user turned conversion of this modality on
	end #go through all modalities
end #go through all subjects
	
	
exit