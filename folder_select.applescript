# I have no idea how applescript works I scrapbooked code from online posts:
# https://apple.stackexchange.com/questions/314404/how-to-get-path-for-multiple-files-correctly-through-applescript-or-through-term
# https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/PromptforaFileorFolder.html
# https://stat.ethz.ch/pipermail/r-sig-mac/2012-November/009741.html
#
# I'm sure there's a better way to do this, but since it works I'm going to parse the
# output of this script in R

tell application "SystemUIServer"
  set Folders to (choose folder with prompt "Choose Folder:" with multiple selections allowed)
  set FolderString to {}
  
  repeat with i from 1 to (Folders count)
    copy (quoted form of POSIX path of (item i of Folders)) & space to end of FolderString
  end repeat
  
  do shell script "echo " & FolderString & " > /tmp/R_folder"
end tell
