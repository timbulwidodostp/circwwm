*! NJC 1.1.0 15 December 1998
* NJC 1.0.3  27 October 1996
* Two-sample tests for circular data
program define circ2sam
        version 5.0
        local varlist "max(1)"
        local if "opt"
        local in "opt"
        local options "BY(string)"
        parse "`*'"

        if "`by'" == "" {
                di in r "by() option required"
                exit 100
        }
        unabbrev "`by'", max(1)
        local by "$S_1"

        tempvar touse cdf1 cdf2 diff diffsq
        tempname diffsum diffss WU2 V k k_star
        mark `touse' `if' `in'
        markout `touse' `varlist' `by', strok

        qui tab `by' if `touse'
        if _result(2) != 2 {
                di in red "`by' takes on " _result(2) " values, not 2"
                exit 450
        }

        di _n in g "Two-sample tests for circular data"
        di in g "    angles from    `varlist'"
        di in g "    classed by     `by'"

        qui {
                count if `touse'
                local first = _N - _result(1) + 1
                sort `touse' `by'
                local by1 = `by'[`first']
                local by2 = `by'[_N]
                count if `touse' & (`by' == `by1')
                local n1 = _result(1)
                count if `touse' & (`by' == `by2')
                local n2 = _result(1)
                sort `touse' `varlist' `by'
                gen `cdf1' = sum(`by' == `by1') if `touse'
                gen `cdf2' = sum(`by' == `by2') if `touse'

                * adjustment for ties
                by `touse' `varlist' : replace `cdf1' = `cdf1'[_N]
                by `touse' `varlist' : replace `cdf2' = `cdf2'[_N]

                gen `diff' = `cdf1' / `n1' - `cdf2' / `n2'
                gen `diffsq' = `diff'^2
                su `diff', meanonly
                scalar `diffsum' = _result(18)
                scalar `V' = _result(6) - _result(5)
                scalar `k' = `n1' * `n2' * `V'
                local nmin = min(`n1',`n2')
                local nmax = max(`n1',`n2')
                local nall = `n1' + `n2'
                scalar `k_star' = /*
                 */ `k' * (1 + 0.155 / sqrt(`nmin') + 0.24 / `nmin') /*
                 */ / sqrt(`nmin' * `nmax' * `nall')
                su `diffsq', meanonly
                scalar `diffss' = _result(18)
                scalar `WU2' = (`n1' * `n2' / (`nall'^2)) /*
                 */ * (`diffss' - (`diffsum'^2 / `nall'))

        }

        di _n in g "sample sizes:   " _c
        di in y %9.0f `nmin' in g _n _dup(16) " " in y %9.0f `nmax'
        di _n in g "Watson U-square:" in y %9.4f  `WU2'
        di _n in g "Kuiper test: V  " in y %9.3f  `V'
        di in g    "             k  " in y %9.0f  `k'
        di in g    "             k* " in y %9.3f  `k_star'

        global S_1 = `nmin'
        global S_2 = `nmax'
        global S_3 = `WU2'
        global S_4 = `V'
        global S_5 = `k'
        global S_6 = `k_star'
end
