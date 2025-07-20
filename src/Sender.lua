local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

local EasyNet = script.Parent:WaitForChild("Networking")
local GetMethod = require(script.Parent.GetMethod)

local sender = {}
sender.__index = sender

function sender.new(name: string, mode: string?)
	local self = setmetatable({}, sender)
	self.Name = name
	self.Mode = mode
	self.Connections = {}
	self.Invoked = nil
	self.All = false

	return self
end

function sender:Send(p, ...)
	local all = self.All
	self.All = false
	if self.Mode == nil then
		warn("Sender mode is nil")
		return
	end
	if typeof(p) == "Instance" and p:IsA("Player") and IsServer then
		if p:GetAttribute("_NETWORK") ~= true then
			repeat task.wait() until p:GetAttribute("_NETWORK")
		end
		return EasyNet[self.Mode][GetMethod(self.Mode, all)](EasyNet[self.Mode], p, self.Name, ...)
	else
		return EasyNet[self.Mode][GetMethod(self.Mode, all)](EasyNet[self.Mode], self.Name, p, ...)
	end
end

function sender:Receive(mode, ...)
	self.Mode = mode
	if self.Mode == nil then
		warn("Sender mode is nil")
		return
	end
	if self.Mode:find("Function") and self.Invoked then
		return self.Invoked(...)
	end
	for _, func in pairs(self.Connections) do
		task.spawn(func, ...)
	end
end

function sender:Connect(func)
	table.insert(self.Connections, func)
end

function sender:Disconnect(func)
	if table.find(self.Connections, func) then
		table.remove(self.Connections, table.find(self.Connections, func))
	end
end

function sender:FireServer(...)
	self.Mode = "RemoteEvent"
	self:Send(...)
end

function sender:FireClient(...)
	self.Mode = "RemoteEvent"
	self:Send(...)
end

function sender:FireAllClients(...)
	self.Mode = "RemoteEvent"
	self.All = true
	self:Send(...)
end

function sender:FireAllClientsUR(...)
	self.Mode = "UnreliableRemoteEvent"
	self.All = true
	self:Send(...)
end

function sender:FireClientUR(...)
	self.Mode = "UnreliableRemoteEvent"
	self:Send(...)
end

function sender:FireServerUR(...)
	self.Mode = "UnreliableRemoteEvent"
	self:Send(...)
end

function sender:InvokeClient(...)
	self.Mode = "RemoteFunction"
	return self:Send(...)
end

function sender:InvokeServer(...)
	self.Mode = "RemoteFunction"
	return self:Send(...)
end

function sender:Invoke(...)
	self.Mode = "BindableFunction"
	return self:Send(...)
end

function sender:Fire(...)
	self.Mode = "BindableEvent"
	self:Send(...)
end

return sender
