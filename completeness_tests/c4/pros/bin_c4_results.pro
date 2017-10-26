pro bin_c4_results

	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
  sightline      = ['S0927', 'S1306', 'U0148', 'U1319']
	
	input_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/results/'

	sightline = ['S0927', 'S1306', 'U0148', 'U1319']

	redshift_min = 4.29
	redshift = redshift_min + dindgen(186)*0.01
	column_density_range = dindgen(20)/10 + 12.5		
	
	str = {z:0.0, c_d:0.0, s3:0.0, s5:0.0}
;	b_values = [10.0, 20.0, 30.0, 40.0]
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	for s = 0, n_elements(sightline) - 1 do begin	
		sol = sightline[s]
		output_fits_name =input_path +  sol + '_c4_h_acc_cd0d1_z0d01.fits'
		output_fits = $
			replicate(str, (n_elements(redshift) - 1)*n_elements(column_density_range))
	
		local_counter = 0.0
		for c = 0, n_elements(column_density_range) - 1 do begin
			cd_index_string = strmid(strtrim(string(c),1),0,1)
			if c gt 9.0 then cd_index_string = strmid(strtrim(string(c),1),0,2)
	
			input_fits_name  = input_path + 'c4_h_acc_sol_' + sol + '_' + cd_index_string + '.fits'
			input_fits = mrdfits(input_fits_name, 1, /silent)

			for z = 0, n_elements(redshift) - 2 do begin
				local_redshift = redshift[z]
				index = where(input_fits.z gt local_redshift - 0.01/2. and input_fits.z lt local_redshift + 0.01/2. and $
							  input_fits.z gt 0.0 and input_fits.c_d gt 11.)
			
				sum3 = total(input_fits[index].s3)
				sum5 = total(input_fits[index].s5)
			
				output_fits[local_counter].z   = local_redshift
				output_fits[local_counter].c_d = column_density_range[c]
				output_fits[local_counter].s3  = sum3/n_elements(index)
				output_fits[local_counter].s5  = sum5/n_elements(index)

				local_counter = local_counter + 1.0
			;	print, sol, c, z, local_counter
		
		
			endfor
	
		endfor
		mwrfits, output_fits[where(output_fits.z gt 0.0 and output_fits.c_d gt 11.)], output_fits_name, /create
		print, output_fits_name
	endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	for s = 0, n_elements(sightline) - 1 do begin	
		sol = sightline[s]
		output_fits_name = input_path + sol + '_art_c4_h_acc_cd0d1_z0d01.fits'
		output_fits = replicate(str, (n_elements(redshift) - 1)*n_elements(column_density_range))
	
		local_counter = 0.0
	
		for c = 0, n_elements(column_density_range) - 1 do begin
			cd_index_string = strmid(strtrim(string(c),1),0,1)
			if c gt 9.0 then cd_index_string = strmid(strtrim(string(c),1),0,2)
	
			input_fits_name  = input_path + 'c4_art_h_acc_sol_' + sol + '_' + cd_index_string + '.fits'
			input_fits = mrdfits(input_fits_name, 1, /silent)

			for z = 0, n_elements(redshift) - 2 do begin
				local_redshift = redshift[z]
				index = where(input_fits.z gt local_redshift - 0.01/2. and input_fits.z lt local_redshift + 0.01/2.and $
							  input_fits.z gt 0.0 and input_fits.c_d gt 11.)
			
				sum3 = total(input_fits[index].s3)
				sum5 = total(input_fits[index].s5)
			
				output_fits[local_counter].z   = local_redshift
				output_fits[local_counter].c_d = column_density_range[c]
				output_fits[local_counter].s3  = sum3/n_elements(index)
				output_fits[local_counter].s5  = sum5/n_elements(index)

				local_counter = local_counter + 1.0
		;		print, sol, c, z, local_counter
		
		
			endfor
	
		endfor
		mwrfits, output_fits[where(output_fits.z gt 0.0 and output_fits.c_d gt 11.)], output_fits_name, /create
		print, output_fits_name
		
	endfor


END