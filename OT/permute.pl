#!/usr/bin/perl
# code that should produce permutations

use List::Permutor;

my @array = (0,1,2,3,4,5,6,7,8);

my $perm = new List::Permutor @array;

while (my @set = $perm->next) {
print " @set\n";
} 
