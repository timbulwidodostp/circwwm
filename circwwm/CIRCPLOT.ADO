*! NJC 1.4.1 16 December 1998
* NJC 1.4.0 12 May 1997
* NJC 1.3.1 29 October 1996
* scatter plot for circular data
program define circplot
    version 5.0
    local varlist "min(2)"
    local if "opt"
    local in "opt"
    local weight "aweight fweight iweight"
    local options "Ycirc Xcirc Pad(int 180) Diff *"
    parse "`*'"
    parse "`varlist'", parse(" ")
    local nvars: word count `varlist'

    preserve
    tempvar touse orig
    mark `touse' `if' `in'
    markout `touse' ``nvars''
    qui keep if `touse'
    gen byte `orig' = 1

    qui if "`ycirc'" == "ycirc" {
        local np1 = _N + 1
        local yvar `1'
        expand 1 + (`yvar' <= `pad' | `yvar' > 360 - `pad')
        if _N >= `np1' { /* need to check that expansion took place */
            replace `yvar' = /*
            */ cond(`yvar' <= `pad', `yvar' + 360, `yvar' - 360) in `np1'/l
            replace `orig' = 0 in `np1'/l
        }
    }

    qui if "`xcirc'" == "xcirc" {
        local np1 = _N + 1
        local xvar ``nvars''
        expand 1 + (`xvar' <= `pad' | `xvar' > 360 - `pad')
        if _N >= `np1' { /* need to check that expansion took place */
            replace `xvar' = /*
            */ cond(`xvar' <= `pad', `xvar' + 360, `xvar' - 360) in `np1'/l
            replace `orig' = 0 in `np1'/l
        }
    }

    qui if "`diff'" != "" {
        if `nvars' != 2 {
            di in bl "diff option not available with `nvars' variables"
        }
        else {
            tempvar copy
            local yvar `1'
            gen `copy' = `yvar' if `orig' == 0
            label var `copy' "copy"
            replace `yvar' = . if `orig' == 0
        }
    }

    graph `copy' `varlist' [`weight' `exp'], `options'
end
