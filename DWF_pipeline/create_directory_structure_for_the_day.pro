pro create_directory_structure_for_the_day

date_string = '151221'
output_path = "/lustre/projects/p025_swin/pipes/arest/DECAM/DEFAULT/rawdata/"
pipe_loop_path = "/lustre/projects/p025_swin/pipes/DWF_PIPE/PIPE_SUBMIT/"

;	create main directory
	new_day_directory = output_path  + 'ut' + date_string
	make_new_day_directory = "mkdir "+ new_day_directory
	spawn, make_new_day_directory

	new_day_pipe_directory = pipe_loop_path  + 'ut' + date_string
	make_new_day_pipe_directory = "mkdir "+ new_day_pipe_directory
	spawn, make_new_day_pipe_directory
	
	
;	now make all of the ccd directories
	for i = 1, 59 do begin
		
		ccd_id = strmid(strtrim(string(i),1),0,1) 
		if i gt 9 then ccd_id = strmid(strtrim(string(i),1),0,2)
		
		sub_directory_name = new_day_directory + '/' + ccd_id
		make_sub_directory_name = "mkdir " + sub_directory_name
		spawn, make_sub_directory_name
		print, sub_directory_name, ' has been created'
		
		;	change permissions to general for the entire directory
			change_command = "chmod 777 " + make_sub_directory_name
			spawn, change_command
		
		sub_directory_name = new_day_pipe_directory + '/' + ccd_id
		make_sub_directory_name = "mkdir " + sub_directory_name
		spawn, make_sub_directory_name
		print, sub_directory_name, ' has been created'
		;	change permissions to general for the entire directory
			change_command = "chmod 777 " + make_sub_directory_name
			spawn, change_command
		
		
	endfor


	

END