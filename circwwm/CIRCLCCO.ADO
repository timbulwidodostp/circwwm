*! 1.2.0 NJC 15 December 1998
* 1.1.1 NJC 26 October 1996
* correlation for linear-circular data
program define circlcco
        version 5.0
        local varlist "min(2) max(2)"
        local if "opt"
        local in "opt"
        parse "`*'"
        parse "`varlist'", parse(" ")
        local y `1'
        local x `2'

        tempvar touse cosx sinx
        tempname r12 r13 r23 r_sq P_val

        qui {
                mark `touse' `if' `in'
                markout `touse' `varlist'
                gen `cosx' = cos(`x' * _pi / 180) if `touse'
                gen `sinx' = sin(`x' * _pi / 180) if `touse'
                corr `y' `cosx'
                scalar `r12' = _result(4)
                corr `y' `sinx'
                scalar `r13' = _result(4)
                corr `cosx' `sinx'
                scalar `r23' = _result(4)
                scalar `r_sq' = `r12'^2 + `r13'^2 - 2 * `r12' * `r13' * `r23'
                scalar `r_sq' = `r_sq' / (1 - `r23'^2)
                count if `touse'
                local N = _result(1)
                scalar `P_val' = chiprob(2, `N' * `r_sq')
        }

        di in g _n "Linear-circular correlation of `y' and `x'"
        di in g "`y' taken to be linear, `x' taken to be circular"
        di in g "Number of data     " in y %9.0f `N'
        di in g "r-square           " in y %9.3f `r_sq'
        di in g "r (positive root)  " in y %9.3f sqrt(`r_sq')
        di in g "P-value (n large)  " in y %9.3f `P_val'

        global S_1 = `N'
        global S_2 = `r_sq'
        global S_3 = `P_val'
end
