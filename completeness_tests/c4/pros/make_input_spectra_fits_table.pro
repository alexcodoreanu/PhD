pro make_input_spectra_fits_table, z_index, SOL, local_element

	profiles_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/profiles/'
	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/'
	
	z_index_string =  strmid(strtrim(string(z_index),1),0,1)
	if z_index gt 9.0 then z_index_string =  strmid(strtrim(string(z_index),1),0,2)
	
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')
	
	new_flux = fltarr(n_elements(f))
	new_flux[*] = 1.00
	
	new_error = fltarr(n_elements(f))
	new_error[*] = 0.001
	
	template_file = SOL + '_c4_' + z_index_string + '.dat'
	openw, lun, template_file , /get_lun
		for i = 0, n_elements(e) - 1 do begin
			line = string((l[i])) + '  ' + $
				   string(float(new_flux[i])) + '  ' + $
	   			   string(float(new_error[i]))
		
			printf,lun, line
	
		endfor
	close, /all
	

	temp = SOL + '_c4_' + z_index_string + '.f26'
	
	column_density_range = dindgen(20)/10 + 12.5
	column_density_error = 0.05
	
	b_range = [10.0 , 20.0 , 30.0 , 40.0 , 50.0 , 60.0]
	b_error = 5.0
	

	redshift_min = 4.29
	redshift = redshift_min + z_index*0.001 + dindgen(37)*0.05
	
	redshift_error = 0.00001
	
	str = {column_density:0.0, b:0.0, redshift:fltarr(37), flux:fltarr(n_elements(f))}
	structure = replicate(str, n_elements(column_density_range)*n_elements(b_range)*2)	
	structure[*].redshift = redshift
	
	output_name = fits_path + 'c4_' + SOL + '_z_index_' + z_index_string + '.fits'
	
	counter = 0.0
	
	for c = 0, n_elements(column_density_range) - 1 do begin
		cd_string1 =  strmid(strtrim(string(column_density_range[c]),1),0,2)
		cd_string2 =  strmid(strtrim(string(column_density_range[c]),1),3,2)
		cd_string = cd_string1 + 'd' + cd_string2
		
		for b = 0, n_elements(b_range) - 1 do begin			
			
			b_string1 =  strmid(strtrim(string(b_range[b]),1),0,2)
			b_string2 =  strmid(strtrim(string(b_range[b]),1),3,2)
			b_string = b_string1 + 'd' + b_string2
			
			structure[counter].flux[*] = f
			structure[counter].column_density = column_density_range[c]
			structure[counter].b = b_range[b]
			
			
			
			for z = 0, n_elements(redshift) - 1 do begin
				z_string1 = strmid(strtrim(string(redshift[z]),1),0,1)
				z_string2 = strmid(strtrim(string(redshift[z]),1),2,4)
				z_string = z_string1 + 'd' + z_string2
			
				lambda_min = (redshift[z] + 1.0)*1535.
				lambda_max = (redshift[z] + 1.0)*1565.
				;	create temp.f26 file
					openw, lun, temp, /get_lun
						line = '%% ' + template_file + '    1     ' + $
							   string(lambda_min) + '      ' + $
							   string(lambda_max) + '   vsig=10.638'
						
						if (redshift[z] + 1)*1548.2049 gt 13000 then $
						line = '%% ' + template_file + '    1     ' + $
							    string(lambda_min) + '      ' + $
							   string(lambda_max) + '   vsig=12.766'
						
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
					
					output_file = 'c4_' + SOL + '_'+ cd_string + '_' + b_string + '_' + z_string + '.dat'
					rdgen_command = 'printf "rd ' + template_file + ' \ngp\n' + temp + '\n25\nwt '+ $
									output_file + $
									 '" | /home/eryan/Code/vpfit_directory/rdgen'
			
					if (redshift[z] + 1)*1548.2049 gt 13000 then $
					rdgen_command = 'printf "rd ' + template_file + ' \ngp\n' + temp + '\n30\nwt '+ $
									output_file + $
									 '" | /home/eryan/Code/vpfit_directory/rdgen'
		
					spawn, rdgen_command					
					
					
					a = file_info(output_file)
					if a.size lt 1 then begin
						z = z-1
						if z lt 0 then z = 0
						wait, 0.001
					endif
				
				
					result = file_test(output_file)
					
					if a.size gt 1 then begin
						
						if result lt 1 then begin
							z = z-1
							if z lt 0 then z = 0
							wait, 0.001
							
						endif
						
						if result eq 1 then begin
							readcol, output_file, individual_l, individual_f, individual_e, individual_v, format=('D, D, D, D')
				
							lambda_ind_index = where(individual_l lt max(individual_l) - 25.00)
							lambda_flux_index = where(structure[counter].flux lt max(individual_l) - 25.00)
				
							structure[counter].flux = structure[counter].flux[lambda_flux_index]*individual_v[lambda_ind_index]
				
							remove_command = "rm -rf " + output_file 
							spawn, remove_command
							
						endif
						
					endif
		
			endfor
			
			
			
			counter = counter+1.
		endfor
	endfor

	
	index = where(structure.b gt 0.0)	
	output_structure = structure[index]
	mwrfits, output_structure, output_name, /create
	print, output_name
	
	
END
