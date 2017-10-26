Function ml_exponential,data,completeness=completeness,logx_range=logx_range,$
                        logx0_range=logx0_range,logB_range=logB_range,$
                        logx0_list=logx0_list,logB_list=logB_list,$
                        likelihood=likelihood,plot=plot
  
;+------------------------------------------------------------------------
;
; ML_EXPONENTIAL
;
; Estimate exponential distribution parameters for a data set using
; maximum likelihood.
;
; exponential form:  P(x) = (B/x0) exp(-x/x0)
;
; Likelikhood function:  L = L_x(x0) * L_n(x0,B)
; where L_x = Product of P(x) for each event, and 
;       L_n = Poisson prob of the observed number of events given the
;             expected mean number
; When computing L_x, a value of B is chosen such that the expected
; mean number of events is equal to the observed number.
;
; INPUTS
;
; KEYWORDS
;        completeness  - 2 x n array of completeness information,
;                        where [0,*] is an array of increasing log(x)
;                        values, and [1,*] is the completeness at each
;                        value.  The completeness outside the given
;                        range of x is extrapolated from the ends.
;        logx_range    - 2-element array, [logx_min, logx_max],
;                        specifying the range over which to fit P(x).
;                        Default is [-1,0.7].
;        logx0_range   - 2-element array, [logx0_min, logx0_max]
;                        giving the range of exponent values over
;                        which to compute the likelihood function.
;                        Default is [-1,1].  The sampling within this
;                        range is set (to 0.01) in the program body.
;        logB_range    - 2-element array, [logB_min, logB_max] giving
;                        the range of scaling values over which to
;                        compute the likelihood function.  The default
;                        range is set to +/-1 of the value of logB
;                        that would produce a mean number of events
;                        equal to the observed number for the middle
;                        value of x0 being evaluated.  The sampling
;                        within this range is set (to 0.01) in the
;                        program body.
;        plot          - If set, plot 68%, 95%, and 99% probability
;                        contours.
;        logx0_list    - Returns the list of logx0 values over which
;                        likelihood is evaluates
;        logB_list     - Returns the list of logB values over which
;                        likelihood is evaluated
;        likelihood    - Returns two-dimensional normalized likelihood
;                        function, with n_logx0 x n_logB elements.
;
; OUTPUTS
;        <result>      - 2-element array with [logx0, logB] at which
;                        likelihood function is maximum
;
; HISTORY
;        Adapted from ML_POWERLAW 10/6/2015 GDB
;-------------------------------------------------------------------------

if (n_params() lt 1) then begin
   print,'CALLING SEQUNCE:  param_est = ml_exponential(data,...)'
   return,-1
endif

;; Completenes information

if keyword_set(completeness) then begin
   complete_logx = reform(completeness(0,*))
   complete_x    = 10d^complete_logx
   complete_frac = reform(completeness(1,*))
   do_analytic   = 0
endif else begin
   complete_logx = 0
   complete_x    = 0
   copmlete_frac = 0
   do_analytic   = 1
endelse

;; Range over which to fit exponential

if keyword_set(logx_range) then begin
   log_xlo = double(logx_range(0))
   log_xhi = double(logx_range(1))
endif else begin
   log_xlo = -1d
   log_xhi = 0.7d
endelse
xlo     = 10d^log_xlo
xhi     = 10d^log_xhi
stop
; Fit only observed data that fall within this range
obs_ls = where(data ge xlo and data le xhi,n_obs)
if (n_obs eq 0) then begin
   print,'No data within range of fit.'
   return,-1
endif
x_obs    = data(obs_ls)
logx_obs = alog10(x_obs)

; Compute n_obs! for evaluating Poisson probabilities
if (n_obs lt 100) then begin
   ln_n_obs_factorial = alog(factorial(n_obs))
endif else begin
   ln_n_obs_factorial = alog(sqrt(2*!dpi*n_obs)) + n_obs*alog(n_obs) - n_obs
endelse

;; Scale values to evaluate

if keyword_set(logx0_range) then begin
   logx0_min  = min(logx0_range)
   logx0_max  = max(logx0_range)
endif else begin
   logx0_min  = -1.0
   logx0_max  =  1.0
endelse
logx0_step =  0.01
n_logx0    = (logx0_max-logx0_min)/logx0_step + 1
logx0_list = logx0_min + logx0_step * dindgen(n_logx0)

;; Normalizations to evaluate

; Analytic integration (for reference)
; P = (B/x0) * exp(-x/x0)
; n_expect = B * (exp(-xlo/x0) - exp(-xhi/x0))

; Grid in x for integrating P(x)
n_grid     = 1e3
log_x_step = (log_xhi - log_xlo) / n_grid
log_x      = log_xlo + log_x_step*(0.5 + dindgen(n_grid))
x          = 10d^log_x
dx         = alog(10d) * x * log_x_step
if not(do_analytic) then $
   corr    = (0 > interpol(complete_frac,complete_logx,log_x)) < 1

