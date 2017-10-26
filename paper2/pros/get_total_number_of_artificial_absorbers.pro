pro get_total_number_of_artificial_absorbers
	path = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/"
	path_fits = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/auto_comparison_plots/fits/"
	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
  sightline = ['S0927', 'S1306', 'U0148', 'U1319']
	sigma_values = ['3', '5']
	ions = ['c4', 'si4']
	
	print, 'ion  sol     raw output     selected output'
	
	for ion = 0, 1 do begin	
		
		for zzz = 1, 1 do begin
			
			for xxx = 0, 3 do begin				
				if ion eq 0 then begin
					minimum = 0.5	
					maximum = 5
					
					redshift = redshift_array[xxx]
					
					regular_name_3_sigma = path + sightline[xxx] + "/" + sightline[xxx] + "_false_c4_" + sigma_values[zzz] + "_sigma.fits"
					regular_3s = mrdfits(regular_name_3_sigma, 1, /SILENT)
				
					index = where(regular_3s.EW1548/regular_3s.EW1548_ERR ge float(sigma_values[zzz]) or $
								  regular_3s.EW1550/regular_3s.EW1550_ERR ge float(sigma_values[zzz]) and $
								  regular_3s.redshift lt redshift and $
								  regular_3s.EW1548/regular_3s.EW1550 le maximum and $	
								  (regular_3s.EW1548 + regular_3s.EW1548_ERR)/(regular_3s.EW1550 + regular_3s.EW1550_ERR) le maximum and $		 
							      (regular_3s.EW1548 - regular_3s.EW1548_ERR)/(regular_3s.EW1550 - regular_3s.EW1550_ERR) le maximum and $		 
								  regular_3s.EW1548/regular_3s.EW1550 ge minimum and $
								  (regular_3s.EW1548 + regular_3s.EW1548_ERR)/(regular_3s.EW1550 + regular_3s.EW1550_ERR) ge minimum and $		 
								  (regular_3s.EW1548 - regular_3s.EW1548_ERR)/(regular_3s.EW1550 - regular_3s.EW1550_ERR) ge minimum)
					
					print, ions[ion], '  ', sightline[xxx], n_elements(regular_3s.redshift), n_elements(index)
					
				
				endif
				
				
				if ion eq 1 then begin					
					minimum = 0.8	
					maximum = 4
					
					redshift = redshift_array[xxx]
					
					regular_name_3_sigma = path + sightline[xxx] + "/" + sightline[xxx] + "_false_si4_" + sigma_values[zzz] + "_sigma.fits"
					regular_3s = mrdfits(regular_name_3_sigma, 1, /SILENT)
				
					index = where(regular_3s.EW1393/regular_3s.EW1393_ERR ge float(sigma_values[zzz]) or $
								  regular_3s.EW1402/regular_3s.EW1402_ERR ge float(sigma_values[zzz]) and $
								  regular_3s.redshift lt redshift and $
								  regular_3s.EW1393/regular_3s.EW1402 le maximum and $	
								  (regular_3s.EW1393 + regular_3s.EW1393_ERR)/(regular_3s.EW1402 + regular_3s.EW1402_ERR) le maximum and $		 
							      (regular_3s.EW1393 - regular_3s.EW1393_ERR)/(regular_3s.EW1402 - regular_3s.EW1402_ERR) le maximum and $		 
								  regular_3s.EW1393/regular_3s.EW1402 ge minimum and $
								  (regular_3s.EW1393 + regular_3s.EW1393_ERR)/(regular_3s.EW1402 + regular_3s.EW1402_ERR) ge minimum and $		 
								  (regular_3s.EW1393 - regular_3s.EW1393_ERR)/(regular_3s.EW1402 - regular_3s.EW1402_ERR) ge minimum and $
								   regular_3s.NUM_PIXELS gt 4)

					print, ions[ion], '  ', sightline[xxx], n_elements(regular_3s.redshift), n_elements(index)
					
				
				endif

			endfor
		endfor
		print, ' '
		print, ' '
		print, ' '
		print, ' '


	endfor

END