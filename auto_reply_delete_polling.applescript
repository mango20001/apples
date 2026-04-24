property blacklisted_sender : "+1234567890" -- Replace with the blacklisted number/email
property auto_reply_text : "This is an automated reply. Please do not contact me."

-- The "idle" handler runs periodically when exported as a "Stay Open" application
on idle
	tell application "Messages"
		-- Look through all active chats
		set allChats to every chat
		
		repeat with aChat in allChats
			try
				-- Try to get the buddy associated with the chat
				set chatBuddy to buddy of aChat
				set sender_id to handle of chatBuddy
				
				-- Check if the chat belongs to the blacklisted sender
				if sender_id is blacklisted_sender then
					
					-- Check if there are unread messages from them to avoid replying repeatedly to old messages
					if unread message count of aChat > 0 then
						
						-- Auto reply
						send auto_reply_text to chatBuddy
						
						-- Call the GUI script to delete
						my delete_chat_via_gui(aChat)
						
					end if
				end if
			on error
				-- Ignore errors (e.g., group chats without a single "buddy")
			end try
		end repeat
	end tell
	
	-- Return the number of seconds before running again (e.g., check every 10 seconds)
	return 10
end idle

-- Function to delete the chat using GUI scripting
on delete_chat_via_gui(targetChat)
	tell application "Messages"
		activate
		-- Try to select the chat first so we delete the correct one
		set selected of targetChat to true 
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
