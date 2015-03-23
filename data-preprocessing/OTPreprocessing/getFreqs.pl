#!/usr/bin/perl
use strict;
use warnings;
use Text::CSV;
use Getopt::Long;

my ($file, $syllColNum, $stressColNum, $freqColNum, $inflection, $rootColNum, $outputFileName); # declaration of parameters

GetOptions('data|d=s' => \$file, 'syl=i' => \$syllColNum, 'stress=i' => \$stressColNum, 'freq=i' => \$freqColNum, , 'inflection|i' => \$inflection, 'root|r=i' => \$rootColNum, 'output|o=s' => \$outputFileName); # getting flag values

while (length($file // '') <= 0) { # if data file isn't specified, ask for it
    print "Enter name of CSV file:\n";
    chomp($file = <>);
}
while (($syllColNum // 0) <= 0) { # if column of syllable structure isn't specified, ask for it
    print "Enter column number of syllable structure:\n";
    $syllColNum = <>;
}
while (($stressColNum // 0) <= 0) { # if column of stress assignment isn't specified, ask for it
    print "Enter column number of stress assignment:\n";
    $stressColNum = <>;
}
while (($freqColNum // 0) <= 0) { # if column number of token frequencies isn't specified, ask for it
    print "Enter column number of frequencies:\n";
    $freqColNum = <>;
}
if (($inflection // 0) eq 1) {
    while (($rootColNum // 0) <= 0) { # if column number of root form isn't specified, ask for it
        print "Enter column number of root form:\n";
        $rootColNum = <>;
    }
}
$syllColNum -= 1; # subtracting all numerical variables by 1 because of 0 indexed csv
$stressColNum -= 1;
$freqColNum -= 1;
if (($inflection // 0) eq 1) {
    $rootColNum -= 1;
}

if (length($outputFileName // '') <= 0) { # sets output stream to a file if specified, STDOUT otherwise
    open(OUTPUT, ">&STDOUT");
} else {
    open (OUTPUT, ">", "$outputFileName");
}

my $csv = Text::CSV-> new(); # creates new CSV object

open (CSV, "<", $file) or die $!;

while (<CSV>) { # iterate over each line of the csv
    if ($csv->parse($_)) {
        my @columns = $csv->fields();
        my $word = normalize($columns[0]); # gets rid of @ symbols and slashes, makes everything lowercase
        if ($word eq '' || $word eq 'word') { # checks if there is a header in the table, if so, skip it because it isn't data
            next;
        }
        print OUTPUT "$word\t"; # print word
        my $stress= $columns[$stressColNum];
        if ($stress =~ /'/) { # removes escaping quote if it exists
            $stress = substr $stress, 1;
        }
        my $translatedWord = translateWord($columns[$syllColNum]);
        my $inflData;
        if (($inflection // 0) eq 1) {
            $inflData = $columns[$rootColNum];
            if ($inflData ne '0' && $inflData ne '') {
                $translatedWord = translateWord($inflData);
                if (length($translatedWord) != length($stress)) {
                    $stress = substr $stress, 0, -1;
                    if (length($translatedWord) != length($stress)) {
                        print STDERR "$translatedWord\t$stress\t";
                        print length($translatedWord);
                        die "Can't get right number of syllables $stress $word $inflData $translatedWord";
                    }
                }
            }
        }
        print OUTPUT $translatedWord; # prints condensed form of syllable structure
        print OUTPUT "\t$stress\t$columns[$freqColNum]"; # prints stress and frequency
        print OUTPUT "\n"; 
    } else {
        my $err = $csv->error_input;
        print STDERR "Failed to parse line: $err\n";
    }
}
close(CSV);

sub translateWord { # high level function for condensing syllable structure to single character coding
    my ($str) = @_; 
    my @strArray = split(/ /, $str);
    my @translated = (); 
    foreach my $syl(@strArray) {
        push(@translated, translateSyl($syl));
    }   
    return join('',@translated);
}

sub translateSyl {
    my ($syl) = @_;
    my $oldsyl = $syl;
    $syl =~ s/^C*//;
    if ($syl =~ '^VV(M|C)+$') {
        return 'S'; # superlong
    } elsif ($syl =~ '^VV$') {
        return 'L'; # long
    } elsif ($syl =~ '(^VC+$)') {
        return 'C'; # closed
    } elsif ($syl =~ '^V$') {
        return 'X'; # short
    } elsif ($syl =~ '^RC+$') {
        return 'D'; # sonorant closed (equivalent to VC) (heard)
    } elsif ($syl =~ '^R$') {
        return 'R'; # sonorant open (light) (actor)
    } elsif ($syl =~ '^VM$') {
        return 'M'; # VC structure, potentially R under certain grammars (ten)
    } elsif ($syl =~ '^VMC+$') {
        return 'T'; # VCC structure, potentially D under certain grammars (tent)
    }
    my $lineNum = $. - 1;
    print STDERR "$oldsyl not a valid syllable structure on line $lineNum\n";
    return 'error';
}

sub normalize {
    my ($word) = @_;
    $word =~ s/@.*//;
    $word =~ s/\+//;
    $word =~ tr/[A-Z]/[a-z]/;
    return $word;
}




