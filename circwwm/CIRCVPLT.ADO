*! NJC 1.5.0 15 December 1998
* NJC 1.4.0 9 May 1997
* NJC 1.3.2 30 October 1996
* cumulative vector plot for circular data
program define circvplt
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local options "UTItle(str) LTItle(str) SAving(str) AHL(int 600) Rotate(real 0)"
    local options "`options' Fudge(real 0)"
    parse "`*'"

    if `fudge' == 0 { local fudge = 69189/64000 }

    preserve
    tempvar xsum ysum newang vecres
    tempname XSUM YSUM vecmean veclng vecstr
    tempname xrange xmax xmin xmid yrange ymax ymin ymid range

    qui {
        if "`if'`in'" != "" { keep `if' `in' }
        drop if `varlist' == .

        gen `xsum' = sum(sin((`varlist'*_pi)/180))
        gen `ysum' = sum(cos((`varlist'*_pi)/180))
        scalar `XSUM' = `xsum'[_N]
        scalar `YSUM' = `ysum'[_N]
        Atan2 `XSUM' `YSUM'
        scalar `vecmean' = $S_1
        scalar `veclng' = sqrt(`XSUM'^2 + `YSUM'^2)
        scalar `vecstr' = `veclng' / _N

        gen `newang' = mod(`varlist' - `vecmean' + 180 + `rotate',360)
        sort `newang'
        local N = _N
        local Np1 = _N + 1
        local Np2 = _N + 2
        set obs `Np2'
        replace `xsum' = .
        replace `xsum' = 0 in 1
        replace `xsum' = sum(sin((`varlist'[_n-1] * _pi) / 180)) in 2/`Np1'
        replace `ysum' = .
        replace `ysum' = 0 in 1
        replace `ysum' = sum(cos((`varlist'[_n-1] * _pi) / 180)) in 2/`Np1'
        gen `vecres' = .
        replace `vecres' = `ysum'[_N-1] in `Np1'
        replace `vecres' = 0 in `Np2'
        replace `xsum' = 0 in `Np2'
        replace `ysum' = `ysum' * `fudge'
        replace `vecres' = `vecres' * `fudge'

        su `xsum', meanonly
        scalar `xrange' = _result(6) - _result(5)
        scalar `xmax' = _result(6)
        scalar `xmin' = _result(5)
        scalar `xmid' = (`xmax' + `xmin')/2
        su `ysum', meanonly
        scalar `yrange' = _result(6) - _result(5)
        scalar `ymax' = _result(6)
        scalar `ymin' = _result(5)
        scalar `ymid' = (`ymax' + `ymin')/2
        scalar `range' = max(`xrange', `yrange')
        replace `xsum' = 16000 + 18000 * (`xsum' - `xmid')/`range'
        replace `ysum' = 10000 - 18000 * (`ysum' - `ymid')/`range'
        replace `vecres' = 10000 - 18000 * (`vecres' - `ymid')/`range'
    }

    if "`saving'" != "" { local saving ", saving(`saving')" }
    gph open `saving'
    gph pen 4
    gph vline `ysum' `xsum'
    gph pen 5
    gph vline `vecres' `xsum'

    local vecresy = `vecres'[_N-1]
    local vecresx = `xsum'[_N-1]
    * arrow heads `ahl' long, angle between heads = _pi/3 = 60 deg
    local ah1y = `vecresy' - `ahl' * `fudge' * cos((`vecmean'*_pi/180) + (5 * _pi / 6))
    local ah1x = `vecresx' + `ahl' * sin((`vecmean'*_pi/180) + (5 * _pi / 6))
    local ah2y = `vecresy' - `ahl' * `fudge' * cos((`vecmean'*_pi/180) + (7 * _pi / 6))
    local ah2x = `vecresx' + `ahl' * sin((`vecmean'*_pi/180) + (7 * _pi / 6))
    gph line `ah1y' `ah1x' `vecresy' `vecresx'
    gph line `ah2y' `ah2x' `vecresy' `vecresx'

    gph pen 1
    gph line 11000 28000 9000 28000
    gph point 8700 28000 275 3
    local text "N"
    gph text 8200 27900 0 0 `text'
    gph text 21000 16000 0 0 `utitle'
    if "`ltitle'" == "." { local ltitle " " }
    if "`ltitle'" == "" {
        local ltitle : /*
         */ di "mean direction " %2.1f `vecmean' /*
         */ "°: vector strength " %4.3f `vecstr'
         /* ASCII 176 summons up the degree symbol */
    }
    gph text 22000 16000 0 0 `ltitle'
    gph close
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
