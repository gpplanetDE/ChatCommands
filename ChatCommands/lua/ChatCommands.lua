if not ChatCommands then
	ChatCommands = ChatCommands or class()
	ChatCommands.modname = "ChatCommands"
	ChatCommands.prefix = "[" .. ChatCommands.modname .. "]"
	
	ChatCommands._commands = {}
	
	function ChatCommands:_send_message_to_peer(peer, message)
		if managers.network:session() then
			peer:send("send_chat_message", ChatManager.GAME, self.prefix .. ": " .. message)
		end
	end
	function validateArguments(chat_args, cmd_args)
		local check_all_required = 1
		for it = 1, #chat_args do
			if cmd_args[it] then
				if cmd_args[it]._value_type == "boolean" and chat_args[it] ~= "true" and chat_args[it] ~= "false" then
					return false
				elseif cmd_args[it]._value_type == "number" and not tonumber(chat_args[it]) then
					return false
				elseif cmd_args[it]._value_type == "string" and chat_args[it] == "" then
					return false
				elseif cmd_args[it]._value_type == "peer_id" and (not tonumber(chat_args[it]) or tonumber(chat_args[it]) < 0 or tonumber(chat_args[it]) > 3) then
					return false
				end
			else
				return false
			end
			check_all_required = it + 1
		end
		if cmd_args[check_all_required] and cmd_args[check_all_required]._required == true then
			return false
		end
		return true
	end
	function ChatCommands:_parseChat(text)
		local message = text:text()
		local command, command_args
		if utf8.sub(message, 1, 1) == "/" then
			local command_string = utf8.sub(message, 2, utf8.len(message))
			command_args = string.split(command_string, " ") or {}
			if #command_args > 0 then
				command = Idstring(table.remove(command_args, 1))
			end
		end
		if command and self._commands[command:key()] then
			local cmd = self._commands[command:key()]
			text:set_text("")
			text:set_selection(0, 0)
			if validateArguments(command_args, cmd._arguments) then
				return cmd._callback(command_args) or false
			else
				local args_string = ""
				for __, arg in pairs(cmd._arguments) do
					if args_string ~= "" then
						args_string = args_string .. " "
					end
					if arg._required == true then
						args_string = args_string .. "*"
					end
					args_string = args_string .. "[" .. arg._argname .. " (" .. arg._value_type .. ")]"
				end
				if args_string ~= "" then
					args_string = " " .. args_string
				end
				return "Usage: /" .. cmd._commandname .. args_string
			end
		end
		return false
	end
	
	function ChatCommands:_stringInTable(str, tbl)
		for __, tbl_str in pairs(tbl) do
			if tbl_str == str then
				return true
			end
		end
		return false
	end
	
	function ChatCommands:_respond(message)
		if not message then
			return
		end
		message = tostring(message)
		if managers and managers.chat and managers.chat._receivers and managers.chat._receivers[1] then
			for __, rcvr in pairs(managers.chat._receivers[1]) do
				rcvr:receive_message(">>", message, Color(1, 255, 0, 0)) 
			end  
		end
	end
	
	function ChatCommands:addCommand(command, modname, cmd_description, arguments, callback)
		arguments = arguments or {}
		modname = modname or ""
		self._commands[Idstring(command):key()] = {_commandname = command, _callback = callback, _modname = modname, _description = cmd_description,  _arguments = arguments}
	end
	function ChatCommands:newArgument(argname, value_type, required)
		return {_argname = argname, _value_type = value_type, _required = required and true}
	end
	
	function ChatCommands:getCommand(command)
		return self._commands[Idstring(command):key()]
	end
	function ChatCommands:modGetCommands(modname)
		local commands = {}
		for __, cmd in pairs(self._commands) do
			if cmd._modname == modname then
				table.insert(commands, cmd)
			end
		end
		return commands
	end
	function ChatCommands:getCommandedMods()
		local mods = {}
		for __, cmd in pairs(self._commands) do
			if not ChatCommands:_stringInTable(cmd._modname, mods) then
				table.insert(mods, cmd._modname)
			end
		end
		return mods
	end
	
	dofile(ModPath .. "lua/CommandUtilities.lua")
end
if RequiredScript == "lib/managers/chatmanager" then
	local CCcm_enter_key_callback_original = ChatGui.enter_key_callback
	function ChatGui:enter_key_callback()
		if not self._enabled then
			return
		end
		local response = ChatCommands:_parseChat(self._input_panel:child("input_text"))
		if response ~= false then
			ChatCommands:_respond(response)
			return
		else
			CCcm_enter_key_callback_original(self)
		end
	end
elseif RequiredScript == "lib/managers/hud/hudchat" then
	local CChc_enter_key_callback_original = HUDChat.enter_key_callback
	function HUDChat:enter_key_callback()
		local response = ChatCommands:_parseChat(self._input_panel:child("input_text"))
		if response ~= false then
			managers.hud:set_chat_focus(false)
			ChatCommands:_respond(response)
			return
		else
			CChc_enter_key_callback_original(self)
		end
	end
end
