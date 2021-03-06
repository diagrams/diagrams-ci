#!/bin/bash

VERSION=$1
TMPDIR=docs-$VERSION-tmp

rm -rf $TMPDIR  # remove build dir in case it is still there from before
mkdir $TMPDIR
cd $TMPDIR

ln -s ../stack-docs-$VERSION.yaml stack.yaml

git clone https://github.com/diagrams/diagrams-doc

cd diagrams-doc
git checkout deploy-$VERSION
cd ..

## Build diagrams
stack setup
stack build || exit 1

## Build diagrams-haddock diagrams
# for repo in "${REPOS[@]}"; do
#   cd repo && stack exec diagrams-haddock
# done

## Build the website
stack exec bash -- -c 'cd diagrams-doc && diagrams-doc +RTS -N7 -RTS buildh'

## Deploy
rsync -r diagrams-doc/web/_site/* byorgey@projects.haskell.org:/srv/projects/diagrams/
ssh byorgey@projects.haskell.org 'chmod -R o+rX /srv/projects/diagrams/*'
