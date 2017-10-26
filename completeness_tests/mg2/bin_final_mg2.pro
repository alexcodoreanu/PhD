pro bin_final_mg2

	pixels = [5, 7, 9, 11, 13, 15]
	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'

	output_name_5 = fits_path + "binned_ew_0d01_l_28A_5.fits"
	output_name_7 = fits_path + "binned_ew_0d01_l_28A_7.fits"
	output_name_9 = fits_path + "binned_ew_0d01_l_28A_9.fits"
	output_name_11 = fits_path + "binned_ew_0d01_l_28A_11.fits"
	output_name_14 = fits_path + "binned_ew_0d01_l_28A_13.fits"
	output_name_15 = fits_path + "binned_ew_0d01_l_28A_15.fits"
	
	output_5 	= mrdfits(output_name_5 , 1)
	output_7   = mrdfits(output_name_7 , 1)
	output_9   = mrdfits(output_name_9 , 1)
	output_11  = mrdfits(output_name_11, 1)
	output_14  = mrdfits(output_name_14, 1)
	output_15  = mrdfits(output_name_15, 1)
	
	
	
	
	
	
	
	
	ew_bin_min = [0, 0.4, 0.7]
	ew_bin_max = [0.4, 0.7, 1]

	ew_bins = dindgen(101.)/100.
	
	lambda_min = 8645.40
	lambda_max = 21385.4
	lambda_steps = uint((lambda_max-lambda_min)/28.)
	lambda_bins = lambda_min + dindgen(lambda_steps)*28.
	
	str = { EW: 0.0, $
 					LAMBDA: 0.0, $
 					SIGMA5: 0.0, $
 					SIGMA3: 0.0}
	
	;	bin the completeness results by sightline
	for index = 0, 3 do begin
		index_string = strmid(strtrim(string(index), 1),0, 1)		
		output_name = fits_path + "binned_ew_0d01_l_28A_" + index_string +  ".fits"
		output_fits = replicate(str, (n_elements(ew_bins)*n_elements(lambda_bins)*1.3))	
	
	
	endfor
	
	
	
END