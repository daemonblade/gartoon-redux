#!/bin/sh
#
# make-tarball.sh
# (C) 2008-2009 Krzysztof Kosiński
# Released under GNU GPL v2 or later; see the file COPYING for details
#
# Creates a tarball of this directory, appending the argument after a dash

TARBALL_VERSION=$1
SOURCE_PATH=$(pwd)

cd ..
SOURCE_DIR=$(basename $SOURCE_PATH)
TARBALL_DIR="$SOURCE_DIR-$TARBALL_VERSION"

if test -x $TARBALL_DIR; then
	echo "Error: directory $TARBALL_DIR already exists"
	exit 1
fi
if test -x "$TARBALL_DIR.tar.gz"; then
	echo "Error: file $TARBALL_DIR.tar.gz already exists"
	exit 1
fi

ln -s $SOURCE_DIR $TARBALL_DIR
tar -chzf "$TARBALL_DIR.tar.gz" $TARBALL_DIR --exclude-from="$TARBALL_DIR/.bzrignore" --exclude="$TARBALL_DIR/.bzrignore" --exclude="$TARBALL_DIR/.bzr"
rm $TARBALL_DIR
