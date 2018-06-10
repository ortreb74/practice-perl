#!/usr/bin/env perl

use strict;
use warnings;

# /c/bb/vernimmen/sie-inneo-vernimmem
# to be transformed into
# add to lance.cd c:/bb/preparation-bu/sie-efl-lance.cd/pom.xml

# OS command
my $command_line = "find /c/bb -type d -name sie-*";
my @set = `$command_line`;

foreach my $line(@set) {
	chomp $line;
	$line =~ m/\/c(.*-)(.*)/;
	print "add to $2 c:$1$2/pom.xml\n";
}