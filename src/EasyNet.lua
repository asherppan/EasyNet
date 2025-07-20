local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Objects = path.to.networking.objects

local IsServer = RunService:IsServer()

local Sender = require(path.to.sender)
local GetReceive = require(path.to.get.receive)

local function GetLength(t)
	local i = 0
	for _ in t do
		i += 1
	end
	return i
end

local EasyNet = {}
EasyNet.REMOTE_THRESHOLD = 0
EasyNet.Handled = {}
EasyNet.Senders = {}
function EasyNet.getSender(name: string)
	if EasyNet.Senders[name] then
		return EasyNet.Senders[name]
	end
	local sender = Sender.new(name)
	EasyNet.Senders[name] = sender
	return sender
end

for _, object in pairs(Objects:GetChildren()) do
	if GetReceive(object.Name):find("Invoke") then
		if IsServer then
			object[GetReceive(object.Name)] = function(player, name, ...)
				return EasyNet.getSender(name):Receive(object.Name, player, ...)
			end
		else
			object[GetReceive(object.Name)] = function(name, ...)
				local x = EasyNet.getSender(name):Receive(object.Name, ...)
				return x
			end
		end
	else
		if IsServer then
			object[GetReceive(object.Name)]:Connect(function(player, name, ...)
				EasyNet.getSender(name):Receive(object.Name, player, ...)
			end)
		else
			object[GetReceive(object.Name)]:Connect(function(name, ...)
				EasyNet.getSender(name):Receive(object.Name, ...)
			end)
		end
	end
end

if IsServer == false then
	task.spawn(function()
		repeat task.wait() until game:IsLoaded() and GetLength(EasyNet.Senders) > EasyNet.REMOTE_THRESHOLD+1
		EasyNet.getSender("_NETWORK"):FireServer()
	end)
else
	EasyNet.getSender("_NETWORK"):Connect(function(player)
		EasyNet.Handled[player] = true
		player:SetAttribute("_NETWORK", true)
	end)
end

return EasyNet
