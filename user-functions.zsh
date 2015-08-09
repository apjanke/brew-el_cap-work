# Functions for interactive use
#
#

# Display the last brew run log for a given formula
function last-log() { 
  ls log/runs/*/*/$1 | tail -1 | xargs cat 
}


