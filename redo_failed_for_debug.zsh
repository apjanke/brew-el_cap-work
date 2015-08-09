#!/bin/zsh

# Rebuilds failed formulae with settings suitable for debug and issue reporting
# (verbose, single-process)
#

print "Rebuilding failed formulae in debug mode"

timestamp=$(date "+%Y%m%d_%H%M%S")
baselogdir=log
built_file=$baselogdir/rebuilt-debug-xfail
ok_rebuild_file=$baselogdir/rebuilt-debug-ok
logdir=$baselogdir/runs/run-$timestamp
mkdir -p $logdir
mkdir -p $logdir/install

function list_conflicts() {
  local formula=$1
  local conflicts
  conflicts=($(brew info $formula | grep "Conflicts with" | cut -d: -f 2 | sed -e 's/,//g' ))
  echo $conflicts
}

function do_one() {
	local formula=$1

  if [[ ${built_debug[(i)$formula]} -le ${#built_debug} || ${built_debug_ok[(i)$formula]} -le ${#built_debug_ok} ]]; then
  	print "already built for debug: $formula"
    return
  fi
 
	deps=($(brew deps --1 --skip-optional $formula))
  for dep in $deps; do
    if [[ ${already_failed[(i)$dep]} -le $#already_failed ]]; then
      print "Skipping $formula; dependency $dep failed"
      return 1
    fi
  done


  conflicts=( $(list_conflicts $formula) )
  for conflict in $conflicts; do
    print "$formula: removing conflict $conflict"
    brew rm $conflict 2> /dev/null
  done

  print "building: $formula  ($(date +%H:%M:%S))"
  HOMEBREW_MAKE_JOBS=1 brew install --build-from-source -v $formula &> $logdir/install/$formula
  if [[ $? == 0 ]]; then
    print "OK: $formula"
    print "$formula" >> $ok_rebuild_file
  else
    print "xfail: $formula  ($(date +%H:%M:%S))"
    print "$formula" >> $built_file
  fi
  built_debug+=$formula
  
}

function do_it() {

  for formula in $formulae_to_rebuild; do
    if [[ -z $formula ]]; then
      continue
    fi
    do_one $formula
  done

  print "Done"
}

already_failed=($(cat log/failed | sort | uniq))
touch $built_file
built_debug=($(cat $built_file | sort | uniq))
built_debug_ok=($(cat $ok_rebuild_file | sort | uniq))

if [[ $# == 0 ]]; then
  formulae_to_rebuild=($already_failed)
else
  formulae_to_rebuild=($*)
fi

do_it | tee $logdir/run.log





