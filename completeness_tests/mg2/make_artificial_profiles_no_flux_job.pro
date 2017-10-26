function make_artificial_profiles_no_flux_job, z, x
	
	list = mrdfits("/lustre/projects/p036_swin/alexc/final_files/old_sn_b_folder/completeness_test/systems_to_be_made.fits", 1)

;    BIN_END_VALUE   FLOAT         0.0100000
;    LAMBDA_BIN      FLOAT           8645.40
;    PIXELS          FLOAT     Array[15]
;    EW              FLOAT     Array[15]
;    INDEX_OF_TEMPLATE
;                    FLOAT     Array[15]
;    DELTA_LAMBDA    FLOAT     Array[15]

; ew:0.0, pixels:0.0, lambda:0.0,  delta_lambda:0.0, sigma1:0.0, sigma3:0.0, index:0.0, flux:fltarr(44000)
structure = {ew:0.0, pixels:0.0, lambda:fltarr(128),  $
	         delta_lambda:0.0, sigma3:fltarr(128), sigma5:fltarr(128), $
		     index:0.0}


lambda_starting_point_vector = 8645.40 + dindgen(128)*100.0
bin_end_values = dindgen(128)/100 + 0.01


name_counter = 0.0
folder_id = 0.0


; 	make folder to place the fits into
folder_path = "/lustre/projects/p036_swin/alexc/completeness_test/input_spectra/"


;	z will cycle through pixels, index and delta_lambda
	batch_index = strmid(strtrim(string(z), 1),0, 1)
	if z gt 9 then batch_index = strmid(strtrim(string(z), 1),0, 2)
	
			name_index = strmid(strtrim(string(x), 1),0, 1)
			if x gt 9 then name_index = strmid(strtrim(string(x), 1),0, 2)
			if x gt 99 then name_index = strmid(strtrim(string(x), 1),0, 3)
	
			temp_structure = replicate(structure, 12800)
			temp_structure_name = folder_path + "completeness_test_" + batch_index + "_" + name_index + ".fits"
			line = 'rm -rf ' + temp_structure_name
			spawn, line
			
			
				for y = 0, 12799 do begin
					temp_structure[y].lambda = lambda_starting_point_vector + x


					temp_structure[y].ew = list[y].ew[z]
					temp_structure[y].pixels = list[y].pixels[z]
					temp_structure[y].delta_lambda = list[y].delta_lambda[z]
					temp_structure[y].index = list[y].INDEX_OF_TEMPLATE[z]
					
					
				endfor
				
			mwrfits, temp_structure, temp_structure_name, /create
			print, temp_structure_name
			undefine, temp_structure
				


END
