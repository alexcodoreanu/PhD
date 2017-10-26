pro unit_test, SOL, element, z_index

	

	profiles_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/profiles/'
	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/' + element + '/fits/'

	fits_name = fits_path + element + "_" + SOL +  "_z_index_" + z_index + ".fits"
	a = mrdfits(fits_name, 1)
	
	original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
					SOL + "/" + SOL + "_combined_spectra.dat"
	readcol, original_file, l, f, e, v, format=('D, D, D, D')
	
	if element eq 'c4' then begin
		l1 = 1547.
		l2 = 1553.
		
	endif
	
	if element eq 'si4' then begin
		l1 = 1392.
		l2 = 1404.
		
	endif
	
	
	
	for x = 0, 15 do begin
		random_a_index = uint(n_elements(a.b)*randomu(seed, 1))
		random_z_redshift =  uint(n_elements(a[0].redshift)*randomu(seed, 1))
		
		lambda_min = l1*(1. + a[random_a_index].redshift[random_z_redshift])
		lambda_max = l2*(1. + a[random_a_index].redshift[random_z_redshift])
		
		
		
		plot_title = SOL + ' ' + element + ' z= ' + strmid(strtrim(string(a[random_a_index].redshift[random_z_redshift]),1),0,4) + $
			', cd = ' + strmid(strtrim(string(a[random_a_index].column_density),1),0,4) + $
			', b = ' + strmid(strtrim(string(a[random_a_index].b),1),0,4)


		plot, l, a[random_a_index].flux, yr = [0, 1.5], xr = [lambda_min, lambda_max], xstyle = 1, ystyle = 1, charsize = 2, $
			title = plot_title, psym = 10
		oplot, l, f, thick=2, linestyle = 2
		oplot, l, a[random_a_index].flux/f, linestyle = 3
		oplot, l, e, psym = 10
		
		stop
		
		
	endfor


END