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
	if ($line =~ m/^[d-]rw.(.)(.).{5}\s*\w\s(\S*)\b\s*(\w*)\b.*\s(.*)$/) {		
		my $systemFileMeta = SystemFileMeta->new($directory,$line); # syntaxe du new		
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

# création d'un structure intermédiaire
my %hdt;

foreach my $systemFileMeta(@otherGroup) {
	my $user = $systemFileMeta->get("user");
	if (!exists $hdt{$user}) {
		$hdt{$user} = [];
	}
	
	push @{$hdt{$user}}, $systemFileMeta->get("name");
}

foreach my $user (keys(%hdt)) {		
	my $outputFileName = "/u/ext-pdonzel/bin/var/osu-" . $user . ".sh";
	open (my $outputFile, '>', $outputFileName) or die "Could not open file $outputFileName"; # ouvrir un fichier
	print $outputFile "#!/bin/bash\n";	
	my @tableau = @{$hdt{$user}};
	foreach my $filename(@tableau) {
		print $outputFile "chgrp wheel $filename ; chmod g+w $filename\n"; # écrire dans un fichier
	}
	close ($outputFile); # fermer un fichier
	system ("chmod 755 $outputFileName");
	print "Fichier à lancer : $outputFileName\n";
}

# création d'un structure intermédiaire
%hdt = (); # clear my hash but i guess it's gonna memory leak

foreach my $systemFileMeta(@groupNoWrite) {
	my $user = $systemFileMeta->get("user");
	if (!exists $hdt{$user}) {
		$hdt{$user} = [];
	}
	
	push @{$hdt{$user}}, $systemFileMeta->get("name");
}

foreach my $user (keys(%hdt)) {		
	my $outputFileName = "/u/ext-pdonzel/bin/var/su-" . $user . ".sh";
	open (my $outputFile, '>', $outputFileName) or die "Could not open file $outputFileName"; # ouvrir un fichier
	print $outputFile "#!/bin/bash\n";	
	my @tableau = @{$hdt{$user}};
	foreach my $filename(@tableau) {
		print $outputFile "chmod g+w $filename\n"; # écrire dans un fichier
	}
	close ($outputFile); # fermer un fichier
	system ("chmod 755 $outputFileName");
	print "Fichier à lancer : $outputFileName\n";
}




