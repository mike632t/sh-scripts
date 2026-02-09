#!/bin/sh
#
#  sh-download-curl.sh
#
#  Usage
#
#  -  To download all files use:
#
#     'http://download.nai.com/products/datfiles/4.x/nai/'
#
#     'https://cdimage.debian.org/cdimage/archive/5.0.10/alpha/iso-cd/'
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
#  02 Feb 26   0.5   - Switched from 'wget' to 'curl' - MT
#                    - Added check for 'curl' - MT
#                    - Use a custom progress bar for console output - MT
#  03 Feb 26         - Improved error detection - MT
#  06 Feb 26   0.5   - Can recursively download matching files - MT
#                    - Parses command line options - MT
#                    - Some messages can be suppressed using '--quiet' - MT 
#  07 Feb 26   0.5   - Allows  user to select graphical progress bar  using
#                      '-g' or '--gtk' - MT
#  09 Feb 26         - Replaced last occurrence of 'wget' with 'curl' - MT
#                    - Checks for any HTTP errors before trying to download
#                      any files - MT
#                    - If an error occurs when trying to retrieve a list of
#                      files  available from the URL then if a filename was 
#                      specified in the URL attempt to download it directly
#                      instead - MT 
#                    
#

ZENITY=0  # Enable use of zenity (if installed)
DIALOG=0  # Enable use of dialog (if installed)

#
#  usage
#
#  Displays script usage.
#

_usage() (
   printf '\nUsage: %s [OPTION]... [URL] [FILE]... \n' "$(basename "$0")" >&2
)

#
#  help
#
#  Displays usage and help text.
#

_help() (
   _usage
   printf "\nDownloads all matching files to the current directory.\n\n" >&2
   printf "  -q  --quiet              suppress messages\n" >&2
   printf "  -r  --recurse            recurse into subfolders\n" >&2
   printf "  -v  --verbose            enable verbose output\n" >&2
   printf "      --help               show this help and exit\n" >&2
   printf "      --version            show version and exit\n\n" >&2
)

#
#  getfile URL 
#
#  Displays a graphical progress bar while downloading a file.
#

