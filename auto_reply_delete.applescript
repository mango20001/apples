-- Define the blacklisted sender (phone number or email) and the auto-reply message
property blacklisted_sender : "+1234567890" -- Replace with the actual blacklisted sender
property auto_reply_text : "This is an automated reply. Please do not contact me."

-- The event handler for when a message is received
using terms from application "Messages"
	on message received theMessage from theBuddy for theChat
		-- Get the sender's identifier (handle/phone number/email)
		set sender_id to handle of theBuddy
		
		-- Check if the sender is the blacklisted one
		if sender_id is blacklisted_sender then
			
			-- 1. Auto reply to the sender
			send auto_reply_text to theBuddy
			
			-- 2. Delete the chat
			-- Note: macOS Messages does not support a native "delete chat" command in AppleScript.
			-- We have to use GUI Scripting to simulate deleting the conversation.
			delete_chat_via_gui()
			
		end if
	end message received
end using terms from

-- Function to delete the current chat using GUI scripting
on delete_chat_via_gui()
	tell application "Messages"
		activate
	end tell
	
	tell application "System Events"
		tell process "Messages"
			delay 0.5
			
			-- Simulates pressing Command + Delete (Delete Chat)
			key code 51 using command down
			
			delay 0.5
			
			-- Simulates pressing Enter/Return to confirm the deletion in the popup dialog
			key code 36
		end tell
	end tell
end delete_chat_via_gui
