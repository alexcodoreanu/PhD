

function compress_and_move_bias, tar_name
	
	push_path = "/lustre/projects/p025_swin/tap/cals_forigor/"
	fits_path = "/lustre/projects/p025_swin/pipes/DWF_PIPE/CTIO_FITS/"
	output_path = "/lustre/projects/p025_swin/pipes/arest/DECAM/DEFAULT/rawdata/"
	date_string = '151218'
	
;	tar_name = 'DECam_00502918.tar'

		
	;	get the folder name	which is the tar_name minus the ".tar"
		string_length = strlen(tar_name)
		folder_name = strmid(strtrim(tar_name,1),0,string_length - 4) + "/"
		
	;	get the number of .jp2 files inside the folder as defined by folder_name
	;	and put the output in jp2_files_list
		folder_path = push_path + folder_name
		ls_jp2_command = "ls " + folder_path + "*jp2 > " + folder_path + "jp2_files_list"
		spawn, ls_jp2_command

	;	now read in the jp2_files_list and figure out how many .jp2 files there are
		jp2_files_list_name = folder_path + "jp2_files_list"
		readcol, jp2_files_list_name, jp2_files_list, format = 'A', /silent
			print, ""
			print, ""
			print, "////////////////////////////////////////////////////////////////////////////"
			print, "////////////////////////////////////////////////////////////////////////////"
			print, ""
			print, ""
			print, ""
			print, "In directory: ", folder_path
			print, "There are: ", n_elements(jp2_files_list), "      .jp2 files"
			print, ""
			print, ""
			print, "The next step will launch the decompression jobs"
			print, ""
			print, ""
			print, ""
			print, "////////////////////////////////////////////////////////////////////////////"
			print, "////////////////////////////////////////////////////////////////////////////"
			print, ""
			print, ""
			print, ""
			pipe_loop_check = ''
			print, "Would you like to also run pipeloop on these jobs ?(y/n)"
			read, pipe_loop_check
			check_pipe_yes = str_pos(pipe_loop_check, 'y')
			check_pipe_no = str_pos(pipe_loop_check, 'n')
			print, ""
			print, ""
		

	;	move the .tar file to the pushed sub_folder
		pushed_path = push_path + "pushed/"
		move_command = "mv -f " + tar_name + '  ' + pushed_path
		
