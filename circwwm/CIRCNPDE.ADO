*! NJC 1.1.1 16 December 1998
* NJC 1.1.0 26 October 1996
* nonparametric density estimation for circular data: Fisher 1993 pp.24-27
program define circnpde
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local options "H(real 30) * GENPDF(str) GENDEG(str)"
    parse "`*'"
    tempvar touse deg d e f
    qui {
        mark `touse' `if' `in'
        markout `touse' `varlist'
        count if `touse'
        local n = _result(1)

        gen `deg' = (_n / _N) * 360
        gen `d' = .
        gen `e' = .
        gen `f' = .
        label var `deg' "angle in degrees"
        label var `f' "probability density estimate"

        local i = 1
        while `i' <= _N {
            replace `d' = abs(`deg'[`i'] - `varlist') if `touse'
            replace `e' = min(`d' , 360 - `d')
            replace `e' = cond(`e' >= `h', 0, (1 - `e'^2 / `h'^2)^2)
            su `e', meanonly
            replace `f' = 0.9375 * _result(18) / (`n' * `h') in `i'
            local i = `i' + 1
        }
    }
    graph `f' `deg', `options'
    if "`genpdf'" != "" {
        confirm new variable `genpdf'
        gen `genpdf' = `f'
    }
    if "`gendeg'" != "" {
        confirm new variable `gendeg'
        gen `gendeg' = `deg'
    }
end
