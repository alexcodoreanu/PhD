;
;
;	path [int, float, double] -- the redshift path used to normalise logB
;	
;	sigma_value [int, float, double] -- 3 or 5 denoting the sigma
;
;	zbin_bound_low [int, float, double] -- the redshift lower boundary
;										-- at least 4 elements: 2.00
;
;	zbin_bound_high [int, float, double] -- the redshift upper boundary
;										-- at least 4 elements: 5.19
;
;	ion [string] -- ['c4', 'si4', 'mg2']
;
;	Calling sequence:
;	run_ml_powerlaw_testing_new,  12.8500, 5.00000, 5.19000, 6.20000, 'c4'
;
; run_ml_powerlaw_testing_new,  130.7954,   2.10, 2.99, 'mg2'
;
;
;
pro run_ml_powerlaw_testing_new_mincd, path, zbin_bound_low, zbin_bound_high, ion, mincd

;	output path for contour plots
	fit_plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/paper2/cddfs/plots/'

;	output plot name
	z_bin1_string1 = strmid(strtrim(string(zbin_bound_low), 1), 0, 1)
	z_bin1_string2 = strmid(strtrim(string(zbin_bound_low), 1), 2, 2)
	z_bin1_string =  z_bin1_string1 + 'd' + z_bin1_string2
	z_bin1_line =  z_bin1_string1 + '.' + z_bin1_string2
	
	
	z_bin2_string1 = strmid(strtrim(string(zbin_bound_high), 1), 0, 1)
	z_bin2_string2 = strmid(strtrim(string(zbin_bound_high), 1), 2, 2)
	z_bin2_string =  z_bin2_string1 + 'd' + z_bin2_string2
	z_bin2_line =  z_bin2_string1 + '.' + z_bin2_string2

	redshift_id = z_bin1_string + '_' + z_bin2_string
	mincd_string = strmid(strtrim(string(mincd), 1), 0, 2) + strmid(strtrim(string(mincd), 1), 3, 2)
;	maxcd_string = strmid(strtrim(string(maxcd), 1), 0, 2)

	plotname = fit_plot_path + ion + '_best_fit_CDDF_' + $
		         redshift_id + '_' + $
			       mincd_string  + '_9and10.ps'

;	read in the data
	cddf_input_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/paper2/cddfs/cddf_input_tables/'
	cddf_input_file = cddf_input_path + ion + '_full__cddf_input.dat'
	cddf_input_file = cddf_input_path + ion + '_full__cddf_input_9and10.dat'
	readcol, cddf_input_file, sol, z, N, comp, format=('A, D, D, D'), /silent

;	N    = N[sort(N)]
;	z    = z[sort(N)]
;	comp = comp[sort(N)]
;	sol  = sol[sort(N)]
	
;	select data in the redshift range
	index = where(z ge zbin_bound_low and z lt zbin_bound_high and N ge mincd)

;	set up the input data to pass to George's code
	data = N[index]
	c3 = comp[index]

	c3 = c3[sort(data)]
	data = data[sort(data)]

	completeness3 = fltarr(2, n_elements(data))
	completeness3[0, *] = data
	completeness3[1, *] = c3
;	completeness3[1, *] = 1


;	CDDF MLE input parameters
	logx_range = [min((data)) - 0.5, max((data)) + 0.5, 13.64]
	logB_range = [-15.0,-11.00]
	alpha_range = [-4.1, -0.1]
	
	logB_range = [-18.0,-11.00]
	alpha_range = [-6.1, 2]


	param_est = ml_powerlaw_testing_aug28(10d^completeness3[0, *],completeness=completeness3,logx_range=logx_range,$
                 		   	    	    alpha_range=alpha_range,logB_range=logB_range,$
                 		   	            alpha_list=alpha_list,logB_list=logB_list,$
                 		   	            likelihood=likelihood,plot=plot)

	
