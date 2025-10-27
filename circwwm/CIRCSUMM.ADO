*! 1.3.3 NJC 10 January 1999
* 1.3.2 NJC 1 January 1999
* 1.3.1 NJC 15 December 1998
* 1.3.0 NJC 15 July 1998
* 1.2.2 NJC 29 October 1996
* mean direction, vector strength and circular range of circular data
* with confidence interval for mean and Rayleigh and Kuiper tests
program define circsumm
    version 5.0
    local varlist "req ex max(1)"
    local if "opt"
    local in "opt"
    local weight "aweight fweight iweight"
    local options "Rayleigh Kuiper CI LEVel(integer $S_level) Detail"
    parse "`*'"

    if "`detail'" == "detail" {
        local rayleig "rayleigh"
        local kuiper "kuiper"
        local ci "ci"
    }

    if "`exp'" == "" {
        local exp "= 1"
        local uneqwt = 0
    }
    else local uneqwt = 1

    tempvar touse wt xsum ysum gap scaled rank dplus dminus cos2
    tempname XSUM YSUM vecmean wtmean veclng vecstr veclngw range
    tempname Z factor P_Ray Dplus Dminus Vn V P_Kui

    mark `touse' `if' `in'
    markout `touse' `varlist'

    qui count if `touse'
    local N = _result(1)

    qui {
        gen `wt' `exp' if `touse'
        gen `xsum' = sum(sin((`varlist' * _pi) / 180) * `wt')
        gen `ysum' = sum(cos((`varlist' * _pi) / 180) * `wt')
        scalar `XSUM' = `xsum'[_N]
        scalar `YSUM' = `ysum'[_N]

        /* Stata atan routine takes a single argument
        and gives the wrong answer in three out of four quadrants */
        Atan2 `XSUM' `YSUM'
        scalar `vecmean' = $S_1

        su `wt', meanonly
        scalar `wtmean' = _result(3)
        scalar `XSUM' = `XSUM' * `N' / _result(18)
        scalar `YSUM' = `YSUM' * `N' / _result(18)
        scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
        scalar `vecstr' = `veclng' / `N'

        sort `touse' `varlist'
        gen `gap' = `varlist'[_n + 1] - `varlist' if `touse'
        local first = _N - `N' + 1
        replace `gap' = 360 - `varlist' + `varlist'[`first'] in l
        su `gap', meanonly
        scalar `range' = 360 - _result(6)
    }

    di in g _n "Circular statistics for `varlist'"
    local len = 24 + length("`varlist'")
    di in g _dup(`len') "-" _n
    di in g "Number of data             " in y %6.0f `N'
    di in g "Mean direction, deg     " in y %9.2f `vecmean'

    if "`ci'" == "ci" {
        qui gen `cos2' = /*
         */ cos(2 * (`varlist' - `vecmean') * _pi / 180) if `touse'
        su `cos2', meanonly
        local disp = (1 - _result(3)) / (2 * `vecstr'^2)
        local sem = sqrt(`disp' / `N')
        local mult = invnorm((100 + `level') / 200)
        local ul = `vecmean' + (180 / _pi) * asin(`mult' * `sem')
        if `ul' > 360 { local ul = `ul' - 360 }
        local ll = `vecmean' - (180 / _pi) * asin(`mult' * `sem')
        if `ll' < 0 { local ll = `ll' + 360 }
        di _n in g "`level'% confidence interval for mean"
        di _dup(14) " " in y in g "lower limit" in y %8.2f `ll'
        di _dup(14) " " in y in g "upper limit" in y %8.2f `ul' _n
    }

    di in g "Vector length           "   in y %9.2f `veclng'
    if `uneqwt' {
        scalar `veclngw' = `vecstr' * `wtmean'
        di in g "   in weight units      "   in y %9.2f `veclngw'
    }
    di in g "Vector strength         "   in y %9.3f `vecstr'
    di in g "Circular range, deg     "   in y %9.1f `range'

    if "`rayleigh'" == "rayleigh" {
        di _n in g "Rayleigh test: unimodal not uniform?"
        scalar `Z' = `N' * `vecstr'^2
        scalar `factor' = 1 + (2 * `Z' - `Z'^2) / (4 * `N') - /*
         */ (24 * `Z' - 132 * `Z'^2 + 76 * `Z'^3 - 9 * `Z'^4) / (288 * `N'^2)
        scalar `P_Ray' = exp(-`Z') * `factor'
        di in g "P-value                 "   in y %9.3f `P_Ray'
    }

    if "`kuiper'" == "kuiper" {
        di _n in g "Kuiper test: not uniform?"
        qui {
            gen `scaled' = `varlist' / 360 if `touse'
            gen `rank' = _n - _N + `N' if `touse'
            gen `dplus' = `rank' / `N' - `scaled'
            gen `dminus' = `scaled' - (`rank' - 1) / `N'
            su `dplus', meanonly
            scalar `Dplus' = _result(6)
            su `dminus', meanonly
            scalar `Dminus' = _result(6)
            scalar `Vn' = `Dplus' + `Dminus'
            scalar `V'  = `Vn' * (sqrt(`N') + 0.155 + 0.24 / sqrt(`N'))
            /* Stephens 1970 p.118: preferable to tabulated levels in Fisher
            3 dp accuracy for P < 0.447 (V > 1.26) */
            scalar `P_Kui' = (8 * `V'^2 - 2) * exp(-2 * `V'^2)
        }
        di in g "V                       "   in y %9.3f `V'
        di in g "P-value                 "   in y %9.3f `P_Kui'
    }

    global S_1 = `N'
    global S_2 = `vecmean'
    global S_3 = `veclng'
    global S_4 = `vecstr'
    global S_5 = `range'

    if "`rayleigh'" == "rayleigh" { global S_6 = `P_Ray' }

    if "`kuiper'" == "kuiper" {
        global S_7 = `Vn'
        global S_8 = `V'
        global S_9 = `P_Kui'
    }

    if `uneqwt' { global S_10 = `veclngw' }

    if "`ci'" == "ci" {
        global S_11 `ll'
        global S_12 `ul'
        global S_13 `sem'
    }
end

program define Atan2
* 1.2.0 NJC 14 July 1998
    version 5.0
    tempname at

    local sign1 = sign(`1')
    local sign2 = sign(`2')

    if (`sign1' == 1 & `sign2' == 1) | ((`sign1' == 0) & `sign2' == 1) {
        scalar `at' = atan(`1'/`2')
    }
    else if `sign1' == 1 & `sign2' == 0 {
        scalar `at' = _pi / 2
    }
    else if `sign1' == -1 & `sign2' == 0 {
        scalar `at' = 3 * _pi / 2
    }
    else if `sign2' ==  -1 {
        scalar `at' = _pi + atan(`1'/`2')
    }
    else if `sign1' == -1 & `sign2' == 1 {
        scalar `at' = 2 * _pi + atan(`1'/`2')
    }

    global S_1 = (180 / _pi) * `at'
end

