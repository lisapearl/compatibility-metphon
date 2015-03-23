#!/usr/bin/perl



my $file = 'converted_HV.txt';
open (INPUT, $file) or die "Can't open file: $!\n";
my @lines = <INPUT>;

open (OUTPUT, '>condensed_HV.txt');
#print OUTPUT "WordStress\tTokens\tTypes\n";

my %types = ();
my %tokens = ();

foreach $_(@lines) {
    chomp;
    my @lines = split ('\s+', $_);
    my $wordstress = $lines[0];
    my $freq = $lines[1];
    
    chomp $wordstress;
    chomp $freq;
    
    if( $wordstress =~ 'withstress' ){
        next;
    }else{
        
    
        if (exists $types{$wordstress}) {
            $types{$wordstress}++;
        } else {
            $types{$wordstress} = 1;
        }
        if (exists $tokens{$wordstress}) {
            $tokens{$wordstress} += $freq;
        } else {
            $tokens{$wordstress} = $freq;
        }
    }
}

while ( my ($key, $value) = each(%types)) {
    $numTok = $tokens{$key}; #numTok is number of tokens at that withStress, taken from value in %tokens hash
    print OUTPUT "$key\t$numTok\t$value\n";
}


close (FILE);