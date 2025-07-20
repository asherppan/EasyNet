local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

return function(mode)
	if mode == "RemoteEvent" or mode == "UnreliableRemoteEvent" then
		return IsServer and "OnServerEvent" or "OnClientEvent"
	elseif mode == "RemoteFunction" then
		return IsServer and "OnServerInvoke" or "OnClientInvoke"
	elseif mode == "BindableEvent" then
		return "Event"
	elseif mode == "BindableFunction" then
		return "OnInvoke"
	end
end
