pro bin_artificial_mg2_lambda_ew

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
	pixels = [5, 7, 9, 11, 13, 15]
	
	ew_bins = dindgen(101.)/100.
	str = { EW: 0.0, $
 					INDEX: 0.0, $
 					PIXELS: 0.0, $
 					LAMBDA: 0.0, $
 					SIGMA5: 0.0, $
 					SIGMA3: 0.0}
	
	diff = 0.005
	
	for z = 0, n_elements(pixels) - 1 do begin
		batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
		if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)
		
		for index = 0, 3 do begin
			index_string = strmid(strtrim(string(index), 1),0, 1)	
			
			output_structure = replicate(str, 100000.000)
			output_structure[*].LAMBDA = 0.0
			output_name = fits_path + "binned_artificial_ew_0d01_l_28A_" + batch_index + "_" + index_string + ".fits"
			
			
			input_name = fits_path + "split_artificial_" + batch_index + "_" + index_string + ".fits"
			split_file = mrdfits(input_name, 1)
			
			check_index = where(split_file.lambda gt 7000)
			local_file = split_file[check_index]
			
			lambda_min = min(local_file.lambda)
			lambda_max = max(local_file.lambda)
			
			lambda_steps = uint((lambda_max-lambda_min)/28.)
			lambda_bins = lambda_min + dindgen(lambda_steps)*28.
				
			local_counter = 0.0
			for e = 0, n_elements(ew_bins) - 2 do begin
				ew_index = where(local_file.ew gt (ew_bins[e] - diff) and local_file.ew lt (ew_bins[e+1]))
			
				for l = 0, n_elements(lambda_bins) - 2 do begin
						
					lambda_index = where(local_file[ew_index].lambda gt lambda_bins[l] and local_file[ew_index].lambda le lambda_bins[l + 1])
					if lambda_index[0] lt 0 then stop
					
					
					;	local_file[ew_index[lambda_index]].lambda
					
					output_structure[local_counter].EW = ew_bins[e]
					output_structure[local_counter].INDEX = index
					output_structure[local_counter].PIXELS = pixels[z]
					output_structure[local_counter].LAMBDA = lambda_bins[l]
					output_structure[local_counter].SIGMA5 = total(local_file[ew_index[lambda_index]].sigma5)/n_elements(lambda_index)
					output_structure[local_counter].SIGMA3 = total(local_file[ew_index[lambda_index]].sigma3)/n_elements(lambda_index)
					
					local_counter = local_counter + 1.0
					
				endfor
			endfor
			
			non_zero_index = where(output_structure.lambda gt 70)
			mwrfits, output_structure[non_zero_index], output_name, /create
			print, output_name
			
		endfor
	endfor


END