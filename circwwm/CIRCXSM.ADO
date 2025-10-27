*! NJC 1.3.1 1 January 1999
* NJC 1.3.0 16 December 1998
* NJC 1.2.0 15 May 1997
* NJC 1.1.0 30 September 1996
* ksm for circular data
program define circxsm
    version 5.0
    local varlist "min(2) max(2)"
    local if "opt"
    local in "opt"
    local options "Pad(int 180) XMIN(real 0) XMAX(real 360) *"
    parse "`*'"
    parse "`varlist'", parse(" ")
    local x `2'

    tempvar touse expand
    mark `touse' `if' `in'
    markout `touse' `varlist'
    local np1 = _N + 1

    nobreak {
        qui expand 1 + (`x' <= `xmin' + `pad' | `x' > `xmax' - `pad')
        gen byte `expand' = _n >= `np1'
        if _N >= `np1' { /* need to check that expansion took place */
            #delimit ;
            qui replace `x' =
            cond(`x' <= `xmin' + `pad', `x' + `xmax' - `xmin',
            `x' - `xmax' + `xmin') in `np1'/l ;
            #delimit cr
        }
        ksm `varlist' if `touse', `options'
        qui drop if `expand'
    }
end

