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

local globalEnv = getgenv and getgenv() or _G
local previousStop = rawget(globalEnv, "__TortiVisualWeaponsAddonStop")
if type(previousStop) == "function" then
	pcall(previousStop)
end

local state = {
	running = true,
	currentCharacter = nil,
	activeByType = {},
	renderCacheByKey = {},
	renderMissAtByKey = {},
	screenGui = nil,
	statusLabel = nil,
	connections = {},
}

local attachOffsets = {
	KnifeTorso = CFrame.new(0.7, 0.1, 0.35) * CFrame.Angles(math.rad(18), math.rad(8), math.rad(72)),
	KnifeHand = CFrame.new(0, -0.85, -0.15) * CFrame.Angles(math.rad(-18), math.rad(180), math.rad(95)),
	GunTorso = CFrame.new(-0.72, 0.08, 0.3) * CFrame.Angles(math.rad(84), math.rad(-10), math.rad(-92)),
	GunHand = CFrame.new(0, -0.55, -0.2) * CFrame.Angles(math.rad(92), math.rad(8), math.rad(-92)),
}

local equippedPathHints = {
	"equip",
	"equipped",
	"current",
	"selected",
	"slot",
	"hotbar",
	"loadout",
}

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
local weaponByNormalized = {}

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
			weaponByName[string.lower(entry.name)] = entry
			weaponByNormalized[normalizeName(entry.name)] = entry
			weaponByNormalized[normalizeName(key)] = entry
		end
	end
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

