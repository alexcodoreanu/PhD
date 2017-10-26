pro make_plot_lambda_list


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

	;	create composite lambda, flux, error, fit spliced together at 10300 angstroms
		index_low = where(a.vis_lambda le 10300)
		index_high = where(a.nir_lambda gt 10300)


lambda = [a.vis_lambda[index_low], a.nir_lambda[index_high]]
flux = [a.vis_flux[index_low], a.nir_flux[index_high]]
error = [a.vis_error[index_low], a.nir_error[index_high]]


;	this is the list of all ions that I'm looking for
;	CIV     0       1548.2049       0.189900        2.642e8
readcol, 'ions_list.dat', ion, rest_l, tensor, density, format = 'A, D, D, D', /silent

close, /all
openw, lun, 'plot_lambda_list.dat', /get_lun


;	this for loop will loop over all ions
	for i = 0, n_elements(elements) - 1 do begin
		
	;	create the element_id string
		local_element_string = elements[i] + '                    000000'
		local_element = strmid(local_element_string, 0, 4)
		if local_element eq 'CII ' then local_element = 'CII'
		if local_element eq 'CIV ' then local_element = 'CIV'
		if local_element eq 'MgI ' then local_element = 'MgI'
		if local_element eq 'OI  ' then local_element = 'OI'

		ion_index = where(local_element eq ion)
		if ion_index[0] lt 0.0 then stop
		
		local_lambda = rest_l[ion_index] * ( 1. + z_arr[i])

		;	create redshift string_id
			red1_string = strmid(strtrim(string(z_arr[i]),1),0,1)
   			red2_string = strmid(strtrim(string(z_arr[i]),1),2,5)
   			z_string = red1_string + 'd' + red2_string	
			
			pass_redshift = red1_string + '.' + red2_string
			
			for x = 0, n_elements(ion_index) - 1 do begin
				
			;	get local_index 
				local_index = ion_index[x]	
				

			;	create output file_name
				output_file = 'S0927_' + local_element + '_' + z_string + '_voigt_profile.dat'

			    line = output_file+ '  '+ local_element+ '  '+ string(rest_l[local_index])+  '  '+ string(local_lambda[x])+  '  '+ string(pass_redshift)
				print, line
				printf, lun,line
				
			endfor
			   
	endfor


close, /all

END
