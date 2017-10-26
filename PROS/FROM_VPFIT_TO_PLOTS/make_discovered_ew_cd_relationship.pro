
pro make_discovered_ew_cd_relationship

	vp_profile_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/S0927/individual_voigt_profiles/'

	mg2list = vp_profile_path + 'mg2_list'	
	readcol, mg2list, list, format = 'A'
	
	name_id = 'S0927'
	name_files = 'S0927_analysis.fits'
	fits_file = mrdfits(name_files, 1)

;	select mg2 only elements
	vis_index = where(fits_file.VIS_ELEMENT eq "MgII")
	nir_index = where(fits_file.NIR_ELEMENT eq "MgII")

	mg2_redshifts = [fits_file.vis_z[vis_index], fits_file.nir_z[nir_index]]
	mg2_b =  [fits_file.vis_b[vis_index], fits_file.nir_b[nir_index]]
	mg2_cd =  [fits_file.vis_cd[vis_index], fits_file.nir_cd[nir_index]]
	
	total_spec = 'S0927_total_mg2_fit_spectra.dat'

openw, lun, "S0927_ew99.txt", /get_lun
printf, lun, ""
printf, lun, " the columns are:"
printf, lun, " name_of_file,z, c_d, b, ew_single_fit_2796, num_pix, delta_lambda"


;	cycle through each individual profile
for i = 0, n_elements(list) - 1 do begin
	
	print, i
	local_mg_file = vp_profile_path + list[i]
	
	print, local_mg_file
	readcol, local_mg_file, lmg, fmg, ermg, vpmg, /silent
		

	;	get redshift from the name of the file
		red1 = strmid(strtrim(list[i]),11,1)
		red2 = strmid(strtrim(list[i]),13,5)
		ew_name = red1 + "." + red2
		real_redshift = float(ew_name)
	
	;	get the voigt profile parameter
		redshift_index = findel(real_redshift, mg2_redshifts)
		
	; identify the fit regions
 		fit_region_index = where(vpmg lt 1)


	; find 2796 feature
    index_2796 = where(lmg[fit_region_index] lt 2801.0*(1. +  real_redshift) and lmg[fit_region_index] gt 2750.0*(1. +  real_redshift))
		flux_2796 = fmg[fit_region_index[index_2796]]
		lambda_2796 = lmg[fit_region_index[index_2796]]
  	error_2796 = ermg[fit_region_index[index_2796]]
		fit_2796 = vpmg[fit_region_index[index_2796]]
  
  
	;	find 2803 feature
	 	index_2803= where(lmg[fit_region_index] gt 2801.0*(1. +  real_redshift))
  	flux_2803 = fmg[fit_region_index[index_2803]]
  	lambda_2803 = lmg[fit_region_index[index_2803]]
  	error_2803 = ermg[fit_region_index[index_2803]]
  	fit_2803 = vpmg[fit_region_index[index_2803]]

  		
	;	find the minimum of 2796
  	min_index = where(fit_2796 eq min(fit_2796))
  	lambda_index_mg2796 = fit_region_index[index_2796[min_index]]
	  
	;	find the minimum of 2803
  	min_index_2803 = where(fit_2803 eq min(fit_2803))
  	lambda_index_mg2803 = fit_region_index[index_2803[min_index_2803]]
  
	  

	;	get delta_lambda
  	delta_lambda = (lmg[fit_region_index[index_2796[min_index]]] - $ 
									 lmg[fit_region_index[index_2796[min_index - 1]]]) $
	 									/(1. +  real_redshift)
  
	; create 99% value for 2796 feature
  	ew = total(1. - fit_2796)*delta_lambda
  	ew99 = 99.*ew/100.
	  
	  
	;	create 99% value for 2803 feature
  	ew2803 = total(1. - fit_2803)*delta_lambda
  	ew2803_99 = 99.*ew2803/100
  
	  
	;	2796 feature statistic  
  	local_temp_2796 = 0.0
  	ind_2796 = [min_index]

	  
	; get minimum 3 pixels ew value by creating a new index array
		d = 1
		while(local_temp_2796 le ew99) do begin
			  ind_2796 = [min_index - d, ind_2796, min_index + d]
			  local_temp_2796 = total(1. - fit_2796[ind_2796]) * delta_lambda
			  print, d
  			  d = d + 1

		endwhile
	
  if local_temp_2796 lt ew99 then stop

  number_of_pixels = d

  new_pixels = n_elements(ind_2796)
  
  vp2796=fit_2796[ind_2796]
  error2796=error_2796[ind_2796]
  flux2796=flux_2796[ind_2796]
  lambda2796=lambda_2796[ind_2796]

  total_fit2796 = fit_2796[ind_2796]  

  ew_vp_2796 = 0.0
  ew_flux_2796 = 0.0
  ew_err_2796 = 0.0
  ew_total_mg2_2796 = 0.0
  ew_global_mg2_2796 = 0.0

  for x  = 0, n_elements(vp2796) - 1 do begin
		ew_vp_2796 = ew_vp_2796 + (1. - vp2796[x])*delta_lambda
	  ew_flux_2796 = ew_flux_2796 + (1. - flux2796[x])*delta_lambda
	  ew_err_2796 = ew_err_2796 + (error2796[x]*error2796[x]*delta_lambda*delta_lambda)

  endfor

	ew_err_2796 = SQRT(ew_err_2796)

  ;	2803 feature statistic
	  local_temp_2803 = 0.0
	  ind_2803 = [min_index_2803]	  

  new_line = list[i] + " " + string(mg2_redshifts[redshift_index]) + " " + $
														 string(mg2_cd[redshift_index]) + " " + $
 														 string(mg2_b[redshift_index]) + " " + $
													   string(ew_vp_2796) + " " + $
				                     string(number_of_pixels) + " " + $
														 string(delta_lambda)	
	print, new_line
  printf, lun, ""
  printf, lun, new_line

endfor

close, /all


end





