pro discover_si4, z_index, sol_index
	
	minimum = 0.2	
	maximum = 4
	
	si4_1393 = 1393.76018
	si4_1402 = 1402.77291
	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
  	sightline = ['S0927', 'S1306', 'U0148', 'U1319']
	
	sol_redshift = redshift_array[sol_index]
	SOL = sightline[sol_index]
	
;	read in the original file in order to get the wavelength array	
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')
	
	
	z_index_string =  strmid(strtrim(string(z_index),1),0,1)
	if z_index gt 9.0 then z_index_string =  strmid(strtrim(string(z_index),1),0,2)
	
;	read in the fits array with all of the modified spectra
	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/'
	input_file_name = fits_path + 'si4_' + SOL + '_z_index_' + z_index_string + '.fits'
	input_file = mrdfits(input_file_name, 1)

;	create the output file
	output_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/results/'
	output_file_name = output_path + 'r_si4_' + SOL + '_z_index_' + z_index_string + '.fits'
	str = {column_density:0.0, b:0.0, redshift:fltarr(25), s3:fltarr(25), s5:fltarr(25)}
	output_file = replicate(str, n_elements(input_file.b))


;	now cycle through each element of the input file
	for i = 0, n_elements(input_file.b) - 1 do begin
		output_file[i].column_density = input_file[i].column_density
		output_file[i].b = input_file[i].b
		output_file[i].redshift = input_file[i].redshift
		
		check_lambda = (1. + output_file[i].redshift)*si4_1393
		
		result3 = find_si4_absorbers(l, input_file[i].flux, e, sol_redshift, 3.0)
		index3 = where(result3.EW1393/result3.EW1393_ERR ge 3.0 or $
					  result3.EW1402/result3.EW1402_ERR ge 3.0 and $
					  result3.redshift lt sol_redshift or $
					  result3.EW1393/result3.EW1402 le maximum or $	
					  result3.EW1393/result3.EW1402 ge minimum or $
					  (result3.EW1393 + result3.EW1393_ERR)/(result3.EW1402 + result3.EW1402_ERR) le maximum or $		 
				      (result3.EW1393 - result3.EW1393_ERR)/(result3.EW1402 - result3.EW1402_ERR) le maximum or $		 
					  (result3.EW1393 + result3.EW1393_ERR)/(result3.EW1402 + result3.EW1402_ERR) ge minimum or $		 
					  (result3.EW1393 - result3.EW1393_ERR)/(result3.EW1402 - result3.EW1402_ERR) ge minimum or $
					  result3.NUM_PIXELS gt 4)
	
		
		r3 = result3[index3]	
		sigma3_min  = r3.X_MIN_1393 - 3*0.3*r3.NUM_PIXELS
		sigma3_max  = r3.X_MAX_1393 + 3*0.3*r3.NUM_PIXELS

			
		for x = 0, n_elements(check_lambda) - 1 do begin
			check_index = where(check_lambda[x] ge sigma3_min and check_lambda[x] le sigma3_max)
			if max(check_index) ge 0.0 then output_file[i].s3[x] = 1.0
			if max(check_index) lt 0.0 then output_file[i].s3[x] = 0.0

		endfor
		
		
		
		result5 = find_si4_absorbers(l, input_file[i].flux, e, sol_redshift, 5.0)
		index5 = where(result5.EW1393/result5.EW1393_ERR ge 5.0 or $
					  result5.EW1402/result5.EW1402_ERR ge 5.0 or $
					  result5.redshift lt sol_redshift and $
					  result5.EW1393/result5.EW1402 le maximum or $
					  result5.EW1393/result5.EW1402 ge minimum or $
					  (result5.EW1393 + result5.EW1393_ERR)/(result5.EW1402 + result5.EW1402_ERR) le maximum or $		 
				      (result5.EW1393 - result5.EW1393_ERR)/(result5.EW1402 - result5.EW1402_ERR) le maximum or $		 
					  (result5.EW1393 + result5.EW1393_ERR)/(result5.EW1402 + result5.EW1402_ERR) ge minimum or $		 
					  (result5.EW1393 - result5.EW1393_ERR)/(result5.EW1402 - result5.EW1402_ERR) ge minimum or $
					  result5.NUM_PIXELS gt 4)
	
		r5 = result5[index5]
		sigma5_min  = r5.X_MIN_1393 - 3*0.3*r5.NUM_PIXELS
		sigma5_max  = r5.X_MAX_1393 + 3*0.3*r5.NUM_PIXELS

			
		for x = 0, n_elements(check_lambda) - 1 do begin
			check_index = where(check_lambda[x] ge sigma5_min and check_lambda[x] le sigma5_max)
			if max(check_index) ge 0.0 then output_file[i].s5[x] = 1.0
			if max(check_index) lt 0.0 then output_file[i].s5[x] = 0.0

		endfor
		
	endfor



	mwrfits, output_file, output_file_name, /create
	print, output_file_name
		
	

END