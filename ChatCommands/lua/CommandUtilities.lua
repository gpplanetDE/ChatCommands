if not CommandUtilities then
	CommandUtilities = CommandUtilities or class()
	CommandUtilities.modname = "CommandUtilities"
	CommandUtilities.prefix = "[" .. CommandUtilities.modname .. "]"
	
	ChatCommands:addCommand("whoami", CommandUtilities.modname, "Returns your own peer_id.", nil, function(args)
		return "peer_id: " .. tostring(_G.LuaNetworking:LocalPeerID())
	end)
	
	ChatCommands:addCommand("whois", CommandUtilities.modname, "Returns the steam username belonging to the given peer_id.", {ChatCommands:newArgument("peer_id", "peer_id", true)}, function(args)
		if args and args[1] and tonumber(args[1]) then
			return "steamname: " .. tostring(_G.LuaNetworking:GetNameFromPeerID(tonumber(args[1])))
		end
	end)
	
	ChatCommands:addCommand("help", CommandUtilities.modname, "Returns information about the given command.", {ChatCommands:newArgument("command", "string", false)}, function(args)
		if args and args[1] and ChatCommands:getCommand(args[1]) then
			local cmd = ChatCommands:getCommand(args[1])
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
				args_string = "\nArguments: " .. args_string
			end
			return "[" .. cmd._modname .. "] " .. cmd._commandname .. ": " .. cmd._description .. args_string
		else
			return "Usage: /help [command]. Find available commands with /mods and /modcommands [modname]"
		end
	end)
	
	ChatCommands:addCommand("mods", CommandUtilities.modname, "Returns the commanded mods.", nil, function(args)
		local mods = ChatCommands:getCommandedMods()
		local result = ""
		for __, modname in pairs(mods) do
			if result ~= "" then
				result = result .. "; "
			end
			result = result .. modname
		end
		return result
	end)
	
	ChatCommands:addCommand("modcommands", CommandUtilities.modname, "Returns the commanded mods.", {ChatCommands:newArgument("mod", "string", true)}, function(args)
		if args and args[1] and #ChatCommands:modGetCommands(args[1]) > 0 then
			local cmds = ChatCommands:modGetCommands(args[1])
			local result = ""
			for __, cmd in pairs(cmds) do
				if result ~= "" then
					result = result .. "; "
				end
				result = result .. cmd._commandname
			end
			return result
		else
			return "There is no mod called like this. Try /mods"
		end
	end)
end