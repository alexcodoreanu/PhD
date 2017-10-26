pro bin_artificial_ew0d01_by_index, index

fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_mg2_results/'


pixels = [5,  9,  13]
ew_bins = dindgen(101.)/100.

str = { EW: 0.0, $
		INDEX: 0.0, $
		PIXELS: 0.0, $
		LAMBDA: 0.0, $
		SIGMA5: 0.0, $
		SIGMA3: 0.0, $
		SN2796: 0.0, $
		SN2803: 0.0, $
		EW2796: 0.0, $
		EW2803: 0.0, $
		ERR2796: 0.0, $
		ERR2803: 0.0, $
		USER_SUCCESS_2796: 0.0, $
		USER_FAILURE_2796: 0.0, $
		USER_SUCCESS_2803: 0.0, $
		USER_FAILURE_2803: 0.0}


	index_string = strmid(strtrim(string(index), 1),0, 1)	
	input_name = fits_path + "split_with_human_acceptance_5_" + index_string +  ".fits"
	sol_file = mrdfits(input_name, 1)

	lambda_min = min(sol_file.lambda)
	lambda_max = max(sol_file.lambda)
	
	lambda_steps = uint((lambda_max-lambda_min)/28.)
	lambda_bins = lambda_min + dindgen(lambda_steps)*28.
	
	output_name = fits_path + "binned_artificial_ew_0d01_l_28A_" + index_string +  ".fits"
	output_fits = replicate(str, (n_elements(ew_bins)*n_elements(lambda_bins)*1.3))	
	output_fits[*].lambda = -99.00
	local_counter = 0.0
	
		for e = 0, n_elements(ew_bins) - 2 do begin
			ew_min = ew_bins[e] - 0.001
			ew_max = ew_bins[e + 1] + 0.001
			
			for l = 0, n_elements(lambda_bins) - 2 do begin
				lambda_min = lambda_bins[l]  - 0.001
				lambda_max = lambda_bins[l+1]  + 0.001
				print, e, l, index						
				
				;	now bin across pixels
					sol_file_index = where(sol_file.lambda gt lambda_min and $
								     	   sol_file.lambda le lambda_max and $
								     	   sol_file.ew gt ew_min and $
								     	   sol_file.ew le ew_max and $
								     	 ;  sol_file.pixels le max_pixel_value and $
								     	   sol_file.sigma5 ge 0.0 and $
								     	   sol_file.sigma3 ge 0.0 )

					output_fits[local_counter].EW	   = ew_bins[e]
					output_fits[local_counter].LAMBDA  = lambda_bins[l]
					output_fits[local_counter].SIGMA5  = total(sol_file[sol_file_index].sigma5)/n_elements(sol_file_index)
					output_fits[local_counter].SIGMA3  = total(sol_file[sol_file_index].sigma3)/n_elements(sol_file_index)
					
					output_fits[local_counter].SN2796 = total(sol_file[sol_file_index].SN2796)/n_elements(sol_file_index)
					output_fits[local_counter].SN2803 = total(sol_file[sol_file_index].SN2803)/n_elements(sol_file_index)
					output_fits[local_counter].EW2796 = total(sol_file[sol_file_index].EW2796)/n_elements(sol_file_index)
					output_fits[local_counter].EW2803 = total(sol_file[sol_file_index].EW2803)/n_elements(sol_file_index)
					output_fits[local_counter].ERR2796 = total(sol_file[sol_file_index].ERR2796)/n_elements(sol_file_index)
					output_fits[local_counter].ERR2803 = total(sol_file[sol_file_index].ERR2803)/n_elements(sol_file_index)
				
					output_fits[local_counter].USER_SUCCESS_2796 = total(sol_file[sol_file_index].USER_SUCCESS_2796)/n_elements(sol_file_index)
					output_fits[local_counter].USER_FAILURE_2796 = total(sol_file[sol_file_index].USER_FAILURE_2796)/n_elements(sol_file_index)
					output_fits[local_counter].USER_SUCCESS_2803 = total(sol_file[sol_file_index].USER_SUCCESS_2803)/n_elements(sol_file_index)
					output_fits[local_counter].USER_FAILURE_2803 = total(sol_file[sol_file_index].USER_FAILURE_2803)/n_elements(sol_file_index)
					
					local_counter = local_counter + 1.0
			

			endfor
		endfor
		
		
	print, ' '
	print, ' '	
	non_zero_index = where(output_fits.lambda gt 8000)	
	mwrfits, output_fits[non_zero_index], output_name, /create
	print, output_name	
	print, ' '
	
	
				
				
END





