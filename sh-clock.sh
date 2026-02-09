#!/bin/bash
#
#  sh-clock.sh
#
#  Display a clock in the top right-hand corner of the console.
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
#  05 Dec 18   0.1   - Initial version - MT 
#

_width=$(tput cols)

while true; do
  echo -ne "\e7\e[1;$(($(tput cols) - 20))H\e[7m$(date +" %Y/%m/%d %H:%M:%S ")\e[0m\e8"
  sleep 0.2
done

#  Same as above using but doesn't run 'tput' every time the display is updated
#while true; do
#  echo -ne "\e7\e[1;$(($_width - 20))H\e[7m$(date +" %Y/%m/%d %H:%M:%S ")\e[0m\e8"
#  sleep 0.2
#done

#  Same as above using 'printf'
#while true; do
#  printf "\e7\e[1;%dH\e[7m%s\e[0m\e8" $(($(tput cols) - 20 )) "$(date +" %Y/%m/%d %H:%M:%S ")"
#  sleep 0.2
#done

#  Same as above using but doesn't run 'tput' every time the display is updated
#while true; do
#  printf "\e7\e[1;%dH\e[7m%s\e[0m\e8" $(($_width - 20 )) "$(date +" %Y/%m/%d %H:%M:%S ")"
#  sleep 0.2
#done



