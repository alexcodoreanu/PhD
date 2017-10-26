;
;
;this .pro will create all of the individual voigt profiles
;in an analysis.fits structure by selecting all of ions
;and using rdgen to create a voigt_profile.
;the voigt_profile will then be saved as a .dat file
;in order to be read in by the make_absorber_plots_beta routine
;and oplot the individual voigt_profile over the total fit
;
;
pro make_all_individual_profiles

;	this holds the entire spectra analysis
fits_name = 'S0927_analysis.fits'
a = mrdfits(fits_name, 1)


;	z_arr is the sorted in ascending order redshift array
	z_arr = [a.vis_z, a.nir_z]
	z_err = [a.vis_z_err, a.nir_z_err]


;	elements holds the element id.s in the same index order as the sorted z_arr array
	elements = [a.vis_element, a.nir_element]


;	b_arr will hold the b parameter array with the same index order as z_arr
	b_arr = [a.vis_b, a.nir_b]
	b_err = [a.vis_b_err, a.nir_b_err]

;	cd_arr	will hold the cd parameter array with the same index order as z_arr
	cd_arr = [a.vis_cd, a.nir_cd]
	cd_err = [a.vis_cd_err, a.nir_cd_err]


	;	create composite lambda, flux, error, fit spliced together at 10200 angstroms
	index_low = where(a.vis_lambda le 10300)
	index_high = where(a.nir_lambda gt 10300)

lambda = [a.vis_lambda[index_low], a.nir_lambda[index_high]]
flux = [a.vis_flux[index_low], a.nir_flux[index_high]]
error = [a.vis_error[index_low], a.nir_error[index_high]]


; 	write temporary combined spectrum to pass to rdgen to get the 
;	individual voigt profile fits.
close, /all
openw, lun, 'combined_spectra.dat', /get_lun
	for i = 0, n_elements(lambda) - 1 do begin
		printf, lun, lambda[i], flux[i], error[i]
	endfor
close, /all

;	get all the fit regions to be passed to the invididual voigt profile routine
;	%% S0927_total_up_plotvel.dat     1  10544.7470  10553.3040 vsig=12.766  !  0.0094    24  33
readcol, 'S0927_vis_abs.dat', trash1, file, trash2, vis_low, vis_high, vis_vsig, trash3, trash4, trash5, trash6, format = 'A, A, F, F, F, A, A, F, F, F' 
readcol, 'S0927_nir_abs.dat', trash1, file, trash2, nir_low, nir_high, nir_vsig, trash3, trash4, trash5, trash6, format = 'A, A, F, F, F, A, A, F, F, F'

;		these hold all of the fit regions as used in creating the fit profiles
		low_fit = [vis_low, nir_low]
		high_fit = [vis_high, nir_high]
		vsig = [vis_vsig, nir_vsig]

;	this for loop will loop over all ions
	for i = 0, n_elements(elements) - 1 do begin
	;	create the element_id string
		local_element_string = elements[i] + '                    000000'
		local_element = strmid(local_element_string, 0, 4)
		if local_element eq 'CII ' then local_element = 'CII'
		if local_element eq 'CIV ' then local_element = 'CIV'
		if local_element eq 'MgI ' then local_element = 'MgI'
		if local_element eq 'OI  ' then local_element = 'OI'

		;	create redshift string_id
			red1_string = strmid(strtrim(string(z_arr[i]),1),0,1)
   			red2_string = strmid(strtrim(string(z_arr[i]),1),2,5)
   			z_string = red1_string + 'd' + red2_string	

	;	create output file_name
		output_file = 'S0927_' + local_element + '_' + z_string + '_voigt_profile.dat'

			;	create temporary .f26 file by looping over all possible fit regions 
			;	but only fit the individual element which will take care of all ions
			close, /all
			openw, lun, 'temp.f26', /get_lun
			for y = 0, n_elements(low_fit) - 1 do begin
				line = '%% combined_spectra.dat    1     ' + string(low_fit[y]) +  '  ' +  string(high_fit[y]) + '   ' +  string(vsig[y])
				printf, lun, line
			endfor
			
			if local_element eq 'CII' then local_element = 'C II'
			if local_element eq 'CIV' then local_element = 'C IV'
			if local_element eq 'MgI ' then local_element = 'MgI'
			if local_element eq 'OI' then local_element = 'O I'


			
			last_line = local_element + '    ' + string(z_arr[i]) + '    ' + string(z_err[i]) + '    ' + string(b_arr[i]) + '    ' + string(b_err[i]) + '    ' + string(cd_arr[i]) + '    ' + string(cd_err[i])
			printf, lun, last_line
			close, /all

	rdgen_command = 'printf "rd combined_spectra.dat \ngp\ntemp.f26\n25\nwt '+ output_file + '" | /home/eryan/Code/vpfit_directory/rdgen'
	spawn, rdgen_command





	endfor

move_files = ' mv *voigt_profile*dat individual_voigt_profiles/'
spawn, move_files


END 
