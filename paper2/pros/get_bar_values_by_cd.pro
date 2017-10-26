pro get_bar_values_by_cd, zmin, zmax, atom, real
	
	path = '/lustre/projects/p036_swin/alexc/completeness_test/'
	atom_path = path + atom + '/'
	fits_path = atom_path + 'fits/results/'
	sightline = ['S0927', 'S1306', 'U0148', 'U1319']

	if atom eq 'c4' then column_density_range = dindgen(20)/10 + 12.5 
	if atom eq 'si4' then column_density_range = dindgen(16)/10 + 12.2
	
	sol_redshift = [5.79, 5.99, 5.98, 6.13]
	lyalpha  = 1215.67
	si4_1393 = 1393.76018
	c4_1548  = 1548.2049

	if atom eq 'c4'  then atom_lambda = c4_1548
	if atom eq 'si4' then atom_lambda = si4_1393

	min_redshift = (1.0 + sol_redshift)*lyalpha/atom_lambda - 1.0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	get real failure
	s = 0
	sol = sightline[s]
	failure_fits_name = fits_path + sol + '_failure_c_cd0d1_z0d01.fits'	
	if real gt 0 then failure_fits_name = fits_path + sol + '_art_failure_c_cd0d1_z0d01.fits'	
  failure_fits = mrdfits(failure_fits_name, 1, /silent)
	z_min = zmin
	if zmin lt min_redshift[s] then z_min = min_redshift[s]

	z_max = zmax
	if zmax gt sol_redshift[s] then z_max = sol_redshift[s]
	zindex = where(failure_fits.z ge z_min and failure_fits.z lt z_max)
	failure_fits = failure_fits[zindex]
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		failure_fits_name = fits_path + sol + '_failure_c_cd0d1_z0d01.fits'
		if real gt 0 then failure_fits_name = fits_path + sol + '_art_failure_c_cd0d1_z0d01.fits'	
		temp_fits = mrdfits(failure_fits_name, 1, /silent)
		
		z_min = zmin
		if zmin lt min_redshift[s] then z_min = min_redshift[s]
		z_max = zmax
		if zmax gt sol_redshift[s] then z_max = sol_redshift[s]
		
		zindex = where(temp_fits.z ge z_min and temp_fits.z lt z_max)
		temp_fits = temp_fits[zindex]
		failure_fits = [failure_fits, temp_fits]
		
	endfor


	for c = 0, n_elements(column_density_range) - 1.0 do begin
		zindex = where(failure_fits.c_d gt column_density_range[c] - 0.02 and $
									 failure_fits.c_d lt column_density_range[c] + 0.02 )
		
		if atom eq 'c4' then begin
			aa = finite(failure_fits[zindex].USER_FAILURE_1548)
			aaa = where(aa lt 1)
			failure_fits[zindex[aaa]].USER_FAILURE_1548 = 0.0
			print, 'human_failure, artificial --',  atom, ' ',  $
				     string(zmin), string(zmax), $
					   string(column_density_range[c]), $
				 		 total(failure_fits[zindex].USER_FAILURE_1548)/n_elements(zindex)
		
		endif
		
		if atom eq 'si4' then begin
			aa = finite(failure_fits[zindex].USER_FAILURE_1393)
			aaa = where(aa lt 1)
			failure_fits[zindex[aaa]].USER_FAILURE_1393 = 0.0
			print, 'human_failure, artificial --',  atom, ' ',  $
				     string(zmin), string(zmax), $
					   string(column_density_range[c]), $
				 		 total(failure_fits[zindex].USER_FAILURE_1393)/n_elements(zindex)
		
		endif
	endfor	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	get cbar
	print, ' '
	s = 0
	sol = sightline[s]
	cbar_fits_name = fits_path + sol + '_' + atom + '_h_acc_cd0d1_z0d01.fits'
	if real gt 0 then	cbar_fits_name = fits_path + sol + '_art_' + atom + '_h_acc_cd0d1_z0d01.fits'
  cbar_fits = mrdfits(cbar_fits_name, 1, /silent)
	z_min = zmin
	if zmin lt min_redshift[s] then z_min = min_redshift[s]
	z_max = zmax
	if zmax gt sol_redshift[s] then z_max = sol_redshift[s]
	zindex = where(failure_fits.z ge z_min and failure_fits.z lt z_max)
	cbar_fits = cbar_fits[zindex]
	
	stop
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		cbar_fits_name = fits_path + sol + '_' + atom + '_h_acc_cd0d1_z0d01.fits'
		if real gt 0 then	cbar_fits_name = fits_path + sol + '_art_' + atom + '_h_acc_cd0d1_z0d01.fits'
		temp_fits = mrdfits(cbar_fits_name, 1, /silent)
		
		z_min = zmin
		if zmin lt min_redshift[s] then z_min = min_redshift[s]
		z_max = zmax
		if zmax gt sol_redshift[s] then z_max = sol_redshift[s]
		
		zindex = where(temp_fits.z ge z_min and temp_fits.z lt z_max)
		temp_fits = temp_fits[zindex]
		cbar_fits = [cbar_fits, temp_fits]
	
	endfor
	
	for c = 0, n_elements(column_density_range) - 1.0 do begin
		zindex = where(cbar_fits.c_d gt column_density_range[c] - 0.02 and $
									 cbar_fits.c_d lt column_density_range[c] + 0.02 )
		
		aa = finite(cbar_fits[zindex].s3)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s3 = 0.0
	
		aa = finite(cbar_fits[zindex].s5)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s5 = 0.0
		if real eq 0 then print, 'c_bar, true --', atom, $
			string(zmin), string(zmax), $
			string(column_density_range[c]), $
			total(cbar_fits[zindex].s5)/n_elements(zindex)
		if real gt 0 then print, 	'c_bar, artificial --', atom, $
			string(zmin), string(zmax), $
			string(column_density_range[c]), $
			total(cbar_fits[zindex].s5)/n_elements(zindex)
		
	endfor
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	get lbar
	print, ' '
	s = 0
	sol = sightline[s]
	lbar_fits_name = fits_path + sol + '_binned_cd0d1_z0d01.fits'
	if real gt 0 then	lbar_fits_name = fits_path + sol + '_art_binned_cd0d1_z0d01.fits'
	lbar_fits = mrdfits(lbar_fits_name, 1, /silent)
	
	z_min = zmin
	if zmin lt min_redshift[s] then z_min = min_redshift[s]
	z_max = zmax
	if zmax gt sol_redshift[s] then z_max = sol_redshift[s]
	zindex = where(failure_fits.z ge z_min and failure_fits.z lt z_max)
	lbar_fits = lbar_fits[zindex]
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		lbar_fits_name = fits_path + sol + '_binned_cd0d1_z0d01.fits'
		if real gt 0 then	lbar_fits_name = fits_path + sol + '_art_binned_cd0d1_z0d01.fits'
		temp_fits = mrdfits(lbar_fits_name, 1, /silent)
		
		z_min = zmin
		if zmin lt min_redshift[s] then z_min = min_redshift[s]
		zindex = where(temp_fits.z ge z_min and temp_fits.z lt zmax)
		temp_fits = temp_fits[zindex]
		lbar_fits = [lbar_fits, temp_fits]
	
	endfor
	
	for c = 0, n_elements(column_density_range) - 1.0 do begin
		zindex = where(lbar_fits.c_d gt column_density_range[c] - 0.02 and $
									 lbar_fits.c_d lt column_density_range[c] + 0.02 )
		
		aa = finite(lbar_fits[zindex].s3)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s3 = 0.0
	
		aa = finite(lbar_fits[zindex].s5)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s5 = 0.0
	
		if real eq 0 then print, 'l_bar, true --', atom, $
			string(zmin), string(zmax),$
			string(column_density_range[c]), $
			total(lbar_fits[zindex].s5)/n_elements(zindex)
		if real gt 0 then  print, 'l_bar, artificial --', atom, $
			string(zmin), string(zmax),$
			string(column_density_range[c]), $
			total(lbar_fits[zindex].s5)/n_elements(zindex)		
	
	endfor
	
	
END