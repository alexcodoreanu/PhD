
function add_and_find_abs_systems, z, x, index
	
original_path = '/lustre/projects/p036_swin/alexc/final_files/final_sn_b_folder/'
original_spectra =original_path[0] +  ['s0927_combined_spectra.dat',  'u0148_combined_spectra.dat',$
's1306_combined_spectra.dat',  'u1319_combined_spectra.dat']

readcol, original_spectra[index], l, f, e, /silent

batch_index = strmid(strtrim(string(z), 1),0, 1)
if z gt 9 then batch_index = strmid(strtrim(string(z), 1),0, 2)

name_index = strmid(strtrim(string(x), 1),0, 1)
if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)

index_string = strmid(strtrim(string(index), 1),0, 1)	

no_flux_file_name = $
"/lustre/projects/p036_swin/alexc/completeness_test/input_spectra/no_flux/completeness_test_" $
+ batch_index + "_" + name_index + "_" + index_string + ".fits"

no_flux_file = mrdfits(no_flux_file_name, 1)

new_str = {ew:0.0, index:0.0,  pixels:0.0, lambda:fltarr(128), sigma5:fltarr(128), sigma3:fltarr(128)}	 
pass_structure = replicate(new_str, n_elements(no_flux_file.EW))		 
pass_structure_name = $
"/lustre/projects/p036_swin/alexc/completeness_test/final_result_fits/rf_" $
+ batch_index + "_" + name_index + "_" + index_string + ".fits"


mg2_2796 = 2796.3542699
mg2_2803 = 2803.5314853

minimum = 0.4	
maximum = 3.5


redshift_emission = [5.79, 5.98, 5.99, 6.13]


