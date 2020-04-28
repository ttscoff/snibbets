# Snibbets

A tool for accessing code snippets contained in a folder of plain text Markdown files.

Snibbets allows me to keep code snippets in raw files, not relying on a dedicated code snippet app. I can collect and edit my snippets using a text editor, nvALT (nvUltra), or simply saving snippets from my clipboard to a text file using *NIX redirection on the command line. I can add descriptive names and extended descriptions/notes to code snippets using standard Markdown.

What Snibbets does is simply allow a quick search for a specific snippet that I can either output to the terminal, pipe to my clipboard, or access via LaunchBar (via the included LaunchBar Action). It's basically a wrapper for `find` and `grep` with the ability to separate code blocks from other text in my Markdown files.

## Collecting Snippets

Snibbets is designed to work with a folder containing Markdown files. Each Markdown file can have somewhat flexible formatting, as long as there's at least one code block (either indented by 4 spaces/1 tab or fenced with backticks).

If a file contains multiple snippets, they should be separated by ATX-style headers (one or more `#`) describing the snippets. Additional  descriptions can be included outside of the code block. For example:

A file titled `unix find.md`:

    ### Find by name and execute command

        find . -name "rc.conf" -exec chmod o r '{}' \;

    ### Find by name and grep contents

        find . -name "*.php" -exec grep -H googleapis '{}' \;

    ### Find by age range to CSV

    Finds files older than 18months and newer than 24 months, cats the output to a CSV in the format `/some/path/somewhere, size in bytes, Access Time, Modified Time`

        find /dir/dir -type f -mtime +540 -mtime -720 -printf \"%p\",\"%s\",\"%AD\",|"%TD\"\\n > /dir/dir/output.csv


Searches will be conducted based on a filename first, and if no matches are found, a search of file contents will be conducted. The above file could be found with a query of "find" or something more direct like "find by age".

## CLI

### Installation

CLI: Copy `snibbets` to a location in your `$PATH`. To avoid having to specify a directory on the command line, you can edit the path to your snippets folder directly at the top of the script.


### Usage

    $ snibbets -h
    Usage: snibbets [options] query
        -q, --quiet                      Skip menus and display first match
        -o, --output FORMAT              Output format (launchbar or raw)
        -s, --source FOLDER              Snippets folder to search
        -h, --help                       Display this screen

If your Snippets folder is set in the script, simply running `snibbets [search query]` will perform the search and output the code blocks, presenting a menu if more than one match is found or the target file contains more than one snippet. Selected contents are output raw to STDOUT.

An undocumented output option is `-o json`, which will output all of the matches and their code blocks as a JSON string that can be incorporated into other scripts. It's similar to the `-o launchbar` option, but doesn't contain the extra keys required for the LaunchBar action.

The menu currently causes some issues with piping, so running `snibbets [search query]|pbcopy` gets messed up. Run with `-q` (non-interactive) to skip menus and output the top result.

## LaunchBar Action

### Installation

The LaunchBar action can be installed simply by double clicking the `.lbaction` file in Finder. The CLI is not required for the LaunchBar action to function. 

Once installed, run the action (type `snib` and hit return on the result) to select your Snippets folder.

### Usage

Type `snib` to bring the Action up, then hit Space to enter your query text. Matching files will be presented. If the selected file contains more than one snippet, a list of snippets (based on ATX headers in the file) will be presented as a child menu. Selecting a snippet and hitting return will copy the associated code block to the clipboard.


## Shortcomings

Files that contain multiple snippets are located, but drilling down to a specific snippet still requires manual interaction. Eventually I may have this script target searches based on headers and automatically return the appropriate sub-snippet.
