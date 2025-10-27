*! NJC 1.1.1 23 December 1998
* NJC 1.1.0 16 December 1998
* NJC 1.0.0 9 May 1997
* raw data plot for circular data with point symbols
* 69189/64000 factor not used
program define circdplt
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local options "UTItle(str) LTItle(str) SAving(str) Round(int 5)"
    local options "`options' Symbol(str) SIze(int 275) Fudge(real 1) CT CL"
    local options "`options' noNorth AHL(int 400)"
    parse "`*'"
    preserve
    tempvar xsum ysum xcirc ycirc freq doty dotx
    tempname XSUM YSUM vecmean veclng vecstr

    if "`symbol'" == "" { local symbol "1" }
    else if length("`symbol'") >= 2 {
        di in r "invalid symbol( )"
        exit 198
    }
    else {
        if "`symbol'" == "."      { loc symbol 0 }
        else if "`symbol'" == "O" { loc symbol 1 }
        else if "`symbol'" == "S" { loc symbol 2 }
        else if "`symbol'" == "T" { loc symbol 3 }
        else if "`symbol'" == "o" { loc symbol 4 }
        else if "`symbol'" == "d" { loc symbol 5 }
        else if "`symbol'" == "p" { loc symbol 6 }
    }

    qui {
        if "`if'`in'" != "" { keep `if' `in' }
        drop if `varlist' == .

        gen `xsum' = sum(sin((`varlist'*_pi)/180))
        gen `ysum' = sum(cos((`varlist'*_pi)/180))
        local XSUM = `xsum'[_N]
        local YSUM = `ysum'[_N]
        Atan2 `XSUM' `YSUM'
        scalar `vecmean' = $S_1
        scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
        scalar `vecstr' = `veclng' / _N

        replace `varlist' = round(`varlist',`round')
        replace `varlist' = 0 if `varlist' == 360
        sort `varlist'
        by `varlist': gen `freq' = _N
        su `freq', meanonly
        local freqmax = _result(6)
        by `varlist': replace `freq' = 1 + (_n * `fudge') / `freqmax'
        gen `doty' = 10500 - 5000 * `freq' * cos((`varlist'*_pi)/180)
        gen `dotx' = 16000 + 5000 * `freq' * sin((`varlist'*_pi)/180)
    }

    if "`saving'" != "" { local saving ", saving(`saving')" }
    gph open `saving'
    gph pen 4
    local i = 1
    while `i' <= _N {
        local y = `doty'[`i']
        local x = `dotx'[`i']
        gph point `y' `x' `size' `symbol'
        local i = `i' + 1
    }

    gph pen 1
    if "`north'" == "" {
        gph line 11500 28000 9500 28000
        gph point 9200 28000 275 3
        local text "N"
        gph text 8700 27900 0 0 `text'
    }
    gph text 21500 16000 0 0 `utitle'
    if "`ltitle'" == "." { local ltitle " " }
    if "`ltitle'" == "" {
        local ltitle : /*
         */ di "mean direction " %2.1f `vecmean' /*
         */ "°: vector strength " %4.3f `vecstr'
         /* ASCII 248 summons up the degree symbol */
    }
    gph text 22500 16000 0 0 `ltitle'

    gph pen 5
    local resy = 10500 - 5000 * `vecstr' * cos(`vecmean'*_pi/180)
    local resx = 16000 + 5000 * `vecstr' * sin(`vecmean'*_pi/180)
    gph line 10500 16000 `resy' `resx'

    * arrow heads `ahl' long, angle between heads = _pi/3 = 60 deg
    local ah1y = `resy' - `ahl' * cos((`vecmean'*_pi/180) + (5 * _pi / 6))
    local ah1x = `resx' + `ahl' * sin((`vecmean'*_pi/180) + (5 * _pi / 6))
    local ah2y = `resy' - `ahl' * cos((`vecmean'*_pi/180) + (7 * _pi / 6))
    local ah2x = `resx' + `ahl' * sin((`vecmean'*_pi/180) + (7 * _pi / 6))
    gph line `ah1y' `ah1x' `resy' `resx'
    gph line `ah2y' `ah2x' `resy' `resx'

    if "`ct'" != "" { /* ticks are 500 long */
        gph line  5500 16000  6000  16000  /* North */
        gph line 10500 11000 10500  11500  /* West */
        gph line 10500 21000 10500  20500  /* East */
        gph line 15500 16000 15000  16000  /* South */
    }
    if "`cl'" != "" {
        gph text  6680 15850 0 0 N
        gph text 10680 11800 0 0 W
        gph text 10680 20000 0 0 E
        gph text 14680 15850 0 0 S
    }

    drop _all
    set obs 1001
    gen `ycirc' = sin(2 * _pi * (_n-1)/1000)
    gen `xcirc' = cos(2 * _pi * (_n-1)/1000)
    replace `ycirc' = (10500 + (`ycirc' * 5000))
    replace `xcirc' = 16000 + (`xcirc' * 5000)
    gph vline `ycirc' `xcirc'
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
