#!/bin/zsh

# Script to try installing everything from the homebrew core
# TODO: auto-uninstall conflicting formulae

rubies=($(ls $(brew --prefix)/Library/Formula))
if [[ $# == 0 ]]; then
	all_formulas=()
	for i in $rubies; do
	  all_formulas+=${i%\.*}
	done
else
	all_formulas=($*)
fi

timestamp=$(date "+%Y%m%d_%H%M%S")
baselogdir=log
logdir=$baselogdir/runs/run-$timestamp
mkdir -p $logdir
mkdir -p $logdir/install
already_failed=($(cat log/failed | sort | uniq))
failed=()

function do_one() {
  local formula=$1

  if [[ ${installed[(i)$formula]} -le $#installed ]]; then
    # If it's installed, it clearly worked. There are no bottles yet,
    # so we don't have to worry about that
    #brew rm $formula >/dev/null
    print "Already OK: $formula"
    return 0
  fi
  if [[ ${already_failed[(i)$formula]} -le $#already_failed ]]; then
    print "Already failed: $formula"
    return 1
  fi

  deps=($(brew deps --1 --skip-optional $formula))
  for dep in $deps; do
    if [[ ${already_failed[(i)$dep]} -le $#already_failed ]]; then
      print "Skipping $formula; dependency $dep failed"
      return 1
    fi
    if [[ ${installed[(i)$formula]} -gt $#installed ]]; then
      print "In $formula: trying dep $dep first"
      do_one $dep
      if [[ $? != 0 ]]; then
        print "Skipping $formula: dep $dep failed"
        return 1
      fi
    fi
  done

  print "$(date +%H:%M:%S) trying: $formula"
  brew install --build-from-source $formula &> $logdir/install/$formula
  if [[ $? == 0 ]]; then
    print "ok: $formula"
    return 0
  else
    print "FAILED: $formula  ($(date +%H:%M:%S))"
    print "$formula" >> $logdir/failed
    # Keep a combined list from all runs, for ease of review
    print "$formula" >> $baselogdir/failed
    failed+=$formula
    return 1
  fi

}

function do_it() {

installed=($(brew ls))

for formula in $all_formulas; do
  if [[ -z $formula ]]; then
    return
  fi
  do_one $formula
done

print "Done"
print "Formulas: ${#all_formulas} attempted, ${#failed} failed"

}

do_it | tee $logdir/run.log

