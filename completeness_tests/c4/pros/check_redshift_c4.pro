pro check_redshift_c4

	redshift_min = 4.29
	redshift = redshift_min + dindgen(37)*0.05
	
	for i = 1, 36 do begin
		temp_redshift = redshift_min + z_index*0.001 + dindgen(37)*0.05
		redshift = [redshift, temp_redshift]
		
		
	endfor



	stop



END