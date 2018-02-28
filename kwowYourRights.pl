#!/usr/bin/env perl

use strict;
use warnings;

my $repertoire = @ARGV == 0 ? "." : $ARGV[0];
my @set = `ls -lR $repertoire`;

foreach my $line(@set) {
	chomp $line;
	
	# drwxr-xr-x 1 drncl 197612   0 Feb  5 10:40 efl-deploy-linux/
	# que signifie le deuxième mot
	if ($line =~ m/^[d-]rw.(.)(.).{4}\s\w\s(\w*)\b\s(\w*)\b.*\s\b(.*)$/) {
		my $flag_readg = $1;
		my $flag_writeg = $2;
		my $user = $3;
		my $file_group = $4;
		my $file_name = $5;
	}
}
