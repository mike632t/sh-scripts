#!/bin/sh
#
#  sh-purge-packages.sh
#
#  Purge all packages in listed in file.
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
#  28 Jan 26   0.1   - Initial version - MT 
#  31 Jan 26         - Prompts before purging packages - MT
#                    - Reads list of packages from a file - MT
#                    - Modified for use with /bin/sh - MT
#

#
#  confirm MESSAGE 
#
#  Prints  the message text and waits for the user to enter either a Yes or
#  No response.  Invalid responses are ignored.
#
#  Returns true if user enters Y, Yes or YES or false otherwise.
#

_confirm() (
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
)

if [ "$#" -eq 1 ] ; then
   if [ "$(id -u)" -eq 0 ]; then  # Check effective user ID (zero is root)
      if [ -f "$1" ]; then
         _counter=0
         _count=$(grep -v '^[[:space:]]*$' "$1" | grep -v '^[[:space:]]*#' | wc -l)  # Get number line in the file ignoring comments and blank lines
         if _confirm "This script will attempt to purge $_count packages - continue"; then
            if _confirm "Are you sure"; then
               while IFS= read -r _package; do
                  _package=$(printf "%s" "$_package" | sed 's/[[:space:]]*#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')  # Trim comments and leading/trailing spaces
                  if [ -n "$_package" ]; then  # Ignore blank lines
                     _counter=$((_counter + 1))  # Increment counter
                     if dpkg -s "$_package" > /dev/null 2>&1; then  # Check if package is installed
                        printf 'Purging %s ...\n' "$_package" >&2  # Display error on stderr
                        if stty >/dev/null 2>&1; then  # Is stdout a terminal?
                           echo apt-get purge --ignore-missing --auto-remove -y "$_package" > /dev/null 2>&1  # Redirect output to null
                        else
                           echo apt-get purge --ignore-missing --auto-remove -y "$_package"  # Output will be redirected to file
                        fi
                        if [ $? -ne 0 ]; then
                           printf 'Error: failed to purge %s\n' "$_package" >&2  # Display error on stderr
                        fi
                     else
                        printf 'Skipping %s ...\n' "$_package" >&2  # Display error on stderr
                     fi
                  fi
               done < "$1"  # Read packages from file
            fi
         fi
      else
         printf '%s: File not found.\n' "$(basename "$0")" >&2  # Display error on stderr
      fi
   else
      printf 'This script must be run as root (use sudo).\n' >&2  # Display error on stderr
   fi
else
   printf 'Usage: %s <filename>\n' "$(basename "$0")" >&2  # Display error on stderr
fi   

