local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

return function(mode, all)
	if mode == "RemoteEvent" or mode == "UnreliableRemoteEvent" then
		return IsServer and (all and "FireAllClients" or "FireClient") or "FireServer"
	elseif mode == "RemoteFunction" then
		return IsServer and "InvokeClient" or "InvokeServer"
	elseif mode == "BindableEvent" then
		return "Fire"
	elseif mode == "BindableFunction" then
		return "Invoke"
	end
end
