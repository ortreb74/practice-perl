#!/usr/bin/env perl
use strict; 
use warnings; 

# l'environnement vide est la production
my @env = ("int", "recette", "chaine", "prodbackup", "test", "");

for my $word (@env) {
	# la difficulté c'est que j'espère qu'implicitement cela va changer l'environnement pointé
	$word = "/e8/webbu" . $word;
}

push @env, "/u/progs/webbudev";

for my $word (@env) {
	# la difficulté c'est que j'espère qu'implicitement cela va changer l'environnement pointé
	$word = $word . "/uaur/stl";
}

my $command = "ls -ld " . join(" ", @env);

print "$command\n";

# cela c'est pour dump mais je pense que je n'ai plus besoin de dump

# for my $word (@env) {
#	print "$word\n";
# }

# my $basic = "ls -l /e8/webbu