#  brew-el_cap-work

This repo is my personal work on getting Mac Homebrew [ready for OS X 10.11 El Capitan](https://github.com/Homebrew/homebrew/issues/40837).

The code in here isn't going to be widely useful or reusable.

###   What's in here   ###

Most of this is scripts for doing installs from source of all the formulae in Homebrew core. It has some logic for:

* tracking progress
* following dependencies
* avoiding redundant installs of formulae whose dependencies fail.
* automatically removing conflicting formulae

A bunch of files get dumped under log/ during the progress of the runs. Those don't need to be tracked in git.


###   Usage  ###

All the programs in bin/ need to be run from the base directory of the project. They are not location-aware, assume all paths are relative to pwd, and use that to locate log/, var/, and so on.

The files in bin/ without an extension are scripts intended to be run as commands in their own process. The files with a `.zsh` extension are function definitions intended to be sourced so their functions can be used interactively.

