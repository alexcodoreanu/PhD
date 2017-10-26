pro get_bar_values_si4

	sightline = ['S0927', 'S1306', 'U0148', 'U1319']

	;	redshift bins are 4.34 - 5.19 - 6.13
	zmin = [4.34, 5.19, 4.34, 4.34]
	zmax = [5.19, 6.13, 6.13, 5.48]

	;	get real failure
	failure_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/'
	s = 0
	sol = sightline[s]
	failure_fits_name = failure_path + sol + '_failure_c_cd0d1_z0d01.fits'
  failure_fits = mrdfits(failure_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		failure_fits_name = failure_path + sol + '_failure_c_cd0d1_z0d01.fits'
		temp_fits_name = mrdfits(failure_fits_name, 1, /silent)
		
		failure_fits = [failure_fits, temp_fits_name]
		
	endfor
	
	print, 'human_failure'
	for z = 0, n_elements(zmin) - 1 do begin
		zindex = where(failure_fits.z ge zmin[z] and failure_fits.z lt zmax[z])
		aa = finite(failure_fits[zindex].USER_FAILURE_1393)
		aaa = where(aa lt 1)
		failure_fits[zindex[aaa]].USER_FAILURE_1393 = 0.0
				
		print, zmin[z], zmax[z], total(failure_fits[zindex].USER_FAILURE_1393)/n_elements(zindex)
		
	endfor

	;	get cbar
	cbar_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/results/'
	s = 0
	sol = sightline[s]
	cbar_fits_name = cbar_path + sol + '_si4_h_acc_cd0d1_z0d01.fits'
  cbar_fits = mrdfits(cbar_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		cbar_fits_name = cbar_path + sol + '_si4_h_acc_cd0d1_z0d01.fits'
		temp_fits = mrdfits(cbar_fits_name, 1, /silent)
		
		cbar_fits = [cbar_fits, temp_fits]
		
	endfor
	
	print, 'c_bar, 3sigma,  5sigma'
	for z = 0, n_elements(zmin) - 1 do begin
		zindex = where(cbar_fits.z ge zmin[z] and cbar_fits.z lt zmax[z])
		aa = finite(cbar_fits[zindex].s3)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s3 = 0.0
		
		aa = finite(cbar_fits[zindex].s5)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then cbar_fits[zindex[aaa]].s5 = 0.0
		
		

		print, zmin[z], zmax[z], $
			total(cbar_fits[zindex].s3)/n_elements(zindex), $
			total(cbar_fits[zindex].s5)/n_elements(zindex)
		
	endfor
	
	
	;	get lbar
	lbar_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/results/'
	s = 0
	sol = sightline[s]
	lbar_fits_name = lbar_path + sol + '_binned_cd0d1_z0d01.fits'
  lbar_fits = mrdfits(lbar_fits_name, 1, /silent)
	
	for s = 1, n_elements(sightline) - 1 do begin
		sol = sightline[s]
		lbar_fits_name = lbar_path + sol + '_binned_cd0d1_z0d01.fits'
		temp_fits = mrdfits(lbar_fits_name, 1, /silent)
		
		lbar_fits = [lbar_fits, temp_fits]
		
	endfor
	
	print, 'l_bar, 3sigma,  5sigma'
	for z = 0, n_elements(zmin) - 1 do begin
		zindex = where(lbar_fits.z ge zmin[z] and lbar_fits.z lt zmax[z])
		aa = finite(lbar_fits[zindex].s3)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s3 = 0.0
		
		aa = finite(lbar_fits[zindex].s5)
		aaa = where(aa lt 1)
		if aaa[0] ge 0.0 then lbar_fits[zindex[aaa]].s5 = 0.0
		
		

		print, zmin[z], zmax[z], $
			total(lbar_fits[zindex].s3)/n_elements(zindex), $
			total(lbar_fits[zindex].s5)/n_elements(zindex)
		
	endfor
	
	stop

END