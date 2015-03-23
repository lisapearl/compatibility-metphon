#!/usr/bin/perl

# to run this file, type "perl convert.pl" in the directory that contains data.txt file.

# convert data.txt codes to a diff style of code where each syl is represented by a letter and capitalization reflects stress

# VC = C (could potentially become V, depending on parameter setting)
# VVC = Q (could potentially become VV)
# VV = L
# VCC or VCCC or VCCCC or VVCC or VVCCC or VVCCCC = A, for always closed syllable (even if C is removed by parameter setting)



#!/usr/bin/perl

$debugfile = "convert.debug";
open(DEBUG, ">$debugfile");

open (OUTPUT, '>converted.txt');   #opens output file
print (OUTPUT "withstress\tfreq\n"); #prints heading line

open(IN, "<data.txt") || die("Could not open data.txt\n");

while(<IN>){
my($inline) = $_; # variable holds the line


foreach ($inline) {  #for each line, convert, add stress, and print to converted.txt
    if(!($inline =~ /^Revised/)){
        chomp($inline);
        ($wordForm, $stress, $freq) = split(',',$inline);
        print(DEBUG "debug: Wordform from data.txt is $wordForm\n");
        $wordForm =~ s/^\s+|\s+$//g; # delete spaces, tabs, etcetera at either end of item
        
        my @syls = split(/\s+/, $wordForm); # split original syllable structure string on one or more spaces into array lineitems
        
        my @newSyls = ();
        
        foreach my $syl (@syls) { # for each syllable, convert and push into new array
            
            # first change irrelevant-for-my-purposes symbols back to Cs and Vs
            $syl =~ s/R/VC/; #convert any R in the string to VC, as syllabic consonant is irrelevant for this system and would otherwise be represented as schwa - consonant
            $syl =~ s/M/C/; #convert any M in the string to C, as possibly-syllabic consonant is irrelevant for this system
            $syl =~ s/^C*//;  #remove any number of Cs in syllable-initial location
            
            # then convert all syllable types to their appropriate letter-codes:
            if ($syl =~ '^VVCC(C)*$' || $syl =~ '^VCC(C)*$') {
                $syl = 'A'; # always closed, regardless of extrametrical-consonant parameter setting
            } elsif ($syl =~ '^VV$') {
                $syl = 'L'; # long
            } elsif ($syl =~ '(^VC$)') {
                $syl = 'P'; # closed, could potentially become X, depending on parameter setting
            } elsif ($syl =~ '^V$') {
                $syl = 'X'; # short
            } elsif ($syl =~ '^VVC$') {
                $syl = 'Q'; # closed, but could potentially become L, depending on parameter settings
            }
            
            push(@newSyls, $syl);
            
        }
        
        $wordForm = join('', @newSyls); #join new items into string $test_sequence with spaces between each item
        print(DEBUG "debug: after removing extraneous information and converting wordform is:  $wordForm\n");
        
        
        # then assign capitalization by stress using $stress value 
        
        $withstress = applyStress($wordForm, $stress);
        
        # output to converted.txt in preparation for condensing and addition of type column
        
        print (OUTPUT "$withstress\t$freq\n");
    
    }
   
}
   
    
}


        sub applyStress {
            my ($wordForm, $stress) = @_;
            print( DEBUG "debug: original  stress information for word: $stress \n");
            $wordForm =~ s/\s+//g; #remove all spaces
            $stress =~ s/\s+//g;
            my $final_form;
            for (my $i=0; $i<length($wordForm); $i++) {
                $currChar = substr($wordForm, $i, 1);
                #print (DEBUG "CURRENT CHaracter from wordform we are examining is $currChar\n");
                $currStress = substr($stress, $i, 1);
                #print (DEBUG "CURRENT stress from stress we are examining is $currStress\n");
                if ($currStress eq '0') {
                    $currChar =~ tr/A-Z/a-z/;
                }
                $final_form = $final_form . $currChar;
            }
            print(DEBUG "debug: after adding original stress information to syllable pattern: $final_form \n");
        
            return $final_form;
        }        


 close(IN);
 close (DEBUG);
 close (OUTPUT);
