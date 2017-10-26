pro make_artificial_profiles_no_flux_all_job_files

; procedure = 'add_and_find_abs_systems'


folder_path = "/lustre/projects/p036_swin/alexc/completeness_test/input_spectra/shell/"
pixels = [5, 7, 9, 11, 13, 15]
for z = 0, n_elements(pixels) - 1 do begin
for x = 0, 127 do begin
for index = 0, 3 do begin
	batch_index = strmid(strtrim(string(z), 1),0, 1)
	if z gt 9 then batch_index = strmid(strtrim(string(z), 1),0, 2)

	name_index = strmid(strtrim(string(x), 1),0, 1)
	if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
	if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)

	index_string = strmid(strtrim(string(index), 1),0, 1)	
	
	shell_file = folder_path + "ct_" + $
				 batch_index + "_" + name_index + "_" + index_string + ".sh"

;	shell_file = folder_path + "ct_" + batch_index + "_" + name_index + ".sh"

		;open the .sh file for writing
			openw, lun, shell_file, /get_lun
			printf, lun, "#!/bin/bash "
			printf, lun, "#$ -S /bin/bash"
			printf, lun, "#$ -cwd"
;					printf, lun, "#PBS -l mem=3g"
			printf, lun, "#PBS -l nodes=1:ppn=1:licensed"
			printf, lun, "#PBS -q sstar"
;			printf, lun, "#PBS -q gstar"
			printf, lun, "#PBS -l walltime=6:00:00"
			printf, lun, ""	
			printf, lun, "idl << !here"				
			printf, lun, ""
			printf, lun, ""
			printf, lun, ''
			rnew_line = '.rnew /lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/mg2/add_and_find_abs_systems.pro'
			printf, lun, rnew_line
			printf, lun, ""
			printf, lun, "check = add_and_find_abs_systems(" + batch_index + " , " + name_index + " , " + index_string + ") "
;			printf, lun, "check = make_artificial_profiles_no_flux_job(" + batch_index + " , " + name_index + ") "

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
endfor

submit_file = folder_path + 'submit_file'
openw, lun, submit_file, /get_lun
	for z = 0, n_elements(pixels) - 1 do begin
		for x = 0, 127 do begin
			for index = 0, 3 do begin
			batch_index = strmid(strtrim(string(z), 1),0, 1)
			if z gt 9 then batch_index = strmid(strtrim(string(z), 1),0, 2)

			name_index = strmid(strtrim(string(x), 1),0, 1)
			if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
			if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)

			index_string = strmid(strtrim(string(index), 1),0, 1)	
	
			shell_file =  "ct_" + $
						 batch_index + "_" + name_index + "_" + index_string + ".sh"

		;	shell_file =  "ct_" + batch_index + "_" + name_index + ".sh"
			printf, lun, 'qsub  ', shell_file
			
			endfor
		endfor
	endfor
close, /all




END
