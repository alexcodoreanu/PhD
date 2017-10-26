pro make_mg2_plots_jobs


	shell_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/shell/'   
	pro_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/pros/'      
	plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/mg2/'          
	

	emission_z = 6.13

    ;       this holds the entire spectra analysis
	        fits_name = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/S0927_analysis.fits'
	        a = mrdfits(fits_name, 1)


	readcol, 'plot_lambda_list.dat', plot_titles, plot_element, plot_ionisation, plot_lambda, plot_z, format = ['A, A, F, F, F']

	profile_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/individual_voigt_profiles/'


	ligth = fltarr(1)
	light = 299792.458 ; speed of light in km/s

	; 	QSO's Ly-alpha emission location 	
		ly_alpha = 1217.000 ; just rounding up
		lambda_limit = ly_alpha*(emission_z + 1.00)



	;	this is the list of all ions that I'm looking for
	;	CIV     0       1548.2049       0.189900        2.642e8
		readcol, 'ions_list.dat', ion, rest_l, tensor, density, format = 'A, D, D, D', /silent

		ions = ion
		rest_lambda = rest_l

	;	z_arr is the sorted in ascending order redshift array
		redshift = [a.vis_z, a.nir_z]
		z_error = [a.vis_z_err, a.nir_z_err]



	;	elements holds the element id.s in the same index order as the sorted z_arr array
		els = [a.vis_element, a.nir_element]		
		mg2_el = where(els eq 'MgII')
		elements= strarr(n_elements(els[mg2_el]))
	;	remove the white spaces from els
		for i = 0, n_elements(elements) - 1 do begin
			elements[i] = strtrim(els[i])
		endfor
		z_arr = redshift


