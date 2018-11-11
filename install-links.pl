#!/usr/bin/perl -w
#
# install-links.pl
# (C) 2008-2009 Krzysztof Kosiński
# Released under GNU GPL v2 or later; see the file COPYING for details
#
# This script is used to create symbolic links for the theme, based on link
# description files. It does this directly in the install directory.

use Cwd;

$aliasfile = 'src/0ALIAS';
$icondir = 'prefix/share/icons/GartoonRedux';
foreach (@ARGV) {
	if (/^--alias-file=(.*)$/) { $aliasfile = $1; }
	elsif (/^--icondir=(.*)$/) { $icondir = $1; }
	else { push (@render_sizes, $_); }
}
push (@render_sizes, 'scalable');

open(ALIAS, $aliasfile);
@aliases = <ALIAS>;
close(ALIAS);

# fix relative icondir
if ($icondir !~ m@^/@) { $icondir = &Cwd::cwd() . "/$icondir"; }

my $links = 0;
my $created = 0;
my $alias_dir = ''; my $linkdir = '';

foreach (@render_sizes) {
	$iconsubdir = $_;
	if(!($_ eq 'scalable')) { $iconsubdir = "${_}x${_}"; }
	$linkdir = "$icondir/$iconsubdir";
	$curlinkdir = $linkdir;
	foreach (@aliases) {
		chomp; # remove record separator - newline
		
		# When encountering a comment beginning with at least 3 hashes and
		# containing phrase: folder "some_folder", change the directory into
		# which links go to some_folder
		if (/^#{3,}.*folder "([^"]+)".*$/) {
			$curlinkdir = "$linkdir/$1";
			next;
		}
		
		# skip blank lines and comments
		s/#.*$//;
		next if (/^[ \t]*$/);
		
		# parse an alias definition
		m/^(\S+)(\.[^.\s]+)\s+(\S+)(\.[^.\s]+)$/;
		($target, $ext, $name) = ($1, $2, $3);
		
		# What should the extension be in the current directory?
		# If the directory name contains "scalable", it should be SVG.
		# In other cases, PNG. For non-SVG files keep the extension.
		if ($ext eq '.svg') {
			if(!($iconsubdir eq 'scalable')) {
				$ext = '.png';
			}
		}
		
		$target .= $ext;
		$name = "$curlinkdir/${name}${ext}";
		
		# print $target, "   ", $name, "\n";
		++$links;
		if( symlink ($target, $name) ) {
			++$created;
		} else {
			print $target, ' -> ', $name, "\n";
		}
	}
	close (ALIAS);
}

if ($links > $created) {
	print $links - $created, " of $links links skipped.\n";
}
$links = 0; $created = 0;

# create gnome-mime links
@gnome = `find $icondir -mindepth 1 -maxdepth 1 -type d`;
foreach (@gnome) {
	chomp;
	chdir "$_/mimetypes";
	@files = <*>;
	foreach $file (@files) {
		# do not create gnome-mime links if the filename doesn't contain
		# a hyphen or begins with "gnome"
		next if $file !~ m/-/;
		next if $file =~ m/^gnome/;
		++$links;
		if (symlink("../mimetypes/$file", "../gnome-mime/gnome-mime-$file")) {
			++$created;
		}
	}
	chdir $icondir;
}

if ($links > $created) {
	print $links - $created, " of $links gnome-mime links skipped.\n"
}
