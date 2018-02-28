#!/usr/bin/env perl

use strict;
use warnings;

use lib "lib";
use SystemFileMeta;

# command line
my $repertoire = @ARGV == 0 ? "." : $ARGV[0];

# OS command
my @set = `ls -lR $repertoire`;

# OS to object
my $directory = "";
my @allFiles;

foreach my $line(@set) {
	chomp $line;
	
	# drwxr-xr-x 1 drncl 197612   0 Feb  5 10:40 efl-deploy-linux/
	# que signifie le deuxième mot
	if ($line =~ m/^[d-]rw.(.)(.).{4}\s\w\s(\w*)\b\s(\w*)\b.*\s\b(.*)$/) {
		my $systemFileMeta = SystemFileMeta->new($directory); # syntaxe du new
		
		push @allFiles, $systemFileMeta;
	}
	
	if ($line =~ m/(.*):$/) {
		$directory = $1;
	}
	
}

my $systemFileMeta = pop @allFiles;

$systemFileMeta->display();


# liste des fichiers non modifiables par un utilisateur donné du groupe des developpeurs ("wheel")

## soit le groupe n'est pas wheel
## soit le groupe n'a pas le droit en écriture

my $user = "ext-pdonzel";

my @otherUser;
my @groupNoWrite;




