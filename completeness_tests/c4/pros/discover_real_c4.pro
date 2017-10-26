pro discover_real_c4, sol_index, cd_index

	cd_index_string = strmid(strtrim(string(cd_index),1),0,1)
	if cd_index gt 9.0 then cd_index_string = strmid(strtrim(string(cd_index),1),0,2)
	fits_input_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/'
	input_fits_name = fits_input_path + 'c4_single_profiles_' + cd_index_string + '.fits'
	input_file = mrdfits(input_fits_name, 1)
	
	sightline = ['S0927', 'S1306', 'U0148', 'U1319']
	output_file_name = fits_input_path + 'results/c4_comp_sol_' + sightline[sol_index] + '_' + cd_index_string +'.fits'
	
	minimum = 0.3
	maximum = 5
	
	c4_1548 = 1548.2049
	c4_1550 = 1553.3519
	c4_art  = c4_1548 + 2.*(c4_1550 - c4_1548)

	
	input_file_path = $
		"/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/c4/pros/"
	

	str = {c_d:0.0, b:0.0, z:0.0, s3:0.0, s5:0.0}
	output_fits = replicate(str, n_elements(input_file.z))

	redshift_array = [5.79, 5.99, 5.98, 6.13]
	sol_redshift = redshift_array[sol_index]
	SOL = sightline[sol_index]
	
;	read in the original file in order to get the wavelength array	
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')
	

;	now cycle through each element of the input file
	for i = 0, n_elements(input_file.b) - 1 do begin
		output_fits[i].c_d   = input_file[i].c_d
		output_fits[i].b     = input_file[i].b  
		output_fits[i].z     = input_file[i].z  
		
		altered_flux = f[0:42000]*input_file[i].vp[0:42000]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		result3 = find_c4_absorbers(l, altered_flux, e, sol_redshift, 3.0)
		result3 = result3[sort(result3.X_MIN_1548)]
		index3 = where(result3.EW1548/result3.EW1548_ERR ge 3.0 or $
					  result3.EW1550/result3.EW1550_ERR ge 3.0 and $
					  result3.redshift lt sol_redshift or $
					  result3.EW1548/result3.EW1550 le maximum or $	
					  result3.EW1548/result3.EW1550 ge minimum or $
					  (result3.EW1548 + result3.EW1548_ERR)/(result3.EW1550 + result3.EW1550_ERR) le maximum or $		 
				      (result3.EW1548 - result3.EW1548_ERR)/(result3.EW1550 - result3.EW1550_ERR) le maximum or $		 
					  (result3.EW1548 + result3.EW1548_ERR)/(result3.EW1550 + result3.EW1550_ERR) ge minimum or $		 
					  (result3.EW1548 - result3.EW1548_ERR)/(result3.EW1550 - result3.EW1550_ERR) ge minimum or $
					  result3.NUM_PIXELS gt 3)
	
		
		r3 = result3[index3]	
		sigma3_min  = r3.X_MIN_1548 - 3*0.3*r3.NUM_PIXELS
		sigma3_max  = r3.X_MAX_1548 + 3*0.3*r3.NUM_PIXELS

		check_lambda = (1.0 + input_file[i].z)*c4_1548
		check_index_low  = where(sigma3_min le check_lambda[0])
		check_index_high = where(sigma3_max[check_index_low] ge check_lambda)
		
		if check_index_high[0] ge 0.0 then output_fits[i].s3 = 1.0
		if check_index_high[0] lt 0.0 then output_fits[i].s3 = 0.0
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		result5 = find_c4_absorbers(l, altered_flux, e, sol_redshift, 5.0)
		result5 = result5[sort(result5.X_MIN_1548)]
		index5 = where(result5.EW1548/result5.EW1548_ERR ge 5.0 or $
					  result5.EW1550/result5.EW1550_ERR ge 5.0 or $
					  result5.redshift lt sol_redshift and $
					  result5.EW1548/result5.EW1550 le maximum or $
					  result5.EW1548/result5.EW1550 ge minimum or $
					  (result5.EW1548 + result5.EW1548_ERR)/(result5.EW1550 + result5.EW1550_ERR) le maximum or $		 
				      (result5.EW1548 - result5.EW1548_ERR)/(result5.EW1550 - result5.EW1550_ERR) le maximum or $		 
					  (result5.EW1548 + result5.EW1548_ERR)/(result5.EW1550 + result5.EW1550_ERR) ge minimum or $		 
					  (result5.EW1548 - result5.EW1548_ERR)/(result5.EW1550 - result5.EW1550_ERR) ge minimum or $
					  result5.NUM_PIXELS gt 3)
	
		r5 = result5[index5]
		sigma5_min  = r5.X_MIN_1548 - 3*0.3*r5.NUM_PIXELS
		sigma5_max  = r5.X_MAX_1548 + 3*0.3*r5.NUM_PIXELS
		
		check_index_low  = where(sigma5_min le check_lambda[0])
		check_index_high = where(sigma5_max[check_index_low] ge check_lambda)
		
		if check_index_high[0] ge 0.0 then output_fits[i].s5 = 1.0
		if check_index_high[0] lt 0.0 then output_fits[i].s5 = 0.0
		
		
		print, i, n_elements(input_file.b) - 1
		
	endfor



	mwrfits, output_fits, output_file_name, /create
	print, output_file_name
		



END