Code created by Zephyr Detrano, UC Irvine.

######################
CREATE DATA INPUT FILE
######################
See ReadMe.txt in data/ParametricPreprocessing/ folder.

####################
CREATE GRAMMAR FILE
####################
Run permutations.py (Hayes) or permutations_HV.py to create text file permutations.txt of all permissible grammars for this system.

#Hayes
python permutations.py
# HV
python permutations_HV.py

######################################
RUNNING THE HAYES OR HV COMPATIBILITY CODE
######################################

#Hayes:
Run the hayes.pl file (or hayes_macos.pl version which should be compatible with mac os x) with the data input file (e.g., condensed.txt for no-inflection-knowledge; condensed_withinfl.txt for with-inflection-knowledge) as the argument.

perl hayes_macos.pl --inputfile condensed.txt

Note: permutations.txt must be in same folder as this script.

#HV 
Run the HV.pl file with the data input file (e.g., condensed_HV.txt for no-inflection-knowledge; condensed_HV_withinfl.txt for with-inflection-knowledge) as the argument.

perl HV.pl --inputfile condensed_HV.txt

Note: permutations_HV.txt must be in same folder as this script.

The program expects the data input file to include unique wordforms with frequency by tokens and types, separated by white space. Example:

Wordform Tokens Types
XxL	143	17
lLp	3	2


# Hayes
As of August 2013, the relevant Hayes syllable types are:

X = V (light)
L = VVC* (heavy)
A = VCC+ (A for always closed syllable, even if Em-Cons; weight is determined by VC-H or VC-L)
P = VC (potentially V, if final consonant removed)

Upper case letters in the word form represent stressed syllables, lower case letters represent unstressed syllables.

The program will use permutations.txt as default grammar input and this should also be placed in the working directory. Example line from permutations.txt is:
1 2 1 1 1 1 1 1

Note that the English values are these:
1 2 2 1 1 1 2 1  
(Em-RtCons, QS-VC-H, Ft-Dir-Rt, Moraic Trochees, LP-Strong, DF-Strong, WLER-Rt, Bottom-Up)

The numbers represent parameter settings, for, from left to right:
extrametricality, quantity sensitivity, foot directionality, foot inventory, local parsing, degenerate foot prohibition, word layer end rule, and location.

The default output file for hayes.pl is compatibility_tokensfirst.txt and output includes token compatibility, type compatibility, followed by grammar. Example:
0.525468149807939 0.479497907949791 1 2 1 1 1 1 1 1
0.480963908450704 0.420502092050209 1 2 1 1 1 1 1 2


# HV

As of July 2013, the HV syllable types are:

X = V
L = VVC*
C = VC+

Upper case letters in the word form represent stressed syllables, lower case letters represent unstressed syllables.

The program will use permutations_HV.txt as default grammar input and this should also be placed in the working directory. Example line from permutations_HV.txt is:
1 1 1 1 1
1 1 1 1 2

Note: The English values are 
2 2 2 2 1

The numbers represent parameter settings for, from left to right:
quantity sensitivity, extrametricality, foot directionality, boundedness, foot headedness

The default output file for HV.pl is compatibility_HV.txt and output includes token compatibility, type compatibility, followed by grammar. Example:
0.525468149807939 0.479497907949791 1 1 1 1 1
0.480963908450704 0.420502092050209 1 1 1 1 2

Suggestion: If running program with inflection knowledge, be sure to change output to compatibility_withinfl.txt to avoid confusion

############################################
ANALYZING THE DATA
############################################

There are a few ways that we've decided to analyze the results. One way actually
doesn't involve the results, but rather the encoded Brent data. The Python script
called preAnalysis.py can give details about the total number of tokens, types, 
wordforms with unique stress patterns, wordforms with multiple stress patterns,
data upper bounds, and word form frequencies. Simply run:

python preAnalysis.py condensed.txt 

OR 

python preAnalysis.py condensed_withinfl.txt

This will output a file called upperbound.txt. You can rename it as appropriate.

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




