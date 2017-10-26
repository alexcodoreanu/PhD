pro make_SN_fits

mg2_2796 = 2796.3542699
mg2_2803 = 2803.5314853

;	output path
output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/SN_maps/SN_maps/'

;	plot path
plot_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/SN_maps/SN_plots/'

;	index selects the sightline	
SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]
pixels = [5, 9, 13]
s = 0
p = 0
SOL = SOLS[s]
local_pixels = pixels[p]
pixel_string = strmid(strtrim(string(local_pixels), 1),0, 1)	
if local_pixels gt 9 then pixel_string = strmid(strtrim(string(local_pixels), 1),0, 2)	

output_name = output_path + SOL + '_SN_' + pixel_string + '_pixels.dat'
readcol, output_name, lambda_min, lambda_max, SN_2796, SN_2803, format=('D, D, D'), /silent

str = {sol:' ', pixels:0.0, lambda_min:0.0, lambda_max:0.0, sn2796:0.0, sn2803:0.0}
output_str = replicate(str, n_elements(lambda_min))

output_str.sol    = SOL
output_str.pixels = local_pixels
output_str.lambda_min = lambda_min
output_str.lambda_max = lambda_max
output_str.sn2796 = SN_2796
output_str.sn2803 = SN_2803

;	read in the original spectra with the correct precision
for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	
	for p = 0, n_elements(pixels) - 1 do begin
		if s eq 0 and p eq 0 then p = 1
		local_pixels = pixels[p]
		pixel_string = strmid(strtrim(string(local_pixels), 1),0, 1)	
		if local_pixels gt 9 then pixel_string = strmid(strtrim(string(local_pixels), 1),0, 2)	
		
		output_name = output_path + SOL + '_SN_' + pixel_string + '_pixels.dat'
		readcol, output_name, lambda_min, lambda_max, SN_2796, SN_2803, format=('D, D, D'), /silent
		
		temp_str = replicate(str, n_elements(lambda_min))
		
		temp_str.sol    = SOL
		temp_str.pixels = local_pixels
		temp_str.lambda_min = lambda_min
		temp_str.lambda_max = lambda_max
		temp_str.sn2796 = SN_2796
		temp_str.sn2803 = SN_2803
		
		output_str = [output_str, temp_str]
		
	endfor
endfor


;	plot the SN maps
for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	for p = 0, n_elements(pixels) - 1 do begin
		local_pixels = pixels[p]
		pixel_string = strmid(strtrim(string(local_pixels), 1),0, 1)	
		if local_pixels gt 9 then pixel_string = strmid(strtrim(string(local_pixels), 1),0, 2)	
		
		sol_pixel_index = where(output_str.sol eq SOL and $
			                    output_str.pixels eq pixels[p])
		
		title_name = SOL + ' SN profile for MgII 2796 feature, ' + pixel_string + ' pixels'
		ps_name = plot_path + SOL + '_' + pixel_string + '_pixels.ps'
		
 		SET_PLOT, 'PS'
 		!p.font=0
  		DEVICE, filename = ps_name, /color, xsize=12, ysize=6, /encapsulated, /inches
			plot, output_str[sol_pixel_index].lambda_min, output_str[sol_pixel_index].sn2796, charsize = 1.5, $
				  xtitle = 'Wavelength', ytitle = 'S/N', title = title_name, xthick = 3, ythick = 3
		
		DEVICE, /close
		
		
	endfor
endfor	



mwrfits, output_str, 'SN_maps_by_sol_by_pix.fits', /create
stop



END