pro make_artificial_profiles

fits_output_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/'

spec_name = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/auto_comparison_plots/" + $
	"fit_spectra/S1306_total_mg2_fit_spectra.dat"
readcol, spec_name, lambda, flux, err, vp, format=('D, D, D, D'), /silent

redshift_min = 4.91
redshift = redshift_min + dindgen(122*4)*0.01/4.0

column_density_range = dindgen(16)/10 + 12.2
str = {c_d:0.0, b:0.0, z:0.0, vp:fltarr(n_elements(err))}

si4_1393 = 1393.76018
si4_1402 = 1402.77291
si4_1411 = si4_1393 + (si4_1402-si4_1393)*2

for c = 0, n_elements(column_density_range) - 1 do begin
	cd_index_string = strmid(strtrim(string(c),1),0,1)
	if c gt 9.0 then cd_index_string = strmid(strtrim(string(c),1),0,2)
	
	input_fits_name  = fits_output_path + 'si4_single_profiles_' + cd_index_string + '.fits'
	output_fits_name = fits_output_path + 'si4_artificial_single_profiles_' + cd_index_string + '.fits'
	original_fits = mrdfits(input_fits_name, 1)
	
	output_fits = replicate(str, n_elements(original_fits.z))
	

	for i = 0, n_elements(original_fits.z) - 1 do begin
		vpf = original_fits[i].vp[0:42000]
		artificial_vpf    = fltarr(n_elements(vpf))
		artificial_vpf[*] = 1.0
		
		;	find the second feature of the doublet
		doublet_index = where(vpf lt 0.9999)
		doublet_index_diff = fltarr(n_elements(doublet_index) - 1)
		
			for doublet_index_iter = 0, n_elements(doublet_index)-2 do begin
				doublet_index_diff[doublet_index_iter] = $
					doublet_index[doublet_index_iter + 1] - doublet_index[doublet_index_iter]
		
			endfor
		
		doublet_index_break = where(doublet_index_diff gt 1.0)
		artificial_vpf[0:doublet_index[doublet_index_break]] = vpf[[0:doublet_index[doublet_index_break]]]
		
		;	calculate where to insert the second feature
		min_art_lambda = double(lambda[doublet_index[doublet_index_break+1]]/si4_1402*si4_1411)
		
		
		aa = min_art_lambda - 0.2
		bb = min_art_lambda + 0.2
		
		;	find where to insert the feature
		insert_lambda = where(lambda gt aa[0] and lambda lt bb[0])
	
		artificial_vpf[insert_lambda[0]:insert_lambda[0]+n_elements(doublet_index_diff)-1-doublet_index_break] = $
			vpf[doublet_index[doublet_index_break:n_elements(doublet_index_diff)-1]]
	
		ind = where(artificial_vpf lt 1)
	;	plot, lambda, artificial_vpf, xr = [min(lambda[ind]) - 5, max(lambda[ind]) + 5]
	;	oplot, lambda, vpf
	;	stop
		
		
		output_fits[i].c_d   = original_fits[i].c_d
		output_fits[i].b     = original_fits[i].b  
		output_fits[i].vp    = artificial_vpf
		output_fits[i].z     = original_fits[i].z  
		
		print, i, n_elements(original_fits.z) - 1
		
	endfor

	mwrfits, output_fits, output_fits_name, /create

endfor



end