local function stopAddon()
	state.running = false

	for _, connection in ipairs(state.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	state.connections = {}

	if state.currentCharacter then
		clearCharacterVisuals(state.currentCharacter)
	end

	if state.screenGui then
		state.screenGui:Destroy()
		state.screenGui = nil
		state.statusLabel = nil
	end
end

globalEnv.__TortiVisualWeaponsAddonStop = stopAddon

local function ensureGui()
	if state.screenGui and state.screenGui.Parent then
		return state.screenGui
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return nil
	end

	local oldGui = playerGui:FindFirstChild("MM2VisualWeaponsAddon")
	if oldGui then
		oldGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MM2VisualWeaponsAddon"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local holder = Instance.new("Frame")
	holder.Name = "HiddenHolder"
	holder.Size = UDim2.new(0, 220, 0, 220)
	holder.Position = UDim2.new(0, -5000, 0, -5000)
	holder.BackgroundTransparency = 1
	holder.Parent = screenGui

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(0, 1)
	status.Position = UDim2.new(0, 12, 1, -12)
	status.Size = UDim2.new(0, 520, 0, 28)
	status.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
	status.BackgroundTransparency = 0.25
	status.BorderSizePixel = 0
	status.Font = Enum.Font.Gotham
	status.TextSize = 13
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextColor3 = Color3.fromRGB(180, 220, 255)
	status.Text = "Visual weapons: starting..."
	status.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = status

	state.screenGui = screenGui
	state.statusLabel = status
	return screenGui
end

local function setStatus(text, color)
	local gui = ensureGui()
	if not gui or not state.statusLabel then
		return
	end

	state.statusLabel.Text = text
	if color then
		state.statusLabel.TextColor3 = color
	end
end

local function resolveWeapon(raw)
	if type(raw) ~= "string" or raw == "" then
		return nil
	end

	return weaponByKey[raw] or weaponByName[string.lower(raw)] or weaponByNormalized[normalizeName(raw)]
end

local function getPathScore(pathText, itemType)
	local normalized = normalizeName(pathText)
	local score = 0

	if normalized == "" then
		return 0
	end

	if string.find(normalized, "owned", 1, true) then
		score = score - 20
	end
	if string.find(normalized, "inventory", 1, true) then
		score = score - 8
	end
	if string.find(normalized, string.lower(itemType), 1, true) then
		score = score + 15
	end
	if string.find(normalized, "weapon", 1, true) then
		score = score + 3
	end

	for _, hint in ipairs(equippedPathHints) do
		if string.find(normalized, hint, 1, true) then
			score = score + 10
		end
	end

	return score
end

local function registerCandidate(bestByType, entry, pathText)
	if not entry or not entry.type then
		return
	end

	local score = getPathScore(pathText, entry.type)
	local current = bestByType[entry.type]
	if not current or score > current.score then
		bestByType[entry.type] = {
			entry = entry,
			score = score,
			path = pathText,
		}
	end
end

local function scanEquipped(node, pathText, depth, seen, bestByType)
	if type(node) ~= "table" or seen[node] or depth > 8 then
		return
	end
	seen[node] = true

	for rawKey, value in pairs(node) do
		local keyText = normalizeName(rawKey)
		local nextPath = pathText ~= "" and (pathText .. " " .. keyText) or keyText

		if keyText ~= "owned" then
			if type(value) == "string" then
				registerCandidate(bestByType, resolveWeapon(value), nextPath)
			elseif type(value) == "table" then
				registerCandidate(bestByType, resolveWeapon(value.ItemID), nextPath .. " itemid")
				registerCandidate(bestByType, resolveWeapon(value.ItemName), nextPath .. " itemname")
				registerCandidate(bestByType, resolveWeapon(value.Name), nextPath .. " name")
				registerCandidate(bestByType, resolveWeapon(value.Weapon), nextPath .. " weapon")
				registerCandidate(bestByType, resolveWeapon(value.Knife), nextPath .. " knife")
				registerCandidate(bestByType, resolveWeapon(value.Gun), nextPath .. " gun")
				scanEquipped(value, nextPath, depth + 1, seen, bestByType)
			end
		end
	end
end

local function scanVisibleTools(bestByType)
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	local character = localPlayer.Character

	if character then
		for _, desc in ipairs(character:GetDescendants()) do
			if desc:IsA("Tool") then
				registerCandidate(bestByType, resolveWeapon(desc.Name), "equipped tool " .. desc.Name)
			end
		end
	end

	if backpack then
		for _, desc in ipairs(backpack:GetDescendants()) do
			if desc:IsA("Tool") then
				registerCandidate(bestByType, resolveWeapon(desc.Name), "backpack tool " .. desc.Name)
			end
		end
	end
end

local function findEquippedWeapons()
	local bestByType = {}
	scanEquipped(ProfileData, "", 0, {}, bestByType)
	scanVisibleTools(bestByType)
	return bestByType
end

local function getHolder()
	local gui = ensureGui()
	if not gui then
		return nil
	end
	return gui:FindFirstChild("HiddenHolder")
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

local function createDisplayFrame()
	local holder = getHolder()
	if not holder then
		return nil
	end

	local template = getRenderTemplate()
	if not template then
		return nil
	end

	local frame = template:Clone()
	frame.Name = "VisualRenderFrame"
	frame.Visible = true
	frame.Parent = holder
	return frame
end

local function extractVisualModel(frame)
	if not frame then
		return nil
	end

	for _, desc in ipairs(frame:GetDescendants()) do
		if desc:IsA("WorldModel") then
			for _, candidate in ipairs(desc:GetChildren()) do
				if candidate:IsA("Model") and candidate:FindFirstChildWhichIsA("BasePart", true) then
					return candidate:Clone()
				end
				if candidate:IsA("BasePart") then
					return candidate:Clone()
				end
			end
		end
	end

	for _, desc in ipairs(frame:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildWhichIsA("BasePart", true) then
			return desc:Clone()
		end
		if desc:IsA("BasePart") then
			return desc:Clone()
		end
	end

	return nil
end

local function ensureModel(instance, name)
	if not instance then
		return nil
	end

	if instance:IsA("Model") then
		instance.Name = name
		return instance
	end

	if instance:IsA("BasePart") then
		local model = Instance.new("Model")
		model.Name = name
		instance.Parent = model
		return model
	end

	instance:Destroy()
	return nil
end

local function buildRenderModel(itemKey)
	local weaponData = Sync.Weapons and Sync.Weapons[itemKey]
	if type(weaponData) ~= "table" then
		return nil
	end

	local frame = createDisplayFrame()
	if not frame then
		return nil
	end

	local payload = {}
	for key, value in pairs(weaponData) do
		payload[key] = value
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
	RunService.Heartbeat:Wait()

	local built = ensureModel(extractVisualModel(frame), "__MM2VisualWeapon_" .. itemKey)
	frame:Destroy()

	if built then
		built.Archivable = true
	end

	return built
end

local function getRenderModel(itemKey)
	local cached = state.renderCacheByKey[itemKey]
	if cached then
		return cached
	end

	local lastMissAt = state.renderMissAtByKey[itemKey]
	if lastMissAt and (tick() - lastMissAt) < 5 then
		return nil
	end

	local built = buildRenderModel(itemKey)
	if built then
		state.renderCacheByKey[itemKey] = built
		state.renderMissAtByKey[itemKey] = nil
	else
		state.renderMissAtByKey[itemKey] = tick()
	end

	return built
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

local function prepareModel(model)
	local root = getRootPart(model)
	if not root then
		return nil
	end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			desc:Destroy()
		elseif desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
			desc.CastShadow = false
			if desc ~= root and not desc:FindFirstChild("MM2VisualInternalWeld") then
				local weld = Instance.new("WeldConstraint")
				weld.Name = "MM2VisualInternalWeld"
				weld.Part0 = root
				weld.Part1 = desc
				weld.Parent = root
			end
		end
	end

	model.PrimaryPart = root
	return root
end

local function getAnchorPart(character, weaponType)
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("LowerTorso")
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")

	if weaponType == "Knife" then
		return torso or rightHand or leftHand
	end

	return torso or leftHand or rightHand
end

local function getOffset(anchorPart, weaponType)
	local name = anchorPart and anchorPart.Name or ""
	local isHand = string.find(name, "Hand", 1, true) ~= nil or string.find(name, "Arm", 1, true) ~= nil

	if weaponType == "Knife" then
		return isHand and attachOffsets.KnifeHand or attachOffsets.KnifeTorso
	end

	return isHand and attachOffsets.GunHand or attachOffsets.GunTorso
end

local function clearVisualForType(weaponType)
	local current = state.activeByType[weaponType]
	if current and current.model then
		current.model:Destroy()
	end
	state.activeByType[weaponType] = nil
end

local function attachWeapon(character, weaponType, entry)
	local sourceModel = getRenderModel(entry.key)
	if not sourceModel then
		return false, "render model not found"
	end

	local anchorPart = getAnchorPart(character, weaponType)
	if not anchorPart then
		return false, "anchor part not found"
	end

	local clone = sourceModel:Clone()
	clone.Name = "MM2Visual_" .. weaponType
	clone.Parent = character

	local root = prepareModel(clone)
	if not root then
		clone:Destroy()
		return false, "model has no parts"
	end

	clone:PivotTo(anchorPart.CFrame * getOffset(anchorPart, weaponType))

	local weld = Instance.new("WeldConstraint")
	weld.Name = "MM2VisualWeaponWeld"
	weld.Part0 = anchorPart
	weld.Part1 = root
	weld.Parent = root

	state.activeByType[weaponType] = {
		key = entry.key,
		model = clone,
	}

	return true
end

local function refresh()
	if not state.running then
		return
	end

	local character = localPlayer.Character
	local statusColor = Color3.fromRGB(180, 220, 255)
	local firstError = nil

	if character ~= state.currentCharacter then
		clearVisualForType("Knife")
		clearVisualForType("Gun")
		state.currentCharacter = character
	end

	if not character or not character.Parent then
		setStatus("Visual weapons: waiting for character", Color3.fromRGB(200, 190, 160))
		return
	end

	local equipped = findEquippedWeapons()
	local statusParts = {}

	for _, weaponType in ipairs({ "Knife", "Gun" }) do
		local candidate = equipped[weaponType]
		local desiredKey = candidate and candidate.entry and candidate.entry.key or nil
		local active = state.activeByType[weaponType]

		if not desiredKey then
			clearVisualForType(weaponType)
			table.insert(statusParts, weaponType .. ": none")
		else
			local needsRebuild = (not active)
				or active.key ~= desiredKey
				or not active.model
				or active.model.Parent ~= character

			if needsRebuild then
				clearVisualForType(weaponType)
				local ok, err = attachWeapon(character, weaponType, candidate.entry)
				if ok then
					table.insert(statusParts, weaponType .. ": " .. tostring(candidate.entry.name))
				else
					table.insert(statusParts, weaponType .. ": failed")
					statusColor = Color3.fromRGB(255, 170, 120)
					firstError = firstError or (weaponType .. " error: " .. tostring(err))
				end
			else
				table.insert(statusParts, weaponType .. ": " .. tostring(candidate.entry.name))
			end
		end
	end

	local statusText = table.concat(statusParts, " | ")
	if firstError then
		statusText = statusText .. " | " .. firstError
	end

	if statusText == "" then
		statusText = "Visual weapons: waiting for equipped knife/gun"
	end

	setStatus(statusText, statusColor)
end

table.insert(state.connections, localPlayer.CharacterAdded:Connect(function()
	task.delay(1, function()
		pcall(refresh)
	end)
end))

task.spawn(function()
	while state.running do
		local ok, err = pcall(refresh)
		if not ok then
			setStatus("Visual weapons error: " .. tostring(err), Color3.fromRGB(255, 170, 120))
		end
		task.wait(0.75)
	end
end)

task.delay(1, function()
	pcall(refresh)
end)
