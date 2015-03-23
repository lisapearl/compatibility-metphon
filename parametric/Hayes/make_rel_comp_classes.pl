#!/usr/bin/perl -w

## script to create relative compatibility class "buckets" by tokens and types, sorted from highest to lowest

## input expected (ex: compatibility.txt in Hayes or HV)

# [token-score type-score grammar-description...]
# 0.873289661366158 0.692908653846154 1 2 1 1 1 1 1 1
#0.867769031644567 0.682091346153846 1 2 1 1 1 1 1 2
#0.873289661366158 0.692908653846154 1 2 1 1 1 1 2 1
#0.000950921865920017 0.00360576923076923 1 2 1 1 1 1 2 2

## or for OT: grammars.eval.brent.txt
# [grammar-description (9 numbers) token-score type-score is-english]
# 7 2 4 5 1 8 6 0 3 0.555592798314 0.594594594595 1
# 7 2 4 5 1 8 0 6 3 0.564467215731 0.620334620335 1


## Usage
# make_rel_comp_classes.pl --compatibility_file compatibility.txt
# make_rel_comp_classes.pl --grammars.eval.brent.txt compatibility.txt --OT




use Getopt::Long;
GetOptions("compatibility_file=s" => \$compatibility_file,    # file containing compatibility scores by types and tokens for each grammar in the KR
	   "OT" => \$OT
	    );

print(STDERR "Creating relative class compatibility buckets for $compatibility_file\n");
if($OT){
  print(STDERR "Using OT input settings\n");
}else{
  print(STDERR "Not using OT input settings\n");
}

# hashes that contain compatibility scores for tokens and types
%tokens_scores = ();
%types_scores = ();


open(COMP, "$compatibility_file") || die("Couldn't open compatibility file $compatibility_file\n");

# read in each line of the compatibility file and extract type and token scores for that grammar
while(defined($compline = <COMP>)){
  ($token_score, $type_score) = get_token_type_scores($compline, $OT);
  #print("debug: token score = $token_score, type score = $type_score\n");
  # update hashes as appropriate: +1 grammar for each score
  if($token_score){ # make sure don't have empty value
    if(!exists($tokens_scores{$token_score})){
      $tokens_scores{$token_score} = 1;
    }else{
      $tokens_scores{$token_score} += 1;
    }
  }

  if($type_score){ # make sure don't have empty value
    if(!exists($types_scores{$type_score})){
      $types_scores{$type_score} = 1;
    }else{
      $types_scores{$type_score} += 1;
    }  
  }

}
close(COMP);

# print out buckets, sorted in descending order by hash key (which is score)
# sort {$b <=> $a} -- basic sort to sort in reverse numerical order

# print out tokens buckets
$token_output = $compatibility_file."\.token_buckets\.txt";
open(TOKEN_OUT, ">$token_output") || die ("Couldn't open $token_output to print out token buckets\n");
print(STDERR "Printing token buckets out to $token_output\n");
foreach $token_bucket (sort {$b <=> $a} keys(%tokens_scores)){
    print(TOKEN_OUT "$token_bucket $tokens_scores{$token_bucket}\n");
}
close(TOKEN_OUT);

# print out types buckets
$type_output = $compatibility_file."\.type_buckets\.txt";
open(TYPE_OUT, ">$type_output") || die ("Couldn't open $type_output to print out type buckets\n");
print(STDERR "Printing type buckets out to $type_output\n");
foreach $type_bucket (sort {$b <=> $a} keys(%types_scores)){
    print(TYPE_OUT "$type_bucket $types_scores{$type_bucket}\n");
}
close(TYPE_OUT);


############################
sub get_token_type_scores{
  my ($compline, $OT) = @_;

  my $token_score = ""; 
  my $type_score = ""; 

  if($OT){
    # expect line of form
    # 7 2 4 5 1 8 6 0 3 0.555592798314 0.594594594595 1
     
    # want two floating numbers after string of single digits separated by spaces
    if($compline =~ /( ?\d )+(\d\.\d+) (\d\.\d+)/){
      #print("debug: token score = $2, type score = $2\n");
      $token_score = $2;
      $type_score = $3;
    }

  }else{
    # expect line of form 
    # 0.873289661366158 0.692908653846154 1 2 1 1 1 1 1 1

    # want first two (floating point) numbers
    if($compline =~ /(\d\.\d+) (\d\.\d+)/){
      #print("debug: token score = $2, type score = $2\n");
      $token_score = $1;
      $type_score = $2;
    }

  }

  return ($token_score, $type_score);

}
