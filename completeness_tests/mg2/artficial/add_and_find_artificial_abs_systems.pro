
function add_and_find_artificial_abs_systems, z, x, index
	

mg2_2796 = 2796.3542699
mg2_2803 = (2803.5314853 - 2796.3542699)*2.0 + 2796.3542699

minimum = 0.4	
maximum = 3.5

batch_index = strmid(strtrim(string(z), 1),0, 1)
if z gt 9 then batch_index = strmid(strtrim(string(z), 1),0, 2)

name_index = strmid(strtrim(string(x), 1),0, 1)
if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)

index_string = strmid(strtrim(string(index), 1),0, 1)	

; get the ew values
ew = dindgen(100)/100. + 0.01000
ew = ew[reverse(sort(ew))]


new_str = {ew:0.0, index:0.0,  pixels:0.0, lambda:fltarr(128), sigma5:fltarr(128), sigma3:fltarr(128)}	 
pass_structure = replicate(new_str, n_elements(ew))		 
pass_structure_name = "/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_" + $
	                    batch_index + "_" + name_index + "_" + index_string + ".fits"

;	x is the angstrom distance from the left bound
; will range from 0 to 99
lambda_starting_point_vector = x + 8645.40 + dindgen(128)*100.0
	
; z is the num_pix
num_pix = z

;	index selects the sightline	
SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
SOL = SOLS[index]
redshift_emission = [5.79, 5.98, 5.99, 6.13]

;	read in the original spectra with the correct precision
original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
				SOL + "/" + SOL + "_combined_spectra.dat"
readcol, original_file, l, f, e, v, format=('D, D, D, D')

pass_structure[*].index = index
pass_structure[*].pixels = num_pix


for i = 0, n_elements(ew) - 1 do begin
	pass_structure[i].ew = ew[i]
	steps = (num_pix - 1)/2

	art_flux = fltarr(n_elements(f))
	art_flux[*] = 1.0
	
	for y = 0, n_elements(lambda_starting_point_vector) - 1  do begin
		center_2796 = findel(lambda_starting_point_vector[y], l)
		redshift_scalar =  l[center_2796]/mg2_2796
		center2803 = redshift_scalar*mg2_2803

		center_2803 = findel(center2803, l)

		index_members = dindgen(steps) + 1.
		index_array_2796 = [center_2796 - reverse(index_members), center_2796, center_2796 + index_members]
		delta_lambda = l[center_2796] - l[center_2796 - 1]

		original_depth = 1. - (pass_structure[i].ew/delta_lambda/num_pix) 
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
	
	sigma_3_result = find_false_mg2_absorbers(l, modified_spectrum, e, redshift_emission[index], 3.0)					
	minew2796 = sigma_3_result.EW2796 - sigma_3_result.EW2796_ERR
	maxew2796 = sigma_3_result.EW2796 + sigma_3_result.EW2796_ERR	
	minew2803 = sigma_3_result.EW2803 - sigma_3_result.EW2803_ERR
	maxew2803 = sigma_3_result.EW2803 + sigma_3_result.EW2803_ERR		
  
	sn_cut_3 = where(sigma_3_result.EW2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                   sigma_3_result.EW2803/sigma_3_result.EW2803_ERR ge 3.0 or $
                                   minew2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                   maxew2796/sigma_3_result.EW2796_ERR ge 3.0 or $
                                   minew2803/sigma_3_result.EW2803_ERR ge 3.0 or $
                                   maxew2803/sigma_3_result.EW2803_ERR ge 3.0 )
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
	ind3 = where(diff3 ge -2.*delta_lambda ); and diff3 le 2.*delta_lambda)


	new_sigma_3 = fltarr(n_elements(lambda_starting_point_vector))
	new_sigma_3[*] = 0.0
	new_sigma_3[ind3] = 1.0		

	sigma_5_result = find_false_mg2_absorbers(l, modified_spectrum, e, redshift_emission[index], 5.0)					
	minew2796 = sigma_5_result.EW2796 - sigma_5_result.EW2796_ERR
	maxew2796 = sigma_5_result.EW2796 + sigma_5_result.EW2796_ERR	
	minew2803 = sigma_5_result.EW2803 - sigma_5_result.EW2803_ERR
	maxew2803 = sigma_5_result.EW2803 + sigma_5_result.EW2803_ERR		
	
  sn_cut_5 = where(sigma_5_result.EW2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                   sigma_5_result.EW2803/sigma_5_result.EW2803_ERR ge 5.0 or $
                                   minew2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                   maxew2796/sigma_5_result.EW2796_ERR ge 5.0 or $
                                   minew2803/sigma_5_result.EW2803_ERR ge 5.0 or $
                                   maxew2803/sigma_5_result.EW2803_ERR ge 5.0 )
	
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
		ind5 = where(diff5 ge -2.*delta_lambda); and diff5 le 2.*delta_lambda)
		
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
