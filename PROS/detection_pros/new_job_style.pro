pro  new_job_style

begin_time = systime()

 	original_path = '/lustre/projects/p036_swin/alexc/completeness_test/individual_profiles/original_spectra/'
 	original_spectra =original_path[0] +  ['s0927_combined_spectra.dat',  'u0148_combined_spectra.dat','s1306_combined_spectra.dat',  'u1319_combined_spectra.dat']
	
	
	mg2_2796 = 2796.3542699


	local_spectra = '/lustre/projects/p036_swin/alexc/completeness_test/input_spectra/system_missing_completeness_test_batch_file_1_28.fits'
	spec_fits = mrdfits(local_spectra, 1)    

	new_str = {ew:0.0, pixels:0.0, lambda:fltarr(128), sigma3:fltarr(128), sigma5:fltarr(128)}	
	pass_structure = replicate(new_str, n_elements(spec_fits.EW))		
    pass_structure_name = "/lustre/projects/p036_swin/alexc/completeness_test/pros/system_missing_completeness_find_batch_1_file_28.fits"
	
	
		for x = 0, n_elements(spec_fits.EW) - 1 do begin
			
			print, x, n_elements(spec_fits.EW)
			pass_structure[x].ew = spec_fits[x].ew		
			pass_structure[x].pixels = spec_fits[x].pixels		

			lambda_starting_point_vector = spec_fits[x].LAMBDA
			sigma_3 = fltarr(n_elements(lambda_starting_point_vector))
			sigma_3[*] = 0.0
		
			spectra_index = spec_fits[x].INDEX
			readcol, original_spectra[spectra_index], l, f, e, /silent

 			sigma_3_result = find_mg2_absorbers(l, spec_fits[x].flux[dindgen(n_elements(l))], e,  5.7 , 3.0)	
			
					
 			sigma_5_result = find_mg2_absorbers(l, spec_fits[x].flux[dindgen(n_elements(l))], e,  5.7 , 5.0)
					
	
			;	sort sigma results by X_MIN_2796 increasing index
			sort_sigma3_index = sort(sigma_3_result.X_MIN_2796)


					sigma3_min_index = value_locate(sigma_3_result[sort_sigma3_index].X_MIN_2796, lambda_starting_point_vector)
					sigma3_min = sigma_3_result[sort_sigma3_index[sigma3_min_index]].X_MIN_2796
			
					sigma3_max_index = value_locate(l, sigma3_min)
					sigma3_max = l[sigma3_max_index + sigma_3_result[sort_sigma3_index[sigma3_min_index]].NUM_PIXELS]
			
					diff3 = sigma3_max - lambda_starting_point_vector
					ind3 = where(diff3 ge 0.0)
			
					new_sigma_3 = fltarr(n_elements(lambda_starting_point_vector))
					new_sigma_3[*] = 0.0
					new_sigma_3[ind3] = 1.0
	
	
			sort_sigma5_index = sort(sigma_5_result.X_MIN_2796)


					sigma5_min_index = value_locate(sigma_5_result[sort_sigma5_index].X_MIN_2796, lambda_starting_point_vector)
					sigma5_min = sigma_5_result[sort_sigma5_index[sigma5_min_index]].X_MIN_2796
	
					sigma5_max_index = value_locate(l, sigma5_min)
					sigma5_max = l[sigma5_max_index + sigma_5_result[sort_sigma5_index[sigma5_min_index]].NUM_PIXELS]
	
					diff5 = sigma5_max - lambda_starting_point_vector
					ind5 = where(diff5 ge 0.0)
	
					new_sigma_5 = fltarr(n_elements(lambda_starting_point_vector))
					new_sigma_5[*] = 0.0
					new_sigma_5[ind5] = 1.0
			
			
				
			
			pass_structure[x].sigma3 = new_sigma_3
			pass_structure[x].sigma5 = new_sigma_5
			
			pass_structure[x].lambda = lambda_starting_point_vector
			
			
		endfor
		
		
	close, /all	
	mwrfits, pass_structure, pass_structure_name, /create
	
	end_time = systime()
	print, 'started at: ', begin_time
	print, 'ended at: ', end_time
	
END		

