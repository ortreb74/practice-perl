#!/usr/bin/env perl

$repertoire = $ARGV[0];

@result = `ls -F $repertoire`;

# open() est une alternative

foreach $file (@result) {
 chomp $file;

 if ($file =~ m/(.*)\*$/) {
	$file = $1;
 } 
 
 if ($file =~ m/(.*)\/$/) {
	$basename = $1;
	$extension = "subDirectory";
 } else { 
  if ($file =~ m/(.*)\.(.*)/) { 
	$basename = $1;
	$extension = $2;
  } else { 
	$basename = $file;	
	$extension = "";
  } 
 }
 
 $h{$extension}++;
}

foreach my $k (keys(%h)) {
   printf "%-30s : %s\n", $k, $h{$k};
}