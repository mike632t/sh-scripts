#!/bin/bash
#
#  sh-isnumeric.sh
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
#  See: https://unix.stackexchange.com/questions/151654/
#
#  24 Jan 26   0.1   - Initial version - MT 
#

#
#  isnumeric VALUE
#
#  Tests if the argument is numeric (strictly an integer).
#

_isnumeric () {
   if [ "$#" -gt 1 ]; then  # Print error message if more that one argument
      printf '%s: isnumeric() too many arguments\n' "$(basename "$0")" >&2
      return 1
   fi
   case "$1" in
      *[!+0-9-]*|-|+|?*-*|?*+*|""|0?*|-0?*|+0?*)  
         # Matches  anything that contains a character that is NOT a  valid 
         # numeric character (ie +, -, or 0-9), a sign by itself, a sign in
         # the middle of a string, an empty string, or a string that begins
         # with a zero or a sign followed by a zero.
         return 1 ;;
      *) # Anything else is an integer! 
         return 0 ;;
   esac
}

_isnumeric $@
