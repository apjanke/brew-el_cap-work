# Common code for the build scripts

# Initialization logic for the beginning of one of these 
# build scripts
function init_script() {
	timestamp=$(date "+%Y%m%d_%H%M%S")
	baselogdir=log
	vardir=var
	built_file=$vardir/rebuilt-debug-xfail
	ok_rebuild_file=$vardir/rebuilt-debug-ok
	my_logdir=$baselogdir/runs/run-$timestamp
	mkdir -p $vardir
	mkdir -p $my_logdir
	mkdir -p $my_logdir/install
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
}