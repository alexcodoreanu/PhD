pro make_discover_si4_jobs

	shell_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/shell/'
	pro_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/'

	SOLS = ['S0927', 'S1306', 'U1319', 'U0148']
	column_density_range = dindgen(16)/10 + 12.2

	for s = 0, 3 do begin
		for c = 0, n_elements(column_density_range) do begin
			c_string = strmid(strtrim(string(c),1),0,1)
			if c gt 9 then c_string = strmid(strtrim(string(c),1),0,2)
			
			shell_file =  shell_path + SOLS[s] + '_art_' + c_string + '.sh'
			print, shell_file
			;	open the .sh file for writing
				openw, lun, shell_file, /get_lun
					printf, lun, "#!/bin/bash "
					printf, lun, "#$ -S /bin/bash"
					printf, lun, "#$ -cwd"

					printf, lun, "#PBS -l nodes=1:ppn=1:licensed"
					printf, lun, "#PBS -q sstar"
					printf, lun, ''
				
					printf, lun, "idl << !here"
					printf, lun, ''
					printf, lun, ''
				
				
					printf, lun, ''
					printf, lun, ''
					printf, lun, ''
				
					rnew_line = '.rnew '+  pro_path + 'discover_artificial_si4' 
					printf, lun, rnew_line
				
					printf, lun, ""
					printf, lun, ""

					discover_si4 = 'discover_artificial_si4, ' + string(s) + $
									' , ' + ' ' +string(c)  
					printf, lun, discover_si4
				
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
	endfor



	submit_file = shell_path + 'submit_file'
	openw, lun, submit_file, /get_lun	
		for s = 0, 3 do begin
			for c = 0, n_elements(column_density_range) do begin
				c_string = strmid(strtrim(string(c),1),0,1)
				if c gt 9 then c_string = strmid(strtrim(string(c),1),0,2)
				printf, lun, '   '
				shell_file = SOLS[s] + '_art_' + c_string + '.sh'
			
				line =  'qsub  -l walltime=23:55:00   ' + shell_file
				printf, lun,line
			
			
			endfor
		endfor
	close, /all
	print, submit_file

	




END