#########################
Preprocess for OT data, without or with inflectional morphology
knowledge

Code created by Timothy Ho, UC Irvine.
#########################

To get from a csv file such as dataTableFull.csv to a file like
 condensed.txt (the data that will be used by the OT compatibility
 code), run createDataFile.sh to pull desired columns from the table
 (without or with inflectional morphology knowledge, as prompted on
 teh command line: "Do you want to strip inflection?"). The output
 will be piped to the screen, so it's best to redirect it to a file:

createDataFile.sh > condensed_OT.txt

This script calls the getFreqs.pl, applyStress.pl, and typeTokens.pl scripts with the appropriate arguments. 

