;	take in the split fits and compute the S/N 
;	as well as the user_success and user_failure
;   value associated with the detection (or non-detection)
;   it will take in the split file
;
pro add_human_acceptance_to_real_si4, cd_index

fits_input_path = '/lustre/projects/p036_swin/alexc/completeness_test/si4/fits/'

column_density_range = dindgen(16)/10 + 12.2
column_density_range = column_density_range[cd_index]
cd_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_string = strmid(strtrim(string(cd_index),1),0,2)
cd_index_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_index_string = strmid(strtrim(string(cd_index),1),0,2)


input_fits_name = fits_input_path + 'si4_single_profiles_' + cd_index_string + '.fits'
input_fits = mrdfits(input_fits_name, 1)

si4_1393 = 1393.76018
si4_1402 = 1402.77291

completeness_results_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/real_mg2_results/'
output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'

SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]

;	output fits
str = {c_d:0.0, $
	   b:0.0, $
	   z:0.0, $
	   sn1393:0.0, $
	   sn1402:0.0, $
	   sol:' ', $
	   user_success_1393:0.0, $
	   user_failure_1393:0.0, $
	   user_success_1402:0.0, $
	   user_failure_1402:0.0}

output_fits = replicate(str, n_elements(SOLS)*n_elements(input_fits.b))
output_name = fits_input_path + 'real_si4_human_acc_fail_' + cd_index_string + '.fits'
	  			          

local_counter = 0.0
for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	sol_string = strmid(strtrim(string(s), 1),0, 1)
	;	read in the original spectra with the correct precision
		original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
						SOL + "/" + SOL + "_combined_spectra.dat"
		readcol, original_file, l, f, e, v, format=('D, D, D, D'), /silent
	
		for i = 0, n_elements(input_fits.z) - 1 do begin
			vpf = input_fits[i].vp
			artificial_vpf    = fltarr(n_elements(vpf))
			artificial_vpf[*] = 1.0
		
			;	find the second feature of the doublet
			doublet_index = where(vpf lt 0.9999 and l lt (si4_1402 + 30.)*(1.0 + input_fits[i].z) )
			doublet_index_diff = fltarr(n_elements(doublet_index) - 1)
		
				for doublet_index_iter = 0, n_elements(doublet_index)-2 do begin
					doublet_index_diff[doublet_index_iter] = $
						doublet_index[doublet_index_iter + 1] - doublet_index[doublet_index_iter]
		
				endfor
				;stop
			doublet_index_break = where(doublet_index_diff gt 1.0)

			;	si41393 feature only 
				vp1393     = vpf[doublet_index[0:doublet_index_break]]
				flux1393   =   f[doublet_index[0:doublet_index_break]]
				error1393  =   e[doublet_index[0:doublet_index_break]]
				lambda1393 =   l[doublet_index[0:doublet_index_break]]
			
				intflux1393 = flux1393*vp1393
				sn1393 = total(1.0 - intflux1393)/total(error1393)
				if sn1393 lt 0.0 then sn1393 = 0.0
			
				failure1393 = 0.04*sn1393 -0.001
				if sn1393 ge 5.304 then failure1393 = -1.0*0.029*sn1393 + 0.365
				if failure1393 lt 0.0 then failure1393 = 0.0
				
				
			;	si41402 feature only 
				vp1402     = vpf[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				flux1402   =   f[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				error1402  =   e[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				lambda1402 =   l[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
			
				intflux1402 = flux1402*vp1402
				sn1402 = total(1.0 - intflux1402)/total(error1402)
				if sn1402 lt 0.0 then sn1402 = 0.0
			
				failure1402 = 0.04*sn1402 -0.001
				if sn1402 ge 5.304 then failure1402 = -1.0*0.029*sn1402 + 0.365
				if failure1402 lt 0.0 then failure1402 = 0.0
			
			output_fits[local_counter].c_d = input_fits[i].c_d
			output_fits[local_counter].b = input_fits[i].b
			output_fits[local_counter].z = input_fits[i].z
			output_fits[local_counter].sn1393 = sn1393
			output_fits[local_counter].sn1402 = sn1402
			output_fits[local_counter].sol = SOL
			
			output_fits[local_counter].user_success_1393 = 0.97*(1.0 -exp(-1.0*sn1393/0.993))
			output_fits[local_counter].user_failure_1393 = failure1393
			
			output_fits[local_counter].user_success_1402 = 0.97*(1.0 -exp(-1.0*sn1402/0.993))
			output_fits[local_counter].user_failure_1402 = failure1402
		
			local_counter = local_counter + 1.0
			
			print, s, i, local_counter
		
	endfor
endfor

;	rewrite the fits
mwrfits, output_fits, output_name, /create
print, output_name



END
