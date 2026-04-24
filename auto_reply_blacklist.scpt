-- Auto-Reply for Blacklisted Contacts in Apple Messages
-- This script monitors Messages and auto-replies to/blacklisted contacts

-- Configuration
property blacklist : {"John Doe", "Jane Smith", "Spam Contact"} -- Add phone numbers or names here
property autoReplyMessage : "I am currently unavailable and will respond later."

-- Run this script and keep it open to monitor Messages
on run
	activate application "Messages"
	tell application "System Events"
		set messagesProcess to process "Messages"
	end tell

	display dialog "Auto-Reply Blacklist Monitor is now running." & return & return & ¬
		"Blacklisted contacts:" & return & my joinList(blacklist, ", ") & return & return & ¬
		"Auto-reply message: " & autoReplyMessage buttons {"OK"} default button "OK"

	-- Keep checking for new messages
	my monitorMessages()
end run

on monitorMessages()
	tell application "Messages"
		set idleCheck to 0
		repeat
			try
				set newMessages to (a reference to every chat whose unread count is greater than 0)
				if (count of newMessages) > 0 then
					repeat with currentChat in newMessages
						try
							set senderName to name of currentChat
							set senderHandle to id of currentChat

							-- Check if sender is in blacklist
							if my isBlacklisted(senderName, senderHandle) then
								-- Send auto-reply
								send autoReplyMessage to currentChat

								-- Delete the conversation
								delete currentChat

								-- Log the action (optional - write to a file)
								my logAction(senderHandle)
							end if
						on error errMsg
							log "Error processing message: " & errMsg
						end try
					end repeat
				end if
			on error errMsg
				log "Monitor error: " & errMsg
			end try

			-- Wait before checking again (5 seconds)
			delay 5
		end repeat
	end tell
end monitorMessages

-- Check if sender is blacklisted
on isBlacklisted(senderName, senderHandle)
	repeat with blacklistedPerson in blacklist
		if (senderName contains blacklistedPerson) or (senderHandle contains blacklistedPerson) then
			return true
		end if
	end repeat
	return false
end isBlacklisted

-- Join list items into a string
on joinList(theList, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set theString to theList as text
	set AppleScript's text item delimiters to oldDelimiters
	return theString
end joinList

-- Log action to file (optional)
on logAction(senderHandle)
	set logFile to (path to desktop as text) & "message_block_log.txt"
	set logEntry to (current date) as text & " - Blocked and auto-replied to: " & senderHandle & return

	try
		set fileRef to open for access logFile with write permission
		write logEntry to fileRef starting at eof
		close access fileRef
	on error
		try
			close access logFile
		end try
	end try
end logAction

-- Idle handler for background checking
on idle
	my monitorMessages()
	return 10 -- Check every 10 seconds
end idle
