pro bin_sol_all_pixels



	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
	pixels = [5, 7, 9, 11, 13, 15]
	
	
	
	for index = 0, 3 do begin
		index_string = strmid(strtrim(string(index), 1),0, 1)	

		input_name = fits_path + "binned_ew_0d01_l_28A_5_" + index_string + ".fits"
		temp_file = mrdfits(input_name, 1)
		
		output_name = fits_path + "binned_ew_0d01_l_28A_" + index_string +  "_all_pixels.fits"
		
		
		for z = 1, n_elements(pixels) - 1 do begin
			batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
			if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)


			input_name = fits_path + "binned_ew_0d01_l_28A_" + batch_index + "_" + index_string + ".fits"
			local_file = mrdfits(input_name, 1)
			temp_file = [temp_file, local_file]
			
			
			print, index, z
			
		endfor
		
		print, ' '
		mwrfits, temp_file, output_name, /create
		print, output_name
		print, ' '
		
	endfor









END