# jHelper | GUI

The 'jHelper | GUI' is an application written in Swift to provide a Cocoa interface for easily creating 'Jamf Helper' commands. The application provides GUI control for all of the 'Jamf Helper' binary commands to make selecting and formatting the appropriate arguments easier. 

It allows for launching 'Jamf Helper' with the selected commands to preview the settings, outputting the commands to a '.sh' file on the desktop, and submitting the 'Jamf Helper' command as a script directly to the JSS via the API.

REQUIREMENTS: 
macOS 10.7+ (only macOS 10.10, 10.11, and 10.12 tested)
Jamf Helper binary - Located in "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" in order for previews to work.
