#!/bin/bash
function parse_print_results(){
    results=$1
    signal=$2
    cputime=$( echo "$results" | grep -i "CPU time" | tr -d -c 0-9.'\n' )
    memused=$( echo "$results" | grep -i "Memory used" | tr -d -c 0-9.'\n' )
    satreturn=$( echo "$results" | grep -i "SATISFIABLE\|INDETERMINATE" | tr -d -c A-Z'\n' )
    case $exitcode in
        2) # Interrupted, most likely due to timeout
            satresult="INDETERMINATE"
            ;;
        139) # segfault, likely due to out-of-memory
            satresult="INDETERMINATE"
            ;;
        *) # Some other thing we're not expecting
            # only output error if the sat solver doesn't return its own result
            if [ -z "$satreturn" ]
            then
                satresult="ERROR"
            else
                satresult="$satreturn"
            fi
            ;;
    esac
    echo $cputime","$memused","$satresult
}

function run_with_options(){
    testname=$1
    options=$2
    testfile=$3
    extra_options="-cpu-lim=100"
    runsat=$( ./minisat -verb=1 $options $extra_options $testfile )
    exitcode=$?
    echo "$( basename $testfile ),$testname,"$(parse_print_results "$runsat" $exitcode)
}

function run_tests(){
    testfile=$1
    no_vsids="-no-DLIS -var-decay=0.999 -cla-decay=0.999"
    vsids="-no-DLIS -var-decay=0.9 -cla-decay=0.9"
    # DPLL
    run_with_options "DPLL" "-dis-learn -dis-restart -dis-2LW $no_vsids" $1
    # CL
    run_with_options "CL" "-no-dis-learn -dis-restart -dis-2LW $no_vsids" $1
    # RST
    run_with_options "RST" "-dis-learn -no-dis-restart -dis-2LW $no_vsids" $1
    # 2WL
    run_with_options "2WL" "-dis-learn -dis-restart -no-dis-2LW $no_vsids" $1
    # VSIDS
    run_with_options "VSIDS" "-dis-learn -dis-restart -dis-2LW $vsids" $1
    # NOTCL
    run_with_options "NOTCL" "-dis-learn -no-dis-restart -no-dis-2LW $vsids" $1
    # NOTRST
    run_with_options "NOTRST" "-no-dis-learn -dis-restart -no-dis-2LW $vsids" $1
    # NOT2WL
    run_with_options "NOT2WL" "-no-dis-learn -no-dis-restart -dis-2LW $vsids" $1
    # NOTVSIDS
    run_with_options "NOTVSIDS" "-no-dis-learn -no-dis-restart -no-dis-2LW $no_vsids" $1
    # CDCL
    run_with_options "CDCL" "-no-dis-learn -no-dis-restart -no-dis-2LW $vsids" $1
}
if [ "$#" -lt 1 ]; then
    echo "Usage: ./run-test.sh [cnf file(s)]"
    exit 0
fi
echo "Instance,Option,Time,Memory,Sat"
for cnf in "$@"
do
    run_tests "$cnf"
done