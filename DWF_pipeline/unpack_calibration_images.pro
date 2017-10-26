pro unpack_calibration_images

	fits_name = "DECam_00502918.fits"
	fits_name_length = strlen(fits_name)
	fits_id = strmid(strtrim(fits_name,1),0,fits_name_length - 5)
	obs_id = strmid(strtrim(fits_name,1),8,fits_name_length - 13)
	
	folder_string = 'ut151218'
	
	
	subtract = 0.0

	for i = 1, 62 do begin
		
		if i eq 2 or i eq 31 or i eq 61 then subtract = subtract + 1
		
		temp_fits = mrdfits(fits_name, 1, header)
		
		extnumber = i - subtract
		print, i, extnumber
		index_number = strmid(strtrim(string(extnumber),1),0,1)
		if i gt 9 then index_number = strmid(strtrim(string(extnumber),1),0,2)
		
		
		temp_fits_file_name = "/lustre/projects/p025_swin/pipes/arest/DECAM/DEFAULT/rawdata/ut151218/" + $
								index_number + "/bias." + folder_string + "." + obs_id + "_" + index_number + ".fits"
		
		;remove_command = "rm -r " + temp_fits_file_name
		;spawn, remove_command 
		hdr = header
		
		
		;mwrfits, temp, temp_fits_file_name, header, /create
		mwrfits, temp, temp_fits_file_name, /create
		print, temp_fits_file_name

	endfor



END