#!/bin/sh
#
#  sh-download.sh
#
#  Usage
#
#  -  To download all files use:
#
#     'http://download.nai.com/products/datfiles/4.x/nai/'
#
#  -  To download 'readme.txt' use:
#
#     'http://download.nai.com/products/datfiles/4.x/nai/readme.txt'
#        or
#     'http://download.nai.com/products/datfiles/4.x/nai/' 'readme.txt'
#
#  -  To download all 'zip' and 'exe' files use:
#
#     'http://download.nai.com/products/datfiles/4.x/nai/*.zip' '*.exe'
#        or
#     'http://download.nai.com/products/datfiles/4.x/nai/' '*.zip' '*.exe'
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
#  12 Apr 17   0.1   - Initial version - MT 
#  19 Apr 17   0.2   - Reverse output before extracting percent - MT
#  20 Apr 17   0.3   - Fixed problem with file names that don't have a file
#                      extension - MT
#  29 Jan 26   0.4   - Parse all links and build a list of filenames before
#                      downloading those that match the pattern (could also
#                      use an accept list with wget but this shows the HTML
#                      downloads as well as the progress of each individual
#                      file download by building our own list we avoid that
#                      extraneous output - MT
#  30 Jan 26         - Pass URL from command line - MT
#  31 Jan 26         - Allow multiple filename filters - MT
#  02 Feb 26         - Added check for 'wget' - MT
#                    - Use a custom progress bar for console output - MT
#  03 Feb 26         - Improved error detection - MT
#

ZENITY=0  # Enable use of zenity (if installed)
DIALOG=0  # Enable use of dialog (if installed)
#
#  download URL 
#
#  Displays a graphical progress bar while downloading a file.
#
#  Note - Executes in a sub shell to keep variable scope local.
#

_download() (  
   _url="$@"  # Get URL
   _file="${_url##*/}"
   _url="${_url%/*}/"

   #  -c             : Resume downloading a partly downloaded file.
   #  -np            : Do not follow links to parent directories.
   #  -O             : Output filename.
   #  -e robots=off  : Ignore robots.txt.
   #  --progress-bar : Single-line progress bar.

   _options=" -c -np -O $_file -e robots=off --show-progress "

   _text="Downloading: $_file"
   _size=$(stat -c %s "$_file" 2>/dev/null || echo -1)  # Save current file size (-1 if not present)
   if [ -n "$_file" ]; then
      if [ -n "$TERM" ] && [ "$ZENITY" -eq 1 ] && command -v zenity >/dev/null 2>&1;then  # Define $ZENITY to enable use of zenity
         # Parse progress-bar output from 'wget' and display the percentage
         # progress using 'zenity'.
         # Writes progress to stderr using using \r to refresh the line.
         # Convert \r to \n, extract percentage, and strip the % sign.
         wget $_options $_url$_file 2>&1 \
            | stdbuf -oL sed -e 's\nothing to do\100%\g' \
            | stdbuf -oL grep --line-buffered "%" \
            | stdbuf -oL cut -f1 -d'%' | stdbuf -oL rev \
            | stdbuf -oL cut -f1 -d' ' | stdbuf -oL rev \
            | zenity --progress --title="" --text="$_text" --width=500 2>/dev/null
         if [ "$_size" -eq -1 ] && [ "$(stat -c %s "$_file" 2>/dev/null || echo -0)" -eq 0 ]; then  # If nothing was downloaded assume an error occurred.
            rm "$_file" 2>/dev/null  
            zenity --error --title="Error" --text="\nUnable to download '$_file'.\n\nPlease check the URL and try again." --width=500
         fi
      else
         if [ "$DIALOG" -eq 1 ] && command -v dialog >/dev/null 2>&1;then
            # Parse progress-bar output from 'wget'
            wget $_options $_url$_file 2>&1 \
               | stdbuf -oL sed -e 's\nothing to do\100%\g' \
               | stdbuf -oL grep --line-buffered "%" \
               | stdbuf -oL cut -f1 -d'%' | stdbuf -oL rev \
               | stdbuf -oL cut -f1 -d' ' | stdbuf -oL rev \
               | dialog --guage "$_text" 0 100 
            if [ "$_size" -eq -1 ] && [ "$(stat -c %s "$_file" 2>/dev/null || echo 0)" -eq 0 ]; then   # If nothing was downloaded assume an error occurred
               rm "$_file" 2>/dev/null  
               dialog --title "Error" --msgbox "\nUnable to download '$_file'.\n\nPlease check the URL and try again.\n" 9 60
            fi
         else
            _indent=$(($(tput cols) / 4 ))  # Indent bar to allow space for file name.
            _width=$(($(tput cols) - _indent - 10))  # Get terminal width.
            _filename=$(printf "%-${_indent}.${_indent}s" "$_file") #  Format filename to fixed width (truncate or pad)
            # Parse the output and display percentage as a bar using printf.
            wget $_options $_url$_file 2>&1 \
            | stdbuf -oL sed -e 's\nothing to do\100%\g' \
            | stdbuf -oL grep --line-buffered "%" \
            | stdbuf -oL cut -f1 -d'%' | stdbuf -oL rev \
            | stdbuf -oL cut -f1 -d' ' | stdbuf -oL rev \
            | while IFS= read -r _progress; do
                 _percent="${_progress%.*}"
                 [ -z "$_percent" ] && _percent=0
                 _filled=$(($_percent * _width / 100))
                 _empty=$((_width - _filled))
                 bar="$(printf "%${_filled}s" | tr ' ' '#')"
                 spaces="$(printf "%${_empty}s")"
                 printf "\r%s [%s%s] %3d%%" "$_filename" "$bar" "$spaces" "$_percent"
              done
            printf "\n"
            if [ "$_size" -eq -1 ] && [ "$(stat -c %s "$_file" 2>/dev/null || echo 0)" -eq 0 ]; then  # Check to see if the download was successful.
               rm "$_file" 2>/dev/null  
               printf "Error downloading '%s'.\n" "$_file" >&2  # Let the user know an error occurred.
            else
               if [ "$_size" -eq "$(stat -c %s "$_file" 2>/dev/null || echo 0)" ]; then  # Get size of file again (return 0 if file not found) and compare with original size.
                  printf "Skipping '%s' (already downloaded).\n" $_file >&2  # If the size hasn't changed the file was already downloaded.
               fi
            fi
         fi
      fi
   fi
)


