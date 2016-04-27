if CommandUtilities and not CommandUtilities.ReplaceChars then
	CommandUtilities.ReplaceChars = CommandUtilities.ReplaceChars or class()
	
	CommandUtilities.ReplaceChars._colors = {}
	CommandUtilities.ReplaceChars._colors.red = Color(1, 255, 0, 0)
	CommandUtilities.ReplaceChars._colors.green = Color(1, 0, 255, 0)
	CommandUtilities.ReplaceChars._colors.blue = Color(1, 0, 0, 255)
	CommandUtilities.ReplaceChars._colors.yellow = Color(1, 255, 255, 0)
	CommandUtilities.ReplaceChars._colors.magenta = Color(1, 255, 0, 255)
	CommandUtilities.ReplaceChars._colors.cyan = Color(1, 0, 255, 255)
	
	CommandUtilities.ReplaceChars._data_path = SavePath .. "CommandUtilities_data.txt"

	CommandUtilities.ReplaceChars._data = {
		auto_replacement_enabled = true
	}
	
	CommandUtilities.ReplaceChars._chars = {}
	CommandUtilities.ReplaceChars._chars[1] = { identifier = "ghost", charcode = "BTN_GHOST" }
	CommandUtilities.ReplaceChars._chars[2] = { identifier = "skull", charcode = "BTN_SKULL" }
	CommandUtilities.ReplaceChars._chars[3] = { identifier = "aid", charcode = "BTN_STAT_BOOST" }
	CommandUtilities.ReplaceChars._chars[4] = { identifier = "heart", charcode = "BTN_TEAM_BOOST" }
	CommandUtilities.ReplaceChars._chars[5] = { identifier = "btn_start", charcode = "BTN_START" }
	CommandUtilities.ReplaceChars._chars[6] = { identifier = "btn_back", charcode = "BTN_BACK" }
	CommandUtilities.ReplaceChars._chars[7] = { identifier = "RB", charcode = "BTN_INTERACT" }
	CommandUtilities.ReplaceChars._chars[8] = { identifier = "LB", charcode = "BTN_USE_ITEM" }
	CommandUtilities.ReplaceChars._chars[9] = { identifier = "RT", charcode = "BTN_PRIMARY" }
	CommandUtilities.ReplaceChars._chars[10] = { identifier = "LT", charcode = "BTN_SECONDARY" }
	CommandUtilities.ReplaceChars._chars[11] = { identifier = "dpad", charcode = "BTN_GADGET" }
	CommandUtilities.ReplaceChars._chars[12] = { identifier = "btn_a", charcode = "BTN_A" }
	CommandUtilities.ReplaceChars._chars[13] = { identifier = "btn_b", charcode = "BTN_B" }
	CommandUtilities.ReplaceChars._chars[14] = { identifier = "btn_x", charcode = "BTN_X" }
	CommandUtilities.ReplaceChars._chars[15] = { identifier = "btn_y", charcode = "BTN_Y" }
	
	function CommandUtilities.ReplaceChars:getChars()
		return CommandUtilities.ReplaceChars._chars
	end
	
	function CommandUtilities.ReplaceChars:_save()
		local file = io.open(CommandUtilities.ReplaceChars._data_path, "w+")
		
		if file then
			file:write(json.encode(CommandUtilities.ReplaceChars._data))
			file:close()
		end
	end
	function CommandUtilities.ReplaceChars:_load()
		local file = io.open(CommandUtilities.ReplaceChars._data_path, "r")
		
		if file then
			CommandUtilities.ReplaceChars._data = json.decode(file:read("*all"))
			file:close()
		end
	end
	
	function CommandUtilities.ReplaceChars:auto_replacement_enabled()
		CommandUtilities.ReplaceChars:_load()
		return CommandUtilities.ReplaceChars._data.auto_replacement_enabled
	end
	function CommandUtilities.ReplaceChars:set_auto_replacement_enabled(enabled)
		if enabled == nil then
			enabled = true
		end
		CommandUtilities.ReplaceChars._data.auto_replacement_enabled = enabled
		CommandUtilities.ReplaceChars:_save()
	end
	
	function CommandUtilities.ReplaceChars:_replace_special_chars(str)
		for __,_char in ipairs(CommandUtilities.ReplaceChars._chars) do
			str = str:gsub(tostring(_char.identifier), tostring(managers.localization:get_default_macro(tostring(_char.charcode))))
		end
		return str
	end

	function CommandUtilities.ReplaceChars:_popup_window_msg(title, text, button_text)
		local dialog_data = {}
		dialog_data.title = title or managers.localization:text("CommandUtilities_missing")
		dialog_data.text = text or managers.localization:text("CommandUtilities_missing")
		dialog_data.id = "ChatCommandsPopup"

		local ok_button = {}
		if button_text then
			ok_button.text = tostring(button_text)
		else
			ok_button.text = managers.localization:text("CommandUtilities_dialog_ok")
		end

		dialog_data.button_list = {ok_button}
		
		managers.system_menu:show(dialog_data)
	end
	
	function CommandUtilities.ReplaceChars:_say_in_chat(message)
		message = tostring(message)
		name = managers.network:session():local_peer()
		managers.chat:send_message(ChatManager.GAME, name, message)
	end

	function CommandUtilities.ReplaceChars:_display_chat_message_client(name, message, color)
		  if not message then
				message = ""
		  end
		  if not tostring(color):find('Color') or not color then
				color = nil
		  end
		  if managers and managers.chat and managers.chat._receivers and managers.chat._receivers[1] and tweak_data then
				for __, rcvr in pairs(managers.chat._receivers[1]) do
					  rcvr:receive_message(tostring(name) or ">>", tostring(message), color or tweak_data.chat_colors[5]) 
				end  
		  end
	end
end
if RequiredScript == "lib/managers/chatmanager" then
	local RCcm_send_message_original = ChatManager.send_message
	function ChatManager:send_message(channel_id, sender, message)
		if CommandUtilities.ReplaceChars:auto_replacement_enabled() == true then
			RCcm_send_message_original(self, channel_id, sender, CommandUtilities.ReplaceChars:_replace_special_chars(message))
		else
			RCcm_send_message_original(self, channel_id, sender, message)
		end
	end
end