_getfile() (  
   _status=0
   _url="$@"  # Get URL.
   _file="${_url##*/}"
   _url="${_url%/*}/"

   #  -L             : Follow redirects.
   #  -C -           : Resume transfer (continue).
   #  -R             : Remote timestamp.
   #  --fail         : Fail on HTTP errors.
   #  -o             : Output filename.
   #  --progress-bar : Single-line progress bar.

   _options="-L -C - -R -o $_file --fail --progress-bar"

   _text="Downloading: $_file"
   _size=$(stat -c %s "$_file" 2>/dev/null || echo -1)  # Save current file size (-1 if not present).
   if [ -n "$_file" ]; then
      _status=$(curl -I -f -s "$_url$_file" -w "%{http_code}" -o /dev/null)  # Check to see if URL exists and is accessible before attempting to down load file.
      if [ -n "$TERM" ] && [ "$ZENITY" -eq 1 ] && command -v zenity >/dev/null 2>&1;then  # Define $ZENITY to enable use of zenity.
         if [ "$_status" -lt "400" ]; then
            # Parse progress-bar output from 'curl' and display the percentage
            # progress using 'zenity'.
            # Writes progress to stderr using using \r to refresh the line.
            # Convert \r to \n, extract percentage, and strip the % sign.
            curl $_options "$_url$_file" 2>&1 \
              | stdbuf -oL tr '\r' '\n' \
              | stdbuf -oL grep -Eo '[0-9]{1,3}(\.[0-9]+)?%' \
              | stdbuf -oL sed 's/%$//' \
              | zenity --progress --title="" --text="$_text" --width=500 2>/dev/null
            if [ "$_size" -eq -1 ] && [ "$(stat -c %s "$_file" 2>/dev/null || echo 0)" -eq 0 ]; then  # If nothing was downloaded assume an error occurred.
               zenity --error --title="Error" --text="\nUnable to download '$_file'.\n\nPlease check the URL and try again." --width=500
               _status=1
            fi
         else
            zenity --error --title="Error" --text="\nUnable to download '$_file' (HTTP Error '$_status')..\n\nPlease check the URL and try again." --width=500  # Let the user know an error occurred.
         fi
      else
         if [ "$DIALOG" -eq 1 ] && command -v dialog >/dev/null 2>&1;then
            if [ "$_status" -lt "400" ]; then
               # Parse progress-bar output from 'curl' and convert percentages 
               # to integer values for 'dialog'.
               (
                 curl $_options "$_url$_file" 2>&1 \
                   | stdbuf -oL tr '\r' '\n' \
                   | stdbuf -oL grep -Eo '[0-9]{1,3}(\.[0-9]+)?%' \
                   | stdbuf -oL sed 's/%$//' \
                   | while IFS= read -r _progress; do
                       _percent="${_progress%.*}"
                       [ -z "$_percent" ] && _percent=0
                       printf "%s\n" "$_percent"
                     done
               ) | dialog --gauge "$_text" 0 100  
               printf "\n"
               if [ "$_size" -eq -1 ] && [ "$(stat -c %s "$_file" 2>/dev/null || echo 0)" -eq 0 ]; then  # Check to see if the download was successful.
                  printf "Error downloading '%s'.\n" "$_file" >&2  # Let the user know an error occurred.
                  _status=1
               else
                  if [ "$_quiet" -eq 0 ]; then
                     if [ "$_size" -eq "$(stat -c %s "$_file" 2>/dev/null || echo 0)" ]; then  # Get size of file again (return 0 if file not found) and compare with original size.
                        printf "Skipping '%s' (already downloaded).\n" $_file >&2  # If the size hasn't changed the file was already downloaded.
                     fi
                  fi
               fi
            else
               printf "%s: Unable to download '%s' (HTTP Error '%s').\n" "$(basename $0)" "$_file" "$_status" >&2  # Let the user know an error occurred.
            fi
         else
            _indent=$(($(tput cols) / 4 ))  # Indent bar to allow space for file name.
            _width=$(($(tput cols) - _indent - 10))  # Get terminal width.
            _filename=$(printf "%-${_indent}.${_indent}s" "$_file") #  Format filename to fixed width (truncate or pad).
            if [ "$_status" -lt "400" ]; then
               # Cannot  suppress error messages from 'curl' and still display 
               # a progress bar so parse the output and display it using a bar 
               # drawn using printf.
               curl $_options "$_url$_file" 2>&1 \
               | stdbuf -oL tr '\r' '\n' \
               | stdbuf -oL grep -Eo '[0-9]{1,3}(\.[0-9]+)?%' \
               | stdbuf -oL sed 's/%$//' \
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
                  printf "%s: Error downloading '%s'.\n" "$(basename $0)" "$_file" >&2  # Let the user know an error occurred.
               else
                  if [ "$_quiet" -eq 0 ]; then
                     if [ "$_size" -eq "$(stat -c %s "$_file" 2>/dev/null || echo 0)" ]; then  # Get size of file again (return 0 if file not found) and compare with original size.
                        printf "Skipping '%s' (already downloaded).\n" $_file >&2  # If the size hasn't changed the file was already downloaded.
                     fi
                  fi
               fi
            else
               printf "%s: Unable to download '%s' (HTTP Error '%s').\n" "$(basename $0)" "$_file" "$_status" >&2  # Let the user know an error occurred.
            fi
         fi
      fi
   fi
   return "$_status"  # Return HTTP status code
)

#
#  getfolder URL [FILENAME]... 
#
#  Recursively downloads all matching files from the specified location. 
#

