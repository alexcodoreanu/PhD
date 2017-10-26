

function select_si4_systems, lambda, flux, error, minimum, maximum, structure_name

	structure = mrdfits(structure_name, 1)
	pass_array = dindgen(n_elements(structure.REDSHIFT))
	pass_array[*] = -99.00
	
	
	for ind = 0, n_elements(structure.REDSHIFT) - 1 do begin
		;	get the pixel location in the lambda array
			local_index_1393 = findel(structure[ind].X_MIN_1393, lambda)
			absorption_feature_1393 =uint(local_index_1393  + dindgen(structure[ind].NUM_PIXELS ))

			local_index_1402 = findel(structure[ind].X_MIN_1393*1402.77291/1393.76018, lambda)
			absorption_feature_1402 =uint(local_index_1402  + dindgen(structure[ind].NUM_PIXELS ))
			
			;print, ind
			
		; check that the ratio criteria holds for each pixel 
			check = 0.0
			for p = 0, n_elements(absorption_feature_1393) - 1 do begin
				numerator = (1.0 - flux[absorption_feature_1393[p]])
				if numerator lt 0.0 then numerator = flux[absorption_feature_1393[p]]
			
				denumerator = (1.0 - flux[absorption_feature_1402[p]])
				if denumerator lt 0.0 then denumerator = flux[absorption_feature_1402[p]]
			
				error_value = sqrt((1./denumerator/denumerator)*(error[absorption_feature_1393[p]]*error[absorption_feature_1393[p]])* $
											(numerator*numerator/denumerator/denumerator/denumerator/denumerator)* $
											(error[absorption_feature_1402[p]]*error[absorption_feature_1402[p]]))
			
				if (numerator/denumerator + error_value) le maximum and $
				   (numerator/denumerator - error_value) ge minimum then check = check + 1
					
			;	if (numerator/denumerator) le maximum and $
			;	   (numerator/denumerator) ge minimum then check = check + 1
			endfor
		;	verify that the check value is greater than 2*uint(structure[ind].NUM_PIXELS)/3 + 1
		;	meaning that at more than	half of the pixels (rounded up) are meeting the criteria
		
		;	get pixel inde
			check_value = structure[ind].NUM_PIXELS 
			if check/check_value ge 0.5 and check/check_value le 2.0 then pass_array[ind] = 99.0
				
			

	endfor

	
	pass_index =  where(pass_array gt 0.0)
	pass_index_check = fltarr(n_elements(pass_index))
	pass_index_check[*] = -99.00
	for ind = 0, n_elements(pass_index) - 1 do begin		
		local_index = pass_index[ind]
		;	get an array of the ratios of the flux
			local_index_1393 = findel(structure[local_index].X_MIN_1393, lambda)
			absorption_feature_1393 =uint(local_index_1393  + dindgen(structure[ind].NUM_PIXELS ))

			local_index_1402 = findel(structure[local_index].X_MIN_1393*1402.77291/1393.76018, lambda)
			absorption_feature_1402 =uint(local_index_1402   + dindgen(structure[ind].NUM_PIXELS ))
		
		
			ratio_error_array = fltarr(2, n_elements(absorption_feature_1393))
			
			for p = 0, n_elements(absorption_feature_1393) - 1 do begin
				numerator = (1.0 - flux[absorption_feature_1393[p]])
				if numerator lt 0.0 then numerator = flux[absorption_feature_1393[p]]
			
				denumerator = (1.0 - flux[absorption_feature_1402[p]])
				if denumerator lt 0.0 then denumerator = flux[absorption_feature_1402[p]]
			
				error_value = sqrt((1./denumerator/denumerator)*(error[absorption_feature_1393[p]]*error[absorption_feature_1393[p]])* $
											(numerator*numerator/denumerator/denumerator/denumerator/denumerator)* $
											(error[absorption_feature_1402[p]]*error[absorption_feature_1402[p]]))
			
				ratio_error_array[0, p] = numerator/denumerator
				ratio_error_array[1, p] = error_value
			endfor
			
			average = total(ratio_error_array[0,*])/n_elements(ratio_error_array[0,*])
			average_error = sqrt(total(ratio_error_array[1,*]*ratio_error_array[1,*]))/n_elements(ratio_error_array[0,*])
			
			top_ratio = ratio_error_array[0,*] + ratio_error_array[1,*]
			bottom_ratio = ratio_error_array[0,*] - ratio_error_array[1,*]
			top_average = average + average_error
			bottom_average = average - average_error
	
			average_index = where(top_ratio le top_average or bottom_ratio ge bottom_average)
			
			if n_elements(average_index)/(structure[ind].NUM_PIXELS ) ge 0.5 or n_elements(average_index)/(structure[ind].NUM_PIXELS ) le 2 then $
				pass_index_check[ind] = 99.00
	endfor


	
	index_to_pass_one = where(pass_index_check gt 0.0)


	return, pass_index[index_to_pass_one]





END



