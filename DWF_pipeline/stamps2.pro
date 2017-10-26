pro stamps2,ccdnumber,side,path_stamps=path_stamps,path_cat=path_cat,path_resamp=path_resamp,path_diff=path_diff,sidestamp=sidestamp,sequencenumber,date,field,xdim=xdim,ydim=ydim

;This procedure reads the candidates.cat final file and
;creates stamps, centered on the candidates, from the
;science, template, and subtracted images.

cat=strcompress(path_cat + '/candidates.cat', /remove_all)
readcol, format='(A,F,F)', cat, numcand, x, y 

pathnew='/lustre/projects/p025_swin/pipes/DWF_PIPE/MARY_STAMP' + '/' + field + '_' + date + '_m' + sequencenumber



if (n_elements(numcand) le 50) then begin

i1=ccdnumber
	
for j=0, n_elements(x)-1 do begin 	;for each candidate

       xdim1=string(xdim)
       ydim1=string(ydim)	
       xnew=x[j]
       ynew=y[j]
       
       xmin=fix(xnew-(sidestamp/2))
       xmax=fix(xnew+(sidestamp/2))
       ymin=fix(ynew-(sidestamp/2))
       ymax=fix(ynew+(sidestamp/2))
       
       xmin1=string(fix(xnew-(sidestamp/2)))
       xmax1=string(fix(xnew+(sidestamp/2)))
       ymin1=string(fix(ynew-(sidestamp/2)))
       ymax1=string(fix(ynew+(sidestamp/2)))

       namesci=strcompress(path_resamp + '/sci_' + i1 + '.resamp.fits', /remove_all)
       nametemp=strcompress(path_resamp + '/temp_' + i1 + '.resamp.fits', /remove_all)
       namesub=strcompress(path_diff + '/' + field + '_' + date + '_m' + sequencenumber + '_sub_ccd' + i1 + '.fits', /remove_all)
       
       namestampsci=strcompress(pathnew + '/' + field + '_' + date + '_m' + sequencenumber +  '_stamp_ccd' + i1 + '_cand' + numcand[j] + '_sci.fits', /remove_all)
       namestamptemp=strcompress(pathnew + '/' + field + '_' + date + '_m' + sequencenumber +  '_stamp_ccd' + i1 + '_cand' + numcand[j] + '_temp.fits', /remove_all)
       namestampsub=strcompress(pathnew + '/' + field + '_' + date + '_m' + sequencenumber +  '_stamp_ccd' + i1 + '_cand' + numcand[j] + '_sub.fits', /remove_all)
       
;;;Check if the candidates are close to the border:


;CORNERS
       
       if (xmin le 1) and (ymin le 1) then begin
       
	  commandsci='imcopy ' + strcompress(namesci + '[' + '1' + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
	  commandtemp='imcopy ' + strcompress(nametemp + '[' + '1' + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
	  commandsub='imcopy ' + strcompress(namesub + '[' + '1' + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub
       
       endif
       
       
       if (xmin le 1) and (ymax ge ydim) then begin
       
    	  commandsci='imcopy ' + strcompress(namesci + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsci
     	  commandtemp='imcopy ' + strcompress(nametemp + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsub
    	   
       endif
       
       
       if (xmax ge xdim) and (ymin le 1) then begin
       
    	  commandsci='imcopy ' + strcompress(namesci + '[' + xmin1 + ':' + xdim1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
    	  commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin1 + ':' + xdim1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + xmin1 + ':' + xdim1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub

       endif    
    
    	
       if (xmax ge xdim) and (ymax ge ydim) then begin
       
          commandsci='imcopy ' + strcompress(namesci + '[' + xmin + ':' + xdim1 + ',' + ymin + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsci
    	  commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin + ':' + xdim1 + ',' + ymin + ':' + ydim1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + xmin + ':' + xdim1 + ',' + ymin + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsub
	
       endif  
       
       
;SIDES

       if (xmin le 1) and (ymax le ydim) and (ymin ge 1) then begin
       
	  commandsci='imcopy ' + strcompress(namesci + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
	  commandtemp='imcopy ' + strcompress(nametemp + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
	  commandsub='imcopy ' + strcompress(namesub + '[' + '1' + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub
       
       endif
       
       
       if (xmin ge 1) and (xmax le xdim) and (ymax ge ydim) then begin
       
    	  commandsci='imcopy ' + strcompress(namesci + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsci
     	  commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ydim1 + ']', /remove_all) + ' ' + namestampsub
    	   
       endif
       
       
       if (xmax ge xdim) and (ymin ge 1) and (ymax le ydim) then begin
       
    	  commandsci='imcopy ' + strcompress(namesci + '[' + xmin1 + ':' + xdim1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
    	  commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin1 + ':' + xdim1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + xmin1 + ':' + xdim1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub

       endif  


       if (xmax le xdim) and (xmin ge 1) and (ymin le 1) then begin
       
          commandsci='imcopy ' + strcompress(namesci + '[' + xmin1 + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
    	  commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin1 + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
    	  commandsub='imcopy ' + strcompress(namesub + '[' + xmin1 + ':' + xmax1 + ',' + '1' + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub
	
       endif


; IF EVERYTHING IS ALRIGHT	  
       if (xmin ge 1) and (xmax le xdim) and (ymin ge 1) and (xmax le xdim) then begin
    
       commandsci='imcopy ' + strcompress(namesci + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsci
       commandtemp='imcopy ' + strcompress(nametemp + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestamptemp
       commandsub='imcopy ' + strcompress(namesub + '[' + xmin1 + ':' + xmax1 + ',' + ymin1 + ':' + ymax1 + ']', /remove_all) + ' ' + namestampsub
       
       endif
       
       
               
       spawn, commandsci, outsci
       spawn, commandtemp, outtemp
       spawn, commandsub, outsub
			

	
endfor

endif else print, '!!!!!!!!!!TOO MANY CANDIDATES! SOMETHING WRONG? NO STAMPS GENERATED'

end