;		spawn, move_command
			print, ""
			print, ""
			print, tar_name, " has been moved to CTIO_PUSH/pushed/"
			print, ""
			print, ""


	;	now create shell scripts to launch an individual job for each .jp2 file
	;	this job will take the .jp2 in CTIO_PUSH and change it back to a .fits in CTIO_FITS
	;	
	;			make the same directory in 	CTIO_FITS
	;			create the shell script name
	;			run the j2F commands    ---- this might be a snag due to j2F being a shortcut
	;			open the .fits with mrd_head and identify the OBJECT TAG
	;			rewrite the name of the .fits and then move it to the appropriate CCD subfolder
	
	new_directory_name = fits_path + folder_name
    new_directory_command = "mkdir " + new_directory_name
	spawn, new_directory_command
	
	new_shell_directory_name = new_directory_name + 'shell_scripts'
    new_directory_command = "mkdir " + new_shell_directory_name
	
	spawn, new_directory_command
			print, ""
			print, ""
			print, "The directories:  ", new_directory_name, ' +/shell_scripts'
			print, "have been created"
			print, ""
			print, ""
	
	
	for i = 0, n_elements(jp2_files_list) - 1 do begin
		folder_path_length = strlen(folder_path)
		temporary_file_name = strmid(strtrim(jp2_files_list[i],1),folder_path_length,strlen(jp2_files_list[i]) - folder_path_length)
		temporary_file_name2 = 		temporary_file_name
		;	get the position of each '_' character
			underscore_index = str_pos(temporary_file_name, '_')
	
		;	if there's more than 2 underscores then there's an issue	
			if n_elements(underscore_index) gt 2 then begin
			
				print, ""
				print, "There's more than 2 underscores, the file format should be DECam_obsID_CCD.jp2"
				print, ""
				print, "The file name is: ", jp2_files_list[i]
				print, ""
				print, "Would you like to change the name ? (y/n)  (the file format should be DECam_obsID_CCD.jp2)"
				check = ''
				READ, check
				check_index_yes = str_pos(check, 'y')
				check_index_no = str_pos(check, 'n')
			
					if check_index_yes lt 0.0 and check_index_no lt 0.0 then begin			
						check2 = 0.0
						while check2 eq 0.0 do begin
					
							print, ''
							print, 'Remember, you must input something with "y" for yes or something with "n" for no'
							print, ''
							print, "Would you like to change the name ? (y/n)  (the file format should be DECam_obsID_CCD.jp2)"
							check = ''
							READ, check
							check_index_yes = str_pos(check, 'y')
							check_index_no = str_pos(check, 'n')
							if check_index_yes ge 0.0 or check_index_no ge 0.0 then check2 = 99
					
						endwhile
					endif
			
			
					;	they've said that the name must be changed
						if check_index_yes ge 0.0 then begin
				
							print, ''
							print, 'What would you like the new name to be ?  (the file format should be DECam_obsID_CCD.jp2)'
							new_file_name = ''
							READ, new_file_name
							print, ''
							print, 'Are you happy with the new name ', new_file_name, ' ?(y/n)"'
							print, ''
							check = ''
							READ, check
							check_index_yes2 = str_pos(check, 'y')
							check_index_no2 = str_pos(check, 'n')
						
								if check_index_yes2 lt 0.0 and check_index_no2 lt 0.0 then begin			
									check2 = 0.0
									while check2 eq 0.0 do begin
					
										print, ''
										print, 'Remember, you must input something with "y" for yes or something with "n" for no'
										print, ''
										new_file_name = ''
										READ, new_file_name
										print, 'Are you happy with the new name ', new_file_name, ' ?(y/n)     (the file format should be DECam_obsID_CCD.jp2)'
										check = ''
										READ, check
										check_index_yes3 = str_pos(check, 'y')
										check_index_no3 = str_pos(check, 'n')
										if check_index_yes3 ge 0.0 then check2 = 99
					
									endwhile
								endif
				
							temporary_file_name2 =  new_file_name	
				
						endif
			
					;	they've said that the name doesn't need to be changed
						if check_index_no ge 0.0 then begin
							print, ''
							print, "Okay, you don't want to change the name"
							print, 'Your call ....'
							print, 'But remember that the name sequence is DECam_obsID_CCD.jp2'
							print, ''
							print, ''					
						endif
			
			endif	
		
			;	get the ccd number and obsid by searching for the '_' again
			;	get the position of each '_' character
				underscore_index = str_pos(temporary_file_name, '_')
				if n_elements(underscore_index) ne 2 then begin
					print, ''
					print, ''
					print, ''
					print, ''				
					print, 'You must redefine the .jp2 to have the following structure: DECam_obsID_CCD.jp2'
					print, 'You must redefine the .jp2 to have the following structure: DECam_obsID_CCD.jp2'
					print, 'You must redefine the .jp2 to have the following structure: DECam_obsID_CCD.jp2'
					print, 'You must redefine the .jp2 to have the following structure: DECam_obsID_CCD.jp2'
					print, 'You must redefine the .jp2 to have the following structure: DECam_obsID_CCD.jp2'
					print, 'temporary_file_name =  "DECam_obsID_CCD.jp2"'
					stop
				endif
				
			;	make the shell script name 
				name_length = strlen(temporary_file_name)
				shell_name = new_shell_directory_name + '/' + strmid(strtrim(temporary_file_name,1),0,name_length - 4) + ".sh"
				underscore_index = str_pos(temporary_file_name, '_')
			
			;	get CCD number	
				ccd_max_bound = name_length - 4
				ccd_min_bound = max(underscore_index) + 1
				CCD_number = strmid(strtrim(temporary_file_name,1),ccd_min_bound,ccd_max_bound - ccd_min_bound)
			
			;	get OBS number	
				obs_max_bound = max(underscore_index) - 1
				obs_min_bound = min(underscore_index) + 1
				obs_number = strmid(strtrim(temporary_file_name,1),obs_min_bound,obs_max_bound - obs_min_bound + 1)
			
			
				print, ''
				print, 'Creating decompression job for file ', temporary_file_name, ' with obs_number: ', obs_number, ' and CCD_number: ', CCD_number
				fits_file_name = 'DECam_' + obs_number + '_' + CCD_number + '.fits'
				print, 'Output file is:                     ', fits_file_name
				full_fits_file_name = new_directory_name + fits_file_name
				
					openw, lun, shell_name, /get_lun
		
						printf, lun, "#!/bin/bash "
						printf, lun, "#$ -S /bin/bash"
						printf, lun, "#$ -cwd"
						printf, lun, ""
						printf, lun, ""
					;	cd into the directory where the .jp2 files are
						cd_command = "cd " + folder_path
						printf, lun, cd_command
						printf, lun, ""
						printf, lun, ""
					;	now change the filename 					
					if temporary_file_name ne temporary_file_name2 then begin
						;	move command
						move_command = "mv -f " + temporary_file_name + '  ' + temporary_file_name2
						printf, lun, move_command
					endif	
						printf, lun, ""
						printf, lun, ""
						printf, lun, ""
					;	now uncompress the file
						uncompress_command = "j2f -i " + temporary_file_name + ' -o ' + full_fits_file_name
						printf, lun, uncompress_command
						printf, lun, ""
						printf, lun, ""
						
						
					;	now copy the file over (maybe move it over) from CTIO_FITS to rawdata but add the .object tag
					;	this will be its' own stand alone IDL code
						printf, lun, ""
						
						cd_into_uncompressed_directory = "cd  " + new_directory_name
						printf, lun, cd_into_uncompressed_directory
						printf, lun, ""
						printf, lun, ""
						
						;	start the idl bit
							printf, lun, "idl << !here"
									printf, lun, ""
									
							file_assigment = "fits_file = '" + fits_file_name + "'"
									printf, lun, file_assigment
									printf, lun, ""
									printf, lun, ""
									
							get_header_command = "header = headfits(fits_file)"
									printf, lun, get_header_command
									printf, lun, ""
									printf, lun, ""
									
							get_object_id = "object=strcompress(sxpar( header ,'OBJECT'), /remove_all)"	
							get_filer_string2 = "filterstring2=strsplit(sxpar( header ,'FILTER'), /extract)"
							get_filer_string = "filter=filterstring2[0]"	
									printf, lun, get_object_id
									printf, lun, get_filer_string2
									printf, lun, get_filer_string
									printf, lun, ""
									printf, lun, ""
									
							create_new_name	= "new_name = '" + output_path + "ut" + date_string +"/" +  CCD_number + "/bias" + $
															".ut" + date_string + "." + strmid(strtrim(obs_number,1),2,strlen(obs_number)-2) + $
															"_" + CCD_number + ".fits'"
									printf, lun, create_new_name
									printf, lun, ""
									printf, lun, ""
									
							copy_the_old_fits_to_rawdata_location_with_new_name = "cp_command = 'cp -f ' + fits_file + ' ' + new_name"		
									printf, lun, copy_the_old_fits_to_rawdata_location_with_new_name
									printf, lun, "spawn, cp_command"
									printf, lun, ""
									printf, lun, ""
									
				

									printf, lun, ""
									printf, lun, ""	

							printf, lun, "!here"
					
					
					
						printf, lun, "exit"
					close, /all
	
	endfor	
	
	;	now chmod the shell_scripts so that I can launch the jobs
		chmod_command = "chmod 775 " + new_shell_directory_name + "/*sh "
		spawn, chmod_command
		
	; 	check that the same number of shell scripts as .jp2 files exists
		ls_shell_scripts = "ls " + new_shell_directory_name + "/*sh > " + new_shell_directory_name + "/shell_jobs"
		spawn, ls_shell_scripts
		
		shell_jobs_name = new_shell_directory_name + "/shell_jobs"

		readcol, shell_jobs_name, shell_jobs, format = 'A'
		
			if n_elements(jp2_files_list) ne n_elements(shell_jobs) then begin
			
				print, "There's a different number of shell_scripts than .jp2 files"
				print, "There are ", n_elements(jp2_files_list), " .jp2 files and only"
				print, "          ", n_elements(shell_jobs), " shell scripts"
				print, ""
				print, ""
				print, "The list of all shell_scripts is:"
				print, new_shell_directory_name , "/shell_jobs"
				print, ""
				print, ""
				print, "and the .jp2 files are in:"
				print, folder_path
				print, ""
				print, ""
				print, ""
				print, ""
			
				
			
			endif

	;	create submit file
		submit_file_name = 	new_shell_directory_name + '/submit_jobs'
		openw, lun, submit_file_name, /get_lun
			
			printf, lun, ""
			printf, lun, ""
			
			for i = 0, n_elements(shell_jobs) - 1 do begin
				
				submit_line = "qsub  -q sstar -l walltime=01:55:00  " +  shell_jobs[i]
				printf, lun, submit_line
				printf, lun, ""
				printf, lun, ""
				
			endfor

		close, /all
		print, ""
		print, ""
		print, ""
		print, ""


	; 	submit the jobs
		submit_jobs_command = "source " + submit_file_name
		spawn, submit_jobs_command
		
	;	check the number of jobs running
		print, ""
		print, "waiting one minute"
		print, ""
		print, ""
		print, ""
		print, ""
		wait, 60
		spawn, '(qselect -u acodorea) > list'
		readcol, 'list', l, format=('A'), /silent
		
			while n_elements(l) gt 5.0 do begin
		
				spawn, '(qselect -u acodorea) > list'
				readcol, 'list', l, format=('A'), /silent
				print, n_elements(l), ' jobs out of ', n_elements(shell_jobs), ' still running'
				wait, 2
		
			endwhile
		wait, 20
		print, ''
		print, ''
		print, 'Files are in the raw data directory'
		print, output_path + 'ut' + date_string + '/'
		print, ''
		print, ''
		print, ''


END
