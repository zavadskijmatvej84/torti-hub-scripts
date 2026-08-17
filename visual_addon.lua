local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

pcall(function() setthreadidentity(2) end)
local ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)
local Sync = require(game.ReplicatedStorage.Database.Sync)
pcall(function() setthreadidentity(8) end)

local localPlayer = Players.LocalPlayer
if not localPlayer then
	return
end

local function normalizeName(value)
	local s = string.lower(tostring(value or ""))
	s = string.gsub(s, "^c%.?%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.?%s*", "%1chroma ")
	s = string.gsub(s, "[^%w%s]", "")
	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local weaponByKey = {}
local weaponByName = {}

do
	local source = Sync.Weapons or Sync.Item or {}
	for key, data in pairs(source) do
		if type(data) == "table" and (data.ItemType == "Knife" or data.ItemType == "Gun") then
			local entry = {
				key = key,
				name = data.ItemName or key,
				type = data.ItemType,
			}
			weaponByKey[key] = entry
			weaponByName[normalizeName(entry.name)] = entry
			weaponByName[normalizeName(key)] = entry
		end
	end
end

local function resolveWeapon(raw)
	if type(raw) ~= "string" or raw == "" then
		return nil
	end
	return weaponByKey[raw] or weaponByName[normalizeName(raw)]
end

local function scanForEquipped(node, seen, out)
	if type(node) ~= "table" or seen[node] then
		return
	end
	seen[node] = true

	for key, value in pairs(node) do
		local keyText = normalizeName(key)
		if keyText ~= "owned" then
			if type(value) == "string" then
				local entry = resolveWeapon(value)
				if entry then
					out[entry.type] = out[entry.type] or entry
				end
			elseif type(value) == "table" then
				local candidates = {
					value.ItemID,
					value.ItemName,
					value.Name,
					value.Weapon,
					value.Knife,
					value.Gun,
				}
				for _, candidate in ipairs(candidates) do
					local entry = resolveWeapon(candidate)
					if entry then
						out[entry.type] = out[entry.type] or entry
					end
				end
				scanForEquipped(value, seen, out)
			end
		end
	end
end

local function getEquippedWeapons()
	local equipped = {}
	scanForEquipped(ProfileData, {}, equipped)

	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	local containers = { localPlayer.Character, backpack }
	for _, container in ipairs(containers) do
		if container then
			for _, tool in ipairs(container:GetDescendants()) do
				if tool:IsA("Tool") then
					local entry = resolveWeapon(tool.Name)
					if entry then
						equipped[entry.type] = equipped[entry.type] or entry
					end
				end
			end
		end
	end

	return equipped
end

local function getHiddenGui()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return nil
	end

	local gui = playerGui:FindFirstChild("MM2VisualWeaponsAddon")
	if gui then
		return gui
	end

	gui = Instance.new("ScreenGui")
	gui.Name = "MM2VisualWeaponsAddon"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.Size = UDim2.new(0, 220, 0, 220)
	holder.Position = UDim2.new(0, -5000, 0, -5000)
	holder.BackgroundTransparency = 1
	holder.Parent = gui

	return gui
end

local function getRenderTemplate()
	local ok, template = pcall(function()
		return localPlayer.PlayerGui.TradeGUI.Container.Trade.YourOffer.Container.NewItem1
	end)
	if ok then
		return template
	end
	return nil
end

local function buildModel(itemKey)
	local weaponData = Sync.Weapons and Sync.Weapons[itemKey]
	if type(weaponData) ~= "table" then
		return nil
	end

	local gui = getHiddenGui()
	if not gui then
		return nil
	end

	local holder = gui:FindFirstChild("Holder")
	if not holder then
		return nil
	end

	local template = getRenderTemplate()
	if not template then
		return nil
	end

	local frame = template:Clone()
	frame.Visible = true
	frame.Parent = holder

	local payload = {}
	for k, v in pairs(weaponData) do
		payload[k] = v
	end
	payload.DataType = "Weapons"
	payload.Amount = 1

	local ok = pcall(function()
		ItemModule.DisplayItem(frame, payload)
	end)
	if not ok then
		frame:Destroy()
		return nil
	end

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()

	local result = nil
	for _, desc in ipairs(frame:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildWhichIsA("BasePart", true) then
			result = desc:Clone()
			break
		end
	end

	if not result then
		for _, desc in ipairs(frame:GetDescendants()) do
			if desc:IsA("BasePart") then
				local model = Instance.new("Model")
				desc:Clone().Parent = model
				result = model
				break
			end
		end
	end

	frame:Destroy()
	return result
end

local function getRootPart(model)
	if not model then
		return nil
	end
	if model.PrimaryPart and model.PrimaryPart:IsDescendantOf(model) then
		return model.PrimaryPart
	end
	return model:FindFirstChildWhichIsA("BasePart", true)
end

local function attachWeapon(character, weaponType, entry)
	local built = buildModel(entry.key)
	if not built then
		return false
	end

	local root = getRootPart(built)
	if not root then
		built:Destroy()
		return false
	end

	for _, desc in ipairs(built:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
			if desc ~= root then
				local weldInner = Instance.new("WeldConstraint")
				weldInner.Part0 = root
				weldInner.Part1 = desc
				weldInner.Parent = root
			end
		elseif desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			desc:Destroy()
		end
	end

	built.PrimaryPart = root
	built.Name = "MM2Visual_" .. weaponType
	built.Parent = character

	local anchor = character:FindFirstChild("RightHand")
		or character:FindFirstChild("Right Arm")
		or character:FindFirstChild("LeftHand")
		or character:FindFirstChild("Left Arm")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")

	if not anchor then
		built:Destroy()
		return false
	end

	local offset
	if weaponType == "Knife" then
		offset = CFrame.new(0, -0.85, -0.15) * CFrame.Angles(math.rad(-18), math.rad(180), math.rad(95))
	else
		offset = CFrame.new(0, -0.55, -0.2) * CFrame.Angles(math.rad(92), math.rad(8), math.rad(-92))
	end

	built:PivotTo(anchor.CFrame * offset)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = anchor
	weld.Part1 = root
	weld.Parent = root

	return true
end

local function clearCharacterVisuals(character)
	if not character then
		return
	end
	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "MM2Visual_Knife" or child.Name == "MM2Visual_Gun" then
			child:Destroy()
		end
	end
end

local function run()
	local character = localPlayer.Character
	if not character then
		return
	end

	clearCharacterVisuals(character)

	local equipped = getEquippedWeapons()
	if equipped.Knife then
		pcall(function()
			attachWeapon(character, "Knife", equipped.Knife)
		end)
	end
	if equipped.Gun then
		pcall(function()
			attachWeapon(character, "Gun", equipped.Gun)
		end)
	end
end

task.delay(1, run)
localPlayer.CharacterAdded:Connect(function()
	task.delay(1, run)
end)

