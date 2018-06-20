#!/bin/bash

PROJECT="Metal"
lazbuild $PROJECT.lpr
if [ $? -eq 0 ]; then
	BUNDLE="$PROJECT.app/Contents/MacOS/$PROJECT"

	osascript <<END
	tell application "Terminal"
		if (count of windows) is 0 then
			do script "$BUNDLE"
		else
			do script "$BUNDLE" in window 1
		end if
		activate
	end tell
END

fi