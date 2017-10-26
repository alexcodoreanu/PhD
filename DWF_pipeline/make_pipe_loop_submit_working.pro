pro make_pipe_loop_submit_working

	pipe_loop_path = "/lustre/projects/p025_swin/pipes/DWF_PIPE/PIPE_SUBMIT/"	
	date_string = '151223'
	new_day_pipe_directory = pipe_loop_path  + 'ut' + date_string + "/"

			close, /all

			for i = 1, 59 do begin
		
				ccd_id = strmid(strtrim(string(i),1),0,1) 
				if i gt 9 then ccd_id = strmid(strtrim(string(i),1),0,2)
		
	
					temp_submit_file = new_day_pipe_directory +  "submit_pipe_" + ccd_id + ".sh"
					temp_output_file = new_day_pipe_directory + ccd_id + "/submit_pipe_" + ccd_id + ".out"
					temp_error_file = new_day_pipe_directory + ccd_id + "/submit_pipe_" + ccd_id + ".err"
					
						
					openw, lun, temp_submit_file, /get_lun
					
						printf, lun, " "
						printf , lun, "#!/bin/bash"
						printf , lun, "# Name the job, error and output files"
						
						name_line = "#PBS -N CCD" + ccd_id
						printf , lun, name_line
						printf , lun, ""
						printf , lun, "# Specify the log output and error files (job will fail if these aren.t specified)      "
						
						output_line =  "#PBS -o g2.hpc.swin.edu.au:" + temp_output_file
						printf , lun, output_line
						
						error_line =   "#PBS -e g2.hpc.swin.edu.au:"  + temp_error_file
						printf , lun, error_line
						
						
						
						printf , lun, " "
						printf , lun, " "						
						printf , lun, "# Specify the project name                                                              "
						printf , lun, "#PBS -A p025_swin                                                                       "
						printf , lun, "                                                                                        "
						printf , lun, "# Specify the queue name                                                                "
						printf , lun, "#PBS -q sstar                                                                           "
						printf , lun, "                                                                                        "
						printf , lun, "# Node, processor, and GPU requests                                                     "
						printf , lun, "#PBS -l nodes=1:ppn=1                                                                   "
						printf , lun, "#PBS -l walltime=00:00:10:00                                                            "
						printf , lun, "                                                                                        "
						printf, lun, '#PBS -l nodes=sstar101+sstar102+sstar103+sstar104+sstar026+sstar024+sstar023+sstar016'
						
						printf , lun, "# Memory request                                                                        "
						printf , lun, "#PBS -l pmem=1gb                                                                        "
						printf , lun, "                                                                                        "
						printf , lun, "# List the assigned CPUs and GPUs                                                       "
						printf , lun, "# echo Spawning this many processes:                                                    "
						printf , lun, "# cat $PBS_NNODES                                                                       "
						printf , lun, "# echo Deploying job to CPUs ...                                                        "
						printf , lun, "# cat $PBS_NODEFILE                                                                     "
						printf , lun, "# echo and using GPUs ...                                                               "
						printf , lun, "# cat $PBS_GPUFILE                                                                      "
						printf , lun, "                                                                                        "
						printf , lun, "                                                                                        "
						printf , lun, "echo `date`                                                                             "
						printf , lun, "   "
						
						launch_line =  "/lustre/projects/p025_swin/pipes/DWF_PIPE/TEST/pipelooplaunch.sh ut" + date_string + "    " + ccd_id 
							
						printf , lun,launch_line
						
						
						printf , lun, " " 
						printf , lun, " "                                                                                       
						printf , lun, " " 
						
						
						
						job_id_line = "echo 'Job done CCD      " + ccd_id
						printf , lun, job_id_line
						
						
						printf , lun, "                                                                                        "
						printf , lun, "                                                                                        "
						printf , lun, "                                                                                        "
						printf , lun, "                                                                                        "

				
					close, /all
	
	
				endfor

			close, /all

		submit_file = new_day_pipe_directory + "submit_pipe_jobs"
		print, submit_file
		
		openw, lun, submit_file, /get_lun
		
			printf, lun, ""
			printf, lun, ""

				for i = 1, 59 do begin
					
					ccc_id = strmid(strtrim(string(i),1),0,1)
					if i gt 9 then ccc_id = strmid(strtrim(string(i),1),0,2)
	
	
					printf, lun, ""
					temp_submit_file = "submit_pipe_" + ccc_id + ".sh"
					
					submit_line = "qsub " + temp_submit_file
					
					printf, lun, submit_line
					printf, lun, ""
	
				endfor

			printf, lun, ""
			printf, lun, ""
			
		close, /all


		chmod_cmd = "chmod 777 " + pipe_loop_path + "*/*"
		spawn, chmod_cmd


END