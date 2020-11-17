#!/bin/bash
function parse_print_results(){
    results=$1
    cputime=$( echo "$results" | grep -i "CPU time" | tr -d -c 0-9.'\n' )
    memused=$( echo "$results" | grep -i "Memory used" | tr -d -c 0-9.'\n' )
    echo $cputime","$memused
}

function run_with_options(){
    testname=$1
    options=$2
    testfile=$3
    runsat=$( ./minisat -verb=1 $options $testfile )
    exitcode=$?
    case $exitcode in
        2) # Interrupted, most likely due to timeout
            satresult="TIME"
            ;;
        10) # Satisfiable
            satresult="SAT"
            ;;
        20) # Unsatisfiable
            satresult="UNSAT"
            ;;
        30) # Indeterminate (probably due to timeout)
            satresult="TIME"
            ;;
        40) # Out of memory
            setresult="MEM"
            ;;
        139) # segfault also gets MEM
            satresult="MEM"
            ;;
        *) # Some other thing we're not expecting
            satresult="ERROR"
            ;;
    esac
    echo "$( basename $testfile ),$testname,"$(parse_print_results "$runsat" )","$satresult
}

function run_tests(){
    testfile=$1
    # DPLL
    run_with_options "DPLL" "-dis-learn -dis-restart -dis-2LW" $1
    # CL
    run_with_options "CL" "-no-dis-learn -dis-restart -dis-2LW" $1
    # RST
    run_with_options "RST" "-dis-learn -no-dis-restart -dis-2LW" $1
    # 2WL
    run_with_options "2WL" "-dis-learn -dis-restart -no-dis-2LW" $1
    # VSIDS

    # NOTCL

    # NOTRST

    # NOT2WL

    # NOTVSIDS

    # CDCL
    run_with_options "CDCL" "" $1
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