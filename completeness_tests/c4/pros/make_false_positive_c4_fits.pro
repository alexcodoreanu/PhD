pro make_false_positive_c4_fits
	
	minimum = 0.3
	maximum = 5
	
	c4_1548 = 1548.2049
	c4_1550 = 1553.3519
	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
    sightline = ['S0927', 'S1306', 'U0148', 'U1319']
	
	for s = 0, n_elements(sightline) -1 do begin
			sol_redshift = redshift_array[s]
			SOL = sightline[s]
			fits_name_3s = SOL + '_false_output_3_sigma.fits'
			fits_name_5s = SOL + '_false_output_5_sigma.fits'
	
		;	read in the original file in order to get the wavelength array	
			original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
							SOL + "/" + SOL + "_combined_spectra.dat"
			readcol, original_file, l, f, e, v, format=('D, D, D, D')
	
			ly_limit = 1217*(1. + sol_redshift)
			result3 = find_false_c4_absorbers(l, f, e, sol_redshift, 3.0)
			
			sigma_value = 3.0			
		  	i0 = where(result3.EW1548/result3.EW1548_ERR ge sigma_value or result3.EW1550/result3.EW1550_ERR ge sigma_value)
			i1 = where(result3[i0].X_MIN_1548 gt ly_limit and result3[i0].redshift lt sol_redshift)							 
			i2 = where(result3[i0[i1]].EW1548/result3[i0[i1]].EW1550 le maximum or $	
								  (result3[i0[i1]].EW1548 + result3[i0[i1]].EW1548_ERR)/(result3[i0[i1]].EW1550 + result3[i0[i1]].EW1550_ERR) le maximum or $		 
							      (result3[i0[i1]].EW1548 - result3[i0[i1]].EW1548_ERR)/(result3[i0[i1]].EW1550 - result3[i0[i1]].EW1550_ERR) le maximum )
										
	   	 	i3 = where(result3[i0[[i1[i2]]]].EW1548/result3[i0[[i1[i2]]]].EW1550 ge minimum or $
								(result3[i0[i1[i2]]].EW1548 + result3[i0[i1]].EW1548_ERR)/(result3[i0[[i1[i2]]]].EW1550 + result3[i0[[i1[i2]]]].EW1550_ERR) ge minimum or $		 
								(result3[i0[[i1[i2]]]].EW1548 - result3[i0[i1]].EW1548_ERR)/(result3[i0[[i1[i2]]]].EW1550 - result3[i0[[i1[i2]]]].EW1550_ERR) ge minimum)
						 
			r3 = result3[i0[i1[i2[i3]]]]
			r3 = r3[sort(r3.redshift)]
			mwrfits, r3, fits_name_3s, /create
			
			result5 = find_false_c4_absorbers(l, f, e, sol_redshift, 5.0)
			sigma_value = 5.0			
			
		  	i0 = where(result5.EW1548/result3.EW1548_ERR ge sigma_value or result5.EW1550/result3.EW1550_ERR ge sigma_value)
			i1 = where(result5[i0].X_MIN_1548 gt ly_limit and result5[i0].redshift lt sol_redshift)							 
			i2 = where(result5[i0[i1]].EW1548/result5[i0[i1]].EW1550 le maximum or $	
								  (result5[i0[i1]].EW1548 + result5[i0[i1]].EW1548_ERR)/(result5[i0[i1]].EW1550 + result5[i0[i1]].EW1550_ERR) le maximum or $		 
							    	  (result5[i0[i1]].EW1548 - result5[i0[i1]].EW1548_ERR)/(result5[i0[i1]].EW1550 - result5[i0[i1]].EW1550_ERR) le maximum )
										
	   		i3 = where(result5[i0[[i1[i2]]]].EW1548/result5[i0[[i1[i2]]]].EW1550 ge minimum or $
									(result5[i0[i1[i2]]].EW1548 + result5[i0[i1]].EW1548_ERR)/(result5[i0[[i1[i2]]]].EW1550 + result5[i0[[i1[i2]]]].EW1550_ERR) ge minimum or $		 
										(result5[i0[[i1[i2]]]].EW1548 - result5[i0[i1]].EW1548_ERR)/(result5[i0[[i1[i2]]]].EW1550 - result5[i0[[i1[i2]]]].EW1550_ERR) ge minimum)
						 
									 
			r5 = result5[i0[i1[i2[i3]]]]
			r5 = r5[sort(r5.redshift)]
			mwrfits, r5, fits_name_5s, /create
			
			

	endfor





	

END