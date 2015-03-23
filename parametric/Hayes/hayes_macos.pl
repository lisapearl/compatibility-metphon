#!/usr/bin/perl

# created October 25, 2012

# used to generate stress contours for combinations of syllable structure and stress,
# based on a parametric system of metrical phonology, as described in Hayes (1995)

# takes a word that is coded as a sequence of syllables with relevant encodings (see "input symbols" below) and generates a stress contour for the word using metrical stress rules

# This version works with all logical permutations and outputs token and type compatibility to a text file:
# token_compat type_compat P1 P2 P3 P4 P5 P6 P7 P8

# input symbols: example - "Xl" where each letter is one syllable, capitalization represents stress
# canonical syllable translation: V = X, VVC* = L, VCC+ = A  ( always closed – whether tense or lax vowel. weight depends on quantity parameter setting), VC = P (potentially V, if final consonant is removed by EmFinalCons), 

# generated stress contour: example, "101" ; 1 for stressed, 0 for unstressed

# 8 parameters, based on Hayes (1995); 768 testable grammars, to be read in from permutations.txt

# extrametricality 
# 1 = Em-FinalCons, 2 = Em-Syl-Left, 3 = Em-Syl-Rt, 4=Em-None
# Note: freely combines with all parameter settings

# quantity
# 2 = QS-VC-H, 3= QS-VC-L
# Note: freely combines with all parameter settings

# foot directionality 
# 1 = Ft-Dir-Left, 2 = Ft-Dir-Rt
# Note: freely combines with all parameter settings

# foot inventory 
# 1 = Moraic Trochee, 2 = Iamb, 3 = Syllabic Trochee
# Note: freely combines with all parameter settings

# local parsing
# 1 = LP-Strong, 2 = LP-Weak
# Note: freely combines with all parameter settings

# degenerate foot prohibition
# 1 = DF-Strong, 2 = DF-Weak
# Note: freely combines with all parameter settings

# word layer end rule
# 1 = WLER-Left, 2 = WLER-Right
# Note: freely combines with all parameter settings

# location
# 1= Bottom-up Stress, 2 = Top-down Stress
# Note: freely combines with all parameter settings

##########
# program call
# hayes.pl -inputfile <inputfilename> -debugfile <optionaldebugfilename>
#
# example call
# perl hayes.pl -inputfile condensed.txt -debugfile test.debug

###################
# Program Start           #
###################

process_options();

open(OUTPUT, ">compatibility.txt");

# open inputfile containing all unique wordforms from data 
open(IN, "$opt_inputfile") || die("Could not open $opt_inputfile\n");
@inputlines = <IN>;
close(IN);

# set up debugging
$debugfile = "hayes.debug";
if ($opt_debugfile) {$debugfile = $opt_debugfile;}
open(DEBUG, ">$debugfile");

# open inputfile with grammars
open (INPUT, "permutations.txt"); #grammar file

# hold parameter values for current grammar here
my %param_combo = ();

# hold total grammars thus far examined here 
my $grammars = 0;

