#!/bin/bash
#
#  sh-wait.sh
#
#  This  program is free software: you can redistribute it and/or modify it
#  under  the terms of the GNU General Public License as published  by  the
#  Free  Software Foundation, either version 3 of the License, or (at  your
#  option) any later version.
#
#  This  program  is distributed in the hope that it will  be  useful,  but
#  WITHOUT   ANY   WARRANTY;   without even   the   implied   warranty   of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#  Public License for more details.
#
#  You  should have received a copy of the GNU General Public License along
#  with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  03 Dec 18   0.1   - Initial version - MT 
#

#
# wait TIME MESSAGE 
#
# A prints the message text and remaining time each second or just waits if
# MESSAGE is not defined.
#
# Returns immediately if TIME is no defined negative or not numeric.
#

function _wait {
   local _timeout _message _output _length
   _timeout=$1  # Get duration.
   shift
   _message="$@"  # Get message text 
   while [ "$_timeout" -gt 0 ] 2>/dev/null; do  # Check timeout is greater then zero and suppress error in case it is not numeric!
      _output=`printf "%s %d s ... " "$_message" "$_timeout"` # Get output including time
      _length=`printf "%s" "$_output" | wc -m`  # Get number of characters in output (not bytes so handles unicode correctly)
      [ -n "$_message" ] && printf "%s" "$_output"  # Print output if message is not a null string
      sleep 1
      [ -n "$_message" ] && printf "\r%${_length}s\r" ""  # Erase output (over print with spaces) if there was any
      _timeout=$((_timeout - 1))  # Decrement the counter
   done
}

_wait $@
