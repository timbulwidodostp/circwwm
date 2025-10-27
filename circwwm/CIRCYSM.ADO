*! NJC 1.0.1 1 January 1999
* NJC 1.0.0 17 December 1998
program define circysm
        version 5.0
        local varlist "min(2) max(2)"
        local if "opt"
        local in "opt"
        local options "Line Weight BWidth(real 0) LOWess"
        local options "`options' Symbol(str) Connect(str) Generate(str) *"
        parse "`*'"
        parse "`varlist'", parse(" ")
        local y `1'
        local x `2'
        local kopts "`line' `weight' bw(`bwidth') `lowess'"
        if "`generat'" != "" { confirm new variable `generat' }

        tempvar touse sine cosine ssine scosine smooth
        mark `touse' `if' `in'
        markout `touse' `varlist'

        qui {
                gen `sine' = sin(`y' * _pi / 180) if `touse'
                gen `cosine' = cos(`y' * _pi / 180) if `touse'
                ksm `sine' `x' if `touse', nograph `kopts' gen(`ssine')
                ksm `cosine' `x' if `touse', nograph `kopts' gen(`scosine')
                egen `smooth' = atan2(`ssine' `scosine') if `touse'
        }

        label var `smooth' "smoothed `y'"
        if "`symbol'" == "" { local symbol "oi" }
        if "`connect'" == "" { local connect ".s" }
        circplot `y' `smooth' `x', sy(`symbol') c(`connect') `options'

        qui if "`generat'" != "" { gen `generat' = `smooth' }
end