#read input form permutations.txt, which contains all logical grammar combinations
while(my $line = <INPUT>){ 
    
    chomp $line;
    print DEBUG ("------------------------  CURRENT GRAMMAR IS $line \n");
    
    # for reference: parameter combo for English, as defined in Hayes (1995), is em=>1, quantity=>2, ftdir=>2, ftinventory=>1, lp=>1, df=>1, wler=>2, location=>1
    # assign values for current grammar parameters to %param_combo
    ($emVal, $quantityVal, $ftdirVal, $ftinventoryVal, $lpVal, $dfVal, $wlerVal, $locationVal) = split (/\s+/, $line);

    %param_combo = (
    em => $emVal,
    quantity => $quantityVal,
    ftdir => $ftdirVal,
    ftinventory => $ftinventoryVal,
    lp => $lpVal,
    df => $dfVal,
    wler => $wlerVal,
    location => $locationVal
    );

# create counters for match and nomatch frequencies
my $token_match = 0;
my $type_match = 0;
    
my $token_nomatch = 0;
my $type_nomatch = 0;

# counter for monosyllabics
my $monosyllabics_tokens = 0; 
my $monosyllabics_types = 0; 
    
# read wordform and stress input
# assumption: first item is wordform with stress contour, e.g. Lp, next is tokens, then types
# Lp	2	2
# XLl	237	16
    
foreach my $inline (@inputlines) {
  # skip heading line
  if(!($inline =~ /^Form/)){
    chomp($inline);
    my @lineitems = split(/\s+/, $inline); # split on spaces to grab wordform and frequencies
    my $length = length($lineitems[0]);
    if ($length eq "1") {
        $monosyllabics_tokens += $lineitems[1]; 
        $monosyllabics_types += $lineitems[2];
       }
    else {
    foreach my $lineitem (@lineitems) {
      $lineitem =~ s/^\s+|\s+$//g; # delete spaces, tabs, etcetera at either end of item
    }
    
    print DEBUG ("Original test sequence is $lineitems[0] .\n");
    # subroutine run_generation generates stress contour for wordform $lineitems[0]. returns 0 for no-match original stress contour, 1 for match
    my $is_match = run_generation($lineitems[0]);
      
      if ($is_match == 1) {
          $token_match += $lineitems[1];
          $type_match += $lineitems[2];
          # print DEBUG ("We have added frequency total to token_match, which is now $token_match \n");
      }
      else {
          $token_nomatch += $lineitems[1];
          $type_nomatch += $lineitems[2];
          # print DEBUG ("We have added frequency total to nomatch, which is now $token_nomatch \n\n");
           }
       } 
    }
  }
    
    #print DEBUG ("Tokens matched for this grammar were $token_match\n");
    #print DEBUG ("Tokens NOT matched for this grammar were $token_nomatch\n");
    #print DEBUG ("Types matched for this grammar were $type_match\n\n");
    #print DEBUG ("Types NOT matched for this grammar were $type_nomatch\n\n");
    
    my $token_total = $token_match + $token_nomatch;
    my $type_total = $type_match + $type_nomatch;
    
    #print DEBUG ("The monosyllabics tokens total is $monosyllabics_tokens\n");
    #print DEBUG ("The monosyllabics types for this grammar is $monosyllabics_types\n");
    
    # calculate compatibility tokens, types
    my $token_compat = ($token_match + $monosyllabics_tokens)/($token_total + $monosyllabics_tokens); #tokens matched over total tokens
    my $type_compat = ($type_match + $monosyllabics_types)/($type_total + $monosyllabics_types); #types matched over total types
    
    #print DEBUG ("The total number of tokens checked with this grammar was $token_total\n\n");
    #print DEBUG ("Token compatibility for this grammar is $token_compat\n");
    
    # output token compatibility, type compatibility, and grammar values to target file
    print OUTPUT ("$token_compat ");
    print OUTPUT ("$type_compat ");
    print OUTPUT ("$line\n");
    
# subroutine run_generation generates stress contour and returns 0 for nomatch, 1 for match
sub run_generation{
    my ($orig_struct_stress) = @_;
    
    # translate original stress pattern into 1 and 0 combination
    my $orig_stress = $orig_struct_stress;
    $orig_stress =~ tr/[A-Z]/1/;
    $orig_stress =~ tr/[a-z]/0/;
    
    #convert to all caps to make test sequence
    my $test_sequence = $orig_struct_stress;
    $test_sequence =~ tr/[a-z]/[A-Z]/;
    #print DEBUG ("debug: extracted orig_stress is $orig_stress\n\n");
    #print DEBUG ("debug:The test sequence before translate_encodings is $test_sequence \n\n");

  # translate encodings from Lpx style to VV VC V style
  $test_sequence = translate_encodings($test_sequence);
  print DEBUG ("The test sequence after translate_encodings is $test_sequence\n");

  # call subroutine to generate stress contour
  $stress_contour = gen_stress_contour($test_sequence, \%param_combo);

  # remove any extra spaces in the final stress contour and original stress contour
  $stress_contour =~ s/\s+//g;
  $orig_stress =~ s/\s+//g;

  # determine if is valid or not (doesn't contain any letters)
  $is_valid = true;
  if($stress_contour =~ /[a-z]/){$is_valid = false;}

  my $is_match; #variable to determine if match or no match
  if($stress_contour eq $orig_stress){
    $is_match = 1;
    print(DEBUG "debug: Final contour is $stress_contour; original contour is $orig_stress. These contours match\n\n");
  } else {
    $is_match = 0;
    print(DEBUG "debug: Final contour is $stress_contour; original contour is $orig_stress. These contours do not match\n\n");
  }
    return $is_match;
}

#translate to canonical versions of syllable types, as these are the differences that matter
sub translate_encodings { 
        my ($syllables) = @_;
        
        my $translated = $syllables;
        $translated =~ s/X/V /g;
        $translated =~ s/L/VV /g;
        $translated =~ s/A/VCC /g;
        $translated =~ s/P/VC /g;
        $translated =~ s/\s*$//; #remove whitespace
    
        return $translated;
    }
    
sub gen_stress_contour{
  my ($test_sequence, $param_combo_ref) = @_;

  $em = $param_combo_ref->{"em"};
  $quantity = $param_combo_ref->{"quantity"};
  $test_sequence = do_em_quantity ($test_sequence, $em, $quantity);
  
  # do foot directionality, foot inventory, local parsing, degenerate feet, and word layer end rule together in subroutine do_ftdir_filp
  $ftdir = $param_combo_ref->{"ftdir"};
  $ftinventory = $param_combo_ref->{"ftinventory"};
  $lp = $param_combo_ref->{"lp"};
  $df =  $param_combo_ref->{"df"}; 
  $wler = $param_combo_ref->{"wler"};
  $location = $param_combo_ref->{"location"};
  $test_sequence = do_ftdir_filp($test_sequence, $ftdir, $ftinventory, $lp, $df, $wler, $location);
  print(DEBUG "debug: after do_ftdir_filp: $test_sequence\n");

  # get rid of parens for stress contour comparison
  $stress_contour = $test_sequence;
  $stress_contour =~ s/[\)\(\[\]]//g;
  return $stress_contour;
}

# process test sequence using Extrametricality and Quantity Sensitivity parameter values
sub do_em_quantity{
  my ($test_sequence, $em, $quantity) = @_;
  chomp $test_sequence;
  
    # if extrametrical consonant right, remove C in word-final position
    if($em eq "1")  {
      $test_sequence =~ s/C$//;
      #print DEBUG("This language is Em-Consonant; after removal of word-final consonant test sequence is : $test_sequence\n");
  }

  # process quantity sensitivity after possible removal of word-final Consonant, as this may affect weight of final syllable 
  $test_sequence = do_quantity($test_sequence, $quantity);
  
  # determine length of string $test_sequence to avoid removing right or left syllable on monosyllabics
  my $wordLength = length($test_sequence);
  print( DEBUG "debug: after do_quantity where quantity is $quantity, test_sequence is $test_sequence\n");
  
    # do other em values and add brackets
    # if em-syl-left and not monosyllabic, replace first syllable with 0, add  [ and  ]
    if($em eq "2" && $wordLength !~ "1")
      {
      $test_sequence =~ s/^\w/0\[/;  
      $test_sequence =~ s/(\w)$/$1\]/;   # replace final character with itself and ]
     #print(DEBUG "debug: after em-syl-right, test_sequence is $test_sequence\n");
    }
    # if em-syl-right and not monosyllabic, replace last syllable with ]0 and add [ at beginning
    elsif ($em eq "3" && $wordLength !~ "1"){
    $test_sequence =~ s/\w$/\]0/;   
    $test_sequence =~ s/^(\w)/\[$1/;
  }
    # if em-final-cons or em-none or wordlength is 1, add brackets to signal edges of word
    elsif($em eq "1" || $em eq "4" || $wordLength =~ "1"){
    $test_sequence =~ s/^(\w)/\[$1/;
    $test_sequence =~ s/(\w)$/$1\]/;
  }
 
    else { die("Unrecognized extrametricality parameter: $em\n");}
  
  print(DEBUG "debug: after do_em_quantity where em is $em, test sequence is $test_sequence\n");
  return $test_sequence;
}

# determine VC-H versus VC-L and convert syllables accordingly
sub do_quantity{
 my ($test_sequence, $quantity) = @_;

 # create array to hold syllables and convert based on $quantity value
 my @syllables = split(/\s+/, $test_sequence); 
 my @converted = ();
 foreach my $syllable (@syllables) {
     # if this is a VC-Heavy language, convert V to l and all others (VVC*,VC+) to h
     if ($quantity eq "2") { 
	     if ($syllable eq "V") { 
	             $syllable = 'l';  	        
         	   }
	     else { $syllable = 'h'; }
        }
       # if this is a VC-Light language, convert VVC* to h, convert VC* to l, 
       elsif ($quantity eq "3") {
           if ($syllable =~ '^VV') {
	             $syllable = 'h';
		   } else { $syllable = 'l';}
       }
       else { die("Unrecognized quantity parameter: $em\n");}
       push(@converted, $syllable);
	   }
  $test_sequence = join('', @converted);
 return $test_sequence;
}

# reverse sequence if ft-dir-right; call functions filp and df_wler
sub do_ftdir_filp{
  my($test_sequence, $ftdir, $ftinventory, $lp, $df, $wler, $location) = @_;
  # if ft-dir-left, perform substitutions on test_sequence as is
    if($ftdir eq "1"){
      if($location eq "1"){
         $test_sequence = filp($test_sequence, $ftinventory, $lp, $ftdir);
         # print(DEBUG "debug: after filp  before df_wler on ftdir left to right, test sequence is $test_sequence\n");
      }
       elsif($location eq "2"){
         $test_sequence = topdown_filp($test_sequence, $ftinventory, $lp, $ftdir, $wler, $df);
         # print(DEBUG "debug: after topdownfilp  before df_wler on ftdir left to right, test sequence is $test_sequence\n");
      }
    $test_sequence = df_wler($test_sequence, $ftdir, $df, $wler);
    }
    
  # if ft-dir-right, reverse sequence, apply substitutions, then un-reverse
  elsif($ftdir eq "2") {
    $reversed_sequence = join('',reverse(split(//,$test_sequence)));
    # replace brackets with their inverse
    $reversed_sequence =~ tr/\[\]/\]\[/;
    
      if($location eq "1"){ #bottomup for reversed
          $reversed_sequence = filp($reversed_sequence, $ftinventory, $lp, $ftdir);
          print(DEBUG "debug: after filp  before df_wler on ftdir right to left reveresed sequence is: $reversed_sequence\n");
      } elsif($location eq "2"){ #topdown for reversed
          $reversed_sequence = topdown_filp($test_sequence, $ftinventory, $lp, $ftdir, $wler, $df);
          print(DEBUG "debug: after topdownfilp  before df_wler on ftdir right to left, test sequence is $test_sequence\n");
      }
    
    $reversed_sequence = df_wler($reversed_sequence, $ftdir, $df, $wler, $location);
    print(DEBUG "debug: after df_wler with ftdir right to left, reversed sequence is $reversed_sequence\n");
    # un-reverse
    $test_sequence = join('', reverse(split(//,$reversed_sequence)));
    print(DEBUG "debug: test_sequence after unreverse is $test_sequence\n");
    # replace brackets with their inverse
    $test_sequence =~ tr/\[\]/\]\[/;
    # replace parens with their inverse
    $test_sequence =~ tr/\(\)/\)\(/;
      print(DEBUG "debug: after replacing feet parens and brackets appropriately: $test_sequence\n");
  } else {die("Unrecognized foot directionality parameter value: $ftdir\n");}
    return $test_sequence;
}
    
# Create feet and assign stress from TOP DOWN, starting with word layer.
sub topdown_filp{  
        my($test_sequence, $ftinventory, $lp, $ftdir, $wler, $df) = @_; 
        $test_sequence =~  s/\s+//g;
        print (DEBUG "debug: sequence entering topdown filp is $test_sequence\n");
        print (DEBUG "debug: ftdir is $ftdir and wler is $wler \n");
        
        my @charArray = split(//, $test_sequence);
        my $i = 0;
        for ($i = 0; @charArray[$i] ne '['; $i++) {
        }
        
        # cases where wler is on what is the LAST syllable in this possibly-reversed sequence. 
        if ($ftdir ne $wler) {
            $test_sequence_parsed = filp($test_sequence, $ftinventory, $lp, $ftdir);
            $parsed_sequence = $test_sequence_parsed;
            $parsed_sequence =~ s/.*\[//;
            $parsed_sequence =~ s/\].*//;
            $parsed_sequence =~ s/\(//g;
            $parsed_sequence =~ s/\)//g;
            print (DEBUG "debug: sequence after filp before topdown modification in ftdir ne wler: $parsed_sequence\n");
            @parsedArray = split(//, $parsed_sequence);
            $lastStress = @parsedArray[$#parsed_sequence];
            if ($lastStress eq '1') {
                print (DEBUG "debug: no changes made in topdown filp after regular filp because laststress $lastStress is 1\n");
                return $test_sequence_parsed;
            } else {
                $lastSyllableIndex = index($test_sequence, ']')-1;
                $lastSyllable = @charArray[$lastSyllableIndex];
                if ($lastSyllable eq 'h' || ($lastSyllable eq 'l' && $df eq '2')) {
                    @charArray[$lastSyllableIndex] = 1;
                    splice @charArray, $lastSyllableIndex+1, 0, ')';
                    splice @charArray, $lastSyllableIndex, 0, '(';
                    $test_sequence = join('', @charArray);
                }
                elsif($lastSyllable eq 'l' && $df eq '1') {
                    return '0000000000';
                }
                return filp($test_sequence, $ftinventory, $lp, $ftdir);
            }
        } elsif ($ftdir eq $wler) {
            my @charArray = split(//, $test_sequence);
            
            if (@charArray[$i+1] eq "h") {
                if ($ftdir eq "2" && $ftinventory eq "3") {
                    @charArray[$i+1] = 1;
                    splice @charArray, $i+2, 0,')';
                    splice @charArray, $i+1, 0, '(';
                }
                $test_sequence = join('',@charArray); #Put array back in string and print
                return filp($test_sequence, $ftinventory, $lp, $ftdir);
            } elsif (@charArray[$i+1] eq "l") {
                if (@charArray[$i+2] eq "l") {
                    if (($ftdir eq "2" && $ftinventory eq "2") || ($ftdir eq "1" && $ftinventory eq "1")) {
                        return filp($test_sequence, $ftinventory, $lp, $ftdir);
                    }
                }
                if ($ftdir eq "1" && $ftinventory eq "3") {
                    return filp($test_sequence, $ftinventory, $lp, $ftdir);
                }
                elsif (@charArray[$i+2] eq "h") {
                    if ($ftinventory eq "1" || ($ftdir eq "2" && $ftinventory eq "2")) {
                        if ($df eq "2") {
                            @charArray[$i+1] = 1;
                            splice @charArray, $i+2, 0,')';
                            splice @charArray, $i+1, 0, '(';
                            $test_sequence = join('',@charArray); #Put array back in string and print
                            return filp($test_sequence, $ftinventory, $lp, $ftdir);
                        } else {
                            return '0000000000';
                        }
                    }
                }
                if ($df eq "1") {
                    return '0000000000';
                }
                @charArray[$i+1] = 1;
                splice @charArray, $i+2, 0,')';
                splice @charArray, $i+1, 0, '(';
                $test_sequence = join('',@charArray); #Put array back in string and print
                return filp($test_sequence, $ftinventory, $lp, $ftdir);
            }
        }
    }
    
    # Create feet and assign stress BOTTOM UP, starting with foot parse.
    sub filp {
        
        my($test_sequence, $ftinventory, $lp, $ftdir) = @_;
        $test_sequence =~  s/\s+//g;
        my @charArray = split(//,$test_sequence); # Creates array from string
        
        my $lastChar; # Creates local variable to hold index value at current location for Weak Local Parsing setting. Weak local parsing requires that one consecutive light syllable be skipped after completing a foot parse
        
        for (my $i = 0; $i < ($#charArray+1); $i++) {
            if ($ftdir eq "1") {
                if ($ftinventory eq "1") {
                    if (@charArray[$i] eq "h") { # If heavy syllable, change to (1)
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0,')';
                        splice @charArray, $i, 0, '(';
                    }
                    # Weak Local Parsing case with l directly after foot but not at end of parse, l becomes "0"
                    elsif ($lp eq "2" && $lastChar eq ")" && @charArray[$i] eq "l" && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    }
                    # Strong Local Parsing case or Weak Local Parsing with "l" not directly after foot, change ll to (10)
                    elsif (@charArray[$i] eq 'l' && @charArray[$i+1] eq 'l') {
                        @charArray[$i] = 1;
                        @charArray[$i+1] = 0;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq 'l') { # If l and situation other than above, that is lh or l], change to u "unfooted". Could be allowable degenerate foot if Weak Prohibition of DF, which will be determined in later subroutine.
                        @charArray[$i] = 'u';
                    }
                } elsif ($ftinventory eq "2") { #Iamb
                    if (@charArray[$i] eq "h") { # If h, create foot (1)
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0, ')';
                        splice @charArray, $i, 0, '(';
                    }
                    # Weak Local Parsing case with l directly after foot but not at end of parse, l becomes "0"
                    elsif (($lp eq "2") && ($lastChar eq ")") && (@charArray[$i] eq "l") && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    }
                    #Strong Local Parsing case or Weak Local Parsing with "l" not directly after foot, change ll to (01)
                    elsif ((@charArray[$i] eq "l") && (@charArray[$i+1] eq "l")) {
                        @charArray[$i] = 0;
                        @charArray[$i+1] = 1;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    }
                    #Strong Local Parsing case or Weak Local Parsing with "l" not directly after foot, change lh to (01)
                    elsif (@charArray[$i] eq "l" &&  @charArray[$i+1] eq "h") {
                        @charArray[$i] = 0;
                        @charArray[$i+1] = 1;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq "l") { # If l and situation other than above, that is l], change to u "unfooted". Could be allowable degenerate foot if Weak Prohibition of DF, which will be determined in later subroutine)
                        @charArray[$i] = 'u';
                    }
                } elsif ($ftinventory eq "3") {  #Syllabic Trochee
                    # Weak Local Parsing case with l directly after foot but not at end of parse, l becomes "0"
                    if ($lp eq "2" && $lastChar eq "\)" && @charArray[$i] eq "l" && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    # If hl or lh or ll or hh, change to (10)
                    } elsif ((@charArray[$i] eq "h" || @charArray[$i] eq "l") && $i <$#charArray-1 && (@charArray[$i+1] eq "h" || @charArray[$i+1] eq "l"))  {
                        @charArray[$i] = 1;
                        @charArray[$i+1] = 0;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    # If odd number of syllables with leftover h in end-of-parse position, change to (1)
                    } elsif (@charArray[$i] eq "h" && (@charArray[$i+1] eq "\]" || @charArray[$i+1] eq "\(")) {
                        print (DEBUG "debug: at beginning of endofparse h case for syllabic trochees, current character is @charArray[$i] and next character is @charArray[$i+1] \n");
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0, ')';
                        splice @charArray, $i, 0, '(';
                        print (DEBUG "debug: at end of filp for syllabic trochees, special case h endofparse current character is @charArray[$i] and next character is @charArray[$i+1] \n");
                    }
                    # If odd number of syllables with leftover l in end-of-parse position, change to u unfooted
                    elsif (@charArray[$i] eq 'l') {
                        @charArray[$i] = 'u';
                    }
                } else {
                    die("Unrecognized foot inventory parameter: $ftinventory.\n");
                }
            } elsif ($ftdir eq '2') { 
                if ($ftinventory eq "1") { # moraic trochee with reversed string
                    if (@charArray[$i] eq "h") { 
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0,')';
                        splice @charArray, $i, 0, '(';
                    } # Weak Local Parsing case with l directly after foot but not at end of parse, l becomes "0"
                    elsif ($lp eq "2" && $lastChar eq ")" && @charArray[$i] eq "l" && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    } #Strong Local Parsing case or Weak Local Parsing with "l" not directly after foot, change ll to (10)
                    elsif (@charArray[$i] eq 'l' && @charArray[$i+1] eq 'l') {
                        @charArray[$i] = 0; 
                        @charArray[$i+1] = 1;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq 'l') { # If l and situation other than above, that is lh or l], change to u "unfooted". Could be allowable degenerate foot if Weak Prohibition of DF, which will be determined in later subroutine
                        @charArray[$i] = 'u';
                    }
                } elsif ($ftinventory eq "2") { #iamb with reversed string
                    if (@charArray[$i] eq "h" && @charArray[$i+1] eq "l") {
                        @charArray[$i] = 1;
                        @charArray[$i+1] = 0;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq "h") {
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (($lp eq "2") && ($lastChar eq ")") && (@charArray[$i] eq "l") && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    } elsif ((@charArray[$i] eq "l") && (@charArray[$i+1] eq "l")) {
                        @charArray[$i] = 1;
                        @charArray[$i+1] = 0;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq "l") {
                        @charArray[$i] = 'u';
                    }
                } elsif ($ftinventory eq "3") { #syllabic trochee with reversed string
                    if ($lp eq "2" && $lastChar eq "\)" && @charArray[$i] eq "l" && @charArray[$i+1] ne "\]") {
                        @charArray[$i] = 0;
                    } elsif ((@charArray[$i] eq 'h' || @charArray[$i] eq 'l') && $i <$#charArray-1 && (@charArray[$i+1] eq 'h' || @charArray[$i+1] eq 'l'))  {
                        @charArray[$i] = 0;
                        @charArray[$i+1] = 1;
                        splice @charArray, $i+2, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq 'h' && @charArray[$i+1] eq ']') {
                        @charArray[$i] = 1;
                        splice @charArray, $i+1, 0, ')';
                        splice @charArray, $i, 0, '(';
                    } elsif (@charArray[$i] eq 'l') {
                        @charArray[$i] = 'u';
                    }
                } else {
                    die("Unrecognized foot inventory parameter: $ftinventory.\n");
                }
            } else {
                die("Unrecognized foot directionality parameter: $ftdir.\n");
            }
            
            
            $lastChar = @charArray[$i];
        }
        $test_sequence = join('',@charArray); #Put array back in string and print
        print DEBUG ("after filp process with fi = $ftinventory (1=MT,2=I,3=ST) and lp = $lp (1=S, 2=W): $test_sequence\n");
        return $test_sequence;
    }
    
    # Determine if degenerate feet are allowed and stress them if appropriate
    sub df_wler {
        my($test_sequence, $ftdir, $df, $wler) = @_;
        #print (DEBUG "debug: at beginning of dfwler, test sequence is $test_sequence\n");
        if ($df eq "2") { # if weak prohibition, change u to 1 at end of parse with wler on same side as end of parse
            if (($ftdir eq "1" && $wler eq "2") || ($ftdir eq "2" && $wler eq "1")) {
                $test_sequence =~ s/u\]/1\]/;
            }
            $test_sequence =~ s/\[u\]/\[1\]/;
            #print(DEBUG "debug: after weak df with same side wler - unfooted have been preserved as 1s if appropriate: $test_sequence\n");
        }
        print (DEBUG "debug: at end of dfwler, before replacing remaining us with 0s, test sequence is $test_sequence\n");
        $test_sequence =~ s/u/0/g;  #replace all remaining u with 0
        print (DEBUG "debug: at end of dfwler, after replacing remaining us with 0s, test sequence is $test_sequence\n");
        return $test_sequence;
    }
$grammars++;
} #end of while loop

print "Total number of grammars  checked was $grammars\n\n";

close(DEBUG);
close(OUTPUT);

sub process_options{
    use Getopt::Long;
  &GetOptions("inputfile=s", #grammar file and data file are required
	               "debugfile:s"); #debugfile is optional (default = stress_contours.debug) 
}
