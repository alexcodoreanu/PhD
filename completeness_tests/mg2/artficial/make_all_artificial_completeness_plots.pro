pro make_all_artificial_completeness_plots

plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/completeness_tests/mg2/artficial/completeness_maps/'
fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/'
SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
sigma_name = ['_mg2_map_3s.ps', '_mg2_map_5s.ps']
ps_title = ['SDSS J0927+2001', 'ULAS J0148+0600', 'SDSS J1306+0356', 'ULAS J1319+0950']

tick_indeces = [ 0.2,  0.4,  0.6,  0.8]
tick_values = [ ' ',  ' ', ' ', ' ' ]


pixels = [5, 7, 9, 11, 13, 15]


for z = 0, n_elements(pixels) - 1 do begin
	batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
	if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)

for local_index = 0, 3 do begin
	local_index_string = strmid(strtrim(string(local_index), 1),0, 1)	
	input_fits_name = fits_path + "binned_artificial_ew_0d01_l_28A_" + batch_index + "_" + local_index_string + ".fits"
	input_fits = mrdfits(input_fits_name, 1)
	ew_values = input_fits.ew 

	for x = 0, 1 do begin
		plotname = plot_path + SOLS[local_index]  + '_artificial_' + batch_index + '_pixels_' + sigma_name[x]
		print, plotname
		
		if x eq 0 then sigma_result = input_fits.sigma3*250
		if x eq 1 then sigma_result = input_fits.sigma5*250

		sigma_index = where(sigma_result le 50)
		sigma_result[sigma_index] = 50.
		;!p.font=0
		SET_PLOT, 'PS'

			DEVICE, filename = plotname, /color, xsize=12, ysize=6, /encapsulated, /inches

			loadct, 0
			fake_y_axis = fltarr(n_elements(input_fits.lambda))
			fake_y_axis[*] = 0.0

			y_title = 'Equivalent Width (' + string(197b) + ')'
			x_title = 'Wavelength (' + string(197b) + ')'

			plot, input_fits.lambda, tick_indeces, POSITION=[0.1, 0.16, 0.95, 0.7], $
				xr=[min(input_fits.lambda) + 1., 19516], yr = [0.05, .95], $
				xstyle=8, ystyle=8, $
				XTICKS = 4,  XTICKV = [10000, 12000, 14000, 16000, 18000], $
				XTICKNAME = ['', '', '', '', ''], $
				YTICKS = 3,  YTICKV = [ 0.2, 0.4,  0.6, 0.8], XTICKLEN = -0.02, $
				YTICKNAME = ['',  '', '',''], $
				xtitle = x_title, ytitle = y_title, $
				xthick = 4, ythick = 4, charthick = 6, charsize = 2.0,  $
				/NODATA

			loadct, 3
			 
			contour, sigma_result, input_fits.lambda, ew_values, /irregular, LEVELS=[0, 125, 150, 175, 200, 225, 251], /fill, $
			c_colors = color_vector, /OVERPLOT 

			AXIS, YAXIS=0, YTICKS=3, YTICKV=[ 0.2, 0.4,  0.6, 0.8], $
				  ythick = 4, charthick = 6, charsize = 2.0

			AXIS, YAXIS=1, YTICKS=3, YTICKV=[ 0.2, 0.4,  0.6, 0.8], YTICKN=[ ' ', ' ', ' ', ' '], $
				  ythick = 4, charthick = 6, charsize = 2.0

			;AXIS, XAXIS=0, XTICKS=4, XTICKV=[10000, 12000, 14000, 16000, 18000], $
			;	  xthick = 3, charthick = 6, charsize = 2.0

			AXIS, XAXIS=1, XTICKS=4, XTICKV=[10000, 12000, 14000, 16000, 18000], $
				  XTICKN=[ '2.57', '3.29', '4.00', '4.72', '5.43'], $
				  XTITLE='Redshift', XCHARSIZE =2.0, xthick = 5, charthick = 6
			

			COLORBAR, NCOLORS=250, POSITION=[0.2, 0.82, 0.85, 0.87], DIVISIONS=6, TICKNAMES=['0', '50', '60', '70', '80', '90', '100'], /TOP, $
			RANGE = [125, 250] 

			xyouts, 13100, 1.3, ps_title[local_index], charthick = 5, charsize = 2.0
			

		device, /close

	endfor
endfor
endfor

END