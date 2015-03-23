#!/usr/bin/perl

use Getopt::Long;
my $translatedFile;

GetOptions('file|f=s' => \$translatedFile); # input file (this will come from getFreqs.pl)
if (length($translatedFile // '') > 0) {
    chomp($translatedFile);
    open(STDIN, "<", "$translatedFile");
}
open(ERRFILE, 'errors.log');
my $lineNum = 1;
my $problem = 0;
while(<STDIN>) {
    chomp;
    ($word, $wordForm, $stress, $freq) = split("\t");
    if (length($wordForm) !=  length($stress)) { # checks if number of stress digits are equal to the number of condensed syllables
        print ERRFILE "Syllable number mismatch on line $lineNum\n";
        $problem += 1;
    }
    $applied = applyStress($wordForm, $stress); # applies stress to syllables
    print "$applied\t$freq\n";
    $lineNum += 1;
}
close(STDIN);
close(ERRFILE);

if ($problem > 0) {
    print STDERR "THERE WERE ERRORS APPLYING STRESS. CHECK error.log FOR DETAILS";
} 

sub applyStress {
    my ($wordForm, $stress) = @_;
    my $newWord;
    for (my $i=0; $i<length($wordForm); $i++) {
        $currChar = substr($wordForm, $i, 1);
        $currStress = substr($stress, $i, 1);
        if ($currStress eq '0') {
            $currChar =~ tr/A-Z/a-z/;
        }
        $newWord = $newWord . $currChar;
    }
    return $newWord;
}

