# sz-epub-sync-to-remarkable

 * rm_main.sh: main file
 * convert_epubs.sh: convert epubs to pdf
    Note: for epub-format the links within the newspaper were not working
            on the remarkable, thats why the epub is converted to pdf
 * generate_rm_files.sh: generate remarkable files from the pdf
    Only process files on demand
 * rsync_files.sh: rsync files to the remarkable