;	get total cummulative marginalised pdf for each parameter
	marginalised_pdf_alpha = likelihood[*, 0]
	plot, alpha_list, likelihood[*, 0], xtitle = 'alpha', ytitle = 'PDF', charsize = 2
	print, 'line 85'
	; stop
		for a =0, n_elements(logB_list)-1 do begin
			marginalised_pdf_alpha = marginalised_pdf_alpha + likelihood[*, a]
			print, a, total(marginalised_pdf_alpha)
			oplot, alpha_list, likelihood[*, a], psym = 3
	
		endfor
	; stop	
	print, 'line 93'
	plot, alpha_list, marginalised_pdf_alpha, xtitle = 'alpha', ytitle = 'PDF', charsize = 2
	; stop
	
	marginalised_pdf_logB = likelihood[0, *]
	plot, logB_list, likelihood[0, *], xtitle = 'logB', ytitle = 'PDF', charsize = 2	
	print, 'line 100'
	; stop
		for b =0, n_elements(alpha_list)-1 do begin
			marginalised_pdf_logB = marginalised_pdf_logB + likelihood[b, *]
			print, b, total(marginalised_pdf_logB)
			oplot, logB_list, likelihood[b, *], psym = 3
		
		endfor	
	; stop
	print, 'line 109'
	plot, logB_list, marginalised_pdf_logB, xtitle = 'logB', ytitle = 'PDF', charsize = 2
	; stop

	L68 = param_est[2]
	L95 = param_est[3]
	L99 = param_est[4]


	best_alpha = param_est[0]	
	best_logb = alog10(10d^param_est[1]/path)
	
	
	;	get 68% boundaries for both alpha and logb 
	;	alpha first
		pdf_index = findel(alpha_list, best_alpha)
		local_pdf_value = total(marginalised_pdf_alpha[pdf_index])
		d = 1
		while(local_pdf_value le 0.68) do begin
			  local_pdf_index = [pdf_index - d, pdf_index + d]
			  local_pdf_value = local_pdf_value + total(marginalised_pdf_alpha[local_pdf_index])
			  d = d + 1

		endwhile
		alpha_error = 0.01*(d-1.0)
		alpha_error_string = strmid(strtrim(string(alpha_error), 1), 0, 4)
		alpha_error_bounds = local_pdf_index[0] + dindgen(local_pdf_index[1] - local_pdf_index[0] + 1)
	
		print, 'line 137'
	 	check_pdf_index = local_pdf_index[0] + dindgen(local_pdf_index[1] - local_pdf_index[0] + 1)
	 	plot, alpha_list, marginalised_pdf_alpha, xtitle = 'alpha', ytitle = 'PDF', charsize = 2
	 	oplot, alpha_list[check_pdf_index], marginalised_pdf_alpha[check_pdf_index], psym = 10, thick = 5
		; stop


	;	logB first
		pdf_index = findel(marginalised_pdf_logB, max(marginalised_pdf_logB))
		local_pdf_value = total(marginalised_pdf_logB[pdf_index])
		d = 1
		while(local_pdf_value le 0.68) do begin
			  local_pdf_index = [pdf_index - d, pdf_index + d]
			  local_pdf_value = local_pdf_value + total(marginalised_pdf_logB[local_pdf_index])
			  d = d + 1

		endwhile
		logB_error = 0.01*(d-1.0)
		logB_error_string = strmid(strtrim(string(logB_error), 1), 0, 4)
		logB_error_bounds = local_pdf_index[0] + dindgen(local_pdf_index[1] - local_pdf_index[0] + 1)

		print, 'line 158'
	 	check_pdf_index = local_pdf_index[0] + dindgen(local_pdf_index[1] - local_pdf_index[0] + 1)
	 	plot, logB_list, marginalised_pdf_logB, xtitle = 'logB', ytitle = 'PDF', charsize = 2
	 	oplot, logB_list[check_pdf_index], marginalised_pdf_logB[check_pdf_index], psym = 10, thick = 5
		; stop
	
	;	get error bound
	error_bounds = likelihood[alpha_error_bounds, *]
	error_bounds = error_bounds[*, logB_error_bounds]
	
	error_bounds = likelihood[logB_error_bounds, *]
	error_bounds = error_bounds[*, alpha_error_bounds]
	stop
	
			loadct, 3

	 	    contour,likelihood,alpha_list,alog10(10d^logB_list/path),level=[L99,L95,L68], $
	 			    c_colors = [ 200, 225, 250], /fill, charthick=4,  $
	 			    xtitle='!4a!N', ytitle='!6 log f(N0)!N', xstyle=3, ystyle=3, $
	 				charsize = 2.5, thick = 5, $
	 				xr = alpha_range, xtickv=[-6, -5, -4, -3, -2, -1, 0, 1], $
	 				xtickn = [' ', '!6-5.00!N', ' ', '!6-3.00!N', ' ', '!6-1.00!N', ' ', '!61.00!N'], $
	 				xticks = 7, $
	 				yr = logB_range, ytickv = [ -17, -16, -15, -14, -13, -12], $
	 				ytickn = ['!6-17.00!N', ' ', '!6-15.00!N', ' ', '!6-13.00!N', ' '], $
	 				yticks = 5
	 
	
			loadct, 0
		
			oplot, [-8, 4.0], [best_logb, best_logb], linestyle=2
			oplot, [best_alpha, best_alpha], [-20, -9], linestyle=2
			
			
			xyouts, -6.1, -15.8, '!6N0=10!A13.64!N!N', charsize = 2.5, charthick=4

			best_alpha_string = strmid(strtrim(string(best_alpha), 1), 0, 5) 
			best_alpha_line = '!4a!N!6 = ' + best_alpha_string + '!N!9+!N !6' + alpha_error_string +'!N'
			xyouts, -6.1, -16.6, best_alpha_line, charsize = 2.5, charthick=4
	
	
			best_logb_string = strmid(strtrim(string(best_logb), 1), 0, 6) 
			logb_line = '!6f(N0) = !N10!A' +best_logb_string + '!9+ !6' + logB_error_string + '!N'
			xyouts, -6.1, -17.75, logb_line, charsize = 2.5, charthick=4
			

			if ion eq 'c4' then ion_line = '!6CIV!N'
			if ion eq 'si4' then ion_line = '!6SiIV!N'
			if ion eq 'mg2' then ion_line = '!6MgII!N'

			redshift_line  = '!6' + z_bin1_line +' < z !N!9l!N !6' + z_bin2_line +'!N'
			
			
			

			xyouts, 0.2, -11.75, ion_line,charsize = 2.5, charthick=4
			xyouts, -0.81, -12.4, redshift_line ,charsize = 2.5, charthick=4
	

 	SET_PLOT, 'PS'                                                                                                                                                                           
     !p.font=-1
 	DEVICE, filename = plotname, /color, xsize=12, ysize=6, /encapsulated, /inches
                  
			loadct, 3


		 	    contour,likelihood,alpha_list,alog10(10d^logB_list/path),level=[L99,L95,L68], $
		 			    c_colors = [ 200, 225, 250], /fill, charthick=4,  $
		 			    xtitle='!4a!N', ytitle='!6 log f(N0)!N', xstyle=3, ystyle=3, $
		 				charsize = 2.5, thick = 5, $
		 				xr = alpha_range, xtickv=[-6, -5, -4, -3, -2, -1, 0, 1], $
		 				xtickn = [' ', '!6-5.00!N', ' ', '!6-3.00!N', ' ', '!6-1.00!N', ' ', '!61.00!N'], $
		 				xticks = 7, $
		 				yr = logB_range, ytickv = [ -17, -16, -15, -14, -13, -12], $
		 				ytickn = ['!6-17.00!N', ' ', '!6-15.00!N', ' ', '!6-13.00!N', ' '], $
		 				yticks = 5
		 
		
			loadct, 0
	
			oplot, [-8, 4.0], [best_logb, best_logb], linestyle=2
			oplot, [best_alpha, best_alpha], [-20, -9], linestyle=2
			
			
			xyouts, -6.1, -15.8, '!6N0=10!A13.64!N!N', charsize = 2.5, charthick=4

			best_alpha_string = strmid(strtrim(string(best_alpha), 1), 0, 5) 
			best_alpha_line = '!4a!N!6 = ' + best_alpha_string + '!N!9+!N !6' + alpha_error_string +'!N'
			xyouts, -6.1, -16.6, best_alpha_line, charsize = 2.5, charthick=4
	
	
			best_logb_string = strmid(strtrim(string(best_logb), 1), 0, 6) 
			logb_line = '!6f(N0) = !N10!A' +best_logb_string + '!9+ !6' + logB_error_string + '!N'
			xyouts, -6.1, -17.75, logb_line, charsize = 2.5, charthick=4

			if ion eq 'c4' then ion_line = '!6CIV!N'
			if ion eq 'si4' then ion_line = '!6SiIV!N'
			if ion eq 'mg2' then ion_line = '!6MgII!N'

			redshift_line  = '!6' + z_bin1_line +' < z !N!9l!N !6' + z_bin2_line +'!N'
			
			
			

			xyouts, 0.2, -11.75, ion_line,charsize = 2.5, charthick=4
			xyouts, -0.81, -12.4, redshift_line ,charsize = 2.5, charthick=4

			
 	close, /all
 	device, /close	
	
	print, ' '
	print, ' '
	print,  mincd, path, zbin_bound_low, zbin_bound_high, ' ', ion	
	print, 'best_alpha = ', param_est[0], ' pm ', alpha_error_string
	print, 'best_logB = ', alog10(10d^param_est[1]/path), ' pm ', logB_error_string
	print, ' '
	print, ' '
	


END