;	make a multipanel plot for each extracted red_shift value
for i = 0, n_elements(elements)-1 do begin
	
	id =  strmid(strtrim(string(i), 1),0, 1)
	if i gt 9 then 	id =  strmid(strtrim(string(i), 1),0, 2)
	if i gt 99 then id =  strmid(strtrim(string(i), 1),0, 3)

	pro_file = pro_path + "mg2_plot_" + id + ".pro"	
	openw, lun, pro_file, /get_lun
				              
			printf, lun, "pro mg2_plot_" + id
			printf, lun, ""
				                                                                                                                                                                                            
			printf, lun, "	multiplot_title = 'SDSS J0927+2001'                                                                                                                                                           "
			printf, lun, "	plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/mg2/'                                                                                     "
			printf, lun, "	pro_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/pros/'                                                                                 "
			printf, lun, "	shell_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plots/shell/'                                                                              "
			printf, lun, "	                                                                                                                                                                                             "
			printf, lun, "	ps_title = 'S0927_mg2_'                                                                                                                                                                        "
			printf, lun, "	                                                                                                                                                                                             "
			printf, lun, "	plot_id = plot_path + ps_title                                                                                                                                                               "
			printf, lun, "	                                                                                                                                                                                             "
			printf, lun, "	emission_z = 5.79                                                                                                                                                                            "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	        ;       this holds the entire spectra analysis                                                                                                                                       "
			printf, lun, "	        fits_name = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/S0927_analysis.fits'                                                                "
			printf, lun, "	        a = mrdfits(fits_name, 1)                                                                                                                                                            "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	readcol, '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/plot_lambda_list.dat', plot_titles, plot_element, plot_ionisation, plot_lambda, plot_z, format = ['A, A, F, F, F']                                                                 "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	profile_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/individual_voigt_profiles/'                                                              "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	ligth = fltarr(1)                                                                                                                                                                            "
			printf, lun, "	light = 299792.458 ; speed of light in km/s                                                                                                                                                  "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	; 	QSO's Ly-alpha emission location 	                                                                                                                                                     "
			printf, lun, "		ly_alpha = 1217.000 ; just rounding up                                                                                                                                                   "
			printf, lun, "		lambda_limit = ly_alpha*(emission_z + 1.00)                                                                                                                                              "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	;	this is the list of all ions that I'm looking for                                                                                                                                        "
			printf, lun, "	;	CIV     0       1548.2049       0.189900        2.642e8                                                                                                                                  "
			printf, lun, "		readcol, '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/ions_list.dat', ion, rest_l, tensor, density, format = 'A, D, D, D', /silent                "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "		ions = ion                                                                                                                                                                               "
			printf, lun, "		rest_lambda = rest_l                                                                                                                                                                     "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	;	z_arr is the sorted in ascending order redshift array                                                                                                                                    "
			printf, lun, "		redshift = [a.vis_z, a.nir_z]                                                                                                                                                            "
			printf, lun, "		z_error = [a.vis_z_err, a.nir_z_err]                                                                                                                                                     "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "	;	elements holds the element id.s in the same index order as the sorted z_arr array                                                                                                        "
			printf, lun, "		els = [a.vis_element, a.nir_element]                                                                                                                                                     "
			printf, lun, "        mg2_el = where(els eq 'MgII')                                                                                                                                                                                       "
			
			printf, lun, "		elements= strarr(n_elements(els[mg2_el]))                                                                                                                                                       "
			printf, lun, "	;	remove the white spaces from els                                                                                                                                                         "
			printf, lun, "		for i = 0, n_elements(elements) - 1 do begin                                                                                                                                                  "
			printf, lun, "			elements[i] = strtrim(els[mg2_el[i]])                                                                                                                                                                                                                                                                                                            "
			printf, lun, "		endfor   
		
			printf, lun, "                                                                                                                                                                                               "
			printf, lun, "                                                                                                                                                                                               "
			
			
			
			printf, lun, "  i = ", id 
			printf, lun, "		z_arr = redshift[mg2_el] "
			printf, lun, "		z_err = z_error[mg2_el] "
			printf, lun, "	;	b_arr will hold the b parameter array with the same index order as z_arr "
			printf, lun, "		b_array = [a.vis_b, a.nir_b] "
			printf, lun, "		b_error = [a.vis_b_err, a.nir_b_err] "
			printf, lun, "		b_arr = b_array[mg2_el] "
			printf, lun, "		b_err = b_error[mg2_el] "
			printf, lun, " "
			printf, lun, "	;	cd_arr	will hold the cd parameter array with the same index order as z_arr "
			printf, lun, "		cd_array = [a.vis_cd, a.nir_cd] "
			printf, lun, "		cd_error = [a.vis_cd_err, a.nir_cd_err] "
			printf, lun, "		cd_arr = cd_array[mg2_el] "
			printf, lun, "		cd_err = cd_error[mg2_el] "
			printf, lun, " "
			printf, lun, "		;	create composite lambda, flux, error, fit spliced together at 10200 angstroms "
			printf, lun, "		index_low = where(a.vis_lambda le 10300) "
			printf, lun, "		index_high = where(a.nir_lambda gt 10300) "
			printf, lun, " "
			printf, lun, "	lambda = [a.vis_lambda[index_low], a.nir_lambda[index_high]] "
			printf, lun, "	flux = [a.vis_flux[index_low], a.nir_flux[index_high]] "
			printf, lun, "	error = [a.vis_error[index_low], a.nir_error[index_high]] "
			printf, lun, " "
			printf, lun, "	readcol, '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/S0927_total_fit_spectra.dat', lll, fff, eee, fit "
			printf, lun, " "
			printf, lun, "   	red1_string = strmid(strtrim(string(z_arr[i]),1),0,1) "
			printf, lun, "   	red2_string = strmid(strtrim(string(z_arr[i]),1),2,5) "
			printf, lun, "   	z_string = red1_string + 'd' + red2_string "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " 		title_1 = strmid(strtrim(string(z_arr[i]),1),0,7) "
			printf, lun, " 		title_2 = strmid(strtrim(string(z_err[i]),1),0,10) "
		
			printf, lun, " 		check = str_pos(title_2, 'e')"
			printf, lun, " 		if check[0] ge 0.0 then title_2 = '0.0000' + strmid(strtrim(string(z_err[i]), 1), 0, 1) "
			printf, lun, " 		if check[0] lt 0.0 then title_2 = strmid(strtrim(string(z_err[i]),1),0,7)  "
		
			printf, lun, " 		title = '!6redshift = ' + title_1 + '!N !9+!N !6' + title_2  + '!N'            "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "		plotname =  plot_id + z_string + '_" + id + ".ps' "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "	; 	clean up possible previous instances of the same plot "
			printf, lun, "		remove = 'rm -f ' + plotname "
			printf, lun, "		spawn, remove "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "	; 	identify the possible absorption systems based on the QSO's Ly-alpha emission location "
			printf, lun, "	;	this holds the index of the possible ions and defines the number of panels "
			printf, lun, "		ion_index = where(ions eq 'MgII')                                                                       "
			printf, lun, " "
			printf, lun, "	;	this holds the index of the actual fit elements "
			printf, lun, "		abs_index = where(z_arr gt  (z_arr[i] - 0.05) and z_arr lt (z_arr[i] + 0.05)) "
			printf, lun, " "
			printf, lun, "		close, /all "
			printf, lun, " "
			printf, lun, "	; 	create plot device for multipanel layout "
			printf, lun, "		SET_PLOT, 'PS' "
			printf, lun, "		!p.font=0 "
			printf, lun, "		DEVICE, filename = plotname, /color, xsize=12, ysize=(3*(n_elements(ion_index)) + 3.), /encapsulated, /inches "
			printf, lun, "				multiplot, [1, n_elements(ion_index)]                                                                                   "
			printf, lun, " "
			printf, lun, "	;	select the absorbers associated with the redshift range selected by ion_index "
			printf, lun, "		for x = 0, n_elements(ion_index)-1 do begin "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "			;	this is the ion for which I searched and will be the label "
			printf, lun, "				ind = ion_index[x] "
			printf, lun, "				local_element = strtrim(ions[ind]) "
			printf, lun, " "
			printf, lun, "			;	select individual absorber wavelength tag "
			printf, lun, "				local_lambda = rest_lambda[ind] "
			printf, lun, "				local_wavelength = uint(rest_lambda[ind]) "
			printf, lun, " "
			printf, lun, "				individual_element_index = where(elements[abs_index] eq local_element) "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "			;	identify the actual redshift label to use "
			printf, lun, "			;	this is buggy right now "
			printf, lun, "			; 	I need to select for the closest z_arr[abs_index[individual_element_index]] "
			printf, lun, "			; 	to z_arr[i] "
			printf, lun, "				if individual_element_index[0] ne -1 then begin "
			printf, lun, " "
			printf, lun, "					sub_local_redshift_index = findel(z_arr[i], z_arr[abs_index[individual_element_index]]) "
			printf, lun, "					local_redshift = z_arr[abs_index[individual_element_index[sub_local_redshift_index]]] "
			printf, lun, "					local_redshift_label = string(local_redshift) "
			printf, lun, " "
			printf, lun, "				endif "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "			;	identify the actual redshift label to use "
			printf, lun, "				if individual_element_index[0] eq -1 then begin "
			printf, lun, "					local_redshift_label = '      n.d.' "
			printf, lun, "					local_redshift = z_arr[i] "
			printf, lun, "				endif "
			printf, lun, " "
			printf, lun, "			;	create velocity vector from the wavelength element based on the redshift and rest wavelength of the element "
			printf, lun, "				velocity_vector = (lll/(1. + z_arr[i])- local_lambda)/local_lambda*light[0] "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "			;	get all tick mark locations and redshifts for the elements and change to velocity values "
			printf, lun, "				element_tick_index = where(elements eq local_element) "
			printf, lun, "				element_z = z_arr[element_tick_index] "
			printf, lun, "				element_z_err = z_err[element_tick_index] "
			printf, lun, "				element_b = b_arr[element_tick_index] "
			printf, lun, "				element_b_err = b_err[element_tick_index] "
			printf, lun, "				element_cd = cd_arr[element_tick_index] "
			printf, lun, "				element_cd_err = cd_err[element_tick_index] "
			printf, lun, " "
			printf, lun, "				element_tick_velocity = (local_lambda*(1. + element_z)/(1. + local_redshift)- local_lambda)/local_lambda*light[0] "
			printf, lun, " "
			printf, lun, "			;	get all the other tick marks and their redshifts and change to velocity values "
			printf, lun, "				non_element_tick_index = where(elements ne local_element) "
			printf, lun, "				non_element_z = z_arr[non_element_tick_index] "
			printf, lun, "				non_element_tick_velocity = (local_lambda*(1. + non_element_z)/(1. + local_redshift)- local_lambda)/local_lambda*light[0] "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "				continuum = fltarr(n_elements(velocity_vector)) "
			printf, lun, "				continuum[*] = 10.00 "
			printf, lun, "			; 	plot the data, velocity_vector "
			printf, lun, "				plot, velocity_vector, fff, psym = 10, thick = 4,  charthick = 6, $ "
			printf, lun, "					    ystyle=1,  xthick = 3, ythick = 3, charsize = 2, xr = [-150.0, 550.0],  xstyle=1, $ "
			printf, lun, "              XTICKV = [-100, 0, 100, 200, 300, 400, 500], XTICKN = [ ' ' ,  ' ',  ' ',  ' ',  ' ',  ' ',  ' '],  XTICKS=6, $"	
			printf, lun, "					     yr = [0.0, 1.8], /nodata, font=0, YTICKS=2, YTICKV=[0, 0.5,  1], YTICKN=[ ' ' ,  '  ',   ' ']    "
			printf, lun, " "
			printf, lun, " 				if x eq 0 then begin"
			printf, lun, " 					!p.font=-1 "
			printf, lun, " 						xyouts, -70, 1.85, title, charsize = 3.3, charthick = 7 "
			printf, lun, " 					!p.font=0 "
			printf, lun, " 				 	"
			printf, lun, " 				endif "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "				loadct, 0 "
			printf, lun, "				oplot, velocity_vector, fff, psym = 10, thick = 4 "
			printf, lun, " "
			printf, lun, " "
			
			
