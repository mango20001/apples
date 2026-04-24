-- Simple Auto-Reply for Blacklisted Contacts
-- Save as an application and run in background

-- ===== CONFIGURATION =====
property blacklist : {"+1234567890", "john@email.com", "Jane Doe"} -- Phone numbers, emails, or names
property autoReplyMessage : "This is an automated reply. I cannot respond to your message at this time."
-- ===== END CONFIGURATION =====

using terms from application "Messages"
	on process message msg
		try
			set sender to sender of msg
			set senderID to id of sender

			-- Check if sender is in blacklist
			if my isBlacklisted(senderID) then
				-- Send auto-reply
				tell application "Messages"
					activate
					set newMsg to make new outgoing message with properties ¬
						{content:autoReplyMessage, subject:""} at end of outgoing messages
					send newMsg to sender

					-- Delete the incoming message
					delete msg
				end tell

				return "handled"
			end if
		on error errMsg
			log "Error: " & errMsg
		end try

		return "continue"
	end process message
end using terms from

on isBlacklisted(senderID)
	repeat with blockedContact in blacklist
		if senderID contains blockedContact then
			return true
		end if
	end repeat
	return false
end isBlacklisted

-- Startup notification
on run
	display notification "Auto-Reply Blacklist is now monitoring Messages" with title "Message Auto-Reply"
end run
