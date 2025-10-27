*! 1.0.0 NJC 8 January 1999
program define circcomp
        version 5.0
        local varlist "req ex"
        local if "opt"
        local in "opt"
        local weight "aweight fweight iweight"
        local options "BY(string) CI LEVel(int $S_level)"
        local options "`options' Rayleigh Kuiper Detail"
        parse "`*'"
        parse "`varlist'", parse(" ")

        local nvars : word count `varlist'
        if `nvars' > 1 & "`by'" != "" {
                di in r "too many variables specified"
                exit 103
        }

        if "`by'" != "" {
                unabbrev `by', max(1)
                local by "$S_1"
                local which "    Group "
        }
        else { local which " Variable " }

        if "`detail'" != "" {
                local ci "ci"
                local rayleig "rayleigh"
                local kuiper "kuiper"
        }

        local ndash 31
        if "`ci'`rayleigh'`kuiper'" != "" {
                local con "_c"
                if "`ci'" != "" { local ndash = `ndash' + 18 }
                if "`rayleigh'" != "" { local ndash = `ndash' + 10 }
                if "`kuiper'" != "" { local ndash = `ndash' + 8 }
        }

        di _n in gr "`which'|   Obs"  _col(22) "Mean" /*
        */ _col(28) "Strength" _col(38) "Range" `con'
        if "`rayleigh'`kuiper'" != "" { local con2 "_c" }
        if "`ci'" != "" { di in g "  `level'% Conf. limits" `con2' }
        if "`kuiper'" != "" { local con3 "_c" }
        if "`rayleigh'" != "" { di in g "  Rayleigh" `con3' }
        if "`kuiper'" != "" { di in g "  Kuiper" }
        di in g " ---------+" _dup(`ndash') "-"

        tempvar touse group

        qui while "`1'" != "" {
                mark `touse' `if' `in'
                markout `touse' `1'

                sort `touse' `by'
                by `touse' `by' : gen `group' = _n == 1 if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
                local j 1

                while `j' <= `max' {
                        global S_6
                        global S_9
                        global S_11
                        global S_12
                        circsumm `1' if `group' == `j' [`weight' `exp'], /*
                         */ `ci' level(`level') `rayleigh' `kuiper'
                        if "`by'" != "" {
                                local name = `by'[_N]
                                local bylab : value label `by'
                                if "`bylab'" != "" {
                                        local name : label `bylab' `name'
                                }
                        }
                        else local name "`1'"
                        if length("`name'") > 8 {
                                local name = substr("`name'",1,8) + "+"
                        }
                        local skip = 9 - length("`name'")

                        #delimit ;
                        noi di in gr _skip(`skip') "`name' |" in ye
                        %6.0f  $S_1
                        %8.1f  $S_2
                        %10.3f $S_4
                        %7.1f  $S_5
                        %8.1f  $S_11
                        %10.1f $S_12
                        %10.3f $S_6
                        %8.3f  $S_9
                        ;
                        #delimit cr

                        local j = `j' + 1
                }

                mac shift
                drop `touse' `group'
        }
end
