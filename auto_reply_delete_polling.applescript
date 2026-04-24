property blacklisted_senders : {"+1234567890", "badguy@example.com"} -- Add all blacklisted numbers/emails to this list
property auto_reply_text : "This is an automated reply. Please do not contact me."

-- This allows you to test the script directly in Script Editor by clicking "Play"
on run
	my check_messages()
end run

-- The "idle" handler runs periodically when exported as a "Stay Open" application
on idle
	my check_messages()
	return 10 -- Check every 10 seconds
end idle

on check_messages()
	tell application "Messages"
		try
			-- Look through all active chats
			set allChats to every chat
			
			-- If you click "Play" in script editor, this notification will tell you if it found any chats
			-- display notification "Found " & (count of allChats) & " chats"
			
			repeat with aChat in allChats
				try
					-- In newer macOS, we get the participants of the chat
					set chatParticipants to participants of aChat
					
					-- Exclude group chats: Only process if it's a 1-on-1 direct message (exactly 1 participant)
					if (count of chatParticipants) is 1 then
						
						-- Check the single participant in the direct chat
						repeat with aParticipant in chatParticipants
							set sender_id to handle of aParticipant
							
							-- Check if the participant is in the blacklist
							set is_blacklisted to false
							repeat with blacklisted in blacklisted_senders
								if sender_id contains blacklisted then
									set is_blacklisted to true
									exit repeat
								end if
							end repeat
							
							if is_blacklisted then
								
								-- Auto reply
								send auto_reply_text to aParticipant
								
								-- Call the GUI script to delete
								my delete_chat_via_gui(aChat)
								
								-- Exit the participant loop since we found a match
								exit repeat 
							end if
						end repeat
						
					end if
					
				on error errMsg
					-- Silently continue if a chat's properties can't be read
				end try
			end repeat
		on error errMsg
			-- If 'every chat' completely fails, we log it
			display notification "Error getting chats: " & errMsg
		end try
	end tell
end check_messages

-- Function to delete the chat using GUI scripting
on delete_chat_via_gui(targetChat)
	tell application "Messages"
		activate
		try
			set selected of targetChat to true
		end try
	end tell
	
	tell application "System Events"
		tell process "Messages"
			delay 0.5
			
			-- Simulates pressing Command + Delete (Delete Chat)
			key code 51 using command down
			
			delay 0.5
			
			-- Simulates pressing Enter to confirm the deletion in the popup dialog
			key code 36
		end tell
	end tell
end delete_chat_via_gui
