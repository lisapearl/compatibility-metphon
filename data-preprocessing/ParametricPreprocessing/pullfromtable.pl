 #!/usr/bin/perl

# This code takes needed columns from a CSV data table that holds child directed speech word with their syllabification and other features, then copies the needed columns to data.txt, which will be used by the compatibility code.

 use strict;
 use warnings;
 use Text::CSV;

 open (MYFILE, '>data.txt');   #opens output file

# knowledge settings

    my @ColsIndex = ();  # create array to hold index values for needed columns

    # print out questions and set variables to hold answers. Place number matching needed columns in an array.
   
    # The 1st column will always be syllabification, either with inflectional morphology REMOVED (copy column 9) or INTACT (copy column 6)
    print "Does the child have knowledge of inflectional morphology? [y/n]?\n";
    my $morph = <>;
    chomp($morph);
    if ($morph eq "y") { 
        # print MYFILE "Form(root only) ";  # print heading for this column
           $ColsIndex[0] = 11;}    # if child has morphology knowledge, we need the syllabification column with inflectional morphology REMOVED
    elsif ($morph eq "n") { 
        # print MYFILE "Form\t  "; # print heading for this column
           $ColsIndex[0] = 7;}   # if child has NO morphology knowledge, we need the syllabification column with inflectional morphology INTACT
    elsif ($morph ne "y" && $morph ne "n")  {die "Invalid input\n";}
 
    # The 2nd needed column will always be stress pattern, 8th column in the CSV file

# print MYFILE "Stress\t"; # print heading for this column
    $ColsIndex[1] = 9;

    print "Does the child have knowledge of grammatical categories? [y/n]?\n";
    my $gramcat = <>;
    chomp($gramcat);

    if ($gramcat eq "y") { 
        # print MYFILE "Category\t";
         push(@ColsIndex, 12); }    # if child has grammatical category knowledge, we need the grammatical category column
    elsif ($gramcat ne "y" && $gramcat ne "n")  {die "Invalid input\n";}

    print "Does the child have knowledge of compound words? [y/n]?\n";
    my $compound = <>;
    chomp ($compound);

    if ($compound eq "y") {  
        # print MYFILE "Compound";
            push(@ColsIndex, 17); }    # if child has compound word knowledge, we need the compound word column
    elsif ($compound ne "y" && $compound ne "n")  {die "Invalid input\n";}

    # The last needed column will always be frequency, 17th column in the CSV file

# print MYFILE "Frequency\t"; # print heading for this column
    push(@ColsIndex, 16);

    my $numNeededCols = scalar(@ColsIndex);    # creates the variable that holds the number of columns that are indexed (to be printed to output)

#read input from CSV file and output needed columns to data.txt 

 my $file = 'dataTablefull.csv';    # sets input file to the csv file
 my $csv = Text::CSV->new ( { binary    => 1 } )  
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

 open (my $data, "<:encoding(utf8)", $file) or die $!;
      while (my $row = $csv->getline ($data)) {
             my @columns = $csv->fields();   

  # make any final edits to columns array before output
             if ($morph eq "y" && $columns[10] eq "0") { $columns[11] = $columns[7];} # If inflectional syllabification is 0 (no inflection), copy standard syllabification
             print MYFILE "\n";     # print new line before each output row
  # iterate through needed columns and print to data.txt
          if(!($row =~ /^Word,/)){   # skip heading row
             for (my $i = 0; $i < $numNeededCols; $i++) {             
                 print MYFILE "$columns[$ColsIndex[$i]]";
                       if ($i ne ($numNeededCols-1)) {
                             print MYFILE ",\t";
                        }
              }      
           }
       }
    close $data;
  
    close (MYFILE);







