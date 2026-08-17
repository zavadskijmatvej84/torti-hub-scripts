print("torti smoke test: start")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Torti Smoke Test",
		Text = "Injected successfully",
		Duration = 5,
	})
end)

local ok, err = pcall(function()
	local marker = Instance.new("Folder")
	marker.Name = "TortiSmokeTestMarker"
	marker.Parent = game:GetService("CoreGui")
	task.delay(5, function()
		if marker then
			marker:Destroy()
		end
	end)
end)

if ok then
	print("torti smoke test: marker created")
else
	warn("torti smoke test: marker failed - " .. tostring(err))
end

print("torti smoke test: done")
