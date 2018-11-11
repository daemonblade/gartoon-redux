#!/usr/bin/perl
#
# make-index.pl
# (C) 2008-2009 Krzysztof Kosiński
# Released under GNU GPL v2 or later; see the file COPYING for details
#
# This script is used to generate the theme index file (index.theme).
# It searches for files containing the directory context in the source dir,
# then creates and index file with bitmap dirs for sizes given as arguments
# on the command line.

$builddir = 'build';

foreach (@ARGV) {
	if (/^--builddir=(.*)$/) { $builddir = $1; }
	else { push (@render_sizes, $_); }
}

my @context_files = `find src -name 0CONTEXT`;

foreach my $file (@context_files) {
	chomp($file);
	open (FILE, $file);
	$context = <FILE>;
	close FILE;
	chomp($context);
	$file =~ m@^src/(.+)/0CONTEXT$@;
	$context_hash_small{$1} = $context;
}

while (($dir,$context) = each (%context_hash_small)) {
	foreach (@render_sizes) { $context_hash{"${_}x${_}/$dir"} = $context; }
	$context_hash{"scalable/$dir"} = $context;
}
@dirs = sort keys %context_hash;

open (INDEX, ">$builddir/index.theme");
print INDEX
	"[Icon Theme]\n",
	"Name=Gartoon Redux\n",
	"Comment=Cartoon-style vector theme\n",
	"Example=audacity\n",
	"Inherits=gnome,Human,oxygen,crystalsvg\n",
	"Directories=";

print INDEX join(',', @dirs), "\n\n";

foreach (@dirs) {
	if (/scalable/) {
		print INDEX
			"[$_]\n",
			"Type=Scalable\n",
			"Size=90\n",
			"MinSize=1\n",
			"MaxSize=256\n",
			"Context=$context_hash{$_}\n\n";
	} else {
		m/(([0-9]{1,3})x\2)/;
		print INDEX
			"[$_]\n",
			"Type=Fixed\n",
			"Size=$2\n",
			"Threshold=0\n",
			"Context=$context_hash{$_}\n\n";
	}
}
