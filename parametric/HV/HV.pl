#!/usr/bin/perl

# created December 17, 2009
# used to generate stress contours for combinations of syllable structure and stress,
# based on a parametric system of metrical phonology, as described in Pearl (2007)
# (taken mostly from Dresher (1999))

# takes a syllable sequence, such as "CC" and generates a stress contour

# syllable types:
# short (V) = X, closed (VC+) = C, long (VVC*) = L

# This version works with all logical permutations and outputs token and type compatibility to a text file as:
# token_compat type_compat P1 P2 P3 P4 P5

# 5 parameters

# Total possible grammars = 156  [subtract the 24 untestable QI-with-bounded-moraic grammars from 180)

# quantity sensitivity (1 sub = QS)
# 1= QI, 2 = QS-VC-H, 3 = QS-VC-L

# extrametricality (1 sub = Em-Some)
# 1 = Em-Left, 2 = Em-Rt, 3 = Em-None

# foot directionality
# 1 = Ft-Dir-Left, 2 = Ft-Dir-Rt

# boundedness (2 subs = B-Syl vs. B-Mor, B-2 vs. B-3)
# 1 = Unb, 2 = B-2-Syl, 3 = B-3-Syl, 4 = B-2-Mor, 5 = B-3-Mor
# Note: moraic are incompatible with QI

# feet headedness
# 1 = Ft-Hd-Left, 2 = Ft-Hd-Rt

##########
# program call
# perl HV.pl -inputfile <inputfilename> -debugfile <optionaldebugfilename>

process_options();

# output file is compatibility_HV.txt with NO inflectional knowledge; compatibility_HV_withinfl.txt with inflectional knowledge
open(OUTPUT, ">compatibility_HV.txt");

# read in inputfile
open(IN, "$opt_inputfile") || die("Could not open $opt_inputfile\n");
@inputlines = <IN>;
close(IN);

# set up debugging
$debugfile = "HV.debug";
if ($opt_debugfile) {$debugfile = $opt_debugfile;}
open(DEBUG, ">$debugfile");

#print header to output
#print("pattern\tgenerated\tmatch?\ttokens\ttypes\n");

open (INPUT, "permutations_HV.txt"); #grammar file
my %param_combo = ();
my $grammars = 0;

