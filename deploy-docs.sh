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
./generate-stack-yaml.hs
cd ..

## Build diagrams
stack setup
stack build || exit 1

## Build diagrams-haddock diagrams
# for repo in "${REPOS[@]}"; do
#   cd repo && stack exec diagrams-haddock
# done

## Build the website
cd diagrams-doc && stack exec diagrams-doc -- +RTS -N7 -RTS build

## Deploy
