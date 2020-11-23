#!/bin/bash

# run-test.sh: Benchmarks different variations of MiniSAT and outputs a CSV file with time and memory for each instance.
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
    outfile=$4
    extra_options="-cpu-lim=100"
    echo "    $testname"
    runsat=$( ./minisat -verb=1 $options $extra_options $testfile )
    exitcode=$?
    echo "$( basename $testfile ),$testname,$(parse_print_results "$runsat" $exitcode)" >> "$outfile"
}

function run_tests(){
    testfile=$1
    outfile=$2

    # Settings to disable VSIDS
    no_vsids="-no-DLIS -var-decay=0.999 -cla-decay=0.999" 
    # Settings to enable VSIDS
    vsids="-no-DLIS -var-decay=0.95 -cla-decay=0.999"

    # DPLL
    run_with_options "DPLL" "-dis-learn -dis-restart -dis-2LW $no_vsids" $testfile $outfile
    # CL
    run_with_options "CL" "-no-dis-learn -dis-restart -dis-2LW $no_vsids" $testfile $outfile
    # RST
    run_with_options "RST" "-dis-learn -no-dis-restart -dis-2LW $no_vsids" $testfile $outfile
    # 2WL
    run_with_options "2WL" "-dis-learn -dis-restart -no-dis-2LW $no_vsids" $testfile $outfile
    # VSIDS
    run_with_options "VSIDS" "-dis-learn -dis-restart -dis-2LW $vsids" $testfile $outfile
    # NOTCL
    run_with_options "NOTCL" "-dis-learn -no-dis-restart -no-dis-2LW $vsids" $testfile $outfile
    # NOTRST
    run_with_options "NOTRST" "-no-dis-learn -dis-restart -no-dis-2LW $vsids" $testfile $outfile
    # NOT2WL
    run_with_options "NOT2WL" "-no-dis-learn -no-dis-restart -dis-2LW $vsids" $testfile $outfile
    # NOTVSIDS
    run_with_options "NOTVSIDS" "-no-dis-learn -no-dis-restart -no-dis-2LW $no_vsids" $testfile $outfile
    # CDCL
    run_with_options "CDCL" "-no-dis-learn -no-dis-restart -no-dis-2LW $vsids" $testfile $outfile
}
if [ "$#" -lt 2 ]; then
    echo "Usage: ./run-test.sh [outfile] [cnf file(s)]"
    exit 0
fi

if [ -f "$1" ]; then
    read -p "$1 exists. Overwrite? [y/N]" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting."
        exit 0
    fi
fi

outfile="$1"
echo "Instance,Option,Time,Memory,Sat" > $outfile

shift;
num_files=$#
echo $num_files
for i in $( seq 1 $num_files )
do
    echo "[$i/$num_files]:" "${!i}"
    run_tests "${!i}" "$outfile"
done