while(my $line = <INPUT>){ #read input form permutations.txt, which contains all logical grammar combinations
    chomp $line;
    ($quantityVal, $emVal, $ftdirVal, $boundVal, $fthdVal) = split (/\s+/, $line);
    
    #parameter combo for English, as defined in Dresher (1999), is quantity => 2, em => 2, ftdir => 2, bound => 2, fthd => 1
    %param_combo = (
    quantity => $quantityVal,
    em => $emVal,
    ftdir => $ftdirVal,
    bound => $boundVal,
    fthd => $fthdVal
    );
    
    print (DEBUG "debug: Current grammar is qs em fd b fh $quantityVal $emVal $ftdirVal $boundVal $fthdVal \n");
    
    my $token_match = 0;
    my $type_match = 0;
    
    my $token_nomatch = 0;
    my $type_nomatch = 0;
    
    my $monosyllabics_tokens = 0; # counter for monosyllabics
    my $monosyllabics_types = 0; # counter for monosyllabics
    

# read wordform and stress input 
foreach my $inline (@inputlines){
  # assumption: first item is stress structure contour pattern like LxLx, next is numtokens and next is numtypes
  # Form	NumTokens	NumTypes
  # CC	1829	123
  # CCc	8	5

  # skip heading line
  if(!($inline =~ /^Form/)){
    chomp($inline);
    @lineitems = split(/\s+/, $inline);
      
      print (DEBUG "debug: Incoming sequence is $lineitems[0] \n");
      
      my $length = length($lineitems[0]);
      if ($length eq "1") {
          
      $monosyllabics_tokens += $lineitems[1]; # counter for monosyllabics
      $monosyllabics_types += $lineitems[2];
    
      } else {
      
    foreach $lineitem (@lineitems){
      $lineitem =~ s/^\s+|\s+$//g;  
    }

    my $is_match = run_generation($lineitems[0]);
      
      if ($is_match == 1) {
          $token_match += $lineitems[1];
          $type_match += $lineitems[2];
      }
      else {
          $token_nomatch += $lineitems[1];
          $type_nomatch += $lineitems[2];
      }
      } # ends if length!- 1 loop
  }    #ends if!($inline LOOP
} #ends foreach LOOP
    
    my $token_total = $token_match + $token_nomatch;
    my $type_total = $type_match + $type_nomatch;
    
    #print DEBUG ("The monosyllabics tokens total is $monosyllabics_tokens\n");
    #print DEBUG ("The monosyllabics types for this grammar is $monosyllabics_types\n");
    
    my $token_compat = ($token_match + $monosyllabics_tokens)/($token_total + $monosyllabics_tokens); #tokens matched over total tokens
    my $type_compat = ($type_match + $monosyllabics_types)/($type_total + $monosyllabics_types); #types matched over total types
    
    #print DEBUG ("debug: Number of tokens chcked with this grammar is $token_total, # correct is $token_match. Number of types checked is $type_total, correct is $type_match, grammar is $line. Token compat is $token_compat and type compat is $type_compat .\n");
    
    print OUTPUT ("$token_compat ");
    print OUTPUT ("$type_compat ");
    print OUTPUT ("$line\n");

sub run_generation{
  my ($orig_struct_stress) = @_;
  #$orig_struct_stress = "LxLx";

  # generate stress pattern (into 1 and 0)
  my $orig_stress = $orig_struct_stress;
  $orig_stress =~ tr/[A-Z]/1/;
  $orig_stress =~ tr/[a-z]/0/;

  #convert to all caps to make test sequence
  my $test_sequence = $orig_struct_stress;
  $test_sequence =~ tr/[a-z]/[A-Z]/;

  #$test_sequence = "LCCXS";
  $orig_sequence = $test_sequence;
  #print(DEBUG "debug: test_sequence for $orig_struct_stress is $test_sequence\n");

  # call subroutine to generate stress contour
  # returns stress contour
  $stress_contour = gen_stress_contour($test_sequence, \%param_combo);
    
  # remove any extra spaces in the final stress contour and original stress contour
  $stress_contour =~ s/\s+//g;
  $orig_stress =~ s/\s+//g;

  # determine if is valid or not (doesn't contain any letters (b, h))
  $is_valid = true;
  if($stress_contour =~ /[a-z]/){$is_valid = false;}
    
    my $is_match; #variable to determine if match or not
    if($stress_contour eq $orig_stress){
        $is_match = 1;
        print(DEBUG "debug: Original is $orig_stress, final is $stress_contour . These contours match\n\n");
        #print("$orig_stress\t\t$stress_contour\t\t1\t");
    }else{
        $is_match = 0;
        print(DEBUG "debug: Original is $orig_stress, final is $stress_contour . These do not match\n\n");
        #print("$orig_stress\t\t$stress_contour\t\t0\t");
    }
    #print "The is_match value is $is_match\n\n";
    return $is_match;
    }

# determine stress contour and return series of 0s and 1s.
sub gen_stress_contour{
  my ($test_sequence, $param_combo_ref) = @_;

  # do quantity-sensitivity first
  $quantity = $param_combo_ref->{"quantity"};
  $test_sequence = do_quantity($test_sequence, $quantity);
  print(DEBUG "debug: after quantity-sensitivity assessment, test_sequence is $test_sequence\n");

  # do extrametricality next
  $em = $param_combo_ref->{"em"};
  $test_sequence = do_em($test_sequence, $em);
  print(DEBUG "debug: after extrametricality assessment, test_sequence is $test_sequence\n");

  # do feet directionality and boundedness together
  $ftdir = $param_combo_ref->{"ftdir"};
  $bound = $param_combo_ref->{"bound"};
  $test_sequence = do_ftdir_bound($test_sequence, $ftdir, $bound);

  # get rid of empty feet (), multiple open ((+ and closed parentheses ))+
  print(DEBUG "debug: before getting rid of parens substitution weirdness: $test_sequence\n");
  $test_sequence =~ s/\(\)//g;
  $test_sequence =~ s/\(+/\(/g;
  $test_sequence =~ s/\)+/\)/g;
  $test_sequence =~ s/\($//;
  print(DEBUG "debug: after ft dir and boundedness assessment, test_sequence is $test_sequence\n");

  # do feet headedness
  $fthd = $param_combo_ref->{"fthd"};
  $test_sequence = do_fthd($test_sequence, $fthd);
  print(DEBUG "debug: after ft headedness assessment, test_sequence is $test_sequence\n");

  # get rid of parens for stress contour comparison
  $stress_contour = $test_sequence;
  $stress_contour =~ s/[\)\(]//g;

  return $stress_contour;
}

# check quantity sensitivity parameter value and change syllables to h, l, or s accordingly
sub do_quantity{
  my ($test_sequence, $quantity) = @_;

  # if QI, replace all with s (all identical syllables)
  if($quantity == 1){
    $test_sequence =~ s/\w/s/g;
  }
  # else if QS-VC-H, replace all L and C with h (heavy) and all X with l (light)
  elsif($quantity == 2){
    $test_sequence =~ s/[LC]/h/g;
    $test_sequence =~ s/X/l/g;
  }# else if QS-VC-L, replace all L with h (heavy) and all C and X with l (light)
  elsif($quantity == 3){
    $test_sequence =~ s/L/h/g;
    $test_sequence =~ s/[CX]/l/g;
  } # else invalid parameter value
  else{ die("Unrecognized quantity sensitivity parameter: $quantity\n");}
  return $test_sequence;
}

# check extrametricality parameter value and use parens to separate extrametrical syllables 
sub do_em{
  my ($test_sequence, $em) = @_;
    my $wordLength = length($test_sequence);
    # if monosyllabic, add ( at beginning and ) at end
    if ($wordLength =~ "1"){
        $test_sequence =~ s/^(\w)/\($1/;
        $test_sequence =~ s/(\w)$/$1\)/;
    }# if em-left and not monosyllabic, replace first syllable with 0( and add ) at end
  elsif($em == 1 && $wordLength !~ "1"){
    $test_sequence =~ s/^\w/0\(/;
    $test_sequence =~ s/(\w)$/$1\)/;
  }# if em-right and not monosyllabic, replace last syllable with )0 and add ( at beginning
  elsif($em == 2 && $wordLength !~ "1"){
    $test_sequence =~ s/\w$/\)0/;
    $test_sequence =~ s/^(\w)/\($1/;
  }# if em-none and not monosyllabic, add ( at beginning and ) at end
  elsif($em == 3 && $wordLength !~ "1"){
    $test_sequence =~ s/^(\w)/\($1/;
    $test_sequence =~ s/(\w)$/$1\)/; 
  }# else invalid parameter value
  else{ die("Unrecognized extrametricality parameter: $em\n");}
  print DEBUG ("after do_em test sequence is $test_sequence \n");

  return $test_sequence;
}

# check ftdir and bound value and parse with parens to mark foot boundaries
sub do_ftdir_bound{
  my($test_sequence, $ftdir, $bound) = @_;
  # if ft-dir-left, perform substitutions on test_sequence as is
  if($ftdir == 1){
    $test_sequence = do_bound($test_sequence, $bound);
  } # if ft-dir-right, reverse sequence and then apply same substitutions, then un-reverse
  elsif($ftdir == 2){
    $reversed_sequence = join('',reverse(split(//,$test_sequence)));

    #print("debug: reversed test sequence is $reversed_sequence\n");
    $reversed_sequence =~ s/^(0?)\)/$1\(/;
    $reversed_sequence =~ s/\((0?)$/\)$1/;
    #print("debug: after replacing parens appropriately: $reversed_sequence\n");

    $reversed = do_bound($reversed_sequence, $bound);
    #print("debug: reversed after bound processing is $reversed\n");
    # un-reverse
    $test_sequence = join('', reverse(split(//,$reversed)));
    # print(DEBUG "debug: after un-reverse, test_sequence is now $test_sequence\n");
    # replace parens with their inverse
    @test_seq = split(//, $test_sequence);
    for($index = 0; $index < $#test_seq; $index++){
      if($test_seq[$index] eq "\)"){
	$test_seq[$index] = "\(";
      }elsif($test_seq[$index] eq "\("){
	$test_seq[$index] = "\)";
      }
    }
    $test_sequence = join("", @test_seq);
      #print(DEBUG "debug: after replacing feet parens appropriately in do_ftdir_bound: $test_sequence\n");

  }else {die("Unrecognized feet directionality parameter value: $ftdir\n");}

  return $test_sequence;
}

sub do_bound{
  my($test_sequence, $bound) = @_;

  # if unbounded, replace h with )(h
  if($bound == 1){
    $test_sequence =~ s/h/\)\(h/g; 
  } 
  # if b-2-syl, replace \w\w with (\w\w)(
  elsif($bound == 2){
    $test_sequence =~ s/(\w\w)/\($1\)\(/g;
  }
  # if b-3-syl, replace \w\w\w with (\w\w\w)(

  elsif($bound == 3){
    $test_sequence =~ s/(\w\w\w)/\($1\)\(/g;
  }
  # if b-2-mor, replace (h with (h)(, and (ll with (ll)(, 
  #    and (lh with b (bad combo)
  #    make sure not qi; if so, die with incompatible parameter combo
  elsif($bound == 4){
    if($quantity == 1){die("Can't have bounded moraic with qi\n");}
    $test_sequence =~ s/h/\(h\)\(/g;
    $test_sequence =~ s/ll/\(ll\)\(/g;
    $test_sequence =~ s/l\(?h/b/g;

    # substitute  leftover weird syllables with b
    $test_sequence =~ s/[lh]\(/b\(/g;
  }
  # if b-3-mor, replace (hl with (hl)(, and (lh with (lh)(, and (lll with (lll)( ,
  #    and (hh with b ( bad combo), and (llh with b (bad combo)
  #    make sure not qi; if so, die with incompatible parameter combo
  elsif($bound == 5){
    if($quantity == 1){die("Can't have bounded moraic with qi\n");}

    # to guard against weirdness from initial lhl sequence
    # print(DEBUG "debug: before b-3 mora lhl weirdness takeout: $test_sequence\n");
    $test_sequence =~ s/\(hl/\(hl\)\(/;
    $test_sequence =~ s/\(lh/\(lh\)\(/;
    # print(DEBUG "debug: after b-3 mora lhl weirdness takeout: $test_sequence\n");

    # now do the rest
    $test_sequence =~ s/hl/\(hl\)\(/g;
    $test_sequence =~ s/lh/\(lh\)\(/g;
    $test_sequence =~ s/lll/\(lll\)\(/g;

    # find bad combos
    $test_sequence =~ s/hh/b/g;

    # replace leftover weird syllables with b
    $test_sequence =~ s/[lh]\(/b/g;
    # print(DEBUG "debug: after b-3 mora do_bound all steps completed: $test_sequence\n");
  }
  else{die("Unrecognized boundedness parameter: $bound\n");}
  
  print(DEBUG "debug: after do_bound test sequence is $test_sequence\n");
  return $test_sequence;
}

sub do_fthd{
  my($test_sequence, $fthd) = @_;
  # note: don't replace b with anything nor h that are not stressed

  # if fthd = 1, ft hd left so 
  if($fthd == 1){
    # for quantity insensitive case
    $test_sequence =~ s/\(s/\(1/g; # replace all foot-initial s with 1
    $test_sequence =~ s/s/0/g; # replace all non-foot-initial s with 0

    # for quantity sensitive cases
    $test_sequence =~ s/\([hl]/\(1/g; # replace foot-initial h or l with 1
    $test_sequence =~ s/l/0/g; # replace non-foot-initial l with 0
 
  }  # if fthd = 2,
  elsif($fthd == 2){
    
    # for quantity insensitive case, replace all foot-final s with 1 and all non-foot-final s with 0
    $test_sequence =~ s/s\)/1\)/g;
    $test_sequence =~ s/s/0/g; 

    # for quantity sensitive cases, ft hd right so replace [hl]) with 1 and all other l with 0
    $test_sequence =~ s/[hl]\)/1\)/g;
    $test_sequence =~ s/l/0/g;   

  }else{die("Unrecognized feet headedness parameter value: $fthd\n");}

    print (DEBUG "debug: after do_fthd test sequenc is $test_sequence\n");
  return $test_sequence;
}
    $grammars++;
} # end of while loop

print "\nTotal number of grammars  checked was $grammars\n\n";
close(OUTPUT);
close(DEBUG);

sub process_options{
    use Getopt::Long;
  &GetOptions("inputfile=s", #grammar file and data file are required
	               "debugfile:s"); #debugfile is optional (default = stress_countours.debug) 
}
