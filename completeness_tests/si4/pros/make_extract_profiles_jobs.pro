pro make_extract_profiles_jobs
	
	pro_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/'
	column_density_range = dindgen(16)/10 + 12.2
	
	shell_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/shell_files/'
	
	for c = 0, n_elements(column_density_range) - 1 do begin
		cd_string = strmid(strtrim(string(c),1),0,1)
		if c gt 9 then cd_string = strmid(strtrim(string(c),1),0,2)

		shell_file =  shell_path + 'si4_cd_' + cd_string + '.sh'
		print, shell_file
		;	open the .sh file for writing
			openw, lun, shell_file, /get_lun
				printf, lun, "#!/bin/bash "
				printf, lun, "#$ -S /bin/bash"
				printf, lun, "#$ -cwd"
				printf, lun, "idl << !here"
				printf, lun, ''
				printf, lun, ''
				
				printf, lun, "#PBS -l nodes=1:ppn=1:licensed"
				printf, lun, "#PBS -q sstar"

				
				
				printf, lun, ''
				printf, lun, ''
				printf, lun, ''
				
				rnew_line = '.rnew '+  pro_path + 'extract_profiles' 
				printf, lun, rnew_line
				
				printf, lun, ""
				printf, lun, ""

				extract_line = 'extract_profiles, ' + cd_string
				printf, lun, extract_line
				
				printf, lun, ""
				printf, lun, ""
				printf, lun, "!here"
				printf, lun, ""
				printf, lun, ""
				printf, lun, ""
				printf, lun, "exit"
				printf, lun, ""

			close, /all

	endfor


	submit_file = shell_path + 'submit_file'
	openw, lun, submit_file, /get_lun
		for c = 0, n_elements(column_density_range) - 1 do begin
			cd_string = strmid(strtrim(string(c),1),0,1)
			if c gt 9 then cd_string = strmid(strtrim(string(c),1),0,2)

			shell_file = 'si4_cd_' + cd_string + '.sh'
			line =  'qsub  -l walltime=25:55:00   ' + shell_file
			printf, lun,line
			
		endfor
	close, /all
	print, submit_file

END