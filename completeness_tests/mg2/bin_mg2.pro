pro bin_mg2

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
	pixels = [5, 7, 9, 11, 13, 15]
	

	for z = 0, n_elements(pixels) - 1 do begin
		batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
		if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)
		
		for index = 0, 3 do begin
			index_string = strmid(strtrim(string(index), 1),0, 1)	
			
			temp_file_name = fits_path + "rf_" + batch_index + "_" + index_string + "_0.fits"
			temp_file = mrdfits(temp_file_name, 1)	 
			
			output_name =  fits_path + "unbinned_" + batch_index + "_" + index_string + ".fits"
			
			for x = 1, 99 do begin
				name_index = strmid(strtrim(string(x), 1),0, 1)
				if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
				if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)
		
				fits_file = fits_path + "rf_" + $
							 batch_index + "_" + name_index + "_" + index_string + ".fits"
				
				local_file = mrdfits(fits_file, 1)
				temp_file = [temp_file, local_file]
				
				print, z, index, x
			endfor
			
			mwrfits, temp_file, output_name, /create
			print, output_name
			
		endfor
	endfor





END