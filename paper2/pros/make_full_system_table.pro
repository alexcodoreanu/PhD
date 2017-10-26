pro make_full_system_table

sightline_name = ['S0927', 'S1306', 'U0148', 'U1319']
sightline_titles = ["SDSS J0927+2001", "SDSS J1306+0356", "ULAS J0148+0600", "ULAS J1319+0959"]

path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/paper2/'

component_file = path + 'all_components.dat'

readcol, component_file, $
	system,	component,	sol,	element,	rest_l,	z,	z_err,	c_d,	cd_low,	cd_high,	b,	b_low,	b_high,	ew_flux,	ew_vp,	ew_err,	s3,	s5, $
		 format = ('D, A, A, A, D, D, D, D, D, D, D, D, D, D, D, D')


for i = 0, n_elements(sightline_name) - 1 do begin
	file_name = path + 'system_tables/' + sightline_name[i] + '/all_components.tex'
	sol_index = where(sol eq sightline_name[i])
	
	
	redshift = z 
	redshift_err = z_err 
	
	logN = c_d 
	logN_plus = cd_high  - logN
	logN_minus =logN - cd_low 
	
	b_par = b 
	b_par_plus = b_high  - b_par
	b_par_minus = b_par - b_low 
	
	w = ew_flux 
	w_err = ew_err 
	
	system_number = uint(system)
	component_id = component 
	
	system_tag = strtrim(string(system_number)) + ' ' + component_id
	                                                                                                                 
	openw, lun, file_name, /get_lun           
		printf, lun, '	\documentclass[12pt]{article}                                                                                                                                                        '
		printf, lun, '	\usepackage{graphicx}                                                                                                                                                               '
		printf, lun, '	\usepackage{adjustbox}                                                                                                                                                              '
		printf, lun, '	\usepackage{longtable}                                                                                                                                                              '
		printf, lun, '	\usepackage{pdflscape}                                                                                                                                                              '
		printf, lun, '	\usepackage{changepage}                                                                                                                                                              '
		printf, lun, '	\usepackage{geometry}                                                                                                                                                              '
		printf, lun, '                                                                                                                                                                                      '
		printf, lun, '	\begin{document}                                                                                                                                                                    '
		printf, lun, '                                                                                                                                                                                      '
		printf, lun, '                                                                                                                                                                                      '
	
		printf, lun, '                                                                                                                                                                                      '
		printf, lun, '                                                                                                                                                                                      '
	
		printf, lun, '\begin{footnotesize}'
		printf, lun, '\begin{longtable}{ c c c c c c c c c}  ' 
			
			
			name_line =  '			&	   &                           &            \Large{' + $
						 sightline_titles[i] + $
					 	 '}    & 	& 					&							  	\\     '
			
		
		printf, lun, name_line
		printf, lun, '	     &        	&                           &				&				   &	                    &         	     		 	&  \\              '
		
		printf, lun, '\hline                                                                                                                                                   '                
		printf, lun, '\hline                                                                                                                                                   '
	 	printf, lun, '     	        &     	&                           &				&				   &	                    &         	     		 	& 		comp		& 		system	  	 \\    '          
    	printf, lun, '                                                                                                                                                         '                
		printf, lun, '        &     	&                           &				&				   &	                    &         	     		 	& 		recovery			& 		recovery  	 \\    '          
		printf, lun, '   Sys  & ID  &   Ion     				   &  z 			&      $W_0$       &     log(N)				&    b						&   	rate	&   	rate   \\                      '      
		printf, lun, '          &         &                           &			&     	(\AA)		 &    (cm$^{-2}$)     &    (kms$^{ -1}$)	&        	$\%$	       & $\%$	\\         '                
		printf, lun, '		&	   &                           &            & 	& 					&							  	& \\                                                                 ' 
   	 	printf, lun, '                                                                                                                                                         '                
		printf, lun, '\hline                                                                                                                                                   '                
		printf, lun, '		&	   &                           &            & 	& 					&							  	& \\                                                                 ' 
 																																																	 
		for x = 0, n_elements(sol_index) - 1 do begin
			local_index = sol_index[x]
			ion_string = element[local_index] + ' ' + strtrim(string(uint(rest_l[local_index])))
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				z_value_string = strmid(strtrim(string(redshift[local_index]), 1), 0, 7)
				z_error_string = strmid(strtrim(string(redshift_err[local_index]), 1), 0, 14)
			   	check = str_pos(z_error_string, "e")
			   	if check[0] ge 0.0 then z_error_string = strmid(strtrim(string(redshift_err[local_index]), 1), 0, 3) + " $\times 10^{-5}$ "
			   	if check[0] lt 0.0 then z_error_string = strmid(strtrim(string(redshift_err[local_index]), 1), 0, 7) 	
					
				z_string = ' ' + z_value_string + ' $\pm$ ' + z_error_string + ' '
				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
				ew_string = strmid(strtrim(string(ew_vp[local_index]), 1), 0, 5)
				ew_err_string = strmid(strtrim(string(ew_err[local_index]), 1), 0, 5)
				if ew_flux[local_index] ge 10.0 then begin
					ew_string = strmid(strtrim(string(ew_vp[local_index]), 1), 0, 6)
					ew_err_string = strmid(strtrim(string(ew_err[local_index]), 1), 0, 6)
			
				endif
				if ew_flux[local_index] ge 100.0 then begin
					ew_string = strmid(strtrim(string(ew_vp[local_index]), 1), 0, 7)
					ew_err_string = strmid(strtrim(string(ew_err[local_index]), 1), 0, 7)
			
				endif
				w_string = ' ' + ew_string + ' $\pm$ ' + ew_err_string + ' '
					
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
				logn_value_string = strmid(strtrim(string(logN[local_index]), 1), 0, 5)
			
				local_logN_plus = logN_plus[local_index]
				if local_logN_plus le 0.0 then local_logN_plus = abs(logN_plus[local_index])
			
				local_logN_minus = logN_minus[local_index]
				if local_logN_minus le 0.0 then local_logN_minus = abs(logN_minus[local_index])

				logn_string_plus = strmid(strtrim(string(local_logN_plus), 1), 0, 4) 
				logN_string_minus = strmid(strtrim(string(local_logN_minus), 1), 0, 4) 
				
				if local_logN_minus eq 0.0 then logn_string_plus =  ' '
				if local_logN_minus eq 0.0 then logN_string_minus = ' '
				 
				logn_string = '$' + logn_value_string + '_{ - ' + logN_string_minus + '}^{ + ' + logn_string_plus + '}$'
					
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
				b_value_string = strmid(strtrim(string(b[local_index]), 1), 0, 4)
				local_b_plus = b_par_plus[local_index]
				if local_b_plus le 0.0 then local_b_plus = abs(b_par_plus[local_index])
			
				local_b_minus = b_par_minus[local_index]
				if local_b_plus le 0.0 then local_b_plus = abs(b_par_minus[local_index])

				local_b_plus_string = strmid(strtrim(string(local_b_plus), 1), 0, 4) 
				local_b_minus_string = strmid(strtrim(string(local_b_minus), 1), 0, 4) 
				
				if local_b_plus eq 0.0 then local_b_plus_string = ' '
				if local_b_minus eq 0.0 then local_b_minus_string = ' '


				b_string = '$' + b_value_string + '_{ - ' + local_b_minus_string + '}^{ + ' + local_b_plus_string + '}$'
                system_tag = strtrim(string(system_number)) + ' ' + component_id
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
			
			line =   '  & ' + $
				     '  & ' + $
				   ion_string + '  & ' + $
				     ' & ' + $ 
				   w_string + '  & ' + $
				     '  & ' + $
				     '    & 	 & \\ '
			
			if rest_l[local_index] gt 2796. and rest_l[local_index] lt 2798 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 1548. and rest_l[local_index] lt 1549 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 2851. and rest_l[local_index] lt 2853 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 2599. and rest_l[local_index] lt 2601 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 1669. and rest_l[local_index] lt 1671 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
					
			if rest_l[local_index] gt 1392. and rest_l[local_index] lt 1394 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 1333. and rest_l[local_index] lt 1335 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 3933. and rest_l[local_index] lt 3935 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			if rest_l[local_index] gt 1525. and rest_l[local_index] lt 1527 then $
				line = strtrim(string(system_number[local_index]))  +  '  & ' + $
					   strtrim(string(component_id[local_index])) + '  & ' + $
					   ion_string + '  & ' + $
					   z_string + ' & ' + $ 
					   w_string + '  & ' + $
					   logn_string + '  & ' + $
					   b_string + '    & 	 & \\ '
			
			
			print, line
			printf, lun, line
			
		endfor
		

		printf, lun, ' &        &                   &                &   & 					&							&   	 	& \\  '

		printf, lun, '\hline                                                                                                           '
		printf, lun, '\hline                                                                                                           '
	    printf, lun, '\end{longtable}                                                                                                  '
		printf, lun, '\end{footnotesize}                                                                                                  '
		printf, lun, '\end{document}                                                                                                   '
	
		close, /all
	
endfor


END