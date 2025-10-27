*! NJC 1.0.1 16 December 1998
* NJC 1.0.0 29 October 1996
* differences for circular data
program define circdiff
    version 5.0
    local varlist "min(2) max(2)"
    local if "opt"
    local in "opt"
    local options "Generate(str)"
    parse "`*'"
    if "`generat'" == "" {
        di in r "generate() option required"
        exit 100
    }
    confirm new variable `generat'
    parse "`varlist'", parse(" ")
    local y `1'
    local x `2'
    tempvar diff1 diff2

    qui gen `diff1' = max(`x',`y') - min(`x',`y') `if' `in'
    qui gen `diff2' = 360 - `diff1'
    qui gen `generat' = sign(`y' - `x') * min(`diff1', `diff2')

end
