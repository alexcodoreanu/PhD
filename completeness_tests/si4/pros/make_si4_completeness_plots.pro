pro make_si4_completeness_plots
	
	si4_1393 = 1393.76018
	si4_1402 = 1402.77291
	
	redshift_array = [5.79, 5.99, 5.98, 6.13]
    sightline = ['S0927', 'S1306', 'U0148', 'U1319']
	ps_title = ['SDSS J0927+2001', 'SDSS J1306+0356', 'ULAS J0148+0600',  'ULAS J1319+0950']

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/results/'
	plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/si4/pros/plots/'
	
	output_names = ['_20.fits', '_30.fits', '_40.fits', '_50.fits', '_all.fits']
	
	b_bin_low = [10, 20, 30, 40, 10]
	b_bin_high = [30, 40, 50, 60, 60]

	column_density_range = dindgen(16)/10 + 12.2	
 	
	tick_indeces = [ 12.4, 12.8,  13.2]
	tick_values = ['12.4', '12.8', '13.2']
	tick_values_blank = [' ', ' ', ' ']
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
for s = 0, n_elements(sightline) - 1 do begin
	SOL = sightline[s]	
	file_title = ps_title[s]
	
	lambda_min = 1217*(1. + redshift_array[s])
	lambda_max = si4_1393*(1. + redshift_array[s]) - 50.
	
	if s eq 0 then begin
		x_tick_v = [8400, 8600, 8800, 9000, 9200]
		x_tick_n = ['8400', '8600', '8800', '9000', '9200']
		z_tick_n = ['5.03', '5.17', '5.31', '5.46', '5.60']
		
	endif
	
	if s eq 1 then begin
		x_tick_v = [ 8600, 8800, 9000, 9200, 9400, 9600]
		x_tick_n = [ '8600', '8800', '9000', '9200', '9400', '9600']
		z_tick_n = [ '5.17', '5.31', '5.46', '5.60','5.75', '5.89']
		
	endif
	
	if s eq 2 then begin
		x_tick_v = [ 8600, 8800, 9000, 9200, 9400, 9600]
		x_tick_n = [ '8600', '8800', '9000', '9200', '9400', '9600']
		z_tick_n = [ '5.17', '5.31', '5.46', '5.60','5.75', '5.89']
		
	endif
	
	if s eq 3 then begin
		x_tick_v = [ 8800, 9000, 9200, 9400, 9600, 9800]
		x_tick_n = [ '8800', '9000', '9200', '9400', '9600', '9800']
		z_tick_n = ['5.31', '5.46', '5.60', '5.75', '5.89', '6.03']
		
	endif
	binned_fits_name = fits_path + SOL + '_si4_h_acc_cd0d1_z0d01.fits'
	completeness_result = mrdfits(binned_fits_name, 1)
	lambda = (1.0 + completeness_result.z)*si4_1393	

		for c = 0, 1 do begin

			if c eq 0 then begin
				sigma5_result = completeness_result.s5*250
				plot_name = '_all.ps'
				
			endif
			
			if c eq 1 then begin
				sigma5_result = completeness_result.s3*250
				plot_name = '_all_s3.ps'
				
			endif	
				
					
			index = where(sigma5_result le 10)
			sigma5_result[index] = 10.
			
			plot_name = plot_path + SOL + '/'+ SOL + plot_name
			print, plot_name
							
			SET_PLOT, 'PS'
		    !p.font=-1
				DEVICE, filename = plot_name, /color, xsize=12, ysize=6, /encapsulated, /inches

					loadct, 0
					fake_y_axis = fltarr(n_elements(lambda))
					fake_y_axis[*] = 0.0

					y_title = 'log(N)/cm!A2!N' ;(log(N)/cm!A2!N)'
					x_title = 'Wavelength (' + string(197b) + ')'

					plot, lambda, tick_indeces, POSITION=[0.15, 0.2, 0.98, 0.7], $
						xr=[lambda_min, lambda_max], yr = [12.2, 13.6], $
						xstyle=8, ystyle=8, $
						XTICKS = n_elements(x_tick_v)-1,  XTICKV=x_tick_v, $
						XTICKNAME = x_tick_v, xticklen=-0.04, $
						YTICKS = n_elements(tick_indeces)-1, YTICKV = tick_indeces, $ 
						YTICKNAME = tick_values, $
						xtitle = x_title, ytitle = y_title, $
						xthick = 4, ythick = 4, charthick = 6, charsize = 2.0,  $
						/NODATA
					loadct, 3

					contour, sigma5_result, lambda,  completeness_result.c_d, $
						     /irregular, LEVELS=[0, 125, 150, 175, 200, 225, 251], /fill, $
						     c_colors = [0, 125, 150, 175, 200, 225, 251], /OVERPLOT 

					AXIS, YAXIS=0, YTICKS = n_elements(tick_indeces) - 1, YTICKV = tick_indeces, $
						  YTICKN=tick_values_blank, $
						  ythick = 4, charthick = 6, charsize = 2

					AXIS, YAXIS=1, YTICKS = n_elements(tick_indeces) - 1, YTICKV = tick_indeces, $
						    YTICKN=tick_values_blank, $
						    ythick = 4, charthick = 6, charsize = 2

					AXIS, XAXIS=0, XTICKS=n_elements(x_tick_v)-1, XTICKV=x_tick_v, $
							XTICKN =   [' ', ' ', ' ', ' ', ' ', ' '], $
						  xthick = 3, charthick = 6, charsize = 2

					AXIS, XAXIS=1, XTICKS=n_elements(x_tick_v)-1, XTICKV=x_tick_v, $
						    XTICKN=z_tick_n, $
						    XTITLE='Redshift', XCHARSIZE =2, xthick = 5, charthick = 6
		

					COLORBAR, NCOLORS=250, POSITION=[0.3, 0.84, 0.83, 0.88], DIVISIONS=6, $
						        TICKNAMES=['0', '50', '60', '70', '80', '90', '100'], /TOP, $
										RANGE = [125, 250] 

					
					title_location = (max(x_tick_v) - min(x_tick_v))/2.  + min(x_tick_v) - 150.0
					xyouts, title_location, 14.25, file_title, charthick = 5, charsize = 2
					

				device, /close
				
				
				
	endfor
endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
for s = 0, n_elements(sightline) - 1 do begin
	SOL = sightline[s]	
	file_title = ps_title[s]
	
	
	lambda_min = 1217*(1. + redshift_array[s])
	lambda_max = si4_1393*(1. + redshift_array[s]) - 50.
	
	
	if s eq 0 then begin
		x_tick_v = [8400, 8600, 8800, 9000, 9200, 9400]
		x_tick_n = ['8400', '8600', '8800', '9000', '9200', '9400']
		z_tick_n = ['5.03', '5.17', '5.31', '5.46', '5.60','5.75']
		
	endif
	
	if s eq 1 then begin
		x_tick_v = [ 8600, 8800, 9000, 9200, 9400, 9600]
		x_tick_n = [ '8600', '8800', '9000', '9200', '9400', '9600']
		z_tick_n = [ '5.17', '5.31', '5.46', '5.60','5.75', '5.89']
		
	endif
	
	if s eq 2 then begin
		x_tick_v = [ 8600, 8800, 9000, 9200, 9400, 9600]
		x_tick_n = [ '8600', '8800', '9000', '9200', '9400', '9600']
		z_tick_n = [ '5.17', '5.31', '5.46', '5.60','5.75', '5.89']
		
	endif
	
	if s eq 3 then begin
		x_tick_v = [ 8800, 9000, 9200, 9400, 9600, 9800]
		x_tick_n = [ '8800', '9000', '9200', '9400', '9600', '9800']
		z_tick_n = ['5.31', '5.46', '5.60', '5.75', '5.89', '6.03']
		
	endif
	
	binned_fits_name = fits_path + SOL + '_art_si4_h_acc_cd0d1_z0d01.fits'
	completeness_result = mrdfits(binned_fits_name, 1)
	lambda = (1.0 + completeness_result.z)*si4_1393	

		for c = 0, 1 do begin

			if c eq 0 then begin
				sigma5_result = completeness_result.s5*250
				plot_name = '_art_all.ps'
				
			endif
			
			if c eq 1 then begin
				sigma5_result = completeness_result.s3*250
				plot_name = '_art_all_s3.ps'
				
			endif	
				
					
			index = where(sigma5_result le 10)
			sigma5_result[index] = 10.
			
			plot_name = plot_path + SOL + '/'+ SOL + plot_name
			print, plot_name
							
			SET_PLOT, 'PS'
		    !p.font=-1
				DEVICE, filename = plot_name, /color, xsize=12, ysize=6, /encapsulated, /inches

					loadct, 0
					fake_y_axis = fltarr(n_elements(lambda))
					fake_y_axis[*] = 0.0

					y_title = 'log(N)/cm!A2!N' ;(log(N)/cm!A2!N)'
					x_title = 'Wavelength (' + string(197b) + ')'

					plot, lambda, tick_indeces, POSITION=[0.15, 0.2, 0.98, 0.7], $
						xr=[lambda_min, lambda_max], yr = [12.2, 13.6], $
						xstyle=8, ystyle=8, $
						XTICKS = n_elements(x_tick_v)-1,  XTICKV=x_tick_v, $
						XTICKNAME = x_tick_v, xticklen=-0.04, $
						YTICKS = n_elements(tick_indeces)-1, YTICKV = tick_indeces, $ 
						YTICKNAME = tick_values, $
						xtitle = x_title, ytitle = y_title, $
						xthick = 4, ythick = 4, charthick = 6, charsize = 2.0,  $
						/NODATA
					loadct, 3

					contour, sigma5_result, lambda,  completeness_result.c_d, $
						     /irregular, LEVELS=[0, 125, 150, 175, 200, 225, 251], /fill, $
						     c_colors = [0, 125, 150, 175, 200, 225, 251], /OVERPLOT 

					AXIS, YAXIS=0, YTICKS = n_elements(tick_indeces) - 1, YTICKV = tick_indeces, $
						  YTICKN=tick_values_blank, $
						  ythick = 4, charthick = 6, charsize = 2

					AXIS, YAXIS=1, YTICKS = n_elements(tick_indeces) - 1, YTICKV = tick_indeces, $
						    YTICKN=tick_values_blank, $
						    ythick = 4, charthick = 6, charsize = 2

					AXIS, XAXIS=0, XTICKS=n_elements(x_tick_v)-1, XTICKV=x_tick_v, $
							XTICKN =   [' ', ' ', ' ', ' ', ' ', ' '], $
						  xthick = 3, charthick = 6, charsize = 2

					AXIS, XAXIS=1, XTICKS=n_elements(x_tick_v)-1, XTICKV=x_tick_v, $
						    XTICKN=z_tick_n, $
						    XTITLE='Redshift', XCHARSIZE =2, xthick = 5, charthick = 6
		

					COLORBAR, NCOLORS=250, POSITION=[0.3, 0.84, 0.83, 0.88], DIVISIONS=6, $
						        TICKNAMES=['0', '50', '60', '70', '80', '90', '100'], /TOP, $
										RANGE = [125, 250] 

					
					title_location = (max(x_tick_v) - min(x_tick_v))/2.  + min(x_tick_v) - 150.0
					xyouts, title_location, 14.25, file_title, charthick = 5, charsize = 2
					

				device, /close
				
				
				
	endfor
endfor




END