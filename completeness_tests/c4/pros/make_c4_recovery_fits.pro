pro make_c4_recovery_fits

	c4_1548 = 1548.2049
	c4_1550 = 1550.77845
	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
  sightline = ['S0927', 'S1306', 'U0148', 'U1319']

	output_str = {column_density:0.0, b:0.0, lambda:0.0, s3:0.0, s5:0.0}

	input_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/results/'

	for s = 0, n_elements(sightline) - 1 do begin
		SOL = sightline[s]		
		input_file_name = input_path + 'r_c4_' + SOL + '_z_index_0.fits'
		
		sol_fits = mrdfits(input_file_name, 1, /SILENT)
		
		output_fits_name = input_path + 'r_c4_' + SOL + '_all.fits'
		output_file = replicate(output_str, 51.*n_elements(sol_fits.b)*n_elements(sol_fits[0].s3))
			
		for z = 1, 50 do begin
			z_index_string =  strmid(strtrim(string(z),1),0,1)
			if z gt 9.0 then z_index_string =  strmid(strtrim(string(z),1),0,2)
	
			output_file_name = input_path + 'r_c4_' + SOL + '_z_index_' + z_index_string + '.fits'
			temp_fits = mrdfits(output_file_name, 1, /SILENT)
			sol_fits = [sol_fits, temp_fits]
	
		endfor
		
		
		counter = 0.0
		for i = 0, n_elements(sol_fits.b) - 1 do begin
			for a = 0, n_elements(sol_fits[i].redshift) - 1 do begin
				output_file[counter].column_density = sol_fits[i].column_density
				output_file[counter].b              = sol_fits[i].b
				output_file[counter].lambda         = (1. + sol_fits[i].redshift[a])*c4_1548
				output_file[counter].s3             = sol_fits[i].s3[a]
				output_file[counter].s5             = sol_fits[i].s5[a]
				
				counter = counter + 1.0
				
			endfor
		endfor
		
		mwrfits, output_file, output_fits_name, /create
		print, output_fits_name
		
		
	endfor



END







