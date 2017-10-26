pro make_input_spectra_fits_table_jobs

	shell_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/shell_files/'
	pro_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/'

	SOLS = ['S0927', 'S1306', 'U1319', 'U0148']
	z_index = dindgen(25)
	local_element = 'SiIV'

	for s = 0, 3 do begin
;		for z = 0, n_elements(z_index) - 1 do begin
		for z = 26, 50 do begin
			z_string = strmid(strtrim(string(z),1),0,1)
			if z gt 9 then z_string = strmid(strtrim(string(z),1),0,2)
			
			shell_file =  shell_path + SOLS[s] + '_' + z_string + '.sh'
			print, shell_file
			;	open the .sh file for writing
				openw, lun, shell_file, /get_lun
					printf, lun, "#!/bin/bash "
					printf, lun, "#$ -S /bin/bash"
					printf, lun, "#$ -cwd"
				;	printf, lun, "#PBS -l nodes=1:ppn=1:licensed"
					printf, lun, "#PBS -q gstar"
					printf, lun, ''
					printf, lun, ''
				
					printf, lun, "idl << !here"
					printf, lun, ''
					printf, lun, ''
				
				
					printf, lun, ''
					printf, lun, ''
					printf, lun, ''
				
					rnew_line = '.rnew '+  pro_path + 'make_input_spectra_fits_table' 
					printf, lun, rnew_line
				
					printf, lun, ""
					printf, lun, ""

					extract_line = 'make_input_spectra_fits_table, ' + z_string + $
									' , ' + ' "' + SOLS[s] + '" ' + ",  'SiIV'  "
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
	endfor



	submit_file = shell_path + 'submit_file'
	openw, lun, submit_file, /get_lun	
		for s = 0, 3 do begin
;			for z = 0, n_elements(z_index) - 1 do begin
			for z = 26, 50 do begin
	
				z_string = strmid(strtrim(string(z),1),0,1)
				if z gt 9 then z_string = strmid(strtrim(string(z),1),0,2)
				printf, lun, '   '
				shell_file = SOLS[s] + '_' + z_string + '.sh'
			
				line =  'qsub  -l walltime=25:55:00   ' + shell_file
				printf, lun,line
			
			
			endfor
		endfor
	close, /all
	print, submit_file



END