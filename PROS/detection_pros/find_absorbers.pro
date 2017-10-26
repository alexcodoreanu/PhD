;	find_absorbers.pro
;	takes in a spectra in fits format: Lambda, Flux, Error
;	and looks for absorption features of no less than 3 pixels.
;	It returns a fits structure for wavelength elements
;	which fullfill the required definition of an	
;	absorption feature.
;	S0927_3c_nir_up_plotvel.fits     U0148_3c_vis_up_plotvel.fits
;	S1306_3c_nir_up_plotvel.fits     s0927_uvis_xshooter_plotvel.fits
;	S1306_3c_vis_up_plotvel.fits     u1319_3c_nir_up_plotvel.fits
;	U0148_3c_nir_up_plotvel.fits     u1319_3c_vis_up_plotvel.fits

function find_absorbers, total_lambda, total_flux, total_error, redshift, sigma

	;	working_index will hold all wavelength elements past the Ly-alpha emission peak
		working_index=where(total_lambda gt 1217.0*(1.0+redshift[0]))
	
	;	extract lambda, flux, error, continuum arrays based on working_index
		lambda = total_lambda[working_index]
		flux = total_flux[working_index]
		error = total_error[working_index]


	;	check_array will hold the binary yes/no of whether a wavelength element meets the required 
	;	logic checks. The logic checks will evolve. -99 means No, 0 means Yes	
		check_array = fltarr(n_elements(lambda))
		check_array[*] = -99.0
	
	
	; 	select every possible lambda element and proceed with checks which will evolve over time
		for i = 2, n_elements(lambda)-3 do begin
			if flux[i] lt 1.0 then begin
				if flux[i-1] lt 1.0 or flux[i+1] lt 1.0 then begin
				
					flux1 = flux[i-1]
					flux2 = flux[i]
					flux3 = flux[i+1]

					if flux[i-1] lt 0.0 then flux1 = 1.0 - flux[i-1]
					if flux[i] lt 0.0 then flux2 = 1.0 - flux[i]
					if flux[i+1] lt 0.0 then flux3 = 1.0 - flux[i+1]

					sum_flux= flux1 + flux2 + flux3 
					sum_error = sqrt(error[i-1]*error[i-1] + error[i]*error[i] + error[i+1]*error[i+1])
					if sum_flux/sum_error ge sigma then check_array[i]=99.00	

				endif
			endif
		
		endfor
		index=where(check_array lt 0.0)
		flux[index]=1.0		
		

		str={lambda:fltarr(n_elements(working_index)), flux:fltarr(n_elements(working_index)), error:fltarr(n_elements(working_index))}
	
		result=replicate(str, 1)
	
	
		result.lambda=lambda
		result.flux=flux
		result.error=error

		return, result
	

	
	
	END

