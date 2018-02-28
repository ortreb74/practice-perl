#!/usr/bin/env perl

use strict;
use warnings;

my $repertoire = @ARGV == 0 ? "." : $ARGV[0];
my @set = `ls -lR $repertoire`;

my %properties;

foreach my $line(@set) {
	chomp $line;
	
	# drwxr-xr-x 1 drncl 197612   0 Feb  5 10:40 efl-deploy-linux/
	# que signifie le deuxième mot
	if ($line =~ m/^[d-]rw.(.)(.).{4}\s\w\s(\w*)\b\s(\w*)\b.*\s\b(.*)$/) {
		$properties{"flag_readg"} = $1;
		$properties{"flag_writeg"} = $2;
		$properties{"user"} = $3;
		$properties{"file_group"} = $4;
		$properties{"file_name"} = $5;
	}
}

foreach my $key (keys(%properties)) {
   printf "%-30s : %s\n", $key, $properties{$key};
}
