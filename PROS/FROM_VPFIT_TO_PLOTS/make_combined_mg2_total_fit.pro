pro make_combined_mg2_total_fit

	output_file_name = 'S0927_total_mg2_fit_spectra.dat'

	vp_profile_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/individual_voigt_profiles/'

	mg2list = vp_profile_path + 'mg2_list'
	
	readcol, mg2list, list, format = 'A'
	readcol,vp_profile_path + list[0], l, f, e, vp, /silent


	for i = 1, n_elements(list) - 1 do begin
		
		readcol, vp_profile_path + list[i], local_l, local_f, local_e, local_vp, /silent
		vp = vp*local_vp
		
	endfor



	openw, lun, output_file_name, /get_lun
	
		for i = 0, n_elements(vp) - 1 do begin
		
			printf, lun, l[i], f[i], e[i], vp[i]
			
		endfor

	close, /all


	output_file_name = 'S0927_total_fit_spectra.dat'

	total_list = vp_profile_path + 'list'
	readcol, total_list, list, format = 'A'
	readcol,vp_profile_path + list[0], l, f, e, vp, /silent


	for i = 1, n_elements(list) - 1 do begin
		
		readcol, vp_profile_path + list[i], local_l, local_f, local_e, local_vp, /silent
		vp = vp*local_vp
		
	endfor


	openw, lun, output_file_name, /get_lun
	
		for i = 0, n_elements(vp) - 1 do begin
		
			printf, lun, l[i], f[i], e[i], vp[i]
			
		endfor

	close, /all



END
