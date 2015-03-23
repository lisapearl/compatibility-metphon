#!/usr/bin/perl

use Getopt::Long;

my $stressAppliedCountsFile;
GetOptions("file|f=s" => \$stressAppliedCountsFile);

if (length($stressAppliedCountsFile // '') > 0) {
    open(STDIN, "< $stressAppliedCountsFile");
}
my %types = ();
my %tokens = ();

while(<STDIN>) {
    chomp;
    ($wordForm, $freq) = split("\t");
    if (exists $types{$wordForm}) {
        $types{$wordForm}++;
    } else {
        $types{$wordForm} = 1;
    }
    if (exists $tokens{$wordForm}) {
        $tokens{$wordForm} += $freq;
    } else {
        $tokens{$wordForm} = $freq;
    }
}

while ( my ($key, $value) = each(%types)) {
    $numTok = $tokens{$key};
    print "$key\t$numTok\t$value\n";
}
