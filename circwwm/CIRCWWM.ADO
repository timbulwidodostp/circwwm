*! NJC 1.5.0 15 December 1998
* NJC 1.4.2  27 October 1996
* Wheeler-Watson-Mardia test: Fisher 1993 pp.122-3
program define circwwm
        version 5.0
        local varlist "max(1)"
        local if "opt"
        local in "opt"
        local options "BY(string)"
        parse "`*'"
        parse "`varlist'", parse(" ")

        if "`by'" == "" {
                di in r "by() option required"
                exit 100
        }
        unabbrev "`by'", max(1)
        local by "$S_1"

        tempvar touse rank cosrank sinrank cossum sinsum
        tempname WWM pval

        mark `touse' `if' `in'
        markout `touse' `varlist' `by', strok
        qui count if `touse'
        local N = _result(1)
        if `N' == 0 { error 2000 }

        di _n in g "Wheeler-Watson-Mardia test for circular data"
        di in g "    angles from    `varlist'"
        di in g "    classed by     `by'" _n
        tab `by' if `touse'
        local df = 2 * _result(2) - 2
        if `df' <= 0 { error 148 }

        qui {
                egen `rank' = rank(`varlist') if `touse'
                gen `cosrank' = cos(2 * _pi * (`rank' / `N'))
                gen `sinrank' = sin(2 * _pi * (`rank' / `N'))
                sort `touse' `by'
                by `touse' `by': gen `cossum' = sum(`cosrank')
                by `touse' `by': gen `sinsum' = sum(`sinrank')
                by `touse' `by': replace `cossum' = `cossum'^2/_N
                by `touse' `by': replace `sinsum' = `sinsum'^2/_N
                by `touse' `by': replace `touse' = 0 if _n != _N
                replace `cossum' = sum(`cossum') if `touse'
                replace `sinsum' = sum(`sinsum') if `touse'
        }

        scalar `WWM' = 2 * (`cossum'[_N] + `sinsum'[_N])
        scalar `pval' = chiprob(`df', `WWM')

        di _n in g "W_r statistic  " in y %9.2f  `WWM'  _c
        di in g " (" in y `df' in g " df)" _c
        di in g "     P-value  " in y %9.3f  `pval'

        global S_1 = `WWM'
        global S_2 = `df'
        global S_3 = `pval'
end