_getfolder() (
   _status=0
   _url="$1"
   _file="${_url##*/}"  # Strip off any filename.
   _url="${_url%/*}/"  # Keep URL. 

   shift   # Remove URL.

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

   _status=$(curl -I -f -s "$_url" -w "%{http_code}" -o /dev/null)  # Check to see if URL exists and is accessible before attempting to down load file.
   if [ $_status -lt 400 ]; then  # Check that URL was accessible.
      # Grab all the links from the page.
      _links=$(curl -f -sS "$_url" 2>&1)  # Capture links in folder or error message (if you cannot browse the folder or URL doesn't exist).
      _links=$(echo "$_links" | grep -ioE 'href="[^"]+"')  # Extract the URLs for each link.
      _links=$(echo "$_links" | sed -E 's/[Hh][Rr][Ee][Ff]="([^"]+)"/\1/')  # Strip away any HTML to leave just the link.
      # Get files and folders from links.
      _files=$(echo "$_links" | grep -viE '/$|://|\?|.*/.+')  # Exclude any unwanted links including those containing but not starting with "/" (directories), containing "://" (absolute URLs) or containing "?" (query strings).
      _files=$(echo "$_files" | sort -u)  # Sort the results and removes any duplicates.
      _folders=$(echo "$_links" | grep -E '/$' | grep -viE '://|\?|^\./|^\.\.')  
      _folders=$(echo "$_folders" | sort -u)  # Sort the results.
      # Iterate over each file in the folder
      for _item in $_files; do  # Check each file.
         for _match in "$@"; do  # Avoid globing issues by using the arguments set above.
            case "$_item" in
               $_match)  # Only download matching files!
                  _getfile "$_url$_item"  
                  break  # Only download a matching file once.
                  ;;
            esac
         done
      done
      # Recurse into sub folders if required
      if [ "$_recurse" -gt 0 ]; then
         for _folder in $_folders; do
            _exists=0
            if [ -d $_folder ]; then _exists=1; else mkdir "./$_folder"  2>/dev/null; fi  # If directory does not exist create it.
            if cd "./$_folder" 2>/dev/null; then  # If directory exists then download (matching) contents.
               _getfolder "$_url$_folder" "$@"
               cd ..
            fi
            if [ "$_exists" -eq 1 ] && [ -z "$(ls -A ./$_folder)" ]; then rmdir "./$_folder"; fi  # If directory is empty and didn't exist before delete it.
         done
      fi
   else
      if [ -n "$_file" ]; then  
         _getfile "$_url$_file"  # Attempt to download the file (displays an error if not successful).
         _status="$?"
      else
         printf "%s: Unable to download URL. (HTTP Error '%s').\n" "$(basename $0)" "$_status" >&2  # Let the user know an error occurred.
      fi
   fi
   if [ "$_status" -lt 400 ]; then _status=0; else _status=1; fi  # Return status in range 0-127
   return $_status
)

# Parse command line 
_quiet=0
_recurse=0  
_verbose=0
_count="$#"
while [ "$_count" -gt 0 ]; do  # Parse arguments
   case "$1" in
      -g | --gtk)  # Use ZENITY (if available)
         ZENITY=1
         _count=$((_count - 1))  # Decrement counter
         shift 
         ;;
      -q | --quiet)
         _quiet=1
         _count=$((_count - 1))  # Decrement counter
         shift 
         ;;
      -r | --recurse)
         _recurse=1
         _count=$((_count - 1))  # Decrement counter
         shift 
         ;;
      -v | --verbose)
         _verbose=1
         _count=$((_count - 1))  # Decrement counter
         shift 
         ;;
      --help)
         _help
         exit 0
         ;;
      --*)
         printf "%s: unrecognised option '%s'\n" "$(basename "$0")" "$1" >&2
         exit 1
         ;;
      -*)
         _options=$(printf "%s" "$1" | cut -c2-)
         case "$_options" in
            ?) # Unknown option display error message and quit
               printf "%s: invalid option -- '%s'\n" "$(basename "$0")" "${1#-}" >&2  # Strip leading '-' from $1
               exit 1
               ;;
            *) # Two (or more) options concatenated together split them into separate options 
               shift
               set -- $(printf -- "-%s " $(echo "$_options" | sed 's/./& /g')) "$@"  # Separate out options that have been concatenated together 
               _count="$#"
               ;;
         esac
         ;;
      *)
         set -- "$@" "$1"  # Preserve the positional arguments without globbing (quoting prevents expansion)
         _count=$((_count - 1))  # Decrement counter
         shift
         ;;
   esac
done

if command -v curl >/dev/null 2>&1; then  # Check if 'curl' is installed.
   _getfolder "$@"
else
   printf "%s: Error 'curl' is required but was not found in PATH.\n" "$(basename "$0")" >&2
   _status=1
fi
