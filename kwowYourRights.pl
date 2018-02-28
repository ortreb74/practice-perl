#!/usr/bin/env perl

use strict;
use warnings;

# https://stackoverflow.com/questions/787899/how-do-i-use-a-perl-module-from-a-relative-location
use FindBin; # pour utiliser une bibliothèque
use lib "$FindBin::Bin/lib"; # pour utiliser une bibliothèque

use SystemFileMeta;

# command line
my $repertoire = @ARGV == 0 ? "." : $ARGV[0];

# OS command
my $command_line = "ls -lR $repertoire";
print "command_line " . $command_line . "\n";
my @set = `$command_line`;

print "$#set lignes lues" . "\n"; # taille d'une list

# OS to object

my $directory = "";
my @allFiles;

foreach my $line(@set) {
	chomp $line;
	
	# drwxr-xr-x 1 drncl 197612   0 Feb  5 10:40 efl-deploy-linux/
	# drwxr-xr-x.   7 ext-pdonzel wheel     4096  3 nov.   2016 xsl/
	# -rw-rw-rw-. 1 progs       wheel      99318 27 fÃ©vr. 13:42 z6m39optj.sgm
	# que signifie le deuxième mot
	if ($line =~ m/^[d-]rw.(.)(.).{5}\s*\w\s*(\S*)\b\s*(\w*)\b.*\s*\b(.*)$/) {
		my $systemFileMeta = SystemFileMeta->new($directory); # syntaxe du new		
		push @allFiles, $systemFileMeta; # ajout à une liste
		next;
	}
	
	if ($line =~ m/(.*):$/) {
		$directory = $1;
		next;		
	}
	
	print "$line\n";
	
}

print "$#allFiles lignes interprétées comme des fichiers" . "\n";

# my $systemFileMeta = pop @allFiles;
# $systemFileMeta->display();

# liste des fichiers non modifiables par un utilisateur donné du groupe des developpeurs ("wheel")

## soit le groupe n'est pas wheel
## soit le groupe n'a pas le droit en écriture

my @otherGroup;
my @groupNoWrite;

foreach my $systemFileMeta(@allFiles) {
	# my $user = $systemFileMeta->get("user"); # la syntaxe imbriquée ne marche pas
	# if (! grep( /^$user$/, @users))  { # exists dans une liste 		
	my $group = $systemFileMeta->get("group");
	if ($group ne "wheel") {
		push @otherGroup, $systemFileMeta;
		next;
	}	
	
	if ($systemFileMeta->get("flag_readg") eq "-" || $systemFileMeta->get("flag_writeg") eq "-") {
		push @groupNoWrite, $systemFileMeta;
	}
}

if ($#otherGroup != -1) {
	print "$#otherGroup fichiers qui n'appartiennent pas au groupe wheel\n";
	foreach my $systemFileMeta(@otherGroup) {
		print $systemFileMeta->get('name') . "\n";
	}
}

if ($#groupNoWrite != -1) {
	print "\n";
	print "$#groupNoWrite fichiers sur lesquels le groupe wheel n'a pas tous les droits\n";
	$command_line = "find $repertoire -exec chmod  g+w {} \\;";
	print "changement des droits sur le répertoire : $command_line\n";
	system($command_line);

}


