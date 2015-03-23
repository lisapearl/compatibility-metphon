Code created by Zephyr Detrano, UC Irvine.

#########################
Preprocess for Hayes data input, without or with inflectional morphology knowledge
#########################

To get from a csv file such as dataTableFull.csv to a file like condensed.txt (the data that will be used by the Hayes compatibility code) run pullfromtable.pl to pull desired columns from the table. You can create the file assuming the learner does not have inflectional morphology knowledge (option = “n”) or instead does (option = “y”). You then run convert.pl to convert from VVC type encoding to XpQla type encoding, run condenser.pl to condense remaining word forms and add type and token information.

Output will be condensed.txt, showing unique word forms, frequency by tokens, freq by types: 
XxL	143	17
lLp	3	2

As of August 2013, the syllable types relevant to the Hayes system are:

X = V (light)
L = VVC* (heavy)
A = VCC+ (A for always closed syllable, even if Em-Cons; weight is determined by VC-H or VC-L)
P = VC (potentially V, if final consonant removed)

#######################
Preprocess for HV data input
#######################

To get from a csv file like dataTableFull.csv to condensed_HV.txt, the data that will be used by the HV compatibility code:

1) run pullfromtable.pl to pull desired columns from the table. This code should be the same as that used for Hayes compatibility code.

2) run convert_HV.pl to convert from VVC type encoding to Xl-type encoding, the encoding relevant for the HV compatibility code. Relevant codes for the HV system are:

X = V  short
L = VVC* long
C = VC+   closed, light or heavy depending on VC-H vs VC-L setting

3) Run condenser_HV.pl to condense remaining word forms and add type and token information. This code is the same as condenser.pl with only file names changed.

Output will be condensed_HV.txt, showing unique word forms, frequency by tokens, freq by types: 
XxL	143	17
XLc	13	3

####################### 
Note 1: The pullfromtable.pl script currently also has options for grammatical category knowledge and compound word knowledge.
#######################

