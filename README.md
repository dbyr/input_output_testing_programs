# input_output_testing_programs
Use for running tests on input/output programs.
The programs in here are basically just slight variations of the same program but used for programs developed using different languages.
### The Basic Idea
In order to use these, put a bunch of input files into a folder, and another bunch of expected output files (with names corresponding to those of their corresponding input files) in another folder. When you run the program, specify these two folder and the tester will run the target program with the arguments/input from the input files, and compare the stdout to those of the expected folder.
Specifying the -a option will read the first line of the input file as arguments to the target program.
Specifying the -s option will read the remaining text in the file (i.e., if -a is also given, then all lines after the first) as stdin.
