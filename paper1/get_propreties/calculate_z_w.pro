pro calculate_z_w

	mg2_2796 = 2796.3542699
	mg2_2803 = 2803.5314853

	completeness_results_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'
	output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'

	SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
	redshift_emission = [5.79, 5.98, 5.99, 6.13]
	pixels = [5, 9, 13]
	pixels = [5 ]


	
	local_file0_name = completeness_results_path +  "binned_ew_0d01_l_28A_5_0.fits"
	local_file0 = mrdfits(local_file0_name, 1)
	
	local_file1_name = completeness_results_path +  "binned_ew_0d01_l_28A_5_1.fits"
	local_file1 = mrdfits(local_file1_name, 1)
	
	local_file2_name = completeness_results_path +  "binned_ew_0d01_l_28A_5_2.fits"
	local_file2 = mrdfits(local_file2_name, 1)
	
	local_file3_name = completeness_results_path +  "binned_ew_0d01_l_28A_5_3.fits"
	local_file3 = mrdfits(local_file3_name, 1)
	
	comp_file = [local_file0, local_file1, local_file2, local_file3]

	ew        = comp_file[where(comp_file.lambda le 18036.484)].ew
	uniq_ew   = dindgen(101)/100.0
	
	sn        = comp_file[where(comp_file.lambda le 18036.484)].sn2796
	success   =  0.967*(1.0 - exp(-sn/2.36)) 		
	success[where(success lt 0.0)] = 0.0
	
	
	lambda    = comp_file[where(comp_file.lambda le 18036.484)].lambda
	recovery3 = comp_file[where(comp_file.lambda le 18036.484)].SIGMA3
	recovery5 = comp_file[where(comp_file.lambda le 18036.484)].SIGMA5
	
	comps3    = recovery3*success
	comps5    = recovery5*success
	
	path3_array 	  = fltarr(n_elements(comps3) - 4)
	path3_array[*]  = -99.00
	
	path5_array 	  = fltarr(n_elements(comps5) - 4)
	path5_array[*]  = -99.00
	
	ew_array  = fltarr(n_elements(comps5) - 4) 
	ew_array[*] = -99.0
	
	for e = 0, n_elements(uniq_ew) - 3 do begin
		minew = uniq_ew[e]+0.0001
		maxew = uniq_ew[e+1]+0.0001
		
		local_index_s3 = where(ew gt minew and ew le maxew and comps3 ge 0.5)
		path3 = n_elements(local_index_s3)*0.01
		
		local_index_s5 = where(ew gt minew and ew le maxew and comps5 ge 0.5)
		path5 = n_elements(local_index_s5)*0.01
		
		ew_array[e]    = maxew
		path3_array[e] = path3
		path5_array[e] = path5
		
		print, maxew, path3, path5
		
	endfor
	
	plot,  ew_array[where(ew_array gt 0.0)], path3_array[where(ew_array gt 0.0)], psym = 4
	oplot, ew_array[where(ew_array gt 0.0)], path5_array[where(ew_array gt 0.0)], psym = 3
	
	
	
	
	stop
	
END