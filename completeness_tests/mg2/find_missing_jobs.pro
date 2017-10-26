pro find_missing_jobs

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
	shell_path = "/lustre/projects/p036_swin/alexc/completeness_test/input_spectra/shell/"
	pixels = [5, 7, 9, 11, 13, 15]
	
	missing_jobs_file = shell_path + 'missing_jobs'
	openw, lun, missing_jobs_file, /get_lun
		for z = 0, n_elements(pixels) - 1 do begin
			for x = 0, 99 do begin
				for index = 0, 3 do begin
					batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
					if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)

					name_index = strmid(strtrim(string(x), 1),0, 1)
					if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
					if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)

					index_string = strmid(strtrim(string(index), 1),0, 1)	

					shell_file = shell_path + "ct_" + $
								 batch_index + "_" + name_index + "_" + index_string + ".sh"

					fits_file = fits_path + "rf_" + $
								 batch_index + "_" + name_index + "_" + index_string + ".fits"

					result = file_test(fits_file)
					if result lt 1 then begin
						printf, lun, ' '
						printf, lun, ' '
						line = 'qsub ' + "ct_" + $
								 batch_index + "_" + name_index + "_" + index_string + ".sh"
					  printf, lun, line
						print, line
	
					endif

				endfor
			endfor
		endfor
	close, /all

END