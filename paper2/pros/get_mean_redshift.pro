pro get_mean_redshift, zmin, zmax, ion, real
	
	path = '/lustre/projects/p036_swin/alexc/completeness_test/'
	ion_path = path + ion + '/'
	fits_path = ion_path + 'fits/results/'
	sightline = ['S0927', 'S1306', 'U0148', 'U1319']


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

	
	if real eq 0 then print, 'median redshift = ',median(cbar_fits[zindex].z) 
	
END