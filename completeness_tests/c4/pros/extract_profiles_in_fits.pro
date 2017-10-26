pro extract_profiles_in_fits, cd_index


	profiles_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/profiles/'
	fits_output_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/'
	
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/S0927_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')
	
	new_flux = fltarr(n_elements(f))
	new_flux[*] = 1.00
	
	new_error = fltarr(n_elements(f))
	new_error[*] = 0.001
	
	
;	openw, lun, 'profile_template.dat', /get_lun
;		for i = 0, n_elements(e) - 1 do begin
;			line = string((l[i])) + '  ' + $
;				   string(float(new_flux[i])) + '  ' + $
;	   			   string(float(new_error[i]))
;		
;			printf,lun, line
;	
;		endfor
;	close, /all
	
;	column_density_range = [13.00, 13.50, 14.00]
	b_range = [10.00, 20.00, 30.00, 40.00]

	column_density_range = dindgen(20)/10 + 12.5
	column_density_range = column_density_range[cd_index]
	cd_string = strmid(strtrim(string(cd_index),1),0,1)
	if cd_index gt 9.0 then cd_string = strmid(strtrim(string(cd_index),1),0,2)
	cd_index_string = strmid(strtrim(string(cd_index),1),0,1)
	if cd_index gt 9.0 then cd_index_string = strmid(strtrim(string(cd_index),1),0,2)
	
	b_range = [10.0, 20.0, 30.0, 40.0, 50.0]
	
	redshift_min = 4.29
;	redshift = redshift_min + dindgen(186)*0.01
;	redshift = redshift_min + dindgen(1860)*0.001
	redshift = redshift_min + dindgen(186*4.0)*0.01/4.0

	
	column_density_error = 0.05
	b_error = 5.0
	redshift_error = 0.00001
	
	local_element = 'C IV'
	
	output_fits_name = fits_output_path + 'c4_single_profiles_' + cd_index_string + '.fits'
	
	str = {c_d:0.0, b:0.0, z:0.0, vp:fltarr(n_elements(e))}
	output_fits = replicate(str, n_elements(b_range)*n_elements(redshift))
	
	local_counter = 0.0	
	for c = 0, n_elements(column_density_range) - 1 do begin
		cd_string1 =  strmid(strtrim(string(column_density_range[c]),1),0,2)
		cd_string2 =  strmid(strtrim(string(column_density_range[c]),1),3,2)
		cd_string = cd_string1 + 'd' + cd_string2
		
			for b = 0, n_elements(b_range) - 1 do begin
				b_string1 =  strmid(strtrim(string(b_range[b]),1),0,2)
	;			b_string2 =  strmid(strtrim(string(b_range[b]),1),3,2)
				b_string = b_string1 ; + 'd' + b_string2
		
				for z = 0, n_elements(redshift) - 1 do begin
					z_string1 = strmid(strtrim(string(redshift[z]),1),0,1)
					z_string2 = strmid(strtrim(string(redshift[z]),1),2,4)
					z_string = z_string1 + 'd' + z_string2
			
					output_file =  'c4_' + cd_string + '_' + b_string + '_' + z_string + '.dat'
			
					lambda_min = (redshift[z] + 1.0)*1540.0
					lambda_max = (redshift[z] + 1.0)*1560.0
					
					;	create temp.f26 file
					temp_file = 'temp_c4_' + cd_string + '.f26'
					profile_template = 'profile_template_c4_' + cd_index_string + '.dat'
					
						openw, lun, temp_file, /get_lun
							line = '%% ' + profile_template + '    1     ' + $
								   string(lambda_min) + '      ' + $
								   string(lambda_max) + '   vsig=10.638'
							printf, lun, line
							element_line  = local_element + '    ' + $
											string(redshift[z]) + '    ' + $
											string(redshift_error) + '    ' + $
											string(b_range[b]) + '    ' + $
											string(b_error) + '    ' + $
											string(column_density_range[c]) + '   ' + $
											string(column_density_error)
							printf, lun, element_line
						close, /all
					
						rdgen_command = 'printf "rd ' + profile_template + ' \ngp\n' + temp_file + '\n25\nwt '+ $
										output_file + $
										 '" | /home/eryan/Code/vpfit_directory/rdgen'
			
						spawn, rdgen_command
					
						a = file_info(output_file)
						if a.size lt 1 then begin
							z = z-1
							wait, 0.01
						endif
					
						if a.size gt 0 then begin
							readcol, output_file, lv, fv, ev, vv, /silent
						
							output_fits[local_counter].c_d   = column_density_range[c]
							output_fits[local_counter].b     = b_range[b]
							output_fits[local_counter].z     = redshift[z]
							output_fits[local_counter].vp    = vv
														
							local_counter = local_counter + 1.0
							print, local_counter, n_elements(output_fits.z)
							
							
						endif
						move_command = "mv " + output_file + " /lustre/projects/p036_swin/alexc/completeness_test/c4/profiles/"
						spawn, move_command
					
					
	
				endfor
			
		endfor

	endfor
	
	
	mwrfits, output_fits, output_fits_name, /create
	
END