_status=0
if [ "$#" -gt 0 ]; then  # Print error message if not one argument.
   if command -v wget >/dev/null 2>&1; then  # Check curl is installed.
      _url="$1"
      _file=''
       
      _url="$_url$_file"  # Extract the URL and filename.
      _file="${_url##*/}"
      _url="${_url%/*}/"
      
      shift   # Remove URL

      if [ "$#" -eq 0 ]; then   # No additional filenames.
         if [ -n "$_file" ]; then
            set -- "$_file"  # Replace args[] with just the pattern from the URL.
         else
            set -- "*"  # Replace args[] with wildcard to match everything.
         fi
      else   
         if [ -n "$_file" ]; then
            set -- "$_file" "$@"  # Prepend the pattern from the URL to the argument list.
         fi
      fi

      _files=$(wget -q -O- "$_url" | grep -ioE 'href="[^"]+"')  # Extract the URLs for each link
      _files=$(echo "$_files" | sed -E 's/[Hh][Rr][Ee][Ff]="([^"]+)"/\1/')  # Strip away any HTML to leave just the link
      _files=$(echo "$_files" | grep -viE '/$|://|\?|.*/.+')  # Exclude any unwanted links including those containing but not starting with "/" (directories), containing "://" (absolute URLs) or containing "?" (query strings)
      _files=$(echo "$_files" | sort -u)  # Sort the results and removes any duplicates

      for _item in $_files; do  # Check each file.
         for _match in "$@"; do  # Avoid globing issues by using the arguments set above.
            case "$_item" in
               $_match)  # Only download matching files!
                  _download "$_url$_item"  
                  #echo "$_url$_item"  
                  break  # Only download a matching file once.
                  ;;
            esac
         done
      done
      printf "\n"  # Keeps output clean.
   else
      printf "%s: Error 'wget' is required but was not found in PATH.\n" "$(basename "$0")" >&2
      _status=1
   fi
else
   printf "Usage: %s: <url>\n" "$(basename "$0")" >&2
   _status=1
fi

exit "$_status"
