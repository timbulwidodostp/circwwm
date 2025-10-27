*! NJC 1.3.0 15 December 1998
* NJC 1.2.2 23 October 1996
* correlation for circular data
program define circcorr
        version 5.0
        local varlist "min(2) max(2)"
        local if "opt"
        local in "opt"
        parse "`*'"
        parse "`varlist'", parse(" ")

        tempvar touse y x cc ss cs sc c2x s2x c2y s2y
        tempname A B C D E F G H corr ymean ystr xmean xstr
        tempname a2y a2x b2y b2x uy ux vy vx Z PvalNZ PvalZ

        mark `touse' `if' `in'
        markout `touse' `varlist'

        qui {
                gen `y' = `1' * _pi / 180 if `touse'
                gen `x' = `2' * _pi / 180 if `touse'
                count if `touse'
                local N = _result(1)

                gen `cc' = cos(`y') * cos(`x')
                su `cc', meanonly
                scalar `A' = _result(18)
                gen `ss' = sin(`y') * sin(`x')
                su `ss', meanonly
                scalar `B' = _result(18)
                gen `cs' = cos(`y') * sin(`x')
                su `cs', meanonly
                scalar `C' = _result(18)
                gen `sc' = sin(`y') * cos(`x')
                su `sc', meanonly
                scalar `D' = _result(18)
                gen `c2x' = cos(2 * `x')
                su `c2x', meanonly
                scalar `E' = _result(18)
                gen `s2x' = sin(2 * `x')
                su `s2x', meanonly
                scalar `F' = _result(18)
                gen `c2y' = cos(2 * `y')
                su `c2y', meanonly
                scalar `G' = _result(18)
                gen `s2y' = sin(2 * `y')
                su `s2y', meanonly
                scalar `H' = _result(18)
                scalar `corr' = 4 * (`A' * `B' - `C' * `D') /*
                 */ / sqrt((`N'^2 - `E'^2 - `F'^2)*(`N'^2 - `G'^2 - `H'^2))

                circsumm `y'
                scalar `ymean' = $S_2 * _pi / 180
                scalar `ystr' = $S_4
                circsumm `x'
                scalar `xmean' = $S_2 * _pi / 180
                scalar `xstr' = $S_4
                replace `c2y' = cos(2 * (`y' - `ymean'))
                su `c2y', meanonly
                scalar `a2y' = _result(3)
                replace `c2x' = cos(2 * (`x' - `xmean'))
                su `c2x', meanonly
                scalar `a2x' = _result(3)
                replace `s2y' = sin(2 * (`y' - `ymean'))
                su `s2y', meanonly
                scalar `b2y' = _result(3)
                replace `s2x' = sin(2 * (`x' - `xmean'))
                su `s2x', meanonly
                scalar `b2x' = _result(3)
                scalar `uy' = (1 - `a2y'^2 - `b2y'^2)/2
                scalar `ux' = (1 - `a2x'^2 - `b2x'^2)/2
                scalar `vy' = `ystr'^2 * (1 - `a2y')
                scalar `vx' = `xstr'^2 * (1 - `a2x')
                   /* the formula for Z on p.152 of Fisher 1993 is wrong */
                scalar `Z' = sqrt(`N' * `uy' * `ux') * `corr' / sqrt(`vx' * `vy')
                scalar `PvalNZ' = 2 * (1 - normprob(abs(`Z')))
                scalar `PvalZ' = exp(-(abs(`N' * `corr')))
        }


        di _n in g "Number of data" _dup(20) " " in y %9.0f `N'
        di in g    "Correlation   " _dup(20) " " in y %9.3f `corr'
        di _n in g "P-value (2-tailed)"
        di in g _dup(4) " " "if vector strengths non-zero  " in y %9.3f `PvalNZ'
        di in g _dup(4) " " "if either vector strength zero" in y %9.3f `PvalZ'

        global S_1 = `N'
        global S_2 = `corr'
        global S_3 = `Z'
        global S_4 = `PvalNZ'
        global S_5 = `PvalZ'
end
