;	take in the split fits and compute the S/N 
;	as well as the user_success and user_failure
;   value associated with the detection (or non-detection)
;   it will take in the split file
;
pro add_human_acceptance_to_artificial_mg2_beta_by_sol, s



mg2_2796 = 2796.3542699
mg2_2803 = 2803.5314853


completeness_results_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_mg2_results/'
output_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_mg2_results/'

SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]
pixels = [5, 9, 13]
pixels = [5 ]

sn_name = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/SN_maps/SN_maps_by_sol_by_pix.fits'
sn_maps = mrdfits(sn_name, 1)


str = {$
	EW:0.0, $
	INDEX:0.0, $
	PIXELS:0.0, $
	LAMBDA:0.0, $
	SIGMA5:0.0, $
	SIGMA3:0.0, $
	SN2796:0.0, $
	SN2803:0.0, $
	EW2796:0.0, $
	EW2803:0.0, $
	ERR2796:0.0, $
	ERR2803:0.0, $
	user_success_2796_3s:0.0, $
	user_failure_2796_3s:0.0, $
	user_success_2803_3s:0.0, $
	user_failure_2803_3s:0.0, $
	user_success_2796_5s:0.0, $
	user_failure_2796_5s:0.0, $
	user_success_2803_5s:0.0, $
	user_failure_2803_5s:0.0}


SOL = SOLS[s]
sol_string = strmid(strtrim(string(s), 1),0, 1)
;	read in the original spectra with the correct precision
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')

	p = 0
	local_pixels = pixels[p]
	pixel_string = strmid(strtrim(string(local_pixels), 1),0, 1)	
	if local_pixels gt 9 then pixel_string = strmid(strtrim(string(local_pixels), 1),0, 2)	
	
	steps = (local_pixels - 1)/2
	
	;	select the appropriate SOL and pixel SN arrays
	index = where(sn_maps.sol eq SOL and sn_maps.pixels eq local_pixels)
	print, n_elements(index)
	
	;	now read in the split file 
	recovery_name = completeness_results_path + $
		            'split_artificial_' + pixel_string + $
				    '_' + sol_string + '.fits'
	recovery_fits = mrdfits(recovery_name, 1)
	
	
;	output name
output_name = output_path + 'split_with_human_acceptance_' $
	  			          + pixel_string + '_' + sol_string + '.fits'
output = replicate(str, n_elements(recovery_fits.ew))

output.EW     = recovery_fits.EW
output.INDEX  = recovery_fits.INDEX
output.PIXELS = recovery_fits.PIXELS
output.LAMBDA = recovery_fits.LAMBDA
output.SIGMA5 = recovery_fits.SIGMA5
output.SIGMA3 = recovery_fits.SIGMA3

art_flux = fltarr(n_elements(f))

for i = 0, n_elements(recovery_fits.ew) - 1 do begin
	print, s, p, i
	art_flux[*] = 1.0
	
	;	get the midpoint of the wavelength bin
	local_lambda = recovery_fits[i].lambda 
	center_2796 = findel(local_lambda, l)
	redshift_scalar =  l[center_2796]/mg2_2796
	center2803 = redshift_scalar*mg2_2803

	center_2803 = findel(center2803, l)

	index_members = dindgen(steps) + 1.
	index_array_2796 = [center_2796 - reverse(index_members), center_2796, center_2796 + index_members]
	delta_lambda = l[center_2796] - l[center_2796 - 1]

	original_depth = 1. - (recovery_fits[i].ew/delta_lambda/local_pixels) 
	art_flux[index_array_2796] = original_depth

	index_array_2803 = index_array_2796 + (center_2803 - center_2796)
	art_flux[index_array_2803] =1. - (1. - art_flux[index_array_2796])/2.	

	;	get the SN at that wavelength for the sightline		
	local_sn2796 = total(1.0 - f[index_array_2796]*art_flux[index_array_2796])/$
		           total(e[index_array_2796]*art_flux[index_array_2796])

	local_sn2803 = total(1.0 - f[index_array_2803]*art_flux[index_array_2803])/$
		           total(e[index_array_2803]*art_flux[index_array_2803])
	
	
	output[i].EW2796   = total(1.0 - f[index_array_2796]*art_flux[index_array_2796])
	output[i].EW2803   = total(1.0 - f[index_array_2803]*art_flux[index_array_2803])
	output[i].ERR2796  = total(e[index_array_2796]*art_flux[index_array_2796])
	output[i].ERR2803  = total(e[index_array_2803]*art_flux[index_array_2803])
	
	local_sn2796_3s = local_sn2796
	local_sn2803_3s = local_sn2803	
	
	local_sn2796_5s = local_sn2796 
	local_sn2803_5s = local_sn2803	


	if local_sn2796 lt 3.0 then local_sn2796_3s = 3.0
	if local_sn2803 lt 3.0 then local_sn2803_3s = 3.0
	
	if local_sn2796 lt 5.0 then local_sn2796_5s = 5.0
	if local_sn2803 lt 5.0 then local_sn2803_5s = 5.0
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	f  = 0.954*(1.0 - np.exp(-fit_mid_sn/1.28))
	user_success_2796_3s = 0.954*(1.0 - exp(-1.0*local_sn2796_3s/1.28))
	user_success_2803_3s = 0.954*(1.0 - exp(-1.0*local_sn2803_3s/1.28))
	
	
	;	best_fit = -0.009*x + 0.09
	if local_sn2796 ge 4.421052631578947 then user_failure_2796_3s = -0.009*local_sn2796 + 0.09
	if local_sn2803 ge 4.421052631578947 then user_failure_2803_3s = -0.009*local_sn2803 + 0.09
	
	;	best_fit = 0.01*x + 0.003
	if local_sn2796 lt 4.421052631578947 then user_failure_2796_3s = 0.01*local_sn2796 + 0.006
	if local_sn2803 lt 4.421052631578947 then user_failure_2803_3s = 0.01*local_sn2803 + 0.006
	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
	;	f  = 0.954*(1.0 - np.exp(-fit_mid_sn/1.28))
	user_success_2796_5s = 0.954*(1.0 - exp(-1.0*local_sn2796_5s/1.28))
	user_success_2803_5s = 0.954*(1.0 - exp(-1.0*local_sn2803_5s/1.28))
	
	
	;	best_fit = -0.009*x + 0.09
	if local_sn2796 ge 4.421052631578947 then user_failure_2796_5s = -0.009*local_sn2796 + 0.09
	if local_sn2803 ge 4.421052631578947 then user_failure_2803_5s = -0.009*local_sn2803 + 0.09
	
	;	best_fit = 0.01*x + 0.003
	if local_sn2796 lt 4.421052631578947 then user_failure_2796_5s = 0.01*local_sn2796 + 0.006
	if local_sn2803 lt 4.421052631578947 then user_failure_2803_5s = 0.01*local_sn2803 + 0.006


	output[i].user_success_2796_3s = user_success_2796_3s
	output[i].user_success_2803_3s = user_success_2803_3s
	output[i].user_failure_2796_3s = user_failure_2796_3s
	output[i].user_failure_2803_3s = user_failure_2803_3s
	
	output[i].user_success_2796_5s = user_success_2796_5s
	output[i].user_success_2803_5s = user_success_2803_5s
	output[i].user_failure_2796_5s = user_failure_2796_5s
	output[i].user_failure_2803_5s = user_failure_2803_5s
	
	output[i].sn2796 = local_sn2796
	output[i].sn2803 = local_sn2803
				
endfor

;	rewrite the fits
mwrfits, output, output_name, /create
print, output_name






END
