function make_igor_pipe_loop_submit, file
date = '151219'
field = file

field is object type
date without ut
sequence_number

	for i=0, 58 do begin
	
		nameq=strcompress(/lustre/projects/p025_swin/pipes/DWF_PIPE/QSUB/PIPELLOP + '/' + field + '_' + date + '_m' + sequencenumber + '_ccd' + i1 + '.qsub', /remove_all)  	;define the name of the qsubmission file.
		Openw, lun, /get_lun, nameq

		printf, lun, '#!/bin/bash'
		printf, lun, '# Name the job, error and output files' 
		printf, lun, '#PBS -N ', strcompress(field + '_' + date + '_m' + sequencenumber + '_ccd' + i1, /remove_all)
		printf, lun, ' '
		printf, lun, '# Specify the log output and error files (job will fail if these aren.t specified)'
		printf, lun, '#PBS -o ' + strcompress('g2.hpc.swin.edu.au:' + qfolder_path + '/' + field + '_' + date + '_pipe_ccd' + i1 + '.out', /remove_all)
		printf, lun, '#PBS -e ' + strcompress('g2.hpc.swin.edu.au:' + qfolder_path + '/' + field + '_' + date + '_pipe_ccd' + i1 + '.err', /remove_all)
		printf, lun, ' '
		printf, lun, '# Specify the project name'
		printf, lun, '#PBS -A p025_swin'
		printf, lun, ' '
		printf, lun, '# Specify the queue name'
		printf, lun, '#PBS -q sstar'
		printf, lun, ' '
		printf, lun, '# Node, processor, and GPU requests'	
		printf, lun, '#PBS -l nodes=1:ppn=1'
		printf, lun, '#PBS -l walltime=00:00:05:00'
		printf, lun, '#PBS -l nodes=sstar101+sstar102+sstar103+sstar104+sstar105+sstar106+sstar107+sstar108'
		printf, lun, ' '
		printf, lun, '# Memory request'
		printf, lun, '#PBS -l pmem=1gb'
		close, lun
		free_lun, lun
	
		qsub_command='qsub ' + nameq
		spawn, qsub_command, qsubout
		print, qsubout

	endfor
END