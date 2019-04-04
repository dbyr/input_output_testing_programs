#!/bin/bash

# this script will run input/output tests for java programs
USAGE="Usage:

javatest.sh [-a; -s] <progpath> <inputs_folder_path> <expected_outputs_folder_path>

The names of the input files is expected to be the same as the name of the corresponding expected output files.

-a - Specifies that the input files have the first line as arguments.

-s - Specifies that the input files contain stdin (if -a is also specified, then -s uses the rest of the file as stdin)."

if [[ $# -lt 3 ]] || [[ $# -gt 5 ]]; then
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
	shift
done

PROGRAM=$1
INPUTS=$2
EXPECTED=$3

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
		output=$(tail -n $((lines-1)) $inputfile | java $PROGRAM $(head -n 1 $inputfile))
	# otherwise, use the whole file as either the stdin or arguments
	elif [[ $STDIN == 'true' ]]; then
		output=$(cat $inputfile | java $PROGRAM)
	elif [[ $ARGS == 'true' ]]; then
		output=$(java $PROGRAM $(cat $inputfile))
	else
		# don't know why anyone would run this, but I'll leave it here in case
		output=$(java $PROGRAM)
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
