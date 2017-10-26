pro make_SN_maps

mg2_2796 = 2796.3542699
mg2_2803 = 2803.5314853

;	output path
output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/SN_maps/SN_maps/'

;	index selects the sightline	
SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]
pixels = [5, 9, 13]

;	read in the original spectra with the correct precision
for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, lambda, flux, error, vpfit, format=('D, D, D, D'), /silent
	
	local_lambda = lambda[where(lambda gt 1217.0*(1. + redshift_emission[s]) and $
		  					    lambda lt mg2_2803*(1. + redshift_emission[s]))]
	
	local_SN      = fltarr(n_elements(local_lambda))
	local_SN_2803 = fltarr(n_elements(local_lambda))
	
	for p = 0, n_elements(pixels) - 1 do begin
		local_pixels = pixels[p]
		pixel_string = strmid(strtrim(string(local_pixels), 1),0, 1)	
		if local_pixels gt 9 then pixel_string = strmid(strtrim(string(local_pixels), 1),0, 2)	
		
		steps = (local_pixels - 1)/2
		output_name = output_path + SOL + '_SN_' + pixel_string + '_pixels.dat'
		
		print, output_name
		
		openw, lun, output_name, /get_lun
		printf, lun, '       lambda          SN_2796        SN_2803'
			; now itterate through the local_lambda array and calculate the SN associated with each pixel
			for l = 0, n_elements(local_lambda) - 1 do begin
				;	identify the 2796 feature
				center_2796 = findel(local_lambda[l], lambda)
				redshift_scalar =  lambda[center_2796]/mg2_2796
				center2803 = redshift_scalar*mg2_2803
			
				center_2803 = findel(center2803, lambda)
			
				index_members = dindgen(steps) + 1.
				index_array_2796 = [center_2796 - reverse(index_members), center_2796, center_2796 + index_members]
				index_array_2803 = index_array_2796 + (center_2803 - center_2796)
			
				local_SN[l]		 = total(1. - flux[index_array_2796])/total(error[index_array_2796])
				local_SN_2803[l] = total(1. - flux[index_array_2803])/total(error[index_array_2803])
				
				
				printf, lun, string(min(lambda[index_array_2796])), '  ', $
					         string(max(lambda[index_array_2796])), '  ', $
						     string(local_SN[l]), '  ', string(local_SN_2803[l])
			
			endfor
		
		close, /all
		
	endfor
endfor


END