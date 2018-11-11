#!/usr/bin/perl -w
#
# fix-logo.pl
# (C) 2008-2009 Krzysztof Kosiński
# Released under GNU GPL v2 or later; see the file COPYING for details
#
# Fix the distributor logo based on the output of lsb_release.

use Switch;

$icondir = '/usr/share/icons/GartoonRedux';
%distro_hash = (
	'ubuntu' => '../extras/distribution-ubuntu',
	'edubuntu' => '../extras/distribution-edubuntu',
	'xubuntu' => '../extras/distribution-xubuntu',
	'fedora' => '../extras/distribution-fedora',
	'arch linux' => '../extras/distribution-arch-linux',
	'gentoo' => '../extras/distribution-gentoo'
);

foreach (@ARGV) {
	if (/^--icondir=(.*)$/) { $icondir = $1; }
}

$distribution = `lsb_release -si`;
chomp $distribution;
$dist = lc($distribution);

if ($dist eq 'ubuntu') {
	if (check_deb_package('xubuntu-desktop')) {
		$dist = 'xubuntu';
	}
	elsif (check_deb_package('edubuntu-desktop')) {
		$dist = 'edubuntu';
	}
}

$logo = $distro_hash{$dist};
if (!$logo) { exit 0; }

# Fix the scalable logo
$target_scalable = "$icondir/scalable/places/distributor-logo.svg";
unlink ($target_scalable);
symlink ("$logo.svg", $target_scalable);
#print "$logo.svg -> $target_scalable\n";

# Fix the rendered logos
@sizes = `find $icondir -mindepth 1 -maxdepth 1 -type d -printf '%P\n'`;
foreach (@sizes) {
	next if m/^scalable$/;
	chomp;
	$target = "$icondir/${_}/places/distributor-logo.png";
	unlink ($target);
	symlink ("$logo.png", $target);
	#print "$logo.png -> $target\n";
}

sub check_deb_package {
	$name = shift;
	$status = `dpkg-query -Wf '\${Status}' $name 2>/dev/null`;
	if ($status =~ m/^install\b/) { return 1; }
	else { return 0; }
}
