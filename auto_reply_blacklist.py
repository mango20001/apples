#!/usr/bin/env python3
"""
Auto-Reply for Blacklisted Contacts in Apple Messages
Requires: pip install pyobjc

Usage: python auto_reply_blacklist.py
"""

import logging
from datetime import datetime
from Foundation import NSObject
from AppKit import NSApplication, NSAlert
from PyObjCTools import AppHelper

# ===== CONFIGURATION =====
BLACKLIST = [
    "+1234567890",  # Add phone numbers
    "john@email.com",  # Add email addresses
    "Jane Doe",  # Add display names
]
AUTO_REPLY_MESSAGE = "This is an automated reply. I cannot respond to your message at this time."
# ===== END CONFIGURATION =====

# Setup logging
logging.basicConfig(
    filename='auto_reply_log.txt',
    level=logging.INFO,
    format='%(asctime)s - %(message)s'
)

class MessageAutoReply(NSObject):
    """Handle incoming messages and auto-reply to blacklisted contacts"""

    def init(self):
        self = super().init()
        if self is None:
            return None

        # Import Messages framework
        from PyObjCTools import AppHelper
        import IMChat
        import IMMessage
        import IMAccount

        self.im_framework = AppHelper
        return self

    def check_and_reply(self):
        """Check for new messages and reply to blacklisted senders"""
        try:
            from ApplicationServices import AXElements
            from Messages import MessagesApplication

            Messages = MessagesApplication.messages()

            for chat in Messages.chats():
                if chat.unread_count() > 0:
                    sender_id = chat.id()
                    sender_name = chat.name()

                    # Check if sender is blacklisted
                    if self.is_blacklisted(sender_id, sender_name):
                        # Send auto-reply
                        chat.send_message(AUTO_REPLY_MESSAGE)

                        # Delete the chat/conversation
                        chat.delete()

                        # Log the action
                        logging.info(f"Auto-replied and deleted from: {sender_id}")

        except Exception as e:
            logging.error(f"Error checking messages: {e}")

    def is_blacklisted(self, sender_id, sender_name):
        """Check if sender is in the blacklist"""
        for blocked in BLACKLIST:
            if blocked.lower() in sender_id.lower() or blocked.lower() in sender_name.lower():
                return True
        return False

    def start_monitoring(self):
        """Start monitoring for new messages periodically"""
        import time

        print("Auto-Reply Blacklist Monitor is running...")
        print(f"Monitoring {len(BLACKLIST)} blacklisted contacts")
        print("Press Ctrl+C to stop")

        try:
            while True:
                self.check_and_reply()
                time.sleep(5)  # Check every 5 seconds
        except KeyboardInterrupt:
            print("\nStopping monitor...")


class SimpleAutoReply:
    """Simpler version using AppleScript via subprocess"""

    @staticmethod
    def is_blacklisted(sender):
        """Check if sender is in blacklist"""
        for blocked in BLACKLIST:
            if blocked.lower() in sender.lower():
                return True
        return False

    @staticmethod
    def send_auto_reply(phone_number, message=AUTO_REPLY_MESSAGE):
        """Send message using AppleScript"""
        import subprocess

        script = f'''
        tell application "Messages"
            set targetService to 1st service whose service type = iMessage
            set targetBuddy to buddy "{phone_number}" of targetService
            send "{message}" to targetBuddy
        end tell
        '''

        subprocess.run(["osascript", "-e", script])

    @staticmethod
    def delete_conversation(phone_number):
        """Delete conversation using AppleScript"""
        import subprocess

        script = f'''
        tell application "Messages"
            set targetChat to a chat whose name contains "{phone_number}"
            delete targetChat
        end tell
        '''

        subprocess.run(["osascript", "-e", script])


if __name__ == "__main__":
    # Show startup alert
    alert = NSAlert.alloc().init()
    alert.setMessageText_("Auto-Reply Blacklist Monitor")
    alert.setInformativeText_(f"Monitoring {len(BLACKLIST)} contacts\nAuto-reply: {AUTO_REPLY_MESSAGE}")
    alert.addButtonWithTitle_("Start")
    alert.addButtonWithTitle_("Cancel")

    if alert.runModal() == 1001:  # Cancel button
        exit(0)

    # Start the monitor
    monitor = MessageAutoReply.alloc().init()
    monitor.start_monitoring()
