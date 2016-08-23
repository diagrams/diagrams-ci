#!/bin/bash

REPOS=(

  # support libraries
  'monoid-extras'
  'diagrams-solve'
  'dual-tree'
  'active'

  # core libraries
  'diagrams'
  'diagrams-core'
  'diagrams-lib'
  'diagrams-contrib'

  # extras
  'SVGFonts'
  'palette'
  'diagrams-input'
  'diagrams-graphviz'
  'diagrams-builder'

  # backends
  'statestack'
  'diagrams-cairo'
  'diagrams-gtk'
  'diagrams-html5'
  'diagrams-pgf'
  'diagrams-postscript'
  'diagrams-povray'
  'diagrams-rasterific'
  'diagrams-svg'

  # documentation, tests, & admin
  'diagrams-doc'
  'diagrams-haddock'
  'docutils'
  'diagrams-backend-tests'
  'package-ops'

  # miscellaneous
  'force-layout'
  )

rm -rf build-tmp  # remove build-tmp in case it is still there from before
mkdir build-tmp
cd build-tmp
ln -s ../stack-HEAD.yaml stack.yaml

## Check out everything
for repo in "${REPOS[@]}"; do
  git clone https://github.com/diagrams/$repo
done

## Setup
echo 'Setting up stack...'
stack setup
echo 'Building gtk2hs-buildtools...'
stack build gtk2hs-buildtools || exit 1

echo 'Generating stack.yaml for diagrams-doc...'
## Generate stack.yaml for diagrams-doc
cd diagrams-doc && ./generate-stack-yaml.hs

echo 'Building...'
## Build diagrams
if [[ $OSTYPE == darwin* ]]; then
    stack exec -- stack build --flag gtk:have-quartz-gtk || exit 1
else
    stack -v exec -- stack build || exit 1
fi

## Build diagrams-haddock diagrams
# for repo in "${REPOS[@]}"; do
#   cd $repo && stack exec -- diagrams-haddock -d `stack path --dist-dir` || exit 1
# done

## Build the website
stack exec diagrams-doc -- +RTS -N7 -RTS build || exit 1
