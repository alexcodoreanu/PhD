pro get_bar_values, zmin, zmax, ion, real
	
	path = '/lustre/projects/p036_swin/alexc/completeness_test/'
	ion_path = path + ion + '/'
	fits_path = ion_path + 'fits/results/'
	sightline = ['S0927', 'S1306', 'U0148', 'U1319']

	;	get real failure
	s = 0
	sol = sightline[s]
	failure_fits_name = fits_path + sol + '_failure_c_cd0d1_z0d01.fits'	
	if real gt 0 then failure_fits_name = fits_path + sol + '_art_failure_c_cd0d1_z0d01.fits'	
  failure_fits = mrdfits(failure_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		failure_fits_name = fits_path + sol + '_failure_c_cd0d1_z0d01.fits'
		if real gt 0 then failure_fits_name = fits_path + sol + '_art_failure_c_cd0d1_z0d01.fits'	
		temp_fits_name = mrdfits(failure_fits_name, 1, /silent)
		failure_fits = [failure_fits, temp_fits_name]
		
	endfor
	

	zindex = where(failure_fits.z ge zmin and failure_fits.z lt zmax)
	
	if ion eq 'c4' then begin
		aa = finite(failure_fits[zindex].USER_FAILURE_1548)
		aaa = where(aa lt 1)
		failure_fits[zindex[aaa]].USER_FAILURE_1548 = 0.0
		print, 'human_failure, true --', ion, ' ',  string(zmin), string(zmax), $
					 							total(failure_fits[zindex].USER_FAILURE_1548)/n_elements(zindex)
	endif
		
	if ion eq 'si4' then begin
		aa = finite(failure_fits[zindex].USER_FAILURE_1393)
		aaa = where(aa lt 1)
		failure_fits[zindex[aaa]].USER_FAILURE_1393 = 0.0
		print, 'human_failure, artificial --',  ion, ' ',  string(zmin), string(zmax), $
					 							total(failure_fits[zindex].USER_FAILURE_1393)/n_elements(zindex)
		
	endif
		

	;	get cbar
	s = 0
	sol = sightline[s]
	cbar_fits_name = fits_path + sol + '_' + ion + '_h_acc_cd0d1_z0d01.fits'
	if real gt 0 then	cbar_fits_name = fits_path + sol + '_art_' + ion + '_h_acc_cd0d1_z0d01.fits'
  cbar_fits = mrdfits(cbar_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		cbar_fits_name = fits_path + sol + '_' + ion + '_h_acc_cd0d1_z0d01.fits'
		if real gt 0 then	cbar_fits_name = fits_path + sol + '_art_' + ion + '_h_acc_cd0d1_z0d01.fits'
		temp_fits = mrdfits(cbar_fits_name, 1, /silent)
		cbar_fits = [cbar_fits, temp_fits]
		
	endfor
	
	zindex = where(cbar_fits.z ge zmin and cbar_fits.z lt zmax)
	aa = finite(cbar_fits[zindex].s3)
	aaa = where(aa lt 1)
	if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s3 = 0.0
	
	aa = finite(cbar_fits[zindex].s5)
	aaa = where(aa lt 1)
	if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s5 = 0.0

	
	if real eq 0 then print, 'c_bar, true --', ion, ' 3sigma, ', $
		total(cbar_fits[zindex].s3)/n_elements(zindex), ' 5sigma', $
			total(cbar_fits[zindex].s5)/n_elements(zindex)
	if real gt 0 then print, 	'c_bar, artificial --', ion, ' 3sigma, ', $
					total(cbar_fits[zindex].s3)/n_elements(zindex), ' 5sigma', $
						total(cbar_fits[zindex].s5)/n_elements(zindex)
		

	
	;	get lbar
	s = 0
	sol = sightline[s]
	lbar_fits_name = fits_path + sol + '_binned_cd0d1_z0d01.fits'
	if real gt 0 then	lbar_fits_name = fits_path + sol + '_art_binned_cd0d1_z0d01.fits'
 
  lbar_fits = mrdfits(lbar_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		lbar_fits_name = fits_path + sol + '_binned_cd0d1_z0d01.fits'
		if real gt 0 then	lbar_fits_name = fits_path + sol + '_art_binned_cd0d1_z0d01.fits'
		temp_fits = mrdfits(lbar_fits_name, 1, /silent)
		
		lbar_fits = [lbar_fits, temp_fits]
		
	endfor
	
	zindex = where(lbar_fits.z ge zmin and lbar_fits.z lt zmax)
	aa = finite(lbar_fits[zindex].s3)
	aaa = where(aa lt 1)
	if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s3 = 0.0
	
	aa = finite(lbar_fits[zindex].s5)
	aaa = where(aa lt 1)
	if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s5 = 0.0
	
	if real eq 0 then print, 'l_bar, true --', ion, string(zmin), string(zmax),' 3sigma, ', $
		total(lbar_fits[zindex].s3)/n_elements(zindex), ' 5sigma', $
			total(lbar_fits[zindex].s5)/n_elements(zindex)
	if real gt 0 then  print, 'l_bar, artificial --', ion, string(zmin), string(zmax),' 3sigma, ', $
 		total(lbar_fits[zindex].s3)/n_elements(zindex), ' 5sigma', $
 			total(lbar_fits[zindex].s5)/n_elements(zindex)		
	
	
END