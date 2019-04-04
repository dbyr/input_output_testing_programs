#!/bin/bash

# this script will run input/output tests for C programs
USAGE="Usage:

mpitest.sh [-a; -s] <progpath> <num_processes> <inputs_folder_path> <expected_outputs_folder_path> 

The names of the input files is expected to be the same as the name of the corresponding expected output files.

-a - Specifies that the input files have the first line as arguments.

-s - Specifies that the input files contain stdin (if -a is also specified, then -s uses the rest of the file as stdin)."

if [[ $# -lt 4 ]] || [[ $# -gt 6 ]]; then
	echo "$USAGE"
	exit
fi

while getopts "as" option; do
	case $option in
		a)
			ARGS=true
			;;
		s)
			STDIN=true
			;;
		*)
			echo "Invalid option '$option'"
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

PROGRAM=$1
PROCS=$2
INPUTS=$3
EXPECTED=$4

if [[ $PROCS -le 0 ]]; then
	echo "Cannot run on $PROCS processors"
	exit
fi

passed=0
total=$(ls $INPUTS | wc -l)
failed_tests=""
for file in $(ls $INPUTS); do
	inputfile="$INPUTS/$file"
	expectedfile="$EXPECTED/$file"
	echo "Running test '$file'"

	# run with the first line as arguments if both options are set
	if [[ $ARGS == 'true' ]] && [[ $STDIN == 'true' ]]; then
		lines=$(wc -l $inputfile | awk '{print $1}')
		output=$(tail -n $((lines-1)) $inputfile | mpirun -np $PROCS $PROGRAM $(head -n 1 $inputfile))
	# otherwise, use the whole file as either the stdin or arguments
	elif [[ $STDIN == 'true' ]]; then
		output=$(cat $inputfile | mpirun -np $PROCS $PROGRAM)
	elif [[ $ARGS == 'true' ]]; then
		output=$($PROGRAM $(cat $inputfile)) else
		# don't know why anyone would run this, but I'll leave it here in case
		output=$($PROGRAM)
	fi
	retcode=$?
	if [[ $retcode != 0 ]]; then
		echo "Program returned code $retcode"
		continue
	fi
	if [[ $output == $(cat $expectedfile) ]]; then
		passed=$((passed+1))
	else
		failed_tests="${failed_tests}Test $file failed.\nGot      '$output'\nExpected '$(cat $expectedfile)'\n\n"
	fi
done

echo
echo
echo -e "$failed_tests"
echo "$passed of $total tests passed."