if keyword_set(logB_range) then begin
   logB_min = min(logB_range)
   logB_max = max(logB_range)
endif else begin
   ; As a starting point, evaluate B such that the expected mean number = the
   ; obs number of data points for the middle value of logx0 being evaluated.
   logx0_start = 0.5*(logx0_min + logx0_max)
   x0_start    = 10d^logx0_start
   if do_analytic then begin
      ; Analytic integration (no completeness correction)
      ylo      = xlo / x0_start
      yhi      = xhi / x0_start
      ;B_start  = n_obs / (x0_start * (exp(-ylo)*(ylo+1) - exp(-yhi)*(yhi+1)))
      B_start  = n_obs / (exp(-ylo) - exp(-yhi))
   endif else begin
      ; Including completeness correction
      logPdB_nom = -logx0_start - (1/alog(10d))*(x/x0_start); PdB = P / B
      PdB_nom    = 10d^logPdB_nom                 ; nom = nominal P w/o complete
      PdB        = PdB_nom * corr
      ndB        = total(PdB*dx)                  ; mean number divided by B
      B_start    = n_obs / ndB
   endelse   
   logB_start = alog10(B_start)
   logB_min   = logB_start - 1.0
   logB_max   = logB_start + 1.0
endelse
logB_step =  0.01
n_logB    = (logB_max-logB_min)/logB_step + 1
logB_list = logB_min + logB_step * dindgen(n_logB)

;; Calculate likelihood function for each parameter combination

logL_x = dblarr(n_logx0,n_logB)  ; Product of the likehood of each data point
logL_n = dblarr(n_logx0,n_logB)  ; Poisson prob of the total observed number

for i=0,n_logx0-1 do begin

   for j=0,n_logB-1 do begin

      logx0       = logx0_list(i)
      logB        = logB_list(j)
      x0          = 10d^logx0
      B           = 10d^logB

      ; For each pair of parameters, compute probabilities at the
      ; center of a bin in (logx0, logB) space.

      ; L_x: For this alpha, evaluate L_x using normalization such that the
      ; expected number equals the observed number.
      if do_analytic then begin
         B_x0        = n_obs / (exp(-xlo/x0) - exp(-xhi/x0))
         logB_x0     = alog10(B_x0)
         logP_obs    = logB_x0 - logx0 - (1d/alog(10))*(x_obs/x0)
      endif else begin
         logPdB_nom = -logx0 - (1d/alog(10))*(x/x0)
         PdB_nom    = 10d^logPdB_nom
         PdB        = PdB_nom * corr
         ndB        = total(PdB*dx)
         B_x0       = n_obs / ndB
         P          = PdB * B_x0
         logP       = alog10(P)
         logP_obs   = interpol(logP,log_x,logx_obs)
      endelse
      logL_x(i,j) = total(logP_obs)

      ; L_n
      if do_analytic then begin
         n_expect   = B * (exp(-xlo/x0) - exp(-xhi/x0))
      endif else begin
         n_expect   = total(PdB * B * dx)
      endelse
      ln_poisson_prob  = n_obs*alog(n_expect) - n_expect - ln_n_obs_factorial
      log_poisson_prob = ln_poisson_prob / alog(10d)
      logL_n(i,j)      = log_poisson_prob

   endfor

endfor

; Combined likelihood
logL = logL_x + logL_n

;;; Return normalized likelihood array

L          = 10d^(logL - max(logL))
L          = L / total(L)
likelihood = L

;;; Parameter combination where likelihood is maximized

best_ind       = array_indices(logL,where(logL eq max(logL)))
best_logx0_ind = best_ind(0)
best_logB_ind  = best_ind(1)
best_logx0     = logx0_list(best_logx0_ind)
best_logB      = logB_list(best_logB_ind)

;;; Confidence intervals

; Cumulative likelihood as a function of likelihood level
order   = sort(L)
L_level = L(order)
L_sum   = total(L_level,/cumulative)
L68     = interpol(L_level,L_sum,1-0.68)
L95     = interpol(L_level,L_sum,1-0.95)
L99     = interpol(L_level,L_sum,1-0.99)

;;; Plot

if keyword_set(plot) then begin
   contour,L,logx0_list,logB_list,level=[L99,L95,L68],$
           xtitle='logx0',ytitle='logB',xs=3,ys=3
   ;; TESTING
   ;true_logx0 = -0.154902
   ;true_logB  = 1.60206
   ;oplot,[-10,10],replicate(true_logB,2),linestyle=1
   ;oplot,replicate(true_logx0,2),[-1e6,1e6],linestyle=1
   ;print,'Done. Hit key to exit.'
   ;key = get_kbrd()
endif

return,[best_logx0,best_logB]
end
