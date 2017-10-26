pro make_artificial_redshift_ew_completeness_list


mg2_2796 = 2796.3542699	

fp_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_false_positive/'
fp_completeness_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_mg2_results/'

real_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/'
real_completeness_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'

ids = ['0', '1', '2', '3']
SOLS = ['S0927',  'U0148', 'S1306',  'U1319']

openw, lun, 'artificial_lambda_ew_completeness.dat', /get_lun

for s = 0, n_elements(SOLS) - 1 do begin
	;	get discovery file
	real_discovery_name = fp_path + SOLS[s] + '_artificial_mg2_systems.fits'
	real = mrdfits(real_discovery_name, 1, /silent)
	
	;	get completeness file
    real_completeness_name = fp_completeness_path + 'binned_ew_0d01_l_28A_5_' + ids[s] + '.fits'
	real_completeness = mrdfits(real_completeness_name, 1, /silent)

	systems = real[uniq(real.system)].system
	
	for n = 0, n_elements(systems) - 1 do begin
		local_system = systems[n]
		real_index_s3 = where(real.system eq local_system)
		
		local_ew     = real[real_index_s3].SYS_EW
		local_ew_err = real[real_index_s3].SYS_EW_ERR
		
		
		local_v  = real[real_index_s3].SYS_V
		local_v_err  = real[real_index_s3].SYS_V_ERR
		
		local_s3 = real[real_index_s3].S3
		local_s5 = real[real_index_s3].S5
		local_z = real[real_index_s3].z
		
		local_lambda = (local_z + 1.0)*mg2_2796
		
		print, SOLS[s], local_lambda, local_ew, local_ew_err, local_v, local_v_err, local_s3, local_s5
		
	endfor
endfor


close, /all




END