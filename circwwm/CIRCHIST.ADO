*! NJC 1.5.0 16 December 1998
* NJC 1.4.0 15 May 1997
* NJC 1.3.0 13 May 1997
* NJC 1.2.1 29 October 1996
* histogram for circular data
program define circhist
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local weight "aweight fweight iweight"
    local options "Pad(int 180) BY(str) XMIN(real 0) XMAX(real 360) Histplot *"
    parse "`*'"
    preserve
    if "`if'`in'" != "" { qui keep `if' `in' }
    qui drop if `varlist' == .
    local np1 = _N + 1
    qui expand 1 + (`varlist' <= `xmin' + `pad' | `varlist' > `xmax' - `pad')
    qui if _N >= `np1' { /* need to check that expansion took place */
        #delimit ;
        replace `varlist' =
        cond(`varlist' <= `xmin' + `pad', `varlist' + `xmax' - `xmin',
         `varlist' - `xmax' + `xmin') in `np1'/l ;
        #delimit cr
    }
    if "`by'" != "" {
        sort `by'
        local by "by(`by')"
    }
    if "`histplot'" != "" {
        histplot `varlist' [`weight' `exp'], `options' `by'
    }
    else graph `varlist' [`weight' `exp'], `options' `by'
end
