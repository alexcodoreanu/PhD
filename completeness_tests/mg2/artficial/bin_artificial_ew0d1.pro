pro bin_artificial_ew0d1

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'

	ew_function_name = "ew_v_bin_function.fits"
	ew_function = mrdfits(ew_function_name, 1)

	pixels = [5, 7, 9, 11, 13, 15]

	ew_bins = dindgen(11.)/10.

	str = { EW: 0.0, $
 					LAMBDA: 0.0, $
 					SIGMA5: 0.0, $
 					SIGMA3: 0.0}
	
	for index = 0, 3 do begin
		index_string = strmid(strtrim(string(index), 1),0, 1)	
		input_name = fits_path + "binned_artificial_ew_0d01_l_28A_" + index_string +  "_all_pixels.fits"
		sol_file = mrdfits(input_name, 1)

		lambda_min = min(sol_file.lambda)
		lambda_max = max(sol_file.lambda)
		
		lambda_steps = uint((lambda_max-lambda_min)/28.)
		lambda_bins = lambda_min + dindgen(lambda_steps)*28.
		
		output_name = fits_path + "binned_artificial_ew_0d1_l_28A_" + index_string +  ".fits"
		output_fits = replicate(str, (n_elements(ew_bins)*n_elements(lambda_bins)*1.3))	
		output_fits[*].lambda = -99.00
		local_counter = 0.0
		
			for e = 0, n_elements(ew_bins) - 1 do begin
				ew_min = ew_bins[e] - 0.001
				ew_max = ew_bins[e] + 0.101
				
				for l = 0, n_elements(lambda_bins) - 1 do begin
					lambda_min = lambda_bins[l] - 5
					lambda_max = lambda_bins[l] + 5
					
					;	get the max number of pixels for the lambda and ew feature
						ew_function_index = where(ew_function.w2796 ge ew_min and ew_function.w2796 lt ew_max and ew_function.lambda ge lambda_min and ew_function.lambda le lambda_max)
						max_pixels =  max(ew_function[ew_function_index].pixels)
			
						if max_pixels eq 5 then max_pixel_value = 5				
						if max_pixels gt 5 and max_pixels le 9 then max_pixel_value = 9
						if max_pixels gt 9 then max_pixel_value = 13
					
					;	now bin across pixels
						sol_file_index = where(sol_file.lambda gt lambda_min and $
																	 sol_file.lambda lt lambda_max and $
																	 sol_file.ew gt ew_min and $
																	 sol_file.ew lt ew_max and $
																	 sol_file.pixels le max_pixel_value );and $
																;	 sol_file.sigma5 gt 0.0 and $
																;	 sol_file.sigma3 gt 0.0 )

						
					
						output_fits[local_counter].EW			 = ew_bins[e]
						output_fits[local_counter].LAMBDA  = lambda_bins[l]
						output_fits[local_counter].SIGMA5  = total(sol_file[sol_file_index].sigma5)/n_elements(sol_file_index)
						output_fits[local_counter].SIGMA3  = total(sol_file[sol_file_index].sigma3)/n_elements(sol_file_index)

						local_counter = local_counter + 1.0
				
						print, index, e, l
						
						
						
				endfor
			endfor
			
			
		print, ' '
		print, ' '	
		non_zero_index = where(output_fits.lambda gt 8000)	
		mwrfits, output_fits[non_zero_index], output_name, /create
		print, output_name	
		print, ' '
	endfor
				
				
END