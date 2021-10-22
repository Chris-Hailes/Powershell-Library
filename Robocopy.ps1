<#
.DESCRIPTION
 Robocopy script
 
 /MIR specifies that Robocopy should mirror the source directory and the destination directory. 
 /Z ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting.
 /XA:H makes Robocopy ignore hidden files, usually these will be system files that we're not interested in.
 /R:5 rety failed read/writes 5 times before moving on
 /W:5 reduces the wait time between failures to 5 seconds instead of the 30 second default.
 /tee Write output to console and logfile
 /log Log output to logfile and overwrite on executions

.NOTES
 AUTHOR: Chris Hailes (cubesys)
#>


$sourcedir = 'D:\SourceDir'
$destinationdir = 'D:\DestDir'
$logfile = 'C:\Users\admin\desktop\robolog.txt'

robocopy $sourcedir $destinationdir /MIR /Z /XA:H /R:5 /W:5 /tee /log:$logfile