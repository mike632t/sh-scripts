#!/bin/bash
#
#  sh-confirm.sh
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
#  confirm MESSAGE 
#
#  Prints  the message text and waits for the user to enter either a Yes or
#  No response.  Invalid responses are ignored.
#
#  Returns true if user enters Y, Yes or YES or false otherwise.
#

function _confirm {
   _message="$@"  # Get message text 
   [ -z "$_message" ] && _message="Continue"  # Default text if
   while true; do
      printf '%s [y/n] ? ' "$_message" >&2  # Display prompt on stderr (stdout may be redirected).
      if ! read -r _response </dev/tty ; then printf '\n'; return 1; fi  # Return false on EOF (don't use timeout as it is not portable
      case "$_response" in
         [Yy][e][s]|[Y][E][S]|[Yy])  # Yes or Y.
            return 0
            ;;
         [Nn][o]|[N][O]|[Nn])   # No or N.
            return 1
            ;;
         *)  # Anything else (including a blank) is invalid.
            ;;
      esac
   done
}

_confirm $@