for i = 0, n_elements(no_flux_file) - 1 do begin
	lambda_starting_point_vector = no_flux_file[i].lambda
	spectra_index = no_flux_file[i].INDEX

	num_pix = no_flux_file[i].pixels
	steps = (num_pix - 1)/2

	art_flux = fltarr(n_elements(f))
	art_flux[*] = 1.0

	ew = no_flux_file[i].ew
	pass_structure[i].ew = ew
	pass_structure[i].index = spectra_index
	pass_structure[i].pixels = num_pix
	
	for y = 0, n_elements(lambda_starting_point_vector) - 1  do begin
		center_2796 = findel(lambda_starting_point_vector[y], l)
		redshift_scalar =  l[center_2796]/mg2_2796
		center2803 = redshift_scalar*mg2_2803

		center_2803 = findel(center2803, l)

		index_members = dindgen(steps) + 1.
		index_array_2796 = [center_2796 - reverse(index_members), center_2796, center_2796 + index_members]
		delta_lambda = l[center_2796] - l[center_2796 - 1]

		original_depth = 1. - (ew/delta_lambda/num_pix) 
		art_flux[index_array_2796] = original_depth
	
		index_array_2803 = index_array_2796 + (center_2803 - center_2796)
		art_flux[index_array_2803] =1. - (1. - art_flux[index_array_2796])/2.	

	endfor

	zero_index = where(art_flux lt 0.0)
	art_flux[zero_index] = 0.0
	modified_spectrum = f*art_flux
	
	lambda = l
	error = e
	modified_index = dindgen(n_elements(lambda))
	
	sigma_3_result = find_mg2_absorbers(l, modified_spectrum, e, redshift_emission[spectra_index], 3.0)					
	minew2796 = sigma_3_result.EW2796 - sigma_3_result.EW2796_ERR
	maxew2796 = sigma_3_result.EW2796 + sigma_3_result.EW2796_ERR	
	minew2803 = sigma_3_result.EW2803 - sigma_3_result.EW2803_ERR
	maxew2803 = sigma_3_result.EW2803 + sigma_3_result.EW2803_ERR		
    sn_cut_3 = where(sigma_3_result.EW2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                     sigma_3_result.EW2803/sigma_3_result.EW2803_ERR ge 3.0 or $
                                     minew2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                     maxew2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                     minew2803/sigma_3_result.EW2803_ERR ge 3.0 or $
                                     maxew2803/sigma_3_result.EW2803_ERR    ge 3.0 )
    ratio_cut_min = where(sigma_3_result[sn_cut_3].EW2796/sigma_3_result[sn_cut_3].EW2803 ge minimum or $
                          minew2796[sn_cut_3]/minew2803[sn_cut_3] ge minimum or $
                          maxew2796[sn_cut_3]/maxew2803[sn_cut_3] ge minimum)

    ratio_cut_max = where(sigma_3_result[sn_cut_3[ratio_cut_min]].EW2796/sigma_3_result[sn_cut_3[ratio_cut_min]].EW2803 le maximum  or $
                          minew2796[sn_cut_3[ratio_cut_min]]/minew2803[sn_cut_3[ratio_cut_min]] le maximum or $
                          maxew2796[sn_cut_3[ratio_cut_min]]/maxew2803[sn_cut_3[ratio_cut_min]] le maximum )

    sigma_3_result = sigma_3_result[sn_cut_3[ratio_cut_min[ratio_cut_max]]]
	;	sort sigma results by X_MIN_2796 increasing index
	    sort_sigma3_index = sort(sigma_3_result.X_MIN_2796)
		sigma3_min_index = value_locate(sigma_3_result[sort_sigma3_index].X_MIN_2796, lambda_starting_point_vector)
		sigma3_min = sigma_3_result[sort_sigma3_index[sigma3_min_index]].X_MIN_2796

		sigma3_max_index = value_locate(l, sigma3_min)
		sigma3_max = l[sigma3_max_index + sigma_3_result[sort_sigma3_index[sigma3_min_index]].NUM_PIXELS]

		delta_lambda = (l[sigma3_max_index] - l[sigma3_max_index - 1.0])*sigma_3_result[sort_sigma3_index[sigma3_min_index]].NUM_PIXELS
		diff3 = sigma3_max - lambda_starting_point_vector
		ind3 = where(diff3 ge -1.*delta_lambda); and diff3 le 1.*delta_lambda)


		new_sigma_3 = fltarr(n_elements(lambda_starting_point_vector))
		new_sigma_3[*] = 0.0
		new_sigma_3[ind3] = 1.0		
		
			
	
	sigma_5_result = find_mg2_absorbers(l, modified_spectrum, e, redshift_emission[spectra_index], 5.0)					
	minew2796 = sigma_5_result.EW2796 - sigma_5_result.EW2796_ERR
	maxew2796 = sigma_5_result.EW2796 + sigma_5_result.EW2796_ERR	
	minew2803 = sigma_5_result.EW2803 - sigma_5_result.EW2803_ERR
	maxew2803 = sigma_5_result.EW2803 + sigma_5_result.EW2803_ERR		
    sn_cut_5 = where(sigma_5_result.EW2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                     sigma_5_result.EW2803/sigma_5_result.EW2803_ERR ge 5.0 or $
                                     minew2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                     maxew2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                     minew2803/sigma_5_result.EW2803_ERR ge 5.0 or $
                                     maxew2803/sigma_5_result.EW2803_ERR    ge 5.0 )
    ratio_cut_min = where(sigma_5_result[sn_cut_5].EW2796/sigma_5_result[sn_cut_5].EW2803 ge minimum or $
                          minew2796[sn_cut_5]/minew2803[sn_cut_5] ge minimum or $
                          maxew2796[sn_cut_5]/maxew2803[sn_cut_5] ge minimum)

    ratio_cut_max = where(sigma_5_result[sn_cut_5[ratio_cut_min]].EW2796/sigma_5_result[sn_cut_5[ratio_cut_min]].EW2803 le maximum  or $
                          minew2796[sn_cut_5[ratio_cut_min]]/minew2803[sn_cut_5[ratio_cut_min]] le maximum or $
                          maxew2796[sn_cut_5[ratio_cut_min]]/maxew2803[sn_cut_5[ratio_cut_min]] le maximum )

    sigma_5_result = sigma_5_result[sn_cut_5[ratio_cut_min[ratio_cut_max]]]
	;	sort sigma results by X_MIN_2796 increasing index
	    sort_sigma5_index = sort(sigma_5_result.X_MIN_2796)
		sigma5_min_index = value_locate(sigma_5_result[sort_sigma5_index].X_MIN_2796, lambda_starting_point_vector)
		sigma5_min = sigma_5_result[sort_sigma5_index[sigma5_min_index]].X_MIN_2796


		sigma5_max_index = value_locate(l, sigma5_min)
		sigma5_max = l[sigma5_max_index + sigma_5_result[sort_sigma5_index[sigma5_min_index]].NUM_PIXELS]

		diff5 = sigma5_max - lambda_starting_point_vector
		delta_lambda = (l[sigma5_max_index] - l[sigma5_max_index - 1.0])*sigma_5_result[sort_sigma5_index[sigma5_min_index]].NUM_PIXELS
		ind5 = where(diff5 ge -1.*delta_lambda); and diff5 le 1.*delta_lambda)
		
		new_sigma_5 = fltarr(n_elements(lambda_starting_point_vector))
		new_sigma_5[*] = 0.0
		new_sigma_5[ind5] = 1.0
		pass_structure[i].sigma3 = new_sigma_3
		pass_structure[i].sigma5 = new_sigma_5
		pass_structure[i].lambda = lambda_starting_point_vector
endfor

print, pass_structure_name
mwrfits, pass_structure, pass_structure_name, /create


END
