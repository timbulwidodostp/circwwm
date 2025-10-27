*! 1.2.1 NJC 16 December 1998
* 1.2.0 NJC 14 May 1997
* 1.1.0 NJC 23 September 1996
* centring circular data
* generates new variable: angles expressed relative to centre, -180 0 180,
* unless pos option invoked: 0 180 360
program define circcent
    version 5.0
    local varlist "max(1)"
    local if "opt"
    local in "opt"
    local options "Centre(str) Generate(str) Pos"
    parse "`*'"
    if "`generat'" == "" {
        di in r "generate( ) option required"
        exit 100
    }
    confirm new variable `generat'
    if "`centre'" == "" { local centre 0 }

    qui {
        gen `generat' = `varlist' - `centre' `if' `in'
        replace `generat' = `generat' + 360 if `generat' < 0
        replace `generat' = `generat' - 360 if `generat' > 180
        if "`pos'" == "pos" { replace `generat' = `generat' + 180 }
    }
end
