Code created by Timothy Ho, UC Irvine.

############################################
CREATING THE brent.data AND brent.data.FILES
############################################

The createDataFile.sh shell script is meant to encapsulate the data file
creation process. Make sure its permissions are set to executable by
running:

chmod u+x createDataFile.sh

And run the script:

./createDataFile.sh

The script requires a data table CSV file. By default it looks for 
dataTableFull.csv. If it can't find this it will ask the user for the
name of the data table CSV file. 

By default, dataTableFull.csv (as of June 2013) keeps the syllable 
structure in column 8, the stress pattern in column 10, the token frequency
in column 17, and the root form syllabification in column 12. The script 
calls lower level processing scripts with these parameters in mind. 
The results will print to standard output, so it's better to redirect the
output to a file by running:

./createDataFile.sh > brent.data
or
./createDataFile.sh > brent.data.withInfl

Depending on if you plan using the regular data or data with inflection
stripped.

In case you want to run the lower level processing scripts instead of the
high level script, first run getFreqs.pl. It will convert syllable structures
into condensed word forms, list stress patterns, and list frequencies. 
It also takes care of stripping inflection. If you run it with an -o flag
and supply it with a file name, it will direct its output to the file. 
The applyStress.pl script simply maps the stress patterns to the wordforms,
and the typesTokens.pl script adds up all the types and tokens of each
kind of word form. 



############################################
RUNNING THE OT CODE 
############################################ 

Once you have the data file in the working directory simply run the runOT.py
file with the grammar file as the argument. The program expects the grammar 
file to be in the format of nine consecutive integers separated by white 
space. Each integer represents a constraint, and linear precedence denotes a
higher ranked constraint. Each grammar is separated by a newline. As of June
2013, the integer-constraint mapping is:

0 - Foot Binarity
1 - Weight to Stress, VC
2 - Weight to Stress, VV
3 - Parse-sigma
4 - Non Finality
5 - Align Right
6 - Align Left
7 - Trochaic
8 - *Sonorant Nucleus

The runOT.py program requires a data file (the creation of which is described
in the section above), a grammar file, a gen_candidates script, an xfst binary,
 and a feet.xfst file. These last three files are described below:

feet.xfst - Specifies how feet can be built, and how stress transforms 
syllables. I didn't fully understand how it was supposed to be written, but
I have changed it to reflect what I need. 

xfst - This binary (for Linux 64 bit) generates all possible footings and 
stress assignments, given an input string (such as 'xl' or 'cc') and the 
feet.xfst file. It may be necessary to download the appropriate binary for 
your system from:

http://www.stanford.edu/~laurik/.book2software/

gen_candidates - Helper file called by runOT.py to create OT candidates


There is an implementation of Python called PyPy, which I've used successfully 
to run the runOT.py program, and it definitely runs a lot faster than normal
Python, so I recommend getting PyPy and using it instead of Python to speed 
up the process. 

The grammar file is simply a permutation of all constraint rankings, where the
constraints are signified by integers. The perl script permute.pl will create
the permutations:

perl permute.pl > grammars.all

Once you have all of these pieces, run the OT code by entering the command:

python runOT.py [grammarFile] [dataFile]

Typically, this looks like:

python runOT.py grammars.all brent.data > grammars.eval.brent.txt




############################################
ANALYZING THE DATA
############################################

There are a few ways that we've decided to analyze the results. One way actually
doesn't involve the results, but rather the encoded Brent data. The Python script
called preAnalysis.py can give details about the total number of tokens, types, 
wordforms with unique stress patterns, wordforms with multiple stress patterns,
data upper bounds, and word form frequencies. Simply run:

python preAnalysis.py brent.data

On the brent data file (here it's brent.data) to get these data.

###
To get relative compatibility, it can be helpful to sort the output of the analysis file with the built-in unix sort command:

sort -grk 1 compatibility.txt > compatibility.byTokens.txt

This sorts on the first column in reverse numerical order, using numerical values (rather than string versions).

In addition, the make_rel_comp_classes.pl script can be used to get more precise relative compatibility output. The output of this script is a set of "buckets" by tokens and types, sorted from highest to lowest.

To run:
# Hayes, HV
make_rel_comp_classes.pl --compatibility_file compatibility.txt
# OT
make_rel_comp_classes.pl --grammars.eval.brent.txt compatibility.txt --OT

HV, Hayes: input expected (ex: compatibility.txt in Hayes or HV)

[token-score type-score grammar-description...]
0.873289661366158 0.692908653846154 1 2 1 1 1 1 1 1
0.867769031644567 0.682091346153846 1 2 1 1 1 1 1 2
0.873289661366158 0.692908653846154 1 2 1 1 1 1 2 1
0.000950921865920017 0.00360576923076923 1 2 1 1 1 1 2 2

OT: grammars.eval.brent.txt
[grammar-description (9 numbers) token-score type-score is-english]
7 2 4 5 1 8 6 0 3 0.555592798314 0.594594594595 1
7 2 4 5 1 8 0 6 3 0.564467215731 0.620334620335 1




