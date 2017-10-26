;	take in the split fits and compute the S/N 
;	as well as the user_success and user_failure
;   value associated with the detection (or non-detection)
;   it will take in the split file
;
pro combine_human_acceptance_to_art_c4, cd_index

fits_input_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/'
fits_results_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/results/'

column_density_range = dindgen(20)/10 + 12.5
column_density_range = column_density_range[cd_index]
cd_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_string = strmid(strtrim(string(cd_index),1),0,2)
cd_index_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_index_string = strmid(strtrim(string(cd_index),1),0,2)


input_fits_name = fits_input_path + 'art_c4_human_acc_fail_' + cd_index_string + '.fits'
input_fits = mrdfits(input_fits_name, 1)

c4_1548 = 1548.2049
c4_1553 = 1553.77845


completeness_results_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/real_mg2_results/'
output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'

SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]


for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	sol_result_name = fits_results_path + 'c4_comp_art_sol_' + SOL + '_' + cd_index_string + '.fits'
	sol_results = mrdfits(sol_result_name, 1)
	
	sol_input_fits_index = where(input_fits.SOL eq SOL)
	sol_input = input_fits[sol_input_fits_index]
	
	rs = finite(sol_input.USER_SUCCESS_1548)
	sol_input[where(rs lt 1)].USER_SUCCESS_1548 = 0.0
	
	rs = finite(sol_input.USER_FAILURE_1548)
	sol_input[where(rs lt 1)].USER_FAILURE_1548 = 0.0
	
	rs = finite(sol_input.USER_SUCCESS_1553)
	sol_input[where(rs lt 1)].USER_SUCCESS_1553 = 0.0
	
	rs = finite(sol_input.USER_FAILURE_1553)
	sol_input[where(rs lt 1)].USER_FAILURE_1553 = 0.0
	
	human_acc_result_name = fits_results_path + 'c4_art_h_acc_sol_' + SOL + '_' + cd_index_string + '.fits'
	sol_results.s3 = sol_results.s3*sol_input.USER_SUCCESS_1548
	sol_results.s5 = sol_results.s5*sol_input.USER_SUCCESS_1548
	
	
	;	rewrite the fits
	mwrfits, sol_results, human_acc_result_name, /create
	print, human_acc_result_name


endfor


END
