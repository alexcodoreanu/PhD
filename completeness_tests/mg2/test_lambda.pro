pro test_lambda


temp = [0]

for x = 0, 127 do begin
	lambda_starting_point_vector = x + 8645.40 + dindgen(128)*100.0
	temp = [temp,lambda_starting_point_vector ]


endfor

stop

end
