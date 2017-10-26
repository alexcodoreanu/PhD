pro split_mg2


	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
	pixels = [5, 7, 9, 11, 13, 15]
	
	str = { EW: 0.0, $
 					INDEX: 0.0, $
 					PIXELS: 0.0, $
 					LAMBDA: 0.0, $
 					SIGMA5: 0.0, $
 					SIGMA3: 0.0}


	for z = 0, n_elements(pixels) - 1 do begin
		batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
		if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)
		
		for index = 0, 3 do begin
			index_string = strmid(strtrim(string(index), 1),0, 1)	
			input_name =  fits_path + "unbinned_" + batch_index + "_" + index_string + ".fits"
			unbnned_file = mrdfits(input_name, 1)
			
			split_file = replicate(str, 128.00*n_elements(unbnned_file.ew))
			output_name = fits_path + "split_" + batch_index + "_" + index_string + ".fits"
			
			local_counter = 0.0
			for i = 0, n_elements(unbnned_file.ew) - 1 do begin
				for x = 0, 127 do begin
				
					split_file[local_counter].EW				= unbnned_file[i].ew		
					split_file[local_counter].INDEX     = unbnned_file[i].index
					split_file[local_counter].PIXELS    = unbnned_file[i].pixels
					split_file[local_counter].LAMBDA    = unbnned_file[i].lambda[x]
					split_file[local_counter].SIGMA5    = unbnned_file[i].sigma5[x]
					split_file[local_counter].SIGMA3    = unbnned_file[i].sigma3[x]
					
					local_counter = local_counter + 1.0
					
				endfor
			endfor
			
			mwrfits, split_file, output_name, /create
			print, output_name
			
		endfor
	endfor





END