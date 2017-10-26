function str_pos, input_string, check_character

	check = 0
	
	string_length = strlen(input_string)
	index = strpos(input_string, check_character)
	temp1 = 0
	if index[0] gt 0.0 then begin
		while check eq 0.0 do begin
			
			new_string = strmid(strtrim(input_string,1),max(index) + 1,string_length) 
			temp2 = strpos(new_string, check_character)
			
			if temp2 ge 0.0 then begin
				index = [index, index + temp1 + temp2 + 1]
				temp2 = temp1
			endif
			
			if temp2 lt 0.0 then check = 99
			
		endwhile
	endif

return, index[UNIQ(index)]

END