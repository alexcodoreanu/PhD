pro move_flat_and_bias

	output_path = "/lustre/projects/p025_swin/pipes/arest/DECAM/DEFAULT/rawdata/"
	yesterday = 'ut151220'
	today = 'ut151221'

	for i = 1, 59 do begin

		index_number = strmid(strtrim(string(i),1),0,1)
		if i gt 9 then index_number = strmid(strtrim(string(i),1),0,2)
	
		command = "cp " + output_path + yesterday + "/" + index_number + "/*lat* " + output_path + today + "/" + index_number 
	
		spawn, command
		
		command = "cp " + output_path + yesterday + "/" + index_number + "/*ias* " + output_path + today + "/" + index_number 
	
		spawn, command
		

	endfor



END