;			printf, lun, "				redshift_label = 'redshift = ' + strtrim(local_redshift_label)  "
;			printf, lun, "				xyouts, -140.0, 0.10, redshift_label, charsize = 2, charthick = 6 "
			printf, lun, " "
			printf, lun, "			;	plot the error and the fit "
			printf, lun, "				loadct, 13 "
			printf, lun, "				oplot, velocity_vector, fit, color=50, thick = 6 "
			printf, lun, "				oplot, velocity_vector, eee, color = 250, psym = 10, thick = 6 "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "			; 	now find all elements found within +/- 100 Angstrom "
			printf, lun, "				  minus_plus_index = where(plot_lambda ge local_lambda*(z_arr[i] + 1.0) - 100.0 and plot_lambda lt local_lambda*(z_arr[i] + 1.0)  + 100) "
			printf, lun, " "
			printf, lun, "				for z = 0, n_elements(minus_plus_index) - 1 do begin "
			printf, lun, "					color_code = 100 "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "					if local_element  eq plot_element[minus_plus_index[z]] and local_wavelength eq uint(plot_ionisation[minus_plus_index[z]]) then color_code = 50 "
			printf, lun, " "
			printf, lun, "					local_profile_name = profile_path + plot_titles[minus_plus_index[z]] "
			printf, lun, "					readcol, local_profile_name, l, f, e, voigt_profile, /silent "
			printf, lun, " "
			printf, lun, "					;	figure out the element tick mark location "
			printf, lun, "						element_lambda = plot_lambda[minus_plus_index[z]] "
			printf, lun, "						element_index = findel(element_lambda, lll) "
			printf, lun, "						element_velocity_location = velocity_vector[element_index] "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "					if element_velocity_location gt -150.0 and element_velocity_location lt 550.0 then begin "
			printf, lun, " "
			printf, lun, "						; 	select only the fit, not the continuum "
			printf, lun, "							 index = where(velocity_vector gt -300 and velocity_vector lt 800)																									 "
			printf, lun, "							 profile_index = where(l ge min(lll[index]) and l le max(lll[index])) "
			printf, lun, "							 oplot, velocity_vector, voigt_profile, color=color_code, linestyle = 2 "
			printf, lun, " "
			printf, lun, "						;	now get where the associated tick mark should go "
			printf, lun, "							line_x = [element_velocity_location, element_velocity_location] "
			printf, lun, "							line_y = [1.08, 1.2] "
			printf, lun, "							oplot, line_x, line_y,  color=color_code, thick = 5 "
			printf, lun, " "
			printf, lun, "						;	put the label on top of the tick mark "
			printf, lun, "							label = plot_element[minus_plus_index[z]] + ' ' + $ "
			printf, lun, "								    strmid(strtrim(string(plot_ionisation[minus_plus_index[z]]),1),0,4) + ' ' + $ "
			printf, lun, "									strmid(strtrim(string(plot_z[minus_plus_index[z]]),1),0,5) "
			printf, lun, "							xyouts, element_velocity_location + 1., 1.25, label, orientation = 90, $ "
			printf, lun, "								    color=color_code, charthick = 2, charsize = 0.9 "
			printf, lun, " "
			printf, lun, "					endif "
			printf, lun, " "
			printf, lun, "					oplot, [-300, 900], [1, 1], color = 50, linestyle = 2 "
		
			printf, lun, "			; 	plot the element, local_lambda and redshift "
			printf, lun, "				xyouts, 300.0, 0.10, local_element, charsize = 4, charthick = 3 "
			printf, lun, "				xyouts, 360.0, 0.10, local_wavelength, charsize = 4, charthick = 3 "
		
			printf, lun, " "
			printf, lun, "				endfor "
			printf, lun, "			multiplot "
			printf, lun, "	endfor "
			printf, lun, " "
			printf, lun, "    multiplot, /reset "
			printf, lun, " "
			printf, lun, "	close, /all "
			printf, lun, "	device, /close "
			printf, lun, "	print, plotname "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, " "
			printf, lun, "	 END "

	close, /all


	pro_name = pro_path + "mg2_plot_" + id + ".pro"	
	shell_name = shell_path + "mg2_plot_" + id + ".sh"	
	
	openw, lun, shell_name, /get_lun	
	
			printf, lun, "#!/bin/bash "
			printf, lun, "#$ -S /bin/bash"
			printf, lun, "#$ -cwd"
			printf, lun, "idl << !here"
			printf, lun, ""
			printf, lun, ""
			printf, lun, ""
	
			rnew_line = '.rnew '+  pro_name
			printf, lun, rnew_line
	
			exe_line = "mg2_plot_" + id 
			printf, lun, exe_line
	
			printf, lun, ""
			printf, lun, ""
			printf, lun, ""
			printf, lun, "!here"
			printf, lun, ""
			printf, lun, ""
			printf, lun, ""
			printf, lun, "exit"
			printf, lun, ""

	close, /all


endfor			                                                                                                                                                                                             




END


		