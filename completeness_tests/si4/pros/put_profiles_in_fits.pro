pro put_profiles_in_fits

	spec_name = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/auto_comparison_plots/" + $
		"fit_spectra/S1306_total_mg2_fit_spectra.dat"
	readcol, spec_name, lambda, flux, err, vp, format=('D, D, D, D'), /silent

    redshift_min = 4.91
 	redshift = redshift_min + dindgen(122)*0.01
	column_density_range = [12.50, 13.00, 13.50]
	b_range = [10.00 , 20.00 , 30.00 , 40.00]

	
	si4_path = $
		"/lustre/projects/p036_swin/alexc/completeness_test/si4/profiles/"
	
	output_fits_name =  'si4_single_profiles.fits'
	str = {c_d:0.0, b:0.0, z:0.0, vp:fltarr(n_elements(err))}
	output_fits = replicate(str, n_elements(column_density_range)*n_elements(b_range)*n_elements(redshift))
		
	str_counter = 0.0	
	for c = 0, n_elements(column_density_range) - 1 do begin
		cd_string1 =  strmid(strtrim(string(column_density_range[c]),1),0,2)
		cd_string2 =  strmid(strtrim(string(column_density_range[c]),1),3,2)
		cd_string = cd_string1 + 'd' + cd_string2
		
			for b = 0, n_elements(b_range) - 1 do begin
				b_string1 =  strmid(strtrim(string(b_range[b]),1),0,2)
				b_string2 =  strmid(strtrim(string(b_range[b]),1),3,2)
				b_string = b_string1 + 'd' + b_string2
		
				for z = 0, n_elements(redshift) - 1 do begin
					z_string1 = strmid(strtrim(string(redshift[z]),1),0,1)
					z_string2 = strmid(strtrim(string(redshift[z]),1),2,3)
					z_string = z_string1 + 'd' + z_string2
		
					input_file = si4_path +  'si4_cd_' + cd_string + '_b_' + b_string + '_z_' + z_string + '.dat'

					readcol, input_file, lv, fv, ev, vv, /silent
				
					output_fits[str_counter].c_d   = column_density_range[c]
					output_fits[str_counter].b     = b_range[b]
					output_fits[str_counter].vp    = vv[0:n_elements(err) - 1]
					output_fits[str_counter].z     = redshift[z]
					
					print, str_counter, n_elements(output_fits.b)
						
					str_counter = str_counter + 1.0
					
				endfor
			
		endfor

	endfor
	
	
	mwrfits, output_fits, output_fits_name, /create
	
END