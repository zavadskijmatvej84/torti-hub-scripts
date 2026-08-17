-- ============================================================
-- Torti Hub - MM2 Run (Full Script)
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LastTradePartner = nil

local function FormatValue(v)
	if v == nil then return "?" end
	if type(v) == "number" then
		if math.abs(v) < 1 then
			local text = string.format("%.3f", v)
			text = string.gsub(text, "0+$", "")
			text = string.gsub(text, "%.$", "")
			if text == "-0" then
				text = "0"
			end
			return text
		end
		if math.abs(v - math.floor(v)) > 0.000001 then
			local text = string.format("%.3f", v)
			text = string.gsub(text, "0+$", "")
			text = string.gsub(text, "%.$", "")
			return text
		end
		local s = tostring(math.floor(v))
		local k
		repeat s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
		return s
	end
	return tostring(v)
end

local function FormatCatalogValue(v)
	if v == nil then return "?" end
	local numeric = tonumber(v)
	if not numeric then
		return tostring(v)
	end
	if math.abs(numeric - math.floor(numeric)) < 0.000001 and numeric >= 1 then
		return FormatValue(numeric)
	end
	local text = string.format("%.3f", numeric)
	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")
	return text
end

local function NormalizeItemName(value)
	local s = string.lower(tostring(value or ""))
	s = string.gsub(s, "^c%.?%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.?%s*", "%1chroma ")
	s = string.gsub(s, "[^%w%s]", "")
	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local SupremeSnapshotLabel = "August 15, 2026 at 2:00 PM"
local SupremeValueRows = {
	{category = "Unique", name = "Corrupt", value = 410},
	{category = "Vintage", name = "Blood", value = 8},
	{category = "Vintage", name = "Ghost", value = 8},
	{category = "Vintage", name = "Laser", value = 8},
	{category = "Vintage", name = "America", value = 7},
	{category = "Vintage", name = "Prince", value = 6},
	{category = "Vintage", name = "Shadow", value = 6},
	{category = "Vintage", name = "Phaser", value = 5},
	{category = "Vintage", name = "Cowboy", value = 4},
	{category = "Vintage", name = "Golden", value = 4},
	{category = "Vintage", name = "Splitter", value = 3},
	{category = "Ancient", name = "Nik's Scythe", value = "Priceless"},
	{category = "Ancient", name = "Gingerscope", value = 17750},
	{category = "Ancient", name = "Traveler's Axe", value = 8100},
	{category = "Ancient", name = "Celestial", value = 2450},
	{category = "Ancient", name = "Vampire's Axe", value = 1325},
	{category = "Ancient", name = "Harvester", value = 250},
	{category = "Ancient", name = "Icepiercer", value = 160},
	{category = "Ancient", name = "Icebreaker", value = 65},
	{category = "Ancient", name = "Batwing", value = 42},
	{category = "Ancient", name = "Elderwood Scythe", value = 38},
	{category = "Ancient", name = "Swirly Axe", value = 38},
	{category = "Ancient", name = "Hallowscythe", value = 30},
	{category = "Ancient", name = "Logchopper", value = 18},
	{category = "Ancient", name = "Icewing", value = 13},
	{category = "Chroma", name = "Chroma Traveler's Gun", value = 220000},
	{category = "Chroma", name = "Chroma Evergun", value = 75000},
	{category = "Chroma", name = "Chroma Evergreen", value = 48000},
	{category = "Chroma", name = "Chroma Bauble", value = 34000},
	{category = "Chroma", name = "Chroma Vampire's Gun", value = 29000},
	{category = "Chroma", name = "Chroma Constellation", value = 27000},
	{category = "Chroma", name = "Chroma Alienbeam", value = 24000},
	{category = "Chroma", name = "Chroma Raygun", value = 13750},
	{category = "Chroma", name = "Chroma Sunrise", value = 13250},
	{category = "Chroma", name = "Chroma Sunset", value = 9250},
	{category = "Chroma", name = "Chroma Snowcannon", value = 7750},
	{category = "Chroma", name = "Chroma Blizzard", value = 7000},
	{category = "Chroma", name = "Chroma Snowstorm", value = 4250},
	{category = "Chroma", name = "Chroma Heart Wand", value = 4250},
	{category = "Chroma", name = "Chroma Snow Dagger", value = 3250},
	{category = "Chroma", name = "Chroma Watergun", value = 3400},
	{category = "Chroma", name = "Chroma Treat", value = 2300},
	{category = "Chroma", name = "Chroma Sweet", value = 2150},
	{category = "Chroma", name = "Chroma Icecream", value = 1800},
	{category = "Chroma", name = "Chroma Sands", value = 1750},
	{category = "Chroma", name = "Chroma Ornament", value = 1800},
	{category = "Chroma", name = "Chroma Beachy", value = 1650},
	{category = "Chroma", name = "Chroma Darkbringer", value = 65},
	{category = "Chroma", name = "Chroma Lightbringer", value = 60},
	{category = "Chroma", name = "Chroma Luger", value = 50},
	{category = "Chroma", name = "Chroma Candleflame", value = 40},
	{category = "Chroma", name = "Chroma Laser", value = 40},
	{category = "Chroma", name = "Chroma Swirly Gun", value = 38},
	{category = "Chroma", name = "Chroma Elderwood Blade", value = 37},
	{category = "Chroma", name = "Chroma Deathshard", value = 35},
	{category = "Chroma", name = "Chroma Cookiecane", value = 32},
	{category = "Chroma", name = "Chroma Fang", value = 32},
	{category = "Chroma", name = "Chroma Gemstone", value = 32},
	{category = "Chroma", name = "Chroma Shark", value = 32},
	{category = "Chroma", name = "Chroma Slasher", value = 32},
	{category = "Chroma", name = "Chroma Heat", value = 28},
	{category = "Chroma", name = "Chroma Seer", value = 28},
	{category = "Chroma", name = "Chroma Gingerblade", value = 27},
	{category = "Chroma", name = "Chroma Tides", value = 27},
	{category = "Chroma", name = "Chroma Saw", value = 23},
	{category = "Chroma", name = "Chroma Boneblade", value = 22},
	{category = "Godly", name = "Traveler's Gun", value = 5600},
	{category = "Godly", name = "Evergun", value = 3450},
	{category = "Godly", name = "Constellation", value = 2700},
	{category = "Godly", name = "Evergreen", value = 2500},
	{category = "Godly", name = "Turkey", value = 2450},
	{category = "Godly", name = "Alienbeam", value = 2100},
	{category = "Godly", name = "Vampire's Gun", value = 1950},
	{category = "Godly", name = "Darkshot", value = 1800},
	{category = "Godly", name = "Raygun", value = 1800},
	{category = "Godly", name = "Darksword", value = 1750},
	{category = "Godly", name = "Blossom", value = 1370},
	{category = "Godly", name = "Sakura", value = 1360},
	{category = "Godly", name = "Sunrise", value = 1125},
	{category = "Godly", name = "Snowcannon", value = 850},
	{category = "Godly", name = "Bauble", value = 825},
	{category = "Godly", name = "Sunset", value = 625},
	{category = "Godly", name = "Soul", value = 615},
	{category = "Godly", name = "Spirit", value = 605},
	{category = "Godly", name = "Rainbow Gun", value = 420},
	{category = "Godly", name = "Flora", value = 410},
	{category = "Godly", name = "Rainbow", value = 410},
	{category = "Godly", name = "Bloom", value = 400},
	{category = "Godly", name = "Heart Wand", value = 340},
	{category = "Godly", name = "Ocean", value = 285},
	{category = "Godly", name = "Waves", value = 280},
	{category = "Godly", name = "Xenoknife", value = 285},
	{category = "Godly", name = "Iceblaster", value = 33},
	{category = "Godly", name = "Frostbite", value = 7},
	{category = "Godly", name = "Icecream", value = 130},
	{category = "Common", name = "Bells", value = "x2 T1 Commons"},
	{category = "Common", name = "Snowfall", value = "x2 T1 Commons"},
	{category = "Uncommon", name = "Ghostly", value = "x2 T1 Uncommons"},
}

local SupremeAliases = {
	["c travelers gun"] = "Chroma Traveler's Gun",
	["c vampires gun"] = "Chroma Vampire's Gun",
	["c constellation"] = "Chroma Constellation",
	["c elderwood blade"] = "Chroma Elderwood Blade",
	["c swirly gun"] = "Chroma Swirly Gun",
	["chroma swirlygun"] = "Chroma Swirly Gun",
	["swirly gun"] = "Swirlygun",
	["niks scythe"] = "Nik's Scythe",
}

local SupremeValuesByKey = {}
for _, row in ipairs(SupremeValueRows) do
	SupremeValuesByKey[NormalizeItemName(row.name)] = row
end
for alias, targetName in pairs(SupremeAliases) do
	local target = SupremeValuesByKey[NormalizeItemName(targetName)]
	if target then
		SupremeValuesByKey[NormalizeItemName(alias)] = target
	end
end

local function GetSupremeValue(name)
	return SupremeValuesByKey[NormalizeItemName(name)]
end

pcall(function() setthreadidentity(2) end)
local ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)
local Sync = require(game.ReplicatedStorage.Database.Sync)
local ItemPopupService = require(game.ReplicatedStorage.ClientServices.ItemPopupService)
pcall(function() setthreadidentity(8) end)

local TradeRemotes = game.ReplicatedStorage.Trade
local TradeGUI = game.Players.LocalPlayer.PlayerGui.TradeGUI
local TheirOffer = TradeGUI.Container.Trade.TheirOffer
local YourOffer = TradeGUI.Container.Trade.YourOffer

local SearchTextSignal
local TradeInventory
local functions = {}

local Config = {
	item = "",
	in_trade = false,
	player2 = nil
}

-- === Weapon Catalog ===
local WeaponCatalog = {}
local WeaponByKey = {}
local WeaponByName = {}
local RareWeaponKeys = {}
local RareRarities = { Godly = true, Ancient = true, Unique = true, Chroma = true, Legendary = true, Classic = true }

do
	local source = Sync.Weapons or Sync.Item
	for key, data in pairs(source) do
		if type(data) == "table" and (data.ItemType == "Knife" or data.ItemType == "Gun") then
			local rarity = data.Rarity or "Common"
			local isChroma = data.Chroma == true
			local effectiveRarity = isChroma and "Chroma" or rarity
			local entry = {
				key = key,
				name = data.ItemName or key,
				rarity = effectiveRarity,
				type = data.ItemType,
				chroma = isChroma,
			}
			table.insert(WeaponCatalog, entry)
			WeaponByKey[key] = entry
			WeaponByName[string.lower(entry.name)] = entry
			if RareRarities[effectiveRarity] then
				table.insert(RareWeaponKeys, key)
			end
		end
	end
	local rarityOrder = {
		Chroma = 1, Godly = 2, Ancient = 3, Unique = 4, Legendary = 5, Classic = 6,
		Vintage = 7, Rare = 8, Uncommon = 9, Common = 10,
	}
	table.sort(WeaponCatalog, function(a, b)
		local ra = rarityOrder[a.rarity] or 99
		local rb = rarityOrder[b.rarity] or 99
		if ra ~= rb then return ra < rb end
		if a.type ~= b.type then return a.type < b.type end
		return a.name < b.name
	end)
end

-- === Basic item checks ===
local InventoryOverlayTypes = {
	Weapons = true,
	Pets = true,
}

local InventoryOverlayState = {
	baseByType = {},
	deltaByType = {},
	shadowByType = {},
}

local function NormalizeOwnedAmount(value)
	local numeric = tonumber(value)
	if numeric then
		return math.max(0, math.floor(numeric + 0.00001))
	end
	if value == nil then
		return 0
	end
	return 1
end

local function CopyOwnedCounts(source)
	local copy = {}
	if type(source) ~= "table" then
		return copy
	end
	for key, value in pairs(source) do
		if type(key) == "string" then
			local amount = NormalizeOwnedAmount(value)
			if amount > 0 then
				copy[key] = amount
			end
		end
	end
	return copy
end

local function GetOwnedBucket(itemType)
	if not ProfileData[itemType] then
		ProfileData[itemType] = {}
	end
	if type(ProfileData[itemType].Owned) ~= "table" then
		ProfileData[itemType].Owned = {}
	end
	return ProfileData[itemType].Owned
end

local function AnalyzeOwnedCounts(itemType)
	local stringCounts = {}
	local listCounts = {}
	local owned = ProfileData[itemType] and ProfileData[itemType].Owned
	if type(owned) ~= "table" then
		return stringCounts, listCounts
	end

	for key, value in pairs(owned) do
		if type(key) == "string" then
			local amount = NormalizeOwnedAmount(value)
			if amount > 0 then
				stringCounts[key] = (stringCounts[key] or 0) + amount
			end
		elseif type(value) == "string" and value ~= "" then
			listCounts[value] = (listCounts[value] or 0) + 1
		elseif type(value) == "table" then
			local itemName = value.Name or value.ItemName or value.Key or value.Id
			if type(itemName) == "string" and itemName ~= "" then
				local amount = NormalizeOwnedAmount(value.Amount or value.Count or value.Quantity or 1)
				if amount > 0 then
					listCounts[itemName] = (listCounts[itemName] or 0) + amount
				end
			end
		end
	end

	return stringCounts, listCounts
end

local function BuildBaseSnapshot(itemType)
	local base = {}
	local stringCounts, listCounts = AnalyzeOwnedCounts(itemType)

	for itemName, amount in pairs(stringCounts) do
		base[itemName] = {
			stringAmount = amount,
			listAmount = listCounts[itemName] or 0,
		}
	end

	for itemName, amount in pairs(listCounts) do
		if not base[itemName] then
			base[itemName] = {
				stringAmount = 0,
				listAmount = amount,
			}
		end
	end

	return base
end

local function GetOverlayBase(itemType)
	if not InventoryOverlayState.baseByType[itemType] then
		InventoryOverlayState.baseByType[itemType] = BuildBaseSnapshot(itemType)
	end
	return InventoryOverlayState.baseByType[itemType]
end

local function GetOverlayDelta(itemType)
	if not InventoryOverlayState.deltaByType[itemType] then
		InventoryOverlayState.deltaByType[itemType] = {}
	end
	return InventoryOverlayState.deltaByType[itemType]
end

local function GetOverlayShadow(itemType)
	if not InventoryOverlayState.shadowByType[itemType] then
		InventoryOverlayState.shadowByType[itemType] = {}
	end
	return InventoryOverlayState.shadowByType[itemType]
end

local function FireInventoryDataChanged()
	pcall(function()
		game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()
	end)
end

local function GetBaseEntryAmounts(itemType, itemName)
	local entry = GetOverlayBase(itemType)[itemName]
	if not entry then
		return 0, 0
	end
	return entry.stringAmount or 0, entry.listAmount or 0
end

local function GetVisibleAmountFromParts(baseStringAmount, baseListAmount, deltaAmount)
	return baseListAmount + math.max(0, baseStringAmount + (deltaAmount or 0))
end

local function BuildOverlayVisibleCounts(itemType)
	local visible = {}
	local seen = {}
	local base = GetOverlayBase(itemType)
	local delta = GetOverlayDelta(itemType)

	local function visit(itemName)
		if seen[itemName] then
			return
		end
		seen[itemName] = true

		local baseStringAmount, baseListAmount = GetBaseEntryAmounts(itemType, itemName)
		local visibleAmount = GetVisibleAmountFromParts(baseStringAmount, baseListAmount, delta[itemName] or 0)
		if visibleAmount > 0 then
			visible[itemName] = visibleAmount
		end
	end

	for itemName in pairs(base) do
		visit(itemName)
	end
	for itemName in pairs(delta) do
		visit(itemName)
	end

	return visible
end

local function ApplyOverlayForType(itemType)
	if not InventoryOverlayTypes[itemType] then
		return
	end

	local owned = GetOwnedBucket(itemType)
	local base = GetOverlayBase(itemType)
	local delta = GetOverlayDelta(itemType)
	local previousShadow = GetOverlayShadow(itemType)
	local nextShadow = {}
	local seen = {}

	local function visit(itemName)
		if seen[itemName] then
			return
		end
		seen[itemName] = true

		local baseStringAmount = 0
		local entry = base[itemName]
		if entry then
			baseStringAmount = entry.stringAmount or 0
		end

		local targetStringAmount = math.max(0, baseStringAmount + (delta[itemName] or 0))
		if targetStringAmount > 0 then
			owned[itemName] = targetStringAmount
			nextShadow[itemName] = targetStringAmount
		else
			owned[itemName] = nil
		end
	end

	for itemName in pairs(base) do
		visit(itemName)
	end
	for itemName in pairs(delta) do
		visit(itemName)
	end
	for itemName in pairs(previousShadow) do
		visit(itemName)
	end

	InventoryOverlayState.shadowByType[itemType] = nextShadow
end

local function ApplyOverlayForAllTypes(shouldFire)
	for itemType in pairs(InventoryOverlayTypes) do
		ApplyOverlayForType(itemType)
	end
	if shouldFire then
		FireInventoryDataChanged()
	end
end

local function SyncOverlayBaseForType(itemType)
	if not InventoryOverlayTypes[itemType] then
		return false
	end

	local currentString, currentList = AnalyzeOwnedCounts(itemType)
	local base = GetOverlayBase(itemType)
	local delta = GetOverlayDelta(itemType)
	local shadow = GetOverlayShadow(itemType)
	local nextBase = {}
	local changed = false
	local seen = {}

	local function visit(map)
		for itemName in pairs(map) do
			if not seen[itemName] then
				seen[itemName] = true
				local currentStringAmount = currentString[itemName] or 0
				local currentListAmount = currentList[itemName] or 0
				local baseEntry = base[itemName] or {}
				local nextStringAmount = baseEntry.stringAmount or 0
				local nextListAmount = baseEntry.listAmount or 0
				local shadowStringAmount = shadow[itemName]
				if shadowStringAmount == nil then
					shadowStringAmount = nextStringAmount
				end

				if currentStringAmount ~= shadowStringAmount then
					nextStringAmount = currentStringAmount
				end
				if currentListAmount ~= nextListAmount then
					nextListAmount = currentListAmount
				end

				if nextStringAmount ~= (baseEntry.stringAmount or 0) or nextListAmount ~= (baseEntry.listAmount or 0) then
					changed = true
				end

				if nextStringAmount > 0 or nextListAmount > 0 or (delta[itemName] or 0) ~= 0 then
					nextBase[itemName] = {
						stringAmount = nextStringAmount,
						listAmount = nextListAmount,
					}
				end
			end
		end
	end

	visit(currentString)
	visit(currentList)
	visit(base)
	visit(delta)
	visit(shadow)

	InventoryOverlayState.baseByType[itemType] = nextBase

	return changed
end

local function SyncOverlayBaseFromProfile()
	local changed = false
	for itemType in pairs(InventoryOverlayTypes) do
		if SyncOverlayBaseForType(itemType) then
			changed = true
		end
	end
	if changed then
		ApplyOverlayForAllTypes(true)
	end
	return changed
end

local function GetVisibleOwnedAmount(itemType, itemName)
	SyncOverlayBaseFromProfile()
	local baseStringAmount, baseListAmount = GetBaseEntryAmounts(itemType, itemName)
	return GetVisibleAmountFromParts(baseStringAmount, baseListAmount, GetOverlayDelta(itemType)[itemName] or 0)
end

local function AdjustVisibleOwnedAmount(itemName, amountDelta, itemType, shouldFire)
	itemType = itemType or "Weapons"
	amountDelta = math.floor(tonumber(amountDelta) or 0)
	if amountDelta == 0 then
		return GetVisibleOwnedAmount(itemType, itemName)
	end

	SyncOverlayBaseFromProfile()

	local delta = GetOverlayDelta(itemType)
	local baseStringAmount, baseListAmount = GetBaseEntryAmounts(itemType, itemName)
	local currentVisible = GetVisibleAmountFromParts(baseStringAmount, baseListAmount, delta[itemName] or 0)
	local nextVisible = math.max(0, currentVisible + amountDelta)
	local targetStringAmount = math.max(0, nextVisible - baseListAmount)
	local nextDelta = targetStringAmount - baseStringAmount

	if nextDelta ~= 0 then
		delta[itemName] = nextDelta
	else
		delta[itemName] = nil
	end

	ApplyOverlayForType(itemType)
	if shouldFire ~= false then
		FireInventoryDataChanged()
	end

	return nextVisible
end

local function SetVisibleOwnedSnapshot(itemType, targetCounts, shouldFire)
	itemType = itemType or "Weapons"
	SyncOverlayBaseFromProfile()

	local base = GetOverlayBase(itemType)
	local nextDelta = {}
	local cleanTarget = CopyOwnedCounts(targetCounts)
	local seen = {}

	for itemName, targetAmount in pairs(cleanTarget) do
		seen[itemName] = true
		local baseStringAmount, baseListAmount = GetBaseEntryAmounts(itemType, itemName)
		local targetStringAmount = math.max(0, targetAmount - baseListAmount)
		local diff = targetStringAmount - baseStringAmount
		if diff ~= 0 then
			nextDelta[itemName] = math.floor(diff)
		end
	end

	for itemName in pairs(base) do
		if not seen[itemName] then
			local baseStringAmount = GetBaseEntryAmounts(itemType, itemName)
			local diff = -baseStringAmount
			if diff ~= 0 then
				nextDelta[itemName] = diff
			end
		end
	end

	InventoryOverlayState.deltaByType[itemType] = nextDelta
	ApplyOverlayForType(itemType)
	if shouldFire ~= false then
		FireInventoryDataChanged()
	end
end

for itemType in pairs(InventoryOverlayTypes) do
	InventoryOverlayState.baseByType[itemType] = BuildBaseSnapshot(itemType)
	InventoryOverlayState.deltaByType[itemType] = {}
	InventoryOverlayState.shadowByType[itemType] = {}
end

task.spawn(function()
	while task.wait(0.5) do
		pcall(SyncOverlayBaseFromProfile)
	end
end)

local function CheckForItem(ItemName, Type)
	local amount = GetVisibleOwnedAmount(Type, ItemName)
	if amount > 0 then
		return true, amount
	end
	return false
end

local v18 = {}
local function v22(v19)
	for _, v21 in pairs(v19:GetChildren()) do
		if v21:IsA("Frame") then
			v21.Visible = false
			if v18[v21] then
				v18[v21]:Disconnect()
				v18[v21] = nil
			end
		end
	end
end

local CurrencyScanBlockedBranches = {
	weapons = true,
	pets = true,
	effects = true,
	radios = true,
	emotes = true,
	powers = true,
	perks = true,
	crafting = true,
	inventory = true,
	trade = true,
	trading = true,
	settings = true,
	music = true,
}

local CurrencyStatKeys = {
	level = true,
	xp = true,
	experience = true,
	exp = true,
	prestige = true,
	tier = true,
	rank = true,
	index = true,
	id = true,
	chance = true,
	progress = true,
	timer = true,
	time = true,
	streak = true,
}

local CurrencyGenericAmountKeys = {
	amount = true,
	count = true,
	total = true,
	balance = true,
	owned = true,
	value = true,
}

local CurrencyKeywordFragments = {
	"currenc",
	"coin",
	"gem",
	"token",
	"candy",
	"candies",
	"shell",
	"beach",
	"pumpkin",
	"heart",
	"egg",
	"snow",
	"harvest",
	"star",
	"gingerbread",
	"gift",
	"shard",
	"flake",
	"crown",
	"key",
}

local function PathSegments(path)
	local parts = {}
	for segment in string.gmatch(tostring(path or ""), "[^ ]+") do
		table.insert(parts, segment)
	end
	return parts
end

local function PathContainsBlockedCurrencyBranch(path)
	for _, segment in ipairs(PathSegments(path)) do
		if CurrencyScanBlockedBranches[segment] then
			return true
		end
	end
	return false
end

local function PathLooksCurrencyLike(path)
	local text = NormalizeItemName(path)
	for _, fragment in ipairs(CurrencyKeywordFragments) do
		if string.find(text, fragment, 1, true) then
			return true
		end
	end
	return false
end

local function PrettifyCurrencyLabel(text)
	local normalized = NormalizeItemName(text)
	if normalized == "" then
		return "Unknown"
	end

	return (string.gsub(normalized, "(%a)([%w]*)", function(first, rest)
		return string.upper(first) .. rest
	end))
end

local function ResolveCurrencyLabel(rawKey, path)
	local keyText = NormalizeItemName(rawKey)
	if not CurrencyGenericAmountKeys[keyText] then
		return PrettifyCurrencyLabel(rawKey)
	end

	local parts = PathSegments(path)
	for i = #parts - 1, 1, -1 do
		local segment = parts[i]
		if not CurrencyGenericAmountKeys[segment] then
			return PrettifyCurrencyLabel(segment)
		end
	end

	return PrettifyCurrencyLabel(rawKey)
end

local function AddCurrencyRecord(out, rawKey, path, amount)
	if type(amount) ~= "number" or amount == 0 then
		return
	end

	local label = ResolveCurrencyLabel(rawKey, path)
	local key = NormalizeItemName(label)
	if key == "" then
		return
	end

	local existing = out[key]
	if not existing then
		existing = {
			label = label,
			amount = 0,
			path = path,
		}
		out[key] = existing
	end

	existing.amount = existing.amount + amount
end

local function ShouldTreatAsCurrency(path, rawKey)
	local keyText = NormalizeItemName(rawKey)
	local normalizedPath = NormalizeItemName(path)
	local pathParts = PathSegments(normalizedPath)
	local parentPath = table.concat(pathParts, " ", 1, math.max(#pathParts - 1, 0))

	if PathContainsBlockedCurrencyBranch(normalizedPath) then
		return false
	end

	if CurrencyStatKeys[keyText] and not PathLooksCurrencyLike(parentPath) then
		return false
	end

	if PathLooksCurrencyLike(normalizedPath) or PathLooksCurrencyLike(parentPath) then
		return true
	end

	if #pathParts <= 2 and not CurrencyStatKeys[keyText] then
		return true
	end

	return false
end

local function HarvestCurrenciesRecursive(node, out, seen, depth, path)
	if type(node) ~= "table" or seen[node] or depth > 6 then
		return
	end
	seen[node] = true

	for rawKey, value in pairs(node) do
		local keyText = NormalizeItemName(rawKey)
		local nextPath = path ~= "" and (path .. " " .. keyText) or keyText

		if type(value) == "number" then
			if ShouldTreatAsCurrency(nextPath, rawKey) then
				AddCurrencyRecord(out, rawKey, nextPath, value)
			end
		elseif type(value) == "table" then
			if not PathContainsBlockedCurrencyBranch(nextPath) then
				HarvestCurrenciesRecursive(value, out, seen, depth + 1, nextPath)
			end
		end
	end
end

local function ScanProfileCurrencies(profile)
	local out = {}
	HarvestCurrenciesRecursive(profile, out, {}, 0, "")
	return out
end

local VisiblePlayerCurrencyNames = {
	coins = true,
	coin = true,
	gems = true,
	gem = true,
	tokens = true,
	token = true,
	gold = true,
	candy = true,
	candies = true,
	snowtokens = true,
	snowtoken = true,
	beachballs = true,
	beachball = true,
	eggs = true,
	egg = true,
	shards = true,
	shard = true,
	credits = true,
	credit = true,
	keys = true,
	key = true,
}

local function GetNumericValue(instance)
	if instance:IsA("IntValue") or instance:IsA("NumberValue") then
		return instance.Value
	end
	return nil
end

local function CollectLocalCurrencyRows()
	local scanned = ScanProfileCurrencies(ProfileData or {})
	local rows = {}
	for _, entry in pairs(scanned) do
		if type(entry) == "table" then
			table.insert(rows, entry)
		end
	end

	table.sort(rows, function(a, b)
		if a.amount ~= b.amount then
			return a.amount > b.amount
		end
		return a.label < b.label
	end)

	return rows
end

local function ScanPlayerVisibleCurrencies(targetPlayer)
	local found = {}
	if not targetPlayer then
		return found
	end

	local function addRecord(name, value)
		if type(value) ~= "number" then
			return
		end
		local normalized = NormalizeItemName(name)
		if normalized == "" or not VisiblePlayerCurrencyNames[normalized] then
			return
		end

		local existing = found[normalized]
		if not existing or value > existing.value then
			found[normalized] = {
				label = PrettifyCurrencyLabel(name),
				value = value,
			}
		end
	end

	local leaderstats = targetPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		for _, child in ipairs(leaderstats:GetChildren()) do
			local numeric = GetNumericValue(child)
			if type(numeric) == "number" then
				found["leaderstats_" .. string.lower(child.Name)] = {
					label = child.Name,
					value = numeric,
				}
			end
		end
	end

	for attrName, attrValue in pairs(targetPlayer:GetAttributes()) do
		addRecord(attrName, attrValue)
	end

	for _, desc in ipairs(targetPlayer:GetDescendants()) do
		addRecord(desc.Name, GetNumericValue(desc))
	end

	return found
end

local function GetPlayerCurrencyAmount(targetPlayer)
	local bestValue = nil
	for _, entry in pairs(ScanPlayerVisibleCurrencies(targetPlayer)) do
		if type(entry.value) == "number" and (bestValue == nil or entry.value > bestValue) then
			bestValue = entry.value
		end
	end
	return bestValue
end

local function GetPlayerCurrencyDisplay(targetPlayer)
	local amount = GetPlayerCurrencyAmount(targetPlayer)
	if amount == nil then
		return "?"
	end
	return FormatValue(amount)
end

local function GetComparablePlayerCurrency(targetPlayer)
	local amount = GetPlayerCurrencyAmount(targetPlayer)
	if amount == nil then
		return -1
	end
	return amount
end

local function GetComparableSupremeValue(value)
	if value == "Priceless" then
		return math.huge
	end
	if type(value) == "number" then
		return value
	end
	return -1
end

-- === Trade Table ===
local TradeTable = {
	LastOffer = os.time(),
	Locked = false,
	Player1 = {
		Player = game.Players.LocalPlayer,
		Accepted = false,
		Offer = {}
	},
	Player2 = {
		Player = "m0_3a",
		Accepted = false,
		Offer = {}
	},
}

-- === Spawn / Give / Remove ===
local function SpawnItem(ItemName, Amount, ItemType)
	Amount = Amount or 1
	ItemType = ItemType or "Weapons"
	pcall(function()
		AdjustVisibleOwnedAmount(ItemName, Amount, ItemType, true)
	end)
end

local function GiveItem(ItemName, Amount, ItemType)
	Amount = Amount or 1
	ItemType = ItemType or "Weapons"
	pcall(function()
		AdjustVisibleOwnedAmount(ItemName, Amount, ItemType, true)
		ItemPopupService.ItemReceived:Fire(ItemName, ItemType)
	end)
end

local function RemoveItem(ItemName, Amount, ItemType)
	Amount = Amount or 1
	ItemType = ItemType or "Weapons"
	pcall(function()
		local owned = GetVisibleOwnedAmount(ItemType, ItemName)
		if not owned then
			print("doesn't have the item")
			return
		end
		if owned <= 0 then
			print("doesn't have the item")
			return
		end
		AdjustVisibleOwnedAmount(ItemName, -Amount, ItemType, true)
	end)
end

-- === Accept Trade ===
local function AcceptTrade()
	if not TradeTable then return end
	if TradeTable.Player1.Accepted == true and TradeTable.Player2.Accepted == true then
		TradeTable.Locked = true
		task.wait(0.2)

		if TradeTable.Player1.Offer and next(TradeTable.Player1.Offer) ~= nil then
			for _, item in pairs(TradeTable.Player1.Offer) do
				local itemName = item[1]
				local amount = item[2]
				local itemType = item[3]
				pcall(function() RemoveItem(itemName, amount, itemType) end)
			end
		end

		if TradeTable.Player2.Offer and next(TradeTable.Player2.Offer) ~= nil then
			for _, item in pairs(TradeTable.Player2.Offer) do
				local itemName = item[1]
				local amount = item[2]
				local itemType = item[3]
				pcall(function() GiveItem(itemName, amount, itemType) end)
				pcall(function() _G.NewItem(itemName, "You Got...", nil, itemType, amount) end)
			end
		end

		pcall(function() TradeGUI.Enabled = false end)

		local partner = "m0_3a"
		if TradeTable.Player2 and TradeTable.Player2.Player then
			partner = TradeTable.Player2.Player
		end

		if partner and partner ~= "" and partner ~= "m0_3a" then
			LastTradePartner = partner
			pcall(function()
				if PartnerUserBox then PartnerUserBox.Text = partner end
			end)
		end

		TradeTable = {
			LastOffer = os.time(),
			Locked = false,
			Player1 = {
				Player = game.Players.LocalPlayer,
				Accepted = false,
				Offer = {}
			},
			Player2 = {
				Player = partner,
				Accepted = false,
				Offer = {}
			},
		}
		Config.in_trade = false
	end
end

local v84 = false

-- === Offer / Remove local player ===
local function OfferItemLocalPlayer(ItemName, ItemType)
	if not TradeTable then return end
	if TradeTable.Locked == true then return end

	local AlreadyOffered = 0
	for _, Item in pairs(TradeTable.Player1.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			AlreadyOffered = Item[2]
		end
	end

	local HasItem, Amount = CheckForItem(ItemName, ItemType)
	if HasItem and Amount - AlreadyOffered > 0 then
		if AlreadyOffered == 0 then
			if #TradeTable.Player1.Offer < 4 then
				table.insert(TradeTable.Player1.Offer, {ItemName, 1, ItemType})
			end
		else
			for Index, Item in pairs(TradeTable.Player1.Offer) do
				if Item[1] == ItemName then
					TradeTable.Player1.Offer[Index][2] = TradeTable.Player1.Offer[Index][2] + 1
					break
				end
			end
		end
	end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false
	pcall(function() functions.UpdateTrade() end)
end

local function RemoveItemLocalPlayer(ItemName, ItemType)
	if not TradeTable then return end
	if TradeTable.Locked == true then return end
	if TradeTable.Player1.Accepted then return end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false

	for Index, Item in pairs(TradeTable.Player1.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			TradeTable.Player1.Offer[Index][2] = TradeTable.Player1.Offer[Index][2] - 1
			if TradeTable.Player1.Offer[Index][2] <= 0 then
				table.remove(TradeTable.Player1.Offer, Index)
			end
			break
		end
	end
	pcall(function() functions.UpdateTrade() end)
end

-- === Offer / Remove another player ===
local function FindItemInDatabase(itemName, itemType)
	if not Sync[itemType] then return nil end
	if Sync[itemType][itemName] then
		return itemName, Sync[itemType][itemName]
	end
	return nil, nil
end

local function OfferItemAnotherPlayer(ItemName, ItemType)
	if not ItemName or ItemName == "" then return false end
	if not TradeTable then return false end
	if TradeTable.Locked == true then return false end

	if #TradeTable.Player2.Offer >= 4 then
		local foundExisting = false
		for _, Item in pairs(TradeTable.Player2.Offer) do
			if Item[1] == ItemName and Item[3] == ItemType then
				foundExisting = true
				break
			end
		end
		if not foundExisting then return false end
	end

	local AlreadyOffered = 0
	for _, Item in pairs(TradeTable.Player2.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			AlreadyOffered = Item[2]
		end
	end

	if AlreadyOffered == 0 then
		table.insert(TradeTable.Player2.Offer, {ItemName, 1, ItemType})
	else
		for Index, Item in pairs(TradeTable.Player2.Offer) do
			if Item[1] == ItemName and Item[3] == ItemType then
				TradeTable.Player2.Offer[Index][2] = TradeTable.Player2.Offer[Index][2] + 1
				break
			end
		end
	end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false
	pcall(function() functions.UpdateTrade() end)
	return true
end

local function RemoveItemAnotherPlayer()
	if not TradeTable then return end
	if not TradeTable.Player2 then return end
	if not TradeTable.Player2.Offer then return end

	if #TradeTable.Player2.Offer > 0 then
		if TradeTable.Player2.Accepted then return end

		local LastIndex = #TradeTable.Player2.Offer
		TradeTable.Player2.Offer[LastIndex][2] = TradeTable.Player2.Offer[LastIndex][2] - 1
		if TradeTable.Player2.Offer[LastIndex][2] <= 0 then
			table.remove(TradeTable.Player2.Offer, LastIndex)
		end

		TradeTable.LastOffer = os.time()
		TradeTable.Player1.Accepted = false
		TradeTable.Player2.Accepted = false
		pcall(function() functions.UpdateTrade() end)
	end
end

-- === Display items in trade GUI ===
local function v34(v23, v24)
	for v25, v26 in pairs(v24) do
		local ItemID = v26[1] or v26.ItemID
		local Amount = v26[2] or v26.Amount
		local ItemType = v26[3] or v26.ItemType

		local v33 = v23.Container["NewItem" .. v25]
		if not v33 then continue end

		local success = pcall(function()
			if Sync[ItemType] and Sync[ItemType][ItemID] then
				local v30 = {}
				for v31, v32 in pairs(Sync[ItemType][ItemID]) do
					v30[v31] = v32
				end
				v30.DataType = ItemType
				v30.Amount = Amount
				ItemModule.DisplayItem(v33, v30)
			end
		end)

		pcall(function()
			if v18[v33] then
				v18[v33]:Disconnect()
			end
			if v33.Container and v33.Container:FindFirstChild("ActionButton") then
				v18[v33] = v33.Container.ActionButton.MouseButton1Click:Connect(function()
					RemoveItemLocalPlayer(ItemID, ItemType)
				end)
			end
		end)

		v33.Visible = true
	end
end

-- === Cooldown ===
local v85 = 6
local function ResetCooldown(arg1)
	if arg1 then
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false
		v85 = 0
		v84 = false
		return
	else
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true
		v85 = 6
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."
		if not v84 then
			TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true
			v84 = true
			repeat
				wait(1)
				v85 = v85 - 1
				TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."
			until v85 <= 0
			v84 = false
			TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false
			return
		else
			v85 = 6
			return
		end
	end
end

-- === Update trade inventory ===
local function UpdateTradeInventory()
	pcall(function()
		if not TradeInventory or not TradeInventory.Data then return end
		local l_Offer_2 = TradeTable.Player1.Offer
		for v63, v64 in pairs(TradeInventory.Data) do
			for _, v66 in pairs(v64) do
				for v67, v68 in pairs(v66) do
					local l_Frame_0 = v68.Frame
					local l_Amount_0 = v68.Amount
					for _, v72 in pairs(l_Offer_2) do
						local v73 = v72[1] or v72.ItemID
						local v74 = v72[2] or v72.Amount
						local v75 = v72[3] or v72.ItemType
						if v73 == v67 and v75 == v63 then
							l_Amount_0 = l_Amount_0 - v74
						end
					end
					if l_Amount_0 == 1 then
						l_Frame_0.Container.Amount.Text = ""
						l_Frame_0.Visible = true
					elseif l_Amount_0 > 1 then
						l_Frame_0.Container.Amount.Text = "x" .. l_Amount_0
						l_Frame_0.Visible = true
					elseif l_Amount_0 < 1 then
						l_Frame_0.Visible = false
					end
				end
			end
		end
	end)
end

local v35 = "Accept"
functions.UpdateTrade = function()
	pcall(function()
		local Offer1 = TradeTable.Player1.Offer
		local Offer2 = TradeTable.Player2.Offer

		v22(YourOffer.Container)
		v22(TheirOffer.Container)

		v34(YourOffer, Offer1)
		v34(TheirOffer, Offer2)

		v35 = "Accept"

		TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = false
		TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = false
		YourOffer.Accepted.Visible = false
		TheirOffer.Accepted.Visible = false

		local l_AddItem_0 = TradeGUI.Container.Trade.Actions.Accept.AddItem
		local v44 = false
		if #Offer1 < 1 then
			v44 = #Offer2 < 1
		end
		l_AddItem_0.Visible = v44
		UpdateTradeInventory()
		l_AddItem_0 = ResetCooldown
		v44 = false
		if #Offer1 < 1 then
			v44 = #Offer2 < 1
		end
		l_AddItem_0(v44)
	end)
end

function DeclineTrade()
	pcall(function() TradeGUI.Enabled = false end)

	local partner = "m0_3a"
	if TradeTable and TradeTable.Player2 and TradeTable.Player2.Player then
		partner = TradeTable.Player2.Player
	end

	TradeTable = {
		LastOffer = os.time(),
		Locked = false,
		Player1 = {
			Player = game.Players.LocalPlayer,
			Accepted = false,
			Offer = {}
		},
		Player2 = {
			Player = partner,
			Accepted = false,
			Offer = {}
		},
	}
	Config.in_trade = false
	pcall(function() UnConnections() end)
end

local v87 = time()
local Connections = {}

function SetupConnections(v76)
	pcall(function()
		if v76 and v76.Data then
			for v77, v78 in pairs(v76.Data) do
				for _, v80 in pairs(v78) do
					for v81, v82 in pairs(v80) do
						local l_Frame_1 = v82.Frame
						if l_Frame_1 then
							Connections.Connection0 = l_Frame_1.Container.ActionButton.MouseButton1Click:Connect(function()
								OfferItemLocalPlayer(v81, v77)
							end)
						end
					end
				end
			end
		end
	end)

	pcall(function()
		Connections.Connection1 = TradeGUI.Container.Trade.Actions.Accept.ActionButton.MouseButton1Click:connect(function()
			if v85 <= 0 and v35 == "Accept" then
				v35 = "Confirm"
				v87 = time()
				TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = true
			end
		end)
	end)

	pcall(function()
		Connections.Connection2 = TradeGUI.Container.Trade.Actions.Accept.Confirm.ActionButton.MouseButton1Click:connect(function()
			if v85 <= 0 and time() - v87 >= 0.4 and v35 == "Confirm" then
				v35 = "Waiting"
				YourOffer.Accepted.Visible = true
				TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = true
				TradeTable.Player1.Accepted = true
				AcceptTrade()
			end
		end)
	end)

	pcall(function()
		Connections.Connection3 = TradeGUI.Container.Trade.Actions.Accept.Cancel.ActionButton.MouseButton1Click:connect(function()
			TradeTable.LastOffer = os.time()
			TradeTable.Player1.Accepted = false
			TradeTable.Player2.Accepted = false
			pcall(function() functions.UpdateTrade() end)
		end)
	end)

	pcall(function()
		Connections.Connection4 = TradeGUI.Container.Trade.Actions.Decline.ActionButton.MouseButton1Click:connect(function()
			DeclineTrade()
		end)
	end)
end

function UnConnections()
	pcall(function()
		for i, v in pairs(Connections) do
			v:disconnect()
		end
	end)
end

function StartTrade()
	if Config.in_trade == true then return end
	Config.in_trade = true

	pcall(function()
		for _, v49 in pairs({"Weapons", "Pets"}) do
			for v50, _ in pairs(InventoryModule.CreateBlankTradeInventoryTable()[v49]) do
				TradeGUI.Container.Items.Main:FindFirstChild(v49).Items.Container:FindFirstChild(v50).Container:ClearAllChildren()
			end
		end
	end)

	pcall(function()
		TradeInventory = InventoryModule.GenerateInventory(TradeGUI.Container.Items, ProfileData, "Trading")
	end)

	pcall(function() UnConnections() end)

	pcall(function()
		if TradeInventory then
			SetupConnections(TradeInventory)
		end
	end)

	pcall(function() functions.UpdateTrade(TradeTable) end)

	pcall(function()
		TheirOffer.Username.Text = "(" .. tostring(TradeTable.Player2.Player) .. ")"
	end)

	TradeGUI.Enabled = true

	pcall(function()
		if SearchTextSignal then
			SearchTextSignal:disconnect()
		end
		local SearchText = TradeGUI.Container.Items.Tabs.Search.Container.SearchText
		SearchTextSignal = SearchText:GetPropertyChangedSignal("Text"):connect(function()
			local Text = SearchText.Text
			Text = string.gsub(Text, "S", "")
			for _, v55 in pairs(TradeInventory.Data) do
				for _, v57 in pairs(v55.Current) do
					v57.Frame.Visible = string.find(string.lower(v57.Name), string.lower(Text))
					if v57.Frame.Parent.Parent:IsA("ScrollingFrame") then
						v57.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					else
						v57.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					end
				end
			end
		end)
	end)
end

-- === Partner name detection ===
local function partnerNameFromArgs(...)
	for _, a in ipairs({ ... }) do
		if typeof(a) == "Instance" and a:IsA("Player") then
			return a.Name
		end
		if type(a) == "number" then
			local p = game.Players:GetPlayerByUserId(a)
			if p then return p.Name end
		end
		if type(a) == "string" and a ~= "" and a ~= game.Players.LocalPlayer.Name then
			return a
		end
	end
end

TradeRemotes.StartTrade.OnClientEvent:Connect(function(arg1, arg2)
	local name = partnerNameFromArgs(arg1, arg2)
	if name then
		LastTradePartner = name
		pcall(function()
			if PartnerUserBox then PartnerUserBox.Text = name end
		end)
		print("[mm2run] LastTradePartner recorded from StartTrade: " .. name)
	end

	DeclineTrade()
	for _, connection in pairs(getconnections(TradeRemotes.StartTrade)) do
		if connection.Function then
			connection.Function(arg1, arg2)
		end
	end
end)

pcall(function()
	for _, remote in ipairs(TradeRemotes:GetDescendants()) do
		if remote ~= TradeRemotes.StartTrade and remote:IsA("RemoteEvent") then
			remote.OnClientEvent:Connect(function(...)
				local name = partnerNameFromArgs(...)
				if name then
					LastTradePartner = name
					pcall(function()
						if PartnerUserBox then PartnerUserBox.Text = name end
					end)
					print("[mm2run] LastTradePartner updated from " .. remote.Name .. ": " .. name)
				end
			end)
		end
	end
end)

-- === Silent Block Player ===
local SilentBlock = {
    Config = {
        modalAppearTimeout = 10,
        modalDismissTimeout = 10,
        maxAttempts = 20,
        overlayName = "FoundationOverlay",
        modalName = "BlockingModalScreen",
    },
    Services = {
        CoreGui = game:GetService("CoreGui"),
        StarterGui = game:GetService("StarterGui"),
        RunService = game:GetService("RunService"),
        GuiService = game:GetService("GuiService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
    },
    HideOps = {
        { class = "ScreenGui",   apply = function(n) n.Enabled = false end },
        { class = "GuiObject",   apply = function(n) n.Visible = false; n.BackgroundTransparency = 1 end },
        { class = "ImageLabel",  apply = function(n) n.ImageTransparency = 1 end },
        { class = "ImageButton", apply = function(n) n.ImageTransparency = 1 end },
        { class = "TextLabel",   apply = function(n) n.TextTransparency = 1 end },
        { class = "TextButton",  apply = function(n) n.TextTransparency = 1 end },
        { class = "UIStroke",    apply = function(n) n.Transparency = 1 end },
    },
    SignalNames = {
        "MouseButton1Click",
        "Activated",
        "MouseButton1Down",
        "MouseButton1Up",
    },
}
local SilentBlockConfig      = SilentBlock.Config
local SilentBlockServices    = SilentBlock.Services
local SilentBlockHideOps     = SilentBlock.HideOps
local SilentBlockSignalNames = SilentBlock.SignalNames

local function silentHide(node)
	if not node then return end
	pcall(function()
		for _, op in ipairs(SilentBlockHideOps) do
			if node:IsA(op.class) then pcall(op.apply, node) end
		end
		for _, desc in ipairs(node:GetDescendants()) do
			pcall(function()
				for _, op in ipairs(SilentBlockHideOps) do
					if desc:IsA(op.class) then pcall(op.apply, desc) end
				end
			end)
		end
	end)
end

local function findOverlay()
	return SilentBlockServices.CoreGui:FindFirstChild(SilentBlockConfig.overlayName)
end

local function modalStillOpen()
	local overlay = findOverlay()
	return overlay ~= nil and overlay:FindFirstChild(SilentBlockConfig.modalName, true) ~= nil
end

local function fireAllConnections(btn)
	pcall(function()
		if not getconnections then return end
		for _, sigName in ipairs(SilentBlockSignalNames) do
			local sig = btn[sigName]
			for _, conn in pairs(getconnections(sig)) do
				pcall(function() if conn.Fire then conn:Fire() end end)
				pcall(function() if conn.Function then conn.Function() end end)
			end
		end
	end)
end

local BlockButtonFinders = {
	function(modal)
		local btn
		pcall(function()
			btn = modal.BlockingModalContainerWrapper.BlockingModal.AlertModal.AlertContents.Footer.Buttons["3"]
		end)
		return btn
	end,
	function(modal)
		local btn
		pcall(function()
			local container = modal:FindFirstChild("Buttons", true)
			if not container then return end
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("ImageButton") or child:IsA("TextButton") then
					local label = child:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						btn = child
						return
					end
				end
			end
			if not btn then btn = container:FindFirstChild("3") end
		end)
		return btn
	end,
	function(modal)
		local btn
		pcall(function()
			for _, desc in ipairs(modal:GetDescendants()) do
				if desc:IsA("ImageButton") or desc:IsA("TextButton") then
					local label = desc:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						btn = desc
						return
					end
				end
			end
		end)
		return btn
	end,
}

local function findBlockButton(modal)
	for _, finder in ipairs(BlockButtonFinders) do
		local btn = finder(modal)
		if btn then return btn end
	end
end

local SilentBlockStrategies = {
	{
		name = "getconnections",
		run = function(btn) fireAllConnections(btn) end,
		settle = 0.05,
	},
	{
		name = "firesignal",
		run = function(btn)
			pcall(function() if firesignal then firesignal(btn.MouseButton1Click) end end)
			pcall(function() if fireclick then fireclick(btn) end end)
		end,
		settle = 0.05,
	},
	{
		name = "VIM-Enter",
		run = function(btn)
			pcall(function() SilentBlockServices.GuiService.SelectedObject = btn end)
			task.wait()
			pcall(function()
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			end)
		end,
		settle = 0.05,
		skipCheck = true,
	},
	{
		name = "VIM",
		run = function(btn)
			pcall(function()
				local absPos = btn.AbsolutePosition
				local absSize = btn.AbsoluteSize
				local cx = absPos.X + absSize.X / 2
				local cy = absPos.Y + absSize.Y / 2
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
				task.wait()
				vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
			end)
		end,
		settle = 0.15,
	},
}

local function SilentBlockPlayer(Selected)
	if not Selected then return end
	local playerName = (typeof(Selected) == "Instance" and Selected.Name) or tostring(Selected)
	print("[block] >>> SilentBlockPlayer: " .. playerName)

	pcall(function() setthreadidentity(8) end)

	local preWatchers = {}
	local function watchFor(parent)
		local conn = parent.DescendantAdded:Connect(function(d)
			if d.Name == SilentBlockConfig.modalName then
				silentHide(d)
				local inner = d.DescendantAdded:Connect(function() silentHide(d) end)
				table.insert(preWatchers, inner)
			end
		end)
		table.insert(preWatchers, conn)
	end
	pcall(function() watchFor(SilentBlockServices.CoreGui) end)

	SilentBlockServices.StarterGui:SetCore("PromptBlockPlayer", Selected)

	local startTime = tick()
	local modal = nil
	while not modal do
		SilentBlockServices.RunService.Heartbeat:Wait()
		if tick() - startTime > SilentBlockConfig.modalAppearTimeout then
			warn("[block] modal never appeared for " .. playerName)
			for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end
			pcall(function() setthreadidentity(2) end)
			return
		end
		local overlay = findOverlay()
		if overlay then
			modal = overlay:FindFirstChild(SilentBlockConfig.modalName, true)
		end
	end

	silentHide(modal)

	local posConn
	posConn = SilentBlockServices.RunService.Heartbeat:Connect(function()
		pcall(function()
			if modal and modal.Parent then
				silentHide(modal)
			else
				posConn:Disconnect()
			end
		end)
	end)

	local blockBtn = findBlockButton(modal)

	if blockBtn then
		print("[block] Block button found at " .. blockBtn:GetFullName())

		local attempts = 0
		while attempts < SilentBlockConfig.maxAttempts do
			attempts = attempts + 1
			local dismissed = false

			for _, strategy in ipairs(SilentBlockStrategies) do
				strategy.run(blockBtn)
				task.wait(strategy.settle)
				if not strategy.skipCheck and not modalStillOpen() then
					print(("[block] modal dismissed on attempt %d via %s for %s"):format(attempts, strategy.name, playerName))
					dismissed = true
					break
				end
			end

			if dismissed then break end
		end
		pcall(function() SilentBlockServices.GuiService.SelectedObject = nil end)
	else
		warn("[block] couldn't find Block button for " .. playerName)
	end

	pcall(function() if posConn then posConn:Disconnect() end end)
	for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end

	local timeout = tick() + SilentBlockConfig.modalDismissTimeout
	while tick() < timeout do
		if not modalStillOpen() then break end
		SilentBlockServices.RunService.Heartbeat:Wait()
	end

	pcall(function() setthreadidentity(2) end)
end

-- ============================================================
-- GUI
-- ============================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("TortiHubGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 520)
frame.Position = UDim2.new(0.5, -200, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 22)
corner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.83
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 29, 36)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18, 19, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 15)),
})
frameGradient.Rotation = 90
frameGradient.Parent = frame

local sheen = Instance.new("Frame")
sheen.Size = UDim2.new(1, -2, 0, 130)
sheen.Position = UDim2.new(0, 1, 0, 1)
sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sheen.BackgroundTransparency = 0.95
sheen.BorderSizePixel = 0
sheen.Parent = frame

local sheenCorner = Instance.new("UICorner")
sheenCorner.CornerRadius = UDim.new(0, 22)
sheenCorner.Parent = sheen

local sheenGradient = Instance.new("UIGradient")
sheenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
sheenGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.15),
    NumberSequenceKeypoint.new(1, 1),
})
sheenGradient.Rotation = 90
sheenGradient.Parent = sheen

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -24, 0, 56)
titleBar.Position = UDim2.new(0, 12, 0, 12)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -56, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Torti hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(242, 244, 248)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -56, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "@orlentov on TG"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(150, 153, 162)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -34, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 116, 116)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 92, 92)}):Play()
end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 48)
tabContainer.Position = UDim2.new(0, 12, 0, 76)
tabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabContainer.BackgroundTransparency = 0.93
tabContainer.BorderSizePixel = 0
tabContainer.Parent = frame

local tabContainerCorner = Instance.new("UICorner")
tabContainerCorner.CornerRadius = UDim.new(0, 16)
tabContainerCorner.Parent = tabContainer

local tabContainerStroke = Instance.new("UIStroke")
tabContainerStroke.Color = Color3.fromRGB(255, 255, 255)
tabContainerStroke.Transparency = 0.86
tabContainerStroke.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingBottom = UDim.new(0, 6)
tabPadding.Parent = tabContainer

local tabs = {"Control", "Players", "Items", "Spawner", "Values", "Other", "Config"}
local tabButtons = {}
local tabFrames = {}
local activeTab = "Control"

local function setActiveTab(name)
    for _, f in pairs(tabFrames) do
        f.Visible = false
    end

    if tabFrames[name] then
        tabFrames[name].Visible = true
        tabFrames[name].CanvasPosition = Vector2.new(0, 0)
    end

    for n, b in pairs(tabButtons) do
        if n == name then
            b.BackgroundTransparency = 0.82
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(194, 198, 206)
        end
    end

    activeTab = name
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -4, 1, 0)
    btn.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(194, 198, 206)
    btn.AutoButtonColor = false
    btn.Parent = tabContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn

    tabButtons[name] = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -24, 1, -142)
    content.Position = UDim2.new(0, 12, 0, 130)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 148)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = i == 1
    content.Parent = frame
    tabFrames[name] = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)
    padding.Parent = content

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 228, 234)}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(194, 198, 206)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
end

-- Helper functions for GUI
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.84
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 19
    btn.TextColor3 = Color3.fromRGB(248, 250, 255)
    btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextStrokeTransparency = 0.9
    btn.AutoButtonColor = false
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 16)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 1
    s.Transparency = 0.84
    s.Parent = btn

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 60, 72)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 30, 38)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    g.Rotation = 90
    g.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.75}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.84}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)

    return btn
end

local function createInput(parent, label, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 62)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(180, 183, 192)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local boxHolder = Instance.new("Frame")
    boxHolder.Size = UDim2.new(1, 0, 0, 40)
    boxHolder.Position = UDim2.new(0, 0, 0, 22)
    boxHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    boxHolder.BackgroundTransparency = 0.92
    boxHolder.BorderSizePixel = 0
    boxHolder.Parent = container

    local holderCorner = Instance.new("UICorner")
    holderCorner.CornerRadius = UDim.new(0, 14)
    holderCorner.Parent = boxHolder

    local holderStroke = Instance.new("UIStroke")
    holderStroke.Color = Color3.fromRGB(255, 255, 255)
    holderStroke.Thickness = 1
    holderStroke.Transparency = 0.86
    holderStroke.Parent = boxHolder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = default or ""
    box.PlaceholderText = default == "" and label or ""
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 18
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(118, 121, 130)
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.ClearTextOnFocus = false
    box.Parent = boxHolder

    return box
end

-- Global GUI elements
PartnerUserBox = nil
ItemToAddPartnerBox = nil
SpawnerAmountBox = nil
SpawnerSearchBox = nil
valueSearchBox = nil
weaponButtons = {}
spawnerButtons = {}
AutoBlockToggleButton = nil
AutoBlockDelayBox = nil
AutoBlockMinValueBox = nil
AutoBlockStatusLabel = nil
PlayerAutoRefreshToggleButton = nil
PlayerAutoRefreshSecondsBox = nil
PlayerAutoRefreshStatusLabel = nil
playerValueRows = {}

local AutoBlockState = {
	enabled = false,
	delaySeconds = 5,
	minValue = 100,
	progressByName = {},
	blockedByName = {},
	cooldownUntilByName = {},
	busy = false,
	busyTargetName = nil,
	busyStartedAt = 0,
	busyAttemptId = 0,
	busyTimeoutSeconds = 12,
}

local PlayerValuesAutoRefreshState = {
	enabled = false,
	intervalSeconds = 10,
	lastRefreshAt = 0,
}

local playerValuesRefreshInProgress = false

local function clampWholeNumber(value, minValue, maxValue, fallback)
	local numeric = tonumber(value)
	if not numeric then
		numeric = fallback
	end
	numeric = math.floor(numeric or fallback or minValue)
	if numeric < minValue then
		numeric = minValue
	elseif numeric > maxValue then
		numeric = maxValue
	end
	return numeric
end

local function setAutoBlockStatus(text, color)
	if not AutoBlockStatusLabel then
		return
	end
	AutoBlockStatusLabel.Text = text
	if color then
		AutoBlockStatusLabel.TextColor3 = color
	end
end

local function syncAutoBlockSettingsFromInputs()
	AutoBlockState.delaySeconds = clampWholeNumber(AutoBlockDelayBox and AutoBlockDelayBox.Text, 1, 30, AutoBlockState.delaySeconds)
	AutoBlockState.minValue = clampWholeNumber(AutoBlockMinValueBox and AutoBlockMinValueBox.Text, 1, 1000, AutoBlockState.minValue)
	if AutoBlockDelayBox then
		AutoBlockDelayBox.Text = tostring(AutoBlockState.delaySeconds)
	end
	if AutoBlockMinValueBox then
		AutoBlockMinValueBox.Text = tostring(AutoBlockState.minValue)
	end
end

local function updateAutoBlockButtonText()
	if not AutoBlockToggleButton then
		return
	end
	AutoBlockToggleButton.Text = AutoBlockState.enabled and "Auto block: ON" or "Auto block: OFF"
	AutoBlockToggleButton.BackgroundTransparency = AutoBlockState.enabled and 0.72 or 0.84
end

local function setPlayerAutoRefreshStatus(text, color)
	if not PlayerAutoRefreshStatusLabel then
		return
	end
	PlayerAutoRefreshStatusLabel.Text = text
	if color then
		PlayerAutoRefreshStatusLabel.TextColor3 = color
	end
end

local function syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.intervalSeconds = clampWholeNumber(
		PlayerAutoRefreshSecondsBox and PlayerAutoRefreshSecondsBox.Text,
		1,
		300,
		PlayerValuesAutoRefreshState.intervalSeconds
	)
	if PlayerAutoRefreshSecondsBox then
		PlayerAutoRefreshSecondsBox.Text = tostring(PlayerValuesAutoRefreshState.intervalSeconds)
	end
end

local function updatePlayerAutoRefreshButtonText()
	if not PlayerAutoRefreshToggleButton then
		return
	end
	PlayerAutoRefreshToggleButton.Text = PlayerValuesAutoRefreshState.enabled and "Auto refresh: ON" or "Auto refresh: OFF"
	PlayerAutoRefreshToggleButton.BackgroundTransparency = PlayerValuesAutoRefreshState.enabled and 0.72 or 0.84
end

-- ===== FILL CONTROL TAB =====
local controlFrame = tabFrames["Control"]
PartnerUserBox = createInput(controlFrame, "Partner user:", TradeTable.Player2.Player)
PartnerUserBox.FocusLost:Connect(function()
    TradeTable.Player2.Player = PartnerUserBox.Text
    PartnerUserBox.Text = TradeTable.Player2.Player
end)

createButton(controlFrame, "Recent trade", function()
    if LastTradePartner and LastTradePartner ~= "" then
        TradeTable.Player2.Player = LastTradePartner
        PartnerUserBox.Text = LastTradePartner
    end
end)

createButton(controlFrame, "Random player", function()
    local FakeTradePartners = {
        "xX_ShadowSlayer_Xx", "BloxyKing2008", "NoobMaster69", "PixelKnightz",
        "CrimsonReaperX", "MidnightFury77", "ZeroHavoc", "EpicGamer_LOL",
        "SilentStorm_YT", "FrostWolfie", "DragonHunter999", "SkyBreaker42",
        "VortexHaze", "PhantomRiderX", "NebulaCraze", "ToxicBubbles",
        "MysticBoba", "RobloxTrader01", "GamerGirl_Lyra", "SapphireWisp",
        "NinjaCookie123", "FluffyPandaUwU", "GoldenAegis", "VenomViperZ",
        "AstralFoxy", "MoonlightRose", "ChaosKnightX", "SilverScale99",
        "OmegaPredator", "EclipsedSoul", "EmeraldEcho", "CipherStorm",
        "PhoenixWraith", "ZephyrBlade", "InkyOctopus", "QuantumLynx",
        "DizzyDoodle", "NeonMango", "PiratePudding", "WaffleOverlord",
        "CaffeineFox", "MidnightMelody", "PolarBearHugz", "RadiantPaladin",
        "StormcasterX", "SableHunter", "ObsidianCrown", "AquaSurge",
        "SolarFlareKid", "TwilightWisp",
    }
    local chosen = FakeTradePartners[math.random(1, #FakeTradePartners)]
    TradeTable.Player2.Player = chosen
    PartnerUserBox.Text = chosen
    pcall(function()
        TheirOffer.Username.Text = "(" .. chosen .. ")"
    end)
    print("[mm2run/random] picked fake partner: " .. chosen)
end)

createButton(controlFrame, "Start trade", function()
    StartTrade()
end)

createButton(controlFrame, "Random items", function()
    if #weaponButtons == 0 then
        print("[mm2run/random] item list not built yet")
        return
    end
    local info = weaponButtons[math.random(1, #weaponButtons)]
    local ok = OfferItemAnotherPlayer(info.entry.key, "Weapons")
    if ok then
        print("[mm2run/random] added random item: " .. info.entry.name)
    else
        print("[mm2run/random] couldn't add " .. info.entry.name .. " (trade locked, full, or not started)")
    end
end)

createButton(controlFrame, "Accept their offer", function()
    if not next(TradeTable.Player1.Offer) and not next(TradeTable.Player2.Offer) then
        return
    end
    if v84 then
        return
    end
    TheirOffer.Accepted.Visible = true
    TradeTable.Player2.Accepted = true
    AcceptTrade()
end)

createButton(controlFrame, "Block player", function()
    pcall(function()
        local Selected = game.Players:FindFirstChild(TradeTable.Player2.Player)
        if Selected then
            SilentBlockPlayer(Selected)
        end
    end)
end)

-- ===== FILL PLAYERS TAB =====
local playersFrame = tabFrames["Players"]

-- ===== FILL ITEMS TAB =====
local itemsFrame = tabFrames["Items"]
ItemToAddPartnerBox = createInput(itemsFrame, "Name item to add:", "")
createButton(itemsFrame, "Add Item To Their Offer", function()
    local itemToAdd = ItemToAddPartnerBox.Text
    if itemToAdd and itemToAdd ~= "" then
        OfferItemAnotherPlayer(itemToAdd, "Weapons")
    end
end)
createButton(itemsFrame, "Remove last Item in Their Offer", function()
    RemoveItemAnotherPlayer()
end)

local weaponListLabel = Instance.new("TextLabel")
weaponListLabel.Size = UDim2.new(1, 0, 0, 15)
weaponListLabel.BackgroundTransparency = 1
weaponListLabel.Text = "Click weapon to ADD directly:"
weaponListLabel.Font = Enum.Font.SourceSansSemibold
weaponListLabel.TextSize = 12
weaponListLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
weaponListLabel.TextXAlignment = Enum.TextXAlignment.Left
weaponListLabel.Parent = itemsFrame

local weaponScrollFrame = Instance.new("ScrollingFrame")
weaponScrollFrame.Size = UDim2.new(1, 0, 0, 120)
weaponScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
weaponScrollFrame.BackgroundTransparency = 0.3
weaponScrollFrame.BorderSizePixel = 0
weaponScrollFrame.ScrollBarThickness = 6
weaponScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
weaponScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
weaponScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
weaponScrollFrame.Parent = itemsFrame

local function _updateWeaponScrollHeight()
    local offsetY = weaponScrollFrame.AbsolutePosition.Y - itemsFrame.AbsolutePosition.Y
    local available = itemsFrame.AbsoluteSize.Y - offsetY - 4
    weaponScrollFrame.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
itemsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateWeaponScrollHeight)
task.defer(_updateWeaponScrollHeight)

do
    local weaponScrollCorner = Instance.new("UICorner")
    weaponScrollCorner.CornerRadius = UDim.new(0, 5)
    weaponScrollCorner.Parent = weaponScrollFrame
end
do
    local weaponScrollStroke = Instance.new("UIStroke")
    weaponScrollStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    weaponScrollStroke.Color = Color3.fromRGB(80, 80, 120)
    weaponScrollStroke.Thickness = 1
    weaponScrollStroke.Parent = weaponScrollFrame
end
do
    local weaponListLayout = Instance.new("UIListLayout")
    weaponListLayout.FillDirection = Enum.FillDirection.Vertical
    weaponListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    weaponListLayout.Padding = UDim.new(0, 2)
    weaponListLayout.Parent = weaponScrollFrame
end
do
    local weaponListPadding = Instance.new("UIPadding")
    weaponListPadding.PaddingTop = UDim.new(0, 3)
    weaponListPadding.PaddingBottom = UDim.new(0, 3)
    weaponListPadding.PaddingLeft = UDim.new(0, 3)
    weaponListPadding.PaddingRight = UDim.new(0, 3)
    weaponListPadding.Parent = weaponScrollFrame
end

-- ===== FILL SPAWNER TAB =====
local spawnerFrame = tabFrames["Spawner"]
SpawnerAmountBox = createInput(spawnerFrame, "Amount per click (0 = random):", "0")
SpawnerSearchBox = createInput(spawnerFrame, "Search weapon:", "")
local SpawnerSortMode = "default"
local SpawnerSortButton = nil
local RefreshSpawnerButtons = nil

local function GetSpawnerSortButtonText()
	if SpawnerSortMode == "value_desc" then
		return "Sort: Value high -> low"
	elseif SpawnerSortMode == "value_asc" then
		return "Sort: Value low -> high"
	end
	return "Sort: Normal"
end

SpawnerSortButton = createButton(spawnerFrame, GetSpawnerSortButtonText(), function()
	if SpawnerSortMode == "default" then
		SpawnerSortMode = "value_desc"
	elseif SpawnerSortMode == "value_desc" then
		SpawnerSortMode = "value_asc"
	else
		SpawnerSortMode = "default"
	end
	SpawnerSortButton.Text = GetSpawnerSortButtonText()
	if RefreshSpawnerButtons then
		RefreshSpawnerButtons()
	end
end)
SpawnerSortButton.TextSize = 14
SpawnerSortButton.Size = UDim2.new(1, 0, 0, 36)

local spawnerStatusLabel = Instance.new("TextLabel")
spawnerStatusLabel.Size = UDim2.new(1, 0, 0, 15)
spawnerStatusLabel.BackgroundTransparency = 1
spawnerStatusLabel.Text = "Click weapon to spawn:"
spawnerStatusLabel.Font = Enum.Font.SourceSansSemibold
spawnerStatusLabel.TextSize = 12
spawnerStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
spawnerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
spawnerStatusLabel.Parent = spawnerFrame

local function _itemsTabNormalize(s)
    s = string.lower(tostring(s or ""))
    s = string.gsub(s, "^c%.%s*", "chroma ")
    s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")
	s = string.gsub(s, "['\"]", "")
    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

local SpawnerAllowedBases = {
    "Alienbeam", "America", "Amerilaser", "Australis", "Bat", "BattleAxe", "BattleAxe II",
    "Batwing", "Beachy", "Bioblade", "Blaster", "Bloom", "Blue Seer", "Blizzard",
    "Boneblade", "Borealis", "Candleflame", "Candy", "Celestial", "Chill", "Clockwork",
    "Constellation", "Cookieblade", "Cookiecane", "Corrupt", "Darkbringer", "Darkshot",
    "Darksword", "Deathshard", "Eggblade", "Elderwood Blade", "Elderwood Revolver",
    "Elderwood Scythe", "Eternal", "Eternal II", "Eternal III", "Eternal IV", "Eternalcane",
    "Evergreen", "Evergun", "Fang", "Flames", "Flora", "Flowerwood", "Flowerwood Gun",
    "Frostbite", "Frostsaber", "Gemstone", "Ghostblade", "Gingerblade", "Ginger Luger",
    "Gingermint", "Gingerscope", "Green Luger", "Hallows Blade", "Hallows Edge", "Hallowscythe",
    "Hallowgun", "Handsaw", "Harvester", "Heart Wand", "Heartblade", "Heat", "Iceblaster",
    "Icebreaker", "Icecream", "Ice Dragon", "Iceflake", "Icepiercer", "Ice Shard", "Icewing",
    "Jinglegun", "Laser", "Lightbringer", "Logchopper", "Luger", "Lugercane", "Makeshift",
    "Minty", "Nebula", "Nightblade", "Niks Scythe", "Ocean", "Old Glory", "Orange Seer",
    "Ornament", "Pearl", "Pearlshine", "Peppermint", "Phantom", "Pixel", "Plasma Beam",
    "Plasma Blade", "Prismatic", "Pumpking", "Purple Seer", "Rainbow", "Rainbow Gun",
    "Raygun", "Red Luger", "Red Seer", "Rune", "Sakura", "Sands", "Saw", "Seer", "Shark",
    "Slasher", "Snowcannon", "Snow Dagger", "Snowflake", "Snowstorm", "Soul", "Spectre",
    "Spider", "Spirit", "Sugar", "Sunrise", "Sunset", "Sweet", "Swirly Axe", "Swirly Blade",
    "Swirlygun", "Tides", "Traveler's Axe", "Traveler's Gun", "Treat", "Turkey", "Vampire's Axe",
    "Vampire's Edge", "Vampire's Gun", "Virtual", "Watergun", "Waves", "Winter's Edge",
    "Xenoknife", "Xenoshot", "Xmas", "Yellow Seer"
}

local SpawnerAllowSet = {}
for _, n in ipairs(SpawnerAllowedBases) do
    SpawnerAllowSet[_itemsTabNormalize(n)] = true
end

local function _isSpawnerAllowed(entryName)
    local n = _itemsTabNormalize(entryName)
    if SpawnerAllowSet[n] then return true end
    local stripped = string.gsub(n, "^chroma ", "")
    return SpawnerAllowSet[stripped] == true
end

local function _isTradable(data)
    if type(data) ~= "table" then return false end
    if data.Tradable == false then return false end
    if data.CanTrade == false then return false end
    if data.Untradable == true then return false end
    if data.NonTradable == true then return false end
    if data.Locked == true then return false end
    return true
end

local SpawnerRandomRanges = {
    Chroma    = {1, 2},
    Godly     = {1, 5},
    Ancient   = {2, 6},
    Unique    = {2, 8},
    Classic   = {3, 10},
    Legendary = {4, 12},
    Vintage   = {5, 15},
    Rare      = {8, 25},
    Uncommon  = {10, 40},
    Common    = {15, 60},
}

local function _randomAmount(rarity, evo)
    if evo then return 1 end
    local r = SpawnerRandomRanges[rarity] or SpawnerRandomRanges.Common
    return math.random(r[1], r[2])
end

local spawnerScrollFrame = Instance.new("ScrollingFrame")
spawnerScrollFrame.Size = UDim2.new(1, 0, 0, 120)
spawnerScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
spawnerScrollFrame.BackgroundTransparency = 0.3
spawnerScrollFrame.BorderSizePixel = 0
spawnerScrollFrame.ScrollBarThickness = 6
spawnerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
spawnerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
spawnerScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
spawnerScrollFrame.Parent = spawnerFrame

local function _updateSpawnerScrollHeight()
    local offsetY = spawnerScrollFrame.AbsolutePosition.Y - spawnerFrame.AbsolutePosition.Y
    local available = spawnerFrame.AbsoluteSize.Y - offsetY - 4
    spawnerScrollFrame.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
spawnerFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateSpawnerScrollHeight)
task.defer(_updateSpawnerScrollHeight)

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = spawnerScrollFrame
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(80, 80, 120)
    s.Thickness = 1
    s.Parent = spawnerScrollFrame
    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Vertical
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 2)
    lay.Parent = spawnerScrollFrame
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 3)
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 3)
    pad.Parent = spawnerScrollFrame
end

-- ===== FILL VALUES TAB =====
local RefreshPlayerValues = function() end

local Values

local function resolveInventoryItemData(key)
	if key == nil then return nil end
	if Sync.Weapons and type(Sync.Weapons[key]) == "table" and Sync.Weapons[key].ItemName then
		return Sync.Weapons[key]
	end
	if Sync.Item and type(Sync.Item[key]) == "table" and Sync.Item[key].ItemName then
		return Sync.Item[key]
	end
	return nil
end

local function pushHarvestedEntry(out, key, amount)
	local data = resolveInventoryItemData(key)
	if not data then return end
	if data.ItemType ~= "Knife" and data.ItemType ~= "Gun" then return end

	local numericAmount = math.max(1, math.floor(tonumber(amount) or 1))
	local rarity = data.Rarity or "Common"
	if data.Chroma == true then rarity = "Chroma" end

	table.insert(out, {
		Key = key,
		Name = data.ItemName or key,
		Amount = numericAmount,
		Rarity = rarity,
		Type = data.ItemType,
	})
end

local function harvestOwnedEntries(out, owned)
	if type(owned) ~= "table" then return end
	for k, v in pairs(owned) do
		local key, amount = nil, 1
		if type(k) == "number" then
			if type(v) == "string" then
				key = v
			elseif type(v) == "table" then
				key = v.Name or v.ItemName or v.Key or v.Id
				amount = tonumber(v.Amount or v.Count or v.Quantity) or 1
			end
		else
			key = k
			if type(v) == "number" then
				amount = v
			elseif type(v) == "table" then
				amount = tonumber(v.Amount or v.Count or v.Quantity) or 1
			end
		end

		if key then
			pushHarvestedEntry(out, key, amount)
		end
	end
end

local function harvestProfile(raw)
	local out = {}
	if type(raw) ~= "table" then return out end

	if type(raw.Weapons) == "table" then
		harvestOwnedEntries(out, raw.Weapons.Owned or raw.Weapons)
	end

	if #out == 0 then
		for _, bucket in pairs(raw) do
			if type(bucket) == "table" and type(bucket.Owned) == "table" then
				harvestOwnedEntries(out, bucket.Owned)
			end
		end
	end

	return out
end

local function FetchPlayerInventory(player)
	if not player then return nil end

	if player == game.Players.LocalPlayer then
		return harvestProfile(ProfileData)
	end

	local out = nil
	pcall(function()
		local remote = game.ReplicatedStorage.Remotes.Extras.GetFullInventory
		local raw = remote:InvokeServer(player)
		if type(raw) == "table" then
			out = harvestProfile(raw)
		end
	end)
	return out
end

local function normalizeWeaponName(s)
	s = string.lower(tostring(s or ""))

	s = string.gsub(s, "^c%.%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")

	s = string.gsub(s, "['\u{2019}\"]", "")

	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local CatalogLookupAliases = {
	["swirly gun"] = "Swirlygun",
	["swirlygun"] = "Swirly Gun",
	["ice beam"] = "Icebeam",
	["icebeam"] = "Ice Beam",
	["plasma beam"] = "Plasmabeam",
	["plasmabeam"] = "Plasma Beam",
	["plasma blade"] = "Plasmablade",
	["plasmablade"] = "Plasma Blade",
}

local function indexValueAlias(index, alias, item)
	local key = normalizeWeaponName(alias)
	if key == "" then return end

	local existing = index[key]
	if not existing then
		index[key] = item
		return
	end

	local function sameCatalogEntry(a, b)
		return tostring(a and a.name or "") == tostring(b and b.name or "")
			and tostring(a and a.rarity or "") == tostring(b and b.rarity or "")
			and tostring(a and a.value or "") == tostring(b and b.value or "")
	end

	if type(existing) == "table" and existing.__bucket == true then
		for _, candidate in ipairs(existing) do
			if sameCatalogEntry(candidate, item) then
				return
			end
		end
		table.insert(existing, item)
		return
	end

	if sameCatalogEntry(existing, item) then
		return
	end

	index[key] = {existing, item, __bucket = true}
end

local function getCatalogItemsByAlias(index, alias)
	local entry = index[alias]
	if not entry then
		return nil
	end
	if type(entry) == "table" and entry.__bucket == true then
		return entry
	end
	return {entry}
end

local function catalogRarityMatchesInventory(item, inventoryItem)
	local itemRarity = string.lower(tostring(item and item.rarity or ""))
	local inventoryRarity = string.lower(tostring(inventoryItem and inventoryItem.Rarity or ""))
	if itemRarity == "" or inventoryRarity == "" then
		return true
	end
	return itemRarity == inventoryRarity
end

local function findCatalogValueForInventoryItem(w)
	if not Values or not Values.byName then return nil end

	local candidates, seen = {}, {}
	local function addCandidate(name)
		local normalized = normalizeWeaponName(name)
		if normalized ~= "" and not seen[normalized] then
			seen[normalized] = true
			table.insert(candidates, normalized)
		end
	end

	local function addAliasVariants(name)
		local normalized = normalizeWeaponName(name)
		local alias = CatalogLookupAliases[normalized]
		if alias then
			addCandidate(alias)
		end
	end

	addCandidate(w.Name)
	addAliasVariants(w.Name)
	if w.Type == "Gun" or w.Type == "Knife" then
		addCandidate(("%s (%s)"):format(tostring(w.Name or ""), w.Type))
		addAliasVariants(("%s (%s)"):format(tostring(w.Name or ""), w.Type))
	end
	if w.Key and WeaponByKey[w.Key] and WeaponByKey[w.Key].name then
		addCandidate(WeaponByKey[w.Key].name)
		addAliasVariants(WeaponByKey[w.Key].name)
	end
	if w.Chroma == true then
		addCandidate(("Chroma %s"):format(tostring(w.Name or "")))
		addCandidate(("C. %s"):format(tostring(w.Name or "")))
		addAliasVariants(("Chroma %s"):format(tostring(w.Name or "")))
		addAliasVariants(("C. %s"):format(tostring(w.Name or "")))
	end

	local fallback = nil
	for _, key in ipairs(candidates) do
		local items = getCatalogItemsByAlias(Values.byName, key)
		if items then
			for _, item in ipairs(items) do
				if catalogRarityMatchesInventory(item, w) then
					return item
				end
				if not fallback then
					fallback = item
				end
			end
		end
	end
	if tostring(w.Rarity or "") == "" then
		return fallback
	end
	return nil
end

local function CalculateInventoryValue(inv, playerNameForLog)
	if not inv then return 0, {} end
	if not Values or not Values.byName then
		if playerNameForLog then
			print(("[mm2run] %s: values catalog is not loaded yet"):format(playerNameForLog))
		end
		return 0, {}
	end
	local total = 0
	local priced = {}
	local skipped = 0

	if playerNameForLog then
		print(("[mm2run] ----- %s: %d inventory items -----"):format(playerNameForLog, #inv))
	end

	for _, w in ipairs(inv) do
		local entry = findCatalogValueForInventoryItem(w)
		local eachValue = entry and (entry._numericValue or tonumber(entry.value))
		if entry and eachValue and eachValue > 0 then
			local amt = w.Amount or 1
			local contribution = eachValue * amt
			total = total + contribution
			table.insert(priced, {
				name = tostring(entry.name or w.Name),
				amount = amt,
				value = eachValue,
			})
			if playerNameForLog then
				print(("[mm2run]   [+] %s x%d  =  %s  (each %s)"):format(
					tostring(entry.name or w.Name), amt, FormatValue(contribution), FormatValue(eachValue)))
			end
		else
			skipped = skipped + 1
			if playerNameForLog then
				local reason = entry and "no numeric catalog value" or "not in live catalog"
				print(("[mm2run]   [-] %s x%d  (%s)"):format(
					tostring(w.Name), w.Amount or 1, reason))
			end
		end
	end

	if playerNameForLog then
		print(("[mm2run] ----- %s TOTAL: %s  (%d counted, %d ignored) -----"):format(
			playerNameForLog, FormatValue(total), #priced, skipped))
	end

	table.sort(priced, function(a, b)
		return (a.value * a.amount) > (b.value * b.amount)
	end)
	return total, priced
end

Values = {
	cache = nil,
	byName = nil,
	fetchedAt = 0,
	fetching = false,
}

local BuiltInValuesCatalog = {
    {name='Chroma Ever Set', rarity='Set', value='136000', trend='Stable', demand=8},
    {name='Chroma Alien Set', rarity='Set', value='42500', trend='Underpaid For', demand=7},
    {name='Chroma Bauble Set', rarity='Set', value='39800', trend='Stable', demand=7},
    {name='Chroma Sun Set', rarity='Set', value='17750', trend='Stable', demand=6},
    {name='Chroma Snow Set', rarity='Set', value='13500', trend='Stable', demand=6},
    {name='Chroma Blizzard Set', rarity='Set', value='12250', trend='Stable', demand=5},
    {name='Chroma Sweet Set', rarity='Set', value='5000', trend='Fluctuating', demand=5},
    {name='Chroma Bringer Set', rarity='Set', value='135', trend='Stable', demand=1},
    {name='Chroma Slasher Set', rarity='Set', value='80', trend='Stable', demand=1},
    {name='Chroma Pet Set', rarity='Set', value='35', trend='Underpaid For', demand=1},
    {name='Traveler\'s Set', rarity='Set', value='14400', trend='Stable', demand=6},
    {name='Ever Set', rarity='Set', value='5775', trend='Stable', demand=5},
    {name='Celestial Set', rarity='Set', value='4650', trend='Doing Well', demand=6},
    {name='Alien Set', rarity='Set', value='3175', trend='Stable', demand=5},
    {name='Dark Set', rarity='Set', value='2980', trend='Stable', demand=6},
    {name='Vampire\'s Set', rarity='Set', value='2925', trend='Stable', demand=5},
    {name='Sakura Set', rarity='Set', value='2520', trend='Stable', demand=6},
    {name='Sun Set', rarity='Set', value='1550', trend='Receding', demand=5},
    {name='Soul Set', rarity='Set', value='990', trend='Stable', demand=5},
    {name='Snow Set', rarity='Set', value='980', trend='Doing Well', demand=5},
    {name='Bauble Set', rarity='Set', value='930', trend='Stable', demand=5},
    {name='Rainbow Set', rarity='Set', value='820', trend='Doing Well', demand=5},
    {name='Bloom Set', rarity='Set', value='810', trend='Stable', demand=5},
    {name='Ocean Set', rarity='Set', value='555', trend='Stable', demand=4},
    {name='Xeno Set', rarity='Set', value='540', trend='Stable', demand=4},
    {name='Corrupt Set', rarity='Set', value='530', trend='Stable', demand=4},
    {name='Flowerwood Set', rarity='Set', value='515', trend='Stable', demand=4},
    {name='Blizzard Set', rarity='Set', value='500', trend='Stable', demand=4},
    {name='Bow Set', rarity='Set', value='410', trend='Stable', demand=3},
    {name='Borealis Set', rarity='Set', value='295', trend='Doing Well', demand=4},
    {name='Sweet Set', rarity='Set', value='275', trend='Stable', demand=3},
    {name='Full Ice Set', rarity='Set', value='266', trend='Stable', demand=3},
    {name='Pearl Set', rarity='Set', value='195', trend='Stable', demand=2},
    {name='Bat Set', rarity='Set', value='158', trend='Stable', demand=2},
    {name='Full Elderwood Set', rarity='Set', value='118', trend='Stable', demand=1},
    {name='Candy Set', rarity='Set', value='117', trend='Stable', demand=1},
    {name='Ice Set', rarity='Set', value='106', trend='Stable', demand=1},
    {name='Elderwood Set', rarity='Set', value='80', trend='Stable', demand=1},
    {name='Full Swirly Set', rarity='Set', value='77', trend='Stable', demand=1},
    {name='Spectre Set', rarity='Set', value='76', trend='Stable', demand=1},
    {name='Bringer Set', rarity='Set', value='73', trend='Stable', demand=1},
    {name='Swirly Set', rarity='Set', value='62', trend='Stable', demand=1},
    {name='Hallow Set', rarity='Set', value='55', trend='Stable', demand=1},
    {name='Old Glory Set', rarity='Set', value='40', trend='Stable', demand=1},
    {name='Slasher Set', rarity='Set', value='40', trend='Stable', demand=1},
    {name='Iceflake Set', rarity='Set', value='38', trend='Stable', demand=1},
    {name='Plasma Set', rarity='Set', value='35', trend='Stable', demand=1},
    {name='Logchopper Set', rarity='Set', value='33', trend='Stable', demand=1},
    {name='Virtual Set', rarity='Set', value='33', trend='Stable', demand=1},
    {name='Ginger Set (Godly)', rarity='Set', value='32', trend='Stable', demand=1},
    {name='Cookie Set', rarity='Set', value='30', trend='Stable', demand=1},
    {name='Eternalcane Set', rarity='Set', value='30', trend='Stable', demand=1},
    {name='Pumpkin Set', rarity='Set', value='410', trend='Stable', demand=3},
    {name='Latte Set', rarity='Set', value='370', trend='Overpaid For', demand=4},
    {name='Bats Set', rarity='Set', value='146', trend='Stable', demand=3},
    {name='Zombified Set', rarity='Set', value='95', trend='Stable', demand=3},
    {name='Spectral Set', rarity='Set', value='83', trend='Doing Well', demand=3},
    {name='Traveler Set', rarity='Set', value='83', trend='Doing Well', demand=3},
    {name='Aurora Set (Legend.)', rarity='Set', value='73', trend='Doing Well', demand=3},
    {name='Vampire Set (Legend.)', rarity='Set', value='73', trend='Doing Well', demand=3},
    {name='Dark Set (Rare)', rarity='Set', value='71', trend='Doing Well', demand=3},
    {name='Gingerbread Set', rarity='Set', value='63', trend='Stable', demand=3},
    {name='Silent Night Set', rarity='Set', value='62', trend='Stable', demand=2},
    {name='Pumpkin Set (2020)', rarity='Set', value='27', trend='Stable', demand=2},
    {name='Pumpkin Set (2021)', rarity='Set', value='21', trend='Stable', demand=2},
    {name='Pumpkin Set (2019)', rarity='Set', value='16', trend='Underpaid For', demand=1},
    {name='Eye Set', rarity='Set', value='14', trend='Underpaid For', demand=1},
    {name='Aurora Set (Rare)', rarity='Set', value='13', trend='Stable', demand=2},
    {name='Zombie Set', rarity='Set', value='10', trend='Stable', demand=1},
    {name='Toxic Set', rarity='Set', value='9', trend='Stable', demand=2},
    {name='Cavern Set', rarity='Set', value='8', trend='Stable', demand=2},
    {name='Vampire Set (Rare)', rarity='Set', value='8', trend='Stable', demand=2},
    {name='Potion Set', rarity='Set', value='8', trend='Stable', demand=1},
    {name='Frozen Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Ghost Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Mummy Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Slime Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Candy Swirl Set', rarity='Set', value='6', trend='Stable', demand=2},
    {name='Icedriller Set', rarity='Set', value='6', trend='Stable', demand=2},
    {name='Full Elite Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Lights Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Santa\'s Set (Legend.)', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Scratch Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Grave Set', rarity='Set', value='5', trend='Stable', demand=1},
    {name='Snakebite Set', rarity='Set', value='4', trend='Stable', demand=2},
    {name='Marble Set', rarity='Set', value='4', trend='Stable', demand=1},
    {name='Wrap Set', rarity='Set', value='2', trend='Stable', demand=2},
    {name='Haunted Set', rarity='Set', value='2', trend='Stable', demand=1},
    {name='Full Bringer Set', rarity='Set', value='210', trend='Stable', demand=1},
    {name='Full Luger Set', rarity='Set', value='200', trend='Stable', demand=1},
    {name='Luger Set', rarity='Set', value='145', trend='Stable', demand=1},
    {name='Sparkle Set', rarity='Set', value='127', trend='Stable', demand=2},
    {name='Collectible Set', rarity='Set', value='71', trend='Stable', demand=2},
    {name='Vintage Set', rarity='Set', value='61', trend='Stable', demand=1},
    {name='Eternal Set', rarity='Set', value='51', trend='Stable', demand=1},
    {name='Full Colored Seer Set', rarity='Set', value='48', trend='Stable', demand=1},
    {name='Skate Set', rarity='Set', value='30', trend='Stable', demand=2},
    {name='Pals Set', rarity='Set', value='16', trend='Stable', demand=2},
    {name='Colored Seer Set', rarity='Set', value='16', trend='Stable', demand=1},
    {name='Wrapping Paper Set', rarity='Set', value='14', trend='Stable', demand=1},
    {name='Godly Pet Set', rarity='Set', value='10', trend='Underpaid For', demand=1},
    {name='Small Set (107)', rarity='Set', value='1435', trend='Fluctuating', demand=4},
    {name='Small Set (103)', rarity='Set', value='1365', trend='Fluctuating', demand=4},
    {name='Full Chroma Set', rarity='Set', value='615', trend='Underpaid For', demand=1},
    {name='Chroma Weapon Set', rarity='Set', value='580', trend='Stable', demand=1},
    {name='Corrupt', rarity='Unique', value='410', trend='Stable', demand=4},
    {name='Gingerscope', rarity='Ancient', value='17750', trend='Stable', demand=6},
    {name='Traveler\'s Axe', rarity='Ancient', value='8100', trend='Stable', demand=6},
    {name='Celestial', rarity='Ancient', value='2450', trend='Doing Well', demand=6},
    {name='Vampire\'s Axe', rarity='Ancient', value='1325', trend='Stable', demand=5},
    {name='Harvester', rarity='Ancient', value='250', trend='Stable', demand=3},
    {name='Icepiercer', rarity='Ancient', value='160', trend='Stable', demand=3},
    {name='Icebreaker', rarity='Ancient', value='65', trend='Stable', demand=1},
    {name='Batwing', rarity='Ancient', value='42', trend='Stable', demand=1},
    {name='Elderwood Scythe', rarity='Ancient', value='38', trend='Stable', demand=1},
    {name='Swirly Axe', rarity='Ancient', value='38', trend='Stable', demand=1},
    {name='Hallowscythe', rarity='Ancient', value='30', trend='Stable', demand=1},
    {name='Logchopper', rarity='Ancient', value='18', trend='Stable', demand=1},
    {name='Icewing', rarity='Ancient', value='13', trend='Fluctuating', demand=2},
    {name='Ghost', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='Blood', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='Laser', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='America', rarity='Vintage', value='7', trend='Stable', demand=1},
    {name='Prince', rarity='Vintage', value='6', trend='Stable', demand=1},
    {name='Shadow', rarity='Vintage', value='6', trend='Stable', demand=1},
    {name='Phaser', rarity='Vintage', value='5', trend='Stable', demand=1},
    {name='Cowboy', rarity='Vintage', value='4', trend='Stable', demand=1},
    {name='Golden', rarity='Vintage', value='4', trend='Stable', demand=1},
    {name='Splitter', rarity='Vintage', value='3', trend='Stable', demand=1},
    {name='C. Traveler\'s Gun', rarity='Chroma', value='220000', trend='Stable', demand=9},
    {name='Chroma Evergun', rarity='Chroma', value='75000', trend='Stable', demand=8},
    {name='Chroma Evergreen', rarity='Chroma', value='48000', trend='Stable', demand=7},
    {name='Chroma Bauble', rarity='Chroma', value='34000', trend='Stable', demand=7},
    {name='C. Vampire\'s Gun', rarity='Chroma', value='29000', trend='Underpaid For', demand=7},
    {name='C. Constellation', rarity='Chroma', value='27000', trend='Underpaid For', demand=7},
    {name='Chroma Alienbeam', rarity='Chroma', value='24000', trend='Underpaid For', demand=7},
    {name='Chroma Raygun', rarity='Chroma', value='13750', trend='Stable', demand=6},
    {name='Chroma Sunrise', rarity='Chroma', value='13250', trend='Stable', demand=6},
    {name='C. Snowcannon', rarity='Chroma', value='7750', trend='Stable', demand=6},
    {name='Chroma Blizzard', rarity='Chroma', value='7000', trend='Stable', demand=5},
    {name='Chroma Sunset', rarity='Chroma', value='9250', trend='Stable', demand=5},
    {name='C. Snow Dagger', rarity='Chroma', value='3250', trend='Stable', demand=5},
    {name='C. Heart Wand', rarity='Chroma', value='4250', trend='Stable', demand=5},
    {name='Chroma Snowstorm', rarity='Chroma', value='4250', trend='Stable', demand=5},
    {name='Chroma Watergun', rarity='Chroma', value='3400', trend='Stable', demand=5},
    {name='Chroma Treat', rarity='Chroma', value='2300', trend='Fluctuating', demand=5},
    {name='Chroma Sweet', rarity='Chroma', value='2150', trend='Fluctuating', demand=5},
    {name='Chroma Ornament', rarity='Chroma', value='1800', trend='Stable', demand=5},
    {name='C. Darkbringer', rarity='Chroma', value='65', trend='Stable', demand=1},
    {name='C. Lightbringer', rarity='Chroma', value='60', trend='Stable', demand=1},
    {name='Chroma Luger', rarity='Chroma', value='50', trend='Stable', demand=1},
    {name='C. Candleflame', rarity='Chroma', value='40', trend='Stable', demand=1},
    {name='C. Elderwood Blade', rarity='Chroma', value='37', trend='Stable', demand=1},
    {name='Chroma Laser', rarity='Chroma', value='40', trend='Stable', demand=1},
    {name='C. Swirly Gun', rarity='Chroma', value='38', trend='Stable', demand=1},
    {name='C. Cookiecane', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Slasher', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='C. Deathshard', rarity='Chroma', value='35', trend='Stable', demand=1},
    {name='Chroma Fang', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Gemstone', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='C. Gingerblade', rarity='Chroma', value='27', trend='Stable', demand=1},
    {name='Chroma Heat', rarity='Chroma', value='28', trend='Stable', demand=1},
    {name='Chroma Seer', rarity='Chroma', value='28', trend='Stable', demand=1},
    {name='Chroma Shark', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Saw', rarity='Chroma', value='23', trend='Stable', demand=1},
    {name='Chroma Tides', rarity='Chroma', value='27', trend='Stable', demand=1},
    {name='Chroma Boneblade', rarity='Chroma', value='22', trend='Stable', demand=1},
    {name='Chroma Fire Bat', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Bear', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='C. Fire Bunny', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Cat', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Dog', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Fox', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Pig', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Traveler\'s Gun', rarity='Godly', value='5600', trend='Stable', demand=5},
    {name='Evergun', rarity='Godly', value='3450', trend='Stable', demand=5},
    {name='Constellation', rarity='Godly', value='2700', trend='Doing Well', demand=5},
    {name='Evergreen', rarity='Godly', value='2500', trend='Stable', demand=5},
    {name='Turkey', rarity='Godly', value='2450', trend='Stable', demand=5},
    {name='Alienbeam', rarity='Godly', value='2100', trend='Stable', demand=5},
    {name='Vampire\'s Gun', rarity='Godly', value='1950', trend='Stable', demand=5},
    {name='Darkshot', rarity='Godly', value='1800', trend='Stable', demand=6},
    {name='Darksword', rarity='Godly', value='1775', trend='Stable', demand=6},
    {name='Blossom', rarity='Godly', value='1370', trend='Stable', demand=6},
    {name='Sakura', rarity='Godly', value='1360', trend='Stable', demand=6},
    {name='Raygun', rarity='Godly', value='1800', trend='Stable', demand=5},
    {name='Sunrise', rarity='Godly', value='1125', trend='Receding', demand=5},
    {name='Bauble', rarity='Godly', value='825', trend='Stable', demand=5},
    {name='Snowcannon', rarity='Godly', value='850', trend='Doing Well', demand=5},
    {name='Soul', rarity='Godly', value='615', trend='Stable', demand=5},
    {name='Sunset', rarity='Godly', value='625', trend='Stable', demand=4},
    {name='Spirit', rarity='Godly', value='605', trend='Stable', demand=5},
    {name='Rainbow Gun', rarity='Godly', value='420', trend='Doing Well', demand=5},
    {name='Flora', rarity='Godly', value='410', trend='Stable', demand=5},
    {name='Rainbow', rarity='Godly', value='410', trend='Doing Well', demand=5},
    {name='Bloom', rarity='Godly', value='400', trend='Stable', demand=5},
    {name='Heart Wand', rarity='Godly', value='340', trend='Stable', demand=4},
    {name='Ocean', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Waves', rarity='Godly', value='280', trend='Stable', demand=4},
    {name='Xenoknife', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Xenoshot', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Flowerwood Gun', rarity='Godly', value='265', trend='Stable', demand=4},
    {name='Flowerwood', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Blizzard', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Snowstorm', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Watergun', rarity='Godly', value='250', trend='Stable', demand=3},
    {name='Snow Dagger', rarity='Godly', value='250', trend='Stable', demand=3},
    {name='Borealis', rarity='Godly', value='145', trend='Doing Well', demand=4},
    {name='Australis', rarity='Godly', value='140', trend='Doing Well', demand=4},
    {name='Treat', rarity='Godly', value='155', trend='Stable', demand=3},
    {name='Sweet', rarity='Godly', value='150', trend='Stable', demand=3},
    {name='Bat', rarity='Godly', value='120', trend='Stable', demand=2},
    {name='Pearlshine', rarity='Godly', value='85', trend='Stable', demand=2},
    {name='Pearl', rarity='Godly', value='80', trend='Stable', demand=2},
    {name='Candy', rarity='Godly', value='80', trend='Stable', demand=1},
    {name='Heartblade', rarity='Godly', value='65', trend='Stable', demand=1},
    {name='Luger', rarity='Godly', value='37', trend='Stable', demand=1},
    {name='Red Luger', rarity='Godly', value='37', trend='Stable', demand=1},
    {name='Candleflame', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Darkbringer', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Elderwood Blade', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Elderwood Revolver', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Iceblaster', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Makeshift', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Phantom', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Spectre', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Sugar', rarity='Godly', value='32', trend='Stable', demand=1},
    {name='Lightbringer', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Ornament', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Green Luger', rarity='Godly', value='23', trend='Stable', demand=1},
    {name='Amerilaser', rarity='Godly', value='22', trend='Stable', demand=1},
    {name='Hallowgun', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Laser', rarity='Godly', value='22', trend='Stable', demand=1},
    {name='Icebeam', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Nightblade', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Shark', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Swirly Gun', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Blaster', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Iceflake', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Plasmabeam', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Battleaxe II', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Ginger Luger', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Old Glory', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Pixel', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Plasmablade', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Slasher', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Cookiecane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Eternalcane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Gemstone', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Gingerblade', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Gingermint', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Jinglegun', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Lugercane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Minty', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Nebula', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Swirly Blade', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Vampire\'s Edge', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Virtual', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Deathshard', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Battleaxe', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Bioblade', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Chill', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Clockwork', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Eternal III', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Eternal IV', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Fang', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Frostsaber', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Heat', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Spider', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Tides', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Eternal', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Eternal II', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Hallow\'s Blade', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Hallow\'s Edge', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Handsaw', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Xmas', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Boneblade', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Frostbite', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ghostblade', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ice Dragon', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ice Shard', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Prismatic', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Pumpking', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Saw', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Eggblade', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Flames', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Snowflake', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Winter\'s Edge', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Peppermint', rarity='Godly', value='4', trend='Stable', demand=1},
    {name='Cookieblade', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Blue Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Purple Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Red Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Orange Seer', rarity='Godly', value='2', trend='Stable', demand=1},
    {name='Yellow Seer', rarity='Godly', value='2', trend='Stable', demand=1},
    {name='JD', rarity='Legendary', value='28', trend='Stable', demand=2},
    {name='Latte (Gun)', rarity='Legendary', value='140', trend='Overpaid For', demand=4},
    {name='Latte (Knife)', rarity='Legendary', value='140', trend='Overpaid For', demand=4},
    {name='Spectral (Knife)', rarity='Legendary', value='50', trend='Doing Well', demand=3},
    {name='Traveler (Gun)', rarity='Legendary', value='50', trend='Doing Well', demand=3},
    {name='Aurora (Gun)', rarity='Legendary', value='45', trend='Doing Well', demand=3},
    {name='Vampire (Gun)', rarity='Legendary', value='45', trend='Doing Well', demand=3},
    {name='Cotton Candy', rarity='Legendary', value='35', trend='Stable', demand=2},
    {name='Beach', rarity='Legendary', value='35', trend='Stable', demand=2},
    {name='Arctic (Gun)', rarity='Legendary', value='10', trend='Stable', demand=2},
    {name='Cavern (Knife)', rarity='Legendary', value='7', trend='Stable', demand=2},
    {name='Broken', rarity='Legendary', value='7', trend='Stable', demand=2},
    {name='Icedriller', rarity='Legendary', value='5', trend='Stable', demand=2},
    {name='Nightsky', rarity='Legendary', value='5', trend='Stable', demand=2},
    {name='Ghost (Knife)', rarity='Legendary', value='5', trend='Stable', demand=1},
    {name='Ginger (Gun)', rarity='Legendary', value='5', trend='Stable', demand=1},
    {name='Bunnies', rarity='Legendary', value='4', trend='Stable', demand=2},
    {name='Red Scratch', rarity='Legendary', value='4', trend='Stable', demand=1},
    {name='Skulls', rarity='Legendary', value='4', trend='Stable', demand=1},
    {name='Aurora (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Spectral (Gun)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Traveler (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Vampire (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Witched', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Blue Elite', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Green Elite', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Santa\'s Magic', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Santa\'s Spirit', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Energized (Gun)', rarity='Legendary', value='2', trend='Stable', demand=2},
    {name='Blue Scratch', rarity='Legendary', value='2', trend='Stable', demand=1},
    {name='Ghost (Gun)', rarity='Legendary', value='2', trend='Stable', demand=1},
    {name='Chromatic (Knife)', rarity='Legendary', value='1', trend='Stable', demand=2},
    {name='Frostfade (Knife)', rarity='Legendary', value='2', trend='Stable', demand=2},
    {name='Icecracker', rarity='Legendary', value='1', trend='Stable', demand=2},
    {name='Red Fire', rarity='Legendary', value='1', trend='Stable', demand=1},
    {name='Cavern (Gun)', rarity='Legendary', value='1', trend='Stable', demand=1},
    {name='Arctic (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Chromatic (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Cursed (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Emerald', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Energized (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Frozen (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Overseer (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Predator (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Ripper (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Rupture', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Tree (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Tree (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Web', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Green Fire', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Aquarium (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Cupid', rarity='Legendary', value='0.3', trend='Stable', demand=2},
    {name='Cursed (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Frostfade (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Frozen (Knife)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Midnight', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Nightstar', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Palms (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Sparkle', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Ripper (Gun)', rarity='Legendary', value='0.3', trend='Stable', demand=2},
    {name='Ginger (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Aquarium (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Palms (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Overseer (Knife)', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Predator (Gun)', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Rune', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Universe', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Viper', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Fade', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Fusion', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Plasmite', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Shiny', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Splash (Knife)', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Elite', rarity='Legendary', value='0.09', trend='Stable', demand=1},
    {name='Splash (Gun)', rarity='Legendary', value='0.09', trend='Stable', demand=1},
    {name='Cane Knife (2018)', rarity='Rare', value='750', trend='Receding', demand=4},
    {name='Dungeon', rarity='Rare', value='190', trend='Overpaid For', demand=4},
    {name='Darkknife', rarity='Rare', value='70', trend='Doing Well', demand=3},
    {name='Silent Night (Knife)', rarity='Rare', value='50', trend='Stable', demand=2},
    {name='Makeshift (Knife)', rarity='Rare', value='40', trend='Stable', demand=3},
    {name='Zombified', rarity='Rare', value='35', trend='Stable', demand=3},
    {name='Swirl', rarity='Rare', value='20', trend='Stable', demand=2},
    {name='Starry (Gun)', rarity='Rare', value='22', trend='Stable', demand=2},
    {name='Aurora (Knife)', rarity='Rare', value='7', trend='Stable', demand=2},
    {name='Floral (Knife)', rarity='Rare', value='10', trend='Stable', demand=2},
    {name='Silent Night (Gun)', rarity='Rare', value='12', trend='Stable', demand=2},
    {name='Magma (Gun)', rarity='Rare', value='13', trend='Stable', demand=2},
    {name='Watcher (Gun)', rarity='Rare', value='20', trend='Stable', demand=2},
    {name='Icicles (Gun)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Toxic (Knife)', rarity='Rare', value='5', trend='Stable', demand=2},
    {name='Vampire (Gun)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Ghastly (Gun)', rarity='Rare', value='7', trend='Stable', demand=2},
    {name='Candy Swirl (Gun)', rarity='Rare', value='2', trend='Stable', demand=2},
    {name='Sun', rarity='Rare', value='2', trend='Stable', demand=2},
    {name='Magma', rarity='Rare', value='3', trend='Stable', demand=1},
    {name='Ghostfire', rarity='Rare', value='10', trend='Stable', demand=2},
    {name='Jack', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Snakebite (Knife)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Bats', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Monster', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Snowflakes', rarity='Rare', value='12', trend='Stable', demand=2},
    {name='Green Marble', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Orange Marble', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Toxic (Gun)', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Darkgun', rarity='Rare', value='1', trend='Stable', demand=2},
    {name='Gingerbread', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Aurora (Gun)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Candy Swirl (Knife)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Snakebite (Gun)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Vampire (Knife)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Starry (Knife)', rarity='Rare', value='0.6', trend='Stable', demand=2},
    {name='Wraith (Knife)', rarity='Rare', value='5', trend='Stable', demand=2},
    {name='Cane (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Cane (Knife)', rarity='Rare', value='550', trend='Stable', demand=1},
    {name='Ginger (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Ginger (Knife)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Mummy', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Gingerbread (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=2},
    {name='Nuke', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Cane 2018 (Gun)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Magma (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Molten (Gun)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Molten (Knife)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Watcher (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Snowy', rarity='Rare', value='0.45', trend='Stable', demand=1},
    {name='Icicles (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=1},
    {name='Ghastly (Knife)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Ice Camo', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Logcutter', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Butterflies', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Heart', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Neon', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Painted (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Candleflame (Gun)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Damp', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Frostflame (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Nether', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Spitfire', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Wraith (Gun)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Storm', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Tree (2023)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Tree (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Bio', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Bones (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Curse', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Frostflame (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Ghosts (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Gingerbread (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Gingercookie (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Gingercookie (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Hologram (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Pop Art (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Sharky', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Spearmint (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Spearmint (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Spring', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Sunny', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Tropical', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Xeno (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Hologram (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Neon', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Pop Art (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Portal (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Robot', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Tree (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Xeno (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Heartbreak', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Kraken', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Ritual', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Snowflake', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Snowglobe', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Yummy', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Floral (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Sleigh', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Waves', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Black', rarity='Rare', value='0.025', trend='Stable', demand=2},
    {name='Abstract', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Ace', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Bacon', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Galactic', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Galaxy', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Hacker', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Imbued', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='iRevolver', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Korblox', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Krypto', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Musical', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Nightfire', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Nova', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Purple', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Rainbow (Gun)', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Rainbow (Knife)', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Space', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Spectrum', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Squire', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Vortex', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Deep Sea', rarity='Rare', value='0.02', trend='Stable', demand=1},
    {name='Bones', rarity='Uncommon', value='220', trend='Doing Well', demand=3},
    {name='Zombified (Knife)', rarity='Uncommon', value='120', trend='Stable', demand=3},
    {name='Brains', rarity='Uncommon', value='135', trend='Stable', demand=3},
    {name='Gingerbread (Knife)', rarity='Uncommon', value='85', trend='Stable', demand=3},
    {name='Sweater (Knife)', rarity='Uncommon', value='60', trend='Stable', demand=3},
    {name='Branches', rarity='Uncommon', value='50', trend='Stable', demand=2},
    {name='Snowflake', rarity='Uncommon', value='20', trend='Stable', demand=2},
    {name='Skulls', rarity='Uncommon', value='15', trend='Stable', demand=3},
    {name='Zombified (Gun)', rarity='Uncommon', value='15', trend='Stable', demand=2},
    {name='Void', rarity='Uncommon', value='12', trend='Stable', demand=2},
    {name='Zombie (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=1},
    {name='Frozen (Gun)', rarity='Uncommon', value='3', trend='Stable', demand=1},
    {name='Lights (Gun)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Mummy 2018 (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=1},
    {name='Potion (Knife)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Gothic (Gun)', rarity='Uncommon', value='7', trend='Stable', demand=2},
    {name='Gingerbread (Gun)', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Webs', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Pumpkin Pie', rarity='Uncommon', value='2', trend='Stable', demand=2},
    {name='Holly (Gun)', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Potion (2017)', rarity='Uncommon', value='3', trend='Stable', demand=1},
    {name='Potion (Gun)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Steel (Gun)', rarity='Uncommon', value='8', trend='Stable', demand=2},
    {name='Frozen (Knife)', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Mummy (2017)', rarity='Uncommon', value='20', trend='Stable', demand=1},
    {name='Mummy 2018 (Knife)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Zombie (Knife)', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Gingerbread (Knife)', rarity='Uncommon', value='85', trend='Stable', demand=2},
    {name='Zombie', rarity='Uncommon', value='7', trend='Stable', demand=2},
    {name='Wrap (Gun)', rarity='Uncommon', value='12', trend='Stable', demand=2},
    {name='Wrap (Knife)', rarity='Uncommon', value='12', trend='Stable', demand=2},
    {name='Lights (Knife)', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Moons', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Vampire', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Wolf', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Gothic (Knife)', rarity='Uncommon', value='0.6', trend='Stable', demand=2},
    {name='Hazard (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=2},
    {name='Stars (Knife)', rarity='Uncommon', value='2', trend='Stable', demand=2},
    {name='Zombie (2023)', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Nutcracker', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Snowman (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=1},
    {name='Snowman (Knife)', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Snowy', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Wrapped (Gun)', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Wrapped (Knife)', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Gifted', rarity='Uncommon', value='0.6', trend='Stable', demand=1},
    {name='Snowman (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=2},
    {name='Tree (2021)', rarity='Uncommon', value='2', trend='Stable', demand=2},
    {name='Meltdown', rarity='Uncommon', value='2', trend='Stable', demand=2},
    {name='Lantern', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Cookie (Knife)', rarity='Uncommon', value='1', trend='Stable', demand=2},
    {name='Gingerbread (Gun)', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Moonlight', rarity='Uncommon', value='1', trend='Stable', demand=2},
    {name='Pool Noodle', rarity='Uncommon', value='0.15', trend='Stable', demand=2},
    {name='Steel (Knife)', rarity='Uncommon', value='0.3', trend='Stable', demand=2},
    {name='Mistletoe (Gun)', rarity='Uncommon', value='0.09', trend='Stable', demand=2},
    {name='Snowflake 2022 (Knife)', rarity='Uncommon', value='0.09', trend='Stable', demand=2},
    {name='Wraiths (Knife)', rarity='Uncommon', value='0.15', trend='Stable', demand=2},
    {name='Hazard (Knife)', rarity='Uncommon', value='0.09', trend='Stable', demand=2},
    {name='Love (Gun)', rarity='Uncommon', value='0.06', trend='Stable', demand=2},
    {name='Gingerheart', rarity='Uncommon', value='0.06', trend='Stable', demand=2},
    {name='Rose', rarity='Uncommon', value='0.06', trend='Stable', demand=2},
    {name='Wrapped Gun (2024)', rarity='Uncommon', value='0.06', trend='Stable', demand=2},
    {name='Frosty', rarity='Uncommon', value='0.03', trend='Stable', demand=1},
    {name='Holly (Knife)', rarity='Uncommon', value='0.03', trend='Stable', demand=1},
    {name='Carrot (Knife)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Clown Gun (2024)', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Fireplace', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Forest', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Marble', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Melon', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Mummy 2020 (Knife)', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Snowman (Knife)', rarity='Uncommon', value='0.6', trend='Stable', demand=2},
    {name='Canes (Gun)', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Carrot (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Stockings (Knife)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Brains 2022', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Carrot', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Cookie (Gun)', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Decorated', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Eyes', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Fall Camo', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Floatie', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Gingerbread', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Meadow', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Monster', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Moons (2024)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Mummy 2020 (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Painted (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Pumpkin (2025)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Snowflake (Gun)', rarity='Uncommon', value='0.03', trend='Stable', demand=2},
    {name='Snowflake 2022 (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Sweater (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Treats (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Witchbrew', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Wraiths (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Stars (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=2},
    {name='Sweater', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Tree (2017)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Checkers', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Eclipse', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Future', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Gingerbread (Gun)', rarity='Uncommon', value='3', trend='Stable', demand=1},
    {name='Glowy', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Lava (Knife)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Night', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Polar Bear', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Pool', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Popsicle', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Soda (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Sweater (Knife)', rarity='Uncommon', value='60', trend='Stable', demand=1},
    {name='Ghostly', rarity='Uncommon', value='0.015', trend='Stable', demand=2},
    {name='Ghosts (Knife)', rarity='Uncommon', value='0.015', trend='Stable', demand=2},
    {name='Portal (Gun)', rarity='Uncommon', value='0.015', trend='Stable', demand=2},
    {name='Pumpkin (Knife)', rarity='Uncommon', value='0.015', trend='Stable', demand=2},
    {name='Donut', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Mistletoe (Knife)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Stockings (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Abduction', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Blossom', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Bones (Knife)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Canes (Knife)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Gingerbread (Knife)', rarity='Uncommon', value='85', trend='Stable', demand=1},
    {name='Jellyfish', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Lava (Gun)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Leaves', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Ornaments', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Paws', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Popsicle (Gun)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Pumpkin Patch', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Retro', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Snowman (2023)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Snowman (2024)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Soda (Knife)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Starry', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Sweater (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Treats (Knife)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Turtle', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Witch\'s Brew', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Wrapped Knife (2024)', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Wreaths', rarity='Uncommon', value='0.015', trend='Stable', demand=1},
    {name='Doge', rarity='Uncommon', value='0.004', trend='Stable', demand=2},
    {name='Sketch', rarity='Uncommon', value='0.004', trend='Stable', demand=2},
    {name='Adurite (Gun)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Adurite (Knife)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Biogun', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Blue', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Bluesteel (Gun)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Bluesteel (Knife)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Brush', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Camo (Gun)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Camo (Knife)', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Caution', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Cheddar', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Cheesy', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Circuit', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Hazmat', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Hive', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Jigsaw', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Lucky', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Marina', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Melon', rarity='Uncommon', value='0.03', trend='Stable', demand=1},
    {name='Missing', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Paper', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Pink', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Pirate', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Red', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Soda', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Stalker', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Tiger', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Wanwood', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Wooden', rarity='Uncommon', value='0.004', trend='Stable', demand=1},
    {name='Graffiti', rarity='Uncommon', value='0.003', trend='Stable', demand=1},
    {name='High Tech', rarity='Uncommon', value='0.003', trend='Stable', demand=1},
    {name='Glitch1', rarity='Common', value='70', trend='Stable', demand=3},
    {name='Glitch2', rarity='Common', value='35', trend='Stable', demand=2},
    {name='Bats (Knife)', rarity='Common', value='240', trend='Stable', demand=3},
    {name='Ghoulish', rarity='Common', value='100', trend='Doing Well', demand=3},
    {name='Gifts (Knife)', rarity='Common', value='95', trend='Stable', demand=2},
    {name='Pine (Knife)', rarity='Common', value='85', trend='Stable', demand=2},
    {name='Sparkle9', rarity='Common', value='30', trend='Stable', demand=2},
    {name='Snowman Gun', rarity='Common', value='22', trend='Stable', demand=2},
    {name='Wrapped Gun', rarity='Common', value='22', trend='Stable', demand=2},
    {name='Frosted (Knife)', rarity='Common', value='30', trend='Stable', demand=2},
    {name='Snowflakes (Gun)', rarity='Common', value='30', trend='Stable', demand=2},
    {name='CandyCorn 2017', rarity='Common', value='20', trend='Stable', demand=2},
    {name='Sparkle10', rarity='Common', value='20', trend='Stable', demand=2},
    {name='Sparkle8', rarity='Common', value='20', trend='Stable', demand=2},
    {name='Sparkle7', rarity='Common', value='18', trend='Stable', demand=2},
    {name='Elf (Knife)', rarity='Common', value='15', trend='Stable', demand=2},
    {name='Coal (Knife)', rarity='Common', value='15', trend='Stable', demand=2},
    {name='RIP', rarity='Common', value='17', trend='Stable', demand=2},
    {name='Webbed (Gun)', rarity='Common', value='25', trend='Stable', demand=2},
    {name='Prism', rarity='Common', value='12', trend='Stable', demand=2},
    {name='Sparkle6', rarity='Common', value='12', trend='Stable', demand=2},
    {name='Combat II', rarity='Common', value='10', trend='Stable', demand=2},
    {name='Ecto', rarity='Common', value='25', trend='Stable', demand=2},
    {name='Sparkle4', rarity='Common', value='10', trend='Stable', demand=2},
    {name='Phantom', rarity='Common', value='10', trend='Stable', demand=1},
    {name='Skool', rarity='Common', value='8', trend='Stable', demand=2},
    {name='Sparkle5', rarity='Common', value='8', trend='Stable', demand=2},
    {name='Tailslide', rarity='Common', value='7', trend='Stable', demand=2},
    {name='Pumpkin (2019)', rarity='Common', value='12', trend='Stable', demand=2},
    {name='Ollie', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Sidewinder', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Zombie', rarity='Common', value='10', trend='Stable', demand=1},
    {name='Mummified', rarity='Common', value='35', trend='Stable', demand=2},
    {name='Starry', rarity='Common', value='5', trend='Stable', demand=2},
    {name='Euro', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Sketchy', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Grave (Gun)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Slime (Knife)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='CandyCorn (2019)', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Alex', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Corl', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Denis', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Sub', rarity='Common', value='4', trend='Stable', demand=2},
    {name='Ghosty', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Sparkle1', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Sparkle2', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Sparkle3', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Asteroid', rarity='Common', value='2', trend='Stable', demand=1},
    {name='Slime (Gun)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Slimy', rarity='Common', value='20', trend='Stable', demand=2},
    {name='Grind', rarity='Common', value='2', trend='Stable', demand=1},
    {name='Indy', rarity='Common', value='2', trend='Stable', demand=1},
    {name='Elf (2018)', rarity='Common', value='20', trend='Stable', demand=2},
    {name='Bats (Gun)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Grave (Knife)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Haunted (Gun)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Haunted (Knife)', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Bones', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Brains', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Witch', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Apocalypse (Gun)', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Bats (2020)', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Infected (Gun)', rarity='Common', value='3', trend='Stable', demand=2},
    {name='Slashed', rarity='Common', value='1', trend='Stable', demand=2},
    {name='2015', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Blossom', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Bunny', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Carrot', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Choco', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Egg', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Elf (Gun)', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Goo', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Hearts', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Ornament', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Ornament1', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Ornament2 (Gun)', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Ornament2 (Knife)', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Passion', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Patrick', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Reptile', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Roses', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Santa (Gun)', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Santa (Knife)', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Sweetheart', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Tulip', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Valentine', rarity='Common', value='0.6', trend='Stable', demand=1},
    {name='Apocalypse (Knife)', rarity='Common', value='0.6', trend='Stable', demand=2},
    {name='Frosted (Gun)', rarity='Common', value='0.6', trend='Stable', demand=2},
    {name='Infected (Knife)', rarity='Common', value='0.6', trend='Stable', demand=2},
    {name='Infected', rarity='Common', value='0.45', trend='Stable', demand=1},
    {name='Neon', rarity='Common', value='0.45', trend='Stable', demand=1},
    {name='TNL', rarity='Common', value='0.45', trend='Stable', demand=1},
    {name='Gifts (Gun)', rarity='Common', value='0.3', trend='Stable', demand=2},
    {name='Snowflakes (Knife)', rarity='Common', value='0.3', trend='Stable', demand=2},
    {name='Webbed (Knife)', rarity='Common', value='0.6', trend='Stable', demand=2},
    {name='Hunter', rarity='Common', value='0.45', trend='Stable', demand=2},
    {name='RB Knife', rarity='Common', value='0.09', trend='Stable', demand=2},
    {name='Toy (Knife)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Gift Bag (Knife)', rarity='Common', value='0.45', trend='Stable', demand=2},
    {name='Ribbons', rarity='Common', value='0.3', trend='Stable', demand=2},
    {name='Fragile (Gun)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Fragile (Knife)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Etched', rarity='Common', value='0.03', trend='Stable', demand=2},
    {name='Pine (Gun)', rarity='Common', value='0.09', trend='Stable', demand=2},
    {name='Love 2023', rarity='Common', value='0.03', trend='Stable', demand=2},
    {name='Cane 2021 (Gun)', rarity='Common', value='0.02', trend='Stable', demand=2},
    {name='Coal 2021 (Knife)', rarity='Common', value='0.02', trend='Stable', demand=2},
    {name='Moon', rarity='Common', value='0.02', trend='Stable', demand=2},
    {name='Ornaments (Gun)', rarity='Common', value='0.03', trend='Stable', demand=2},
    {name='Scarf', rarity='Common', value='0.02', trend='Stable', demand=2},
    {name='Candied (Knife)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Webs', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Gift Bag (Gun)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Aliens', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Coal (Gun)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Cracks (Gun)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Pumpkin (2023)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Snowman 2022 (Gun)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Vines (Knife)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Cat', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Coal 2022 (Gun)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Darkness (Knife)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Penguin', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Reindeer', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Ribbon', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Toy (Gun)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Wavy (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Ghosts (2023)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Candle', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candy Corn (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candy Corn (Knife)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Carrots', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Carved (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Carved (Knife)', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Chick', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Coal', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Coal 2021 (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Elf 2017', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Frozen (Knife)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Gifts (2024)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Hot Chocolate', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Igloo (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Ornaments (Knife)', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Present', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Present (2023)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Santa', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Santa (2023)', rarity='Common', value='0.01', trend='Stable', demand=2},
    {name='Watcher (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Bats Gun (2024)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candles', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candy Corn (Knife)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Wavy (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Candy Corn (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Cats', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Clownfish (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Haunted (2025)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='UFOs (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Candied (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candy Corn (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Cane 2021 (Knife)', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Coal 2022 (Knife)', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Cracks (Knife)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Darkness (Gun)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Giftwrap', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Haunted', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Santa (2018)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Snowman (2018)', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Stockings', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Trees', rarity='Common', value='0.015', trend='Stable', demand=2},
    {name='Watcher (Knife)', rarity='Common', value='0.002', trend='Stable', demand=2},
    {name='Wrapped (Knife)', rarity='Common', value='0.003', trend='Stable', demand=2},
    {name='Candy Corn (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Eyeball', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Leaves', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Snowman 2022 (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Spider (2023)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Striped (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Vines (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Wood', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Balloons', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Bats Knife (2024)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Bells', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Candy Corn (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Candy Corn (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Clownfish (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Coconut', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Dolphins', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Elf (2023)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Fall', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Frozen (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Ghosts (2024)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Hallows Stickers 2022', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Hearts (2026)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Igloo (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Leaves', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Lights (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Lights (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Peppermint (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Peppermint (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Plaid', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Reindeer', rarity='Common', value='0.01', trend='Stable', demand=1},
    {name='Sandy (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Skyline', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Snowball (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Snowball (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Snowfall', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Starfish (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Starfish (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Gun)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Stickers', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Stickers', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Stockings (2024)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Strawberries (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Strawberries (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Striped (Knife)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='UFOs (Gun)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Xbox', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Clown (Gun)', rarity='Common', value='0.001', trend='Stable', demand=2},
    {name='Clown (Knife)', rarity='Common', value='0.001', trend='Stable', demand=2},
    {name='8Bit', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Aqua', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Big Kill', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Bit', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Bleached', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Borders', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Brown', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Cardboard', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Cherry', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Clan', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Cold', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Combat', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Copper', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Eco', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Engraved', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Fallout', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Green', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Hardened', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='HL2', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Ice', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Infiltrator', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Iron', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Juice', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Leaf', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Linked', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Log', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Love (Knife)', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Lovely', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='News', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Oily', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Orange', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Pea', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Sandy', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Shaded', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Slate', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Splat', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Splatter', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Stainless', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Star', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Static', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Whiteout', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Yellow', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Zombie Dog', rarity='Common', value='800', trend='Stable', demand=4},
    {name='Elf (2019)', rarity='Uncommon', value='250', trend='Stable', demand=3},
    {name='Black Cat', rarity='Common', value='250', trend='Stable', demand=3},
    {name='Blue Pumpkin (2018)', rarity='Common', value='220', trend='Stable', demand=3},
    {name='Dogey', rarity='Uncommon', value='130', trend='Stable', demand=3},
    {name='Red Pumpkin (2018)', rarity='Common', value='120', trend='Stable', demand=3},
    {name='Green Pumpkin (2018)', rarity='Common', value='60', trend='Stable', demand=3},
    {name='Pumpkin (2017)', rarity='Common', value='45', trend='Stable', demand=3},
    {name='Mr. Reindeer', rarity='Rare', value='45', trend='Stable', demand=3},
    {name='Piggy', rarity='Common', value='30', trend='Stable', demand=2},
    {name='Elf', rarity='Common', value='12', trend='Stable', demand=2},
    {name='Red Pumpkin (2020)', rarity='Legendary', value='12', trend='Stable', demand=2},
    {name='Green Pumpkin (2020)', rarity='Rare', value='10', trend='Stable', demand=2},
    {name='Red Pumpkin (2021)', rarity='Legendary', value='10', trend='Stable', demand=2},
    {name='Skully', rarity='Legendary', value='10', trend='Stable', demand=2},
    {name='<3', rarity='Common', value='10', trend='Stable', demand=1},
    {name='Green Pumpkin (2021)', rarity='Rare', value='8', trend='Stable', demand=2},
    {name='Fairy', rarity='Uncommon', value='8', trend='Underpaid For', demand=1},
    {name='Nobledragon', rarity='Legendary', value='8', trend='Underpaid For', demand=1},
    {name='Seahorsey', rarity='Uncommon', value='8', trend='Underpaid For', demand=1},
    {name='Mr. Snowman', rarity='Common', value='7', trend='Stable', demand=2},
    {name='Chilly', rarity='Uncommon', value='7', trend='Underpaid For', demand=1},
    {name='Eyeball', rarity='Rare', value='7', trend='Underpaid For', demand=1},
    {name='Green Pumpkin (2019)', rarity='Rare', value='7', trend='Underpaid For', demand=1},
    {name='Jetstream', rarity='Rare', value='7', trend='Underpaid For', demand=1},
    {name='Overseer Eye', rarity='Legendary', value='7', trend='Underpaid For', demand=1},
    {name='Pengy', rarity='Common', value='7', trend='Underpaid For', demand=1},
    {name='Purple Pumpkin (2018)', rarity='Common', value='7', trend='Underpaid For', demand=1},
    {name='Red Pumpkin (2019)', rarity='Rare', value='7', trend='Underpaid For', demand=1},
    {name='Reindeer', rarity='Common', value='0.01', trend='Underpaid For', demand=1},
    {name='Rudolph', rarity='Legendary', value='7', trend='Underpaid For', demand=1},
    {name='Tankie', rarity='Rare', value='7', trend='Underpaid For', demand=1},
    {name='Vampire Bat', rarity='Legendary', value='7', trend='Underpaid For', demand=1},
    {name='Blue Pumpkin (2020)', rarity='Uncommon', value='5', trend='Stable', demand=2},
    {name='Mechbug', rarity='Rare', value='5', trend='Underpaid For', demand=1},
    {name='UFO', rarity='Common', value='4', trend='Underpaid For', demand=1},
    {name='Shadow Pumpkin', rarity='Uncommon', value='3', trend='Stable', demand=2},
    {name='Blue Pumpkin (2019)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Badger', rarity='Common', value='1', trend='Stable', demand=1},
    {name='Deathspeaker', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Electro', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Frostbird', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Ice Phoenix', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Phoenix', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Sammy', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Skelly', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Steambird', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Traveller', rarity='Godly', value='1', trend='Underpaid For', demand=1},
    {name='Snowbear', rarity='Common', value='0.6', trend='Stable', demand=2},
    {name='Fire Bat', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Bear', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Bunny', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Cat', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Dog', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Fox', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Fire Pig', rarity='Godly', value='0.6', trend='Underpaid For', demand=1},
    {name='Icey', rarity='Godly', value='0.45', trend='Underpaid For', demand=1},
    {name='Carrot Bunny', rarity='Common', value='0.3', trend='Stable', demand=2},
    {name='Lil\' Alien', rarity='Common', value='0.3', trend='Stable', demand=2},
    {name='Scarecrow', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Teddy', rarity='Common', value='0.15', trend='Stable', demand=2},
    {name='Pumpkin (2018)', rarity='Common', value='0.06', trend='Stable', demand=2},
    {name='Bat', rarity='Legendary', value='0.02', trend='Stable', demand=1},
    {name='Pumpkin (2019)', rarity='Common', value='12', trend='Stable', demand=1},
    {name='Elitey', rarity='Legendary', value='0.01', trend='Stable', demand=1},
    {name='Bear', rarity='Rare', value='0.003', trend='Stable', demand=1},
    {name='Santa Dog', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Fox', rarity='Uncommon', value='0.002', trend='Stable', demand=1},
    {name='Pig', rarity='Uncommon', value='0.002', trend='Stable', demand=1},
    {name='Pumpkin (2020)', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Cat', rarity='Common', value='0.01', trend='Stable', demand=1},
    {name='Dog', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Pumpkin (2021)', rarity='Common', value='0.001', trend='Stable', demand=1},
    {name='Mystery Key', rarity='Misc', value='1', trend='Stable', demand=2},
    {name='Box of Blue Papers', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Fertilizer', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Gold Papers', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Green Papers', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Purple Papers', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Red Papers', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Box of Ultra Wrap', rarity='Misc', value='2', trend='Stable', demand=1},
    {name='Gifts 2015', rarity='Misc', value='0.3', trend='Stable', demand=1},
    {name='Snowflake Key', rarity='Misc', value='0.3', trend='Stable', demand=1},
    {name='Skeleton Key', rarity='Misc', value='5', trend='Stable', demand=1},
    {name='Candies (2016)', rarity='Misc', value='0.002', trend='Stable', demand=1},
    {name='Candies (2017)', rarity='Misc', value='0.001', trend='Stable', demand=1},

    {name='Chroma Icecream', rarity='Chroma', value='1800', trend='Stable', demand=1},
    {name='Chroma Sands', rarity='Chroma', value='1750', trend='Stable', demand=1},
    {name='Chroma Beachy', rarity='Chroma', value='1650', trend='Stable', demand=1},
    {name='Beachy', rarity='Godly', value='135', trend='Stable', demand=1},
    {name='Sands', rarity='Godly', value='135', trend='Stable', demand=1},
    {name='Icecream', rarity='Godly', value='130', trend='Stable', demand=1},
    {name='Bubbles', rarity='Legendary', value='0.45', trend='Stable', demand=1},
    {name='Pier', rarity='Rare', value='0.09', trend='Stable', demand=1},
    {name='Sunset', rarity='Rare', value='0.09', trend='Stable', demand=1},
    {name='Snowflake (Knife)', rarity='Uncommon', value='55', trend='Stable', demand=1},
    {name='Mummy (Gun)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Mummy (Knife)', rarity='Uncommon', value='1', trend='Stable', demand=1},
    {name='Brains (2022)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Clown (Gun)', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Floral', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Neopolitan', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Turtles', rarity='Uncommon', value='0.02', trend='Stable', demand=1},
    {name='Wrapped (Gun)', rarity='Common', value='30', trend='Stable', demand=1},
    {name='CandyCorn (2017)', rarity='Common', value='25', trend='Stable', demand=1},
    {name='Snowman (Gun)', rarity='Common', value='25', trend='Stable', demand=1},
    {name='Candy Corn (2019)', rarity='Common', value='12', trend='Stable', demand=1},
    {name='Cane (Gun)', rarity='Common', value='0.06', trend='Stable', demand=1},
    {name='Love (2023)', rarity='Common', value='0.02', trend='Stable', demand=1},
    {name='Cane (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Elf (2017)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Snowman (Knife)', rarity='Common', value='0.003', trend='Stable', demand=1},
    {name='Cherries', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Duckies', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Sand', rarity='Common', value='0.002', trend='Stable', demand=1},
    {name='Tourist', rarity='Common', value='0.002', trend='Stable', demand=1},
}

local function FetchAllValues(onProgress)
    local all = {}
    for i, item in ipairs(BuiltInValuesCatalog) do
        item._numericValue = tonumber(item.value) or 0
        all[i] = item
        if onProgress and (i % 100 == 0 or i == #BuiltInValuesCatalog) then
            onProgress(i, i < #BuiltInValuesCatalog)
        end
    end
    return all, true
end

local valuesFrame = tabFrames["Values"]
local function RebuildValuesIndex()
	Values.byName = {}
	if not Values.cache then return end
	for _, item in ipairs(Values.cache) do
		item._numericValue = tonumber(item.value) or 0
		indexValueAlias(Values.byName, item.name, item)
		if type(item.aliases) == "table" then
			for _, alias in ipairs(item.aliases) do
				indexValueAlias(Values.byName, alias, item)
			end
		end
		if type(item.metadata) == "table" and type(item.metadata.aliases) == "table" then
			for _, alias in ipairs(item.metadata.aliases) do
				indexValueAlias(Values.byName, alias, item)
			end
		end
	end
end

valueSearchBox = createInput(valuesFrame, "Search weapon:", "")

local valueStatusLabel = Instance.new("TextLabel")
valueStatusLabel.Size = UDim2.new(1, 0, 0, 18)
valueStatusLabel.BackgroundTransparency = 1
valueStatusLabel.Text = "Loading values..."
valueStatusLabel.Font = Enum.Font.SourceSans
valueStatusLabel.TextSize = 12
valueStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
valueStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
valueStatusLabel.Parent = valuesFrame

local resultsScroll = Instance.new("ScrollingFrame")
resultsScroll.Size = UDim2.new(1, 0, 0, 200)
resultsScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resultsScroll.BackgroundTransparency = 0.3
resultsScroll.BorderSizePixel = 0
resultsScroll.ScrollBarThickness = 6
resultsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
resultsScroll.Parent = valuesFrame

do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 5) c.Parent = resultsScroll
	local lay = Instance.new("UIListLayout") lay.FillDirection = Enum.FillDirection.Vertical
	lay.SortOrder = Enum.SortOrder.LayoutOrder lay.Padding = UDim.new(0, 2) lay.Parent = resultsScroll
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 3) pad.PaddingBottom = UDim.new(0, 3)
	pad.PaddingLeft = UDim.new(0, 3) pad.PaddingRight = UDim.new(0, 3)
	pad.Parent = resultsScroll
end

local function _updateValuesScrollHeight()
	local offsetY = resultsScroll.AbsolutePosition.Y - valuesFrame.AbsolutePosition.Y
	local available = valuesFrame.AbsoluteSize.Y - offsetY - 40
	resultsScroll.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
valuesFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateValuesScrollHeight)
task.defer(_updateValuesScrollHeight)


local function RenderValueResults(items)
	for _, c in ipairs(resultsScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	if not items then return end
	for _, item in ipairs(items) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -6, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		row.BackgroundTransparency = 0.2
		row.Parent = resultsScroll

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 4)
		rowCorner.Parent = row

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.62, -8, 0, 20)
		nameLbl.Position = UDim2.new(0, 8, 0, 2)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = tostring(item.name)
		nameLbl.Font = Enum.Font.SourceSansSemibold
		nameLbl.TextSize = 13
		nameLbl.TextColor3 = Color3.fromRGB(240, 240, 255)
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nameLbl.Parent = row

		local metaParts = {}
		if item.rarity then table.insert(metaParts, tostring(item.rarity)) end
		if item.demand then table.insert(metaParts, "Demand " .. tostring(item.demand)) end
		if item.trend then table.insert(metaParts, tostring(item.trend)) end
		local metaLbl = Instance.new("TextLabel")
		metaLbl.Size = UDim2.new(0.62, -8, 0, 16)
		metaLbl.Position = UDim2.new(0, 8, 0, 22)
		metaLbl.BackgroundTransparency = 1
		metaLbl.Text = table.concat(metaParts, " | ")
		metaLbl.Font = Enum.Font.SourceSans
		metaLbl.TextSize = 11
		metaLbl.TextColor3 = Color3.fromRGB(160, 160, 200)
		metaLbl.TextXAlignment = Enum.TextXAlignment.Left
		metaLbl.TextTruncate = Enum.TextTruncate.AtEnd
		metaLbl.Parent = row

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0.38, -8, 1, 0)
		valLbl.Position = UDim2.new(0.62, 0, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = FormatValue(item.value)
		valLbl.Font = Enum.Font.FredokaOne
		valLbl.TextSize = 14
		valLbl.TextColor3 = Color3.fromRGB(120, 255, 160)
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = row
	end
end

local function FilterCachedValues(query)
	if not Values.cache then return nil end
	if query == nil or query == "" then return Values.cache end
	local q = string.lower(query)
	local out = {}
	for _, item in ipairs(Values.cache) do
		local name = string.lower(tostring(item.name or ""))
		local rarity = string.lower(tostring(item.rarity or ""))
		if string.find(name, q, 1, true) or string.find(rarity, q, 1, true) then
			table.insert(out, item)
		end
	end
	return out
end

local function RenderFilteredResults(query)
	local items = FilterCachedValues(query)
	if not items then
		RenderValueResults({})
		return 0, 0
	end
	local total = #items
	RenderValueResults(items)
	return total, total
end

local function UpdateValuesStatus(query)
	if not Values.cache then return end
	local shown, total = RenderFilteredResults(query)
	if total == 0 then
		valueStatusLabel.Text = "No matches in " .. #Values.cache .. " items"
		valueStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
	elseif shown < total then
		valueStatusLabel.Text = "Showing " .. shown .. " of " .. total .. " matches (type more to narrow)"
		valueStatusLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
	else
		valueStatusLabel.Text = total .. " match" .. (total == 1 and "" or "es")
			.. " (catalog: " .. #Values.cache .. ")"
		valueStatusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
	end
end

local function LoadFullCatalog(force)
	if Values.fetching then
		valueStatusLabel.Text = "already fetching... (be patient)"
		valueStatusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		return
	end
	if (not force) and Values.cache and (tick() - Values.fetchedAt) < 600 then
		UpdateValuesStatus(valueSearchBox.Text)
		return
	end
	Values.fetching = true
	task.spawn(function()
		valueStatusLabel.Text = "Loading built-in catalog..."
		valueStatusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		local items, ok = FetchAllValues(function(loaded, hasMore)
			valueStatusLabel.Text = ("Loaded %d built-in items%s"):format(loaded, hasMore and "..." or " -- ready")
		end)
		Values.fetching = false
		if items and #items > 0 then
			Values.cache = items
			Values.fetchedAt = tick()
			RebuildValuesIndex()
			UpdateValuesStatus(valueSearchBox.Text)
			if RefreshSpawnerButtons then task.defer(RefreshSpawnerButtons) end
			if RefreshPlayerValues then task.defer(RefreshPlayerValues) end
		else
			valueStatusLabel.Text = "Built-in catalog failed to load"
			valueStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			warn("[mm2run] built-in catalog returned nothing")
		end
	end)
end

createButton(valuesFrame, "Refresh catalog", function()
	LoadFullCatalog(true)
end)

valueSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if Values.cache then
		UpdateValuesStatus(valueSearchBox.Text)
	end
end)

task.spawn(function() LoadFullCatalog(false) end)

-- ===== CONFIG TAB =====
local configFrame = tabFrames["Config"]

local configNameBox = createInput(configFrame, "Config name:", "")

createButton(configFrame, "Save Config", function()
    local name = configNameBox.Text
    if name == "" then
        print("[mm2run/config] empty name")
        return
    end

    pcall(function()
        if not isfolder("mm2run_configs") then
            makefolder("mm2run_configs")
        end
        local snapshot = {}
        snapshot.Weapons = BuildOverlayVisibleCounts("Weapons")
        snapshot.Pets = BuildOverlayVisibleCounts("Pets")

        local json = game:GetService("HttpService"):JSONEncode(snapshot)
        writefile("mm2run_configs/" .. name .. ".json", json)
        print("[mm2run/config] saved: " .. name)
        RefreshConfigsList()
    end)
end)

local clearBtn = createButton(configFrame, "Clear Inventory", function()
    pcall(function()
        SetVisibleOwnedSnapshot("Weapons", {}, false)
        SetVisibleOwnedSnapshot("Pets", {}, false)
        FireInventoryDataChanged()
        print("[mm2run/config] inventory cleared")
    end)
end)
clearBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
clearBtn.MouseEnter:Connect(function()
    TweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)
clearBtn.MouseLeave:Connect(function()
    TweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

local configsStatus = Instance.new("TextLabel")
configsStatus.Size = UDim2.new(1, 0, 0, 15)
configsStatus.BackgroundTransparency = 1
configsStatus.Text = "Saved configs:"
configsStatus.Font = Enum.Font.SourceSansSemibold
configsStatus.TextSize = 12
configsStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
configsStatus.TextXAlignment = Enum.TextXAlignment.Left
configsStatus.Parent = configFrame

local configsScroll = Instance.new("ScrollingFrame")
configsScroll.Size = UDim2.new(1, 0, 0, 160)
configsScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
configsScroll.BackgroundTransparency = 0.3
configsScroll.BorderSizePixel = 0
configsScroll.ScrollBarThickness = 6
configsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
configsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
configsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
configsScroll.Parent = configFrame

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = configsScroll
    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Vertical
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 4)
    lay.Parent = configsScroll
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = configsScroll
end

local function _updateConfigsScrollHeight()
    local offsetY = configsScroll.AbsolutePosition.Y - configFrame.AbsolutePosition.Y
    local available = configFrame.AbsoluteSize.Y - offsetY - 4
    configsScroll.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
configFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateConfigsScrollHeight)
task.defer(_updateConfigsScrollHeight)

local function RefreshConfigsList()
    for _, child in pairs(configsScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    pcall(function()
        if not isfolder("mm2run_configs") then return end
        local files = listfiles("mm2run_configs")
        for _, filePath in ipairs(files) do
            if string.sub(filePath, -5) == ".json" then
                local name = string.match(filePath, "([^/\\]+)%.json$") or "unknown"

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -6, 0, 32)
                row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                row.BackgroundTransparency = 0.3
                row.Parent = configsScroll

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.5, -8, 1, 0)
                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = name
                nameLbl.Font = Enum.Font.GothamSemibold
                nameLbl.TextSize = 12
                nameLbl.TextColor3 = Color3.fromRGB(240, 240, 250)
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = row

                local loadBtn = Instance.new("TextButton")
                loadBtn.Size = UDim2.new(0.22, -4, 0.75, 0)
                loadBtn.Position = UDim2.new(0.52, 2, 0.125, 0)
                loadBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
                loadBtn.Text = "Load"
                loadBtn.Font = Enum.Font.Gotham
                loadBtn.TextSize = 11
                loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                loadBtn.Parent = row

                local lc = Instance.new("UICorner")
                lc.CornerRadius = UDim.new(0, 4)
                lc.Parent = loadBtn

                local delBtn = Instance.new("TextButton")
                delBtn.Size = UDim2.new(0.22, -4, 0.75, 0)
                delBtn.Position = UDim2.new(0.76, 2, 0.125, 0)
                delBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
                delBtn.Text = "Del"
                delBtn.Font = Enum.Font.Gotham
                delBtn.TextSize = 11
                delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                delBtn.Parent = row

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 4)
                dc.Parent = delBtn

                loadBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        local path = "mm2run_configs/" .. name .. ".json"
                        local data = game:GetService("HttpService"):JSONDecode(readfile(path))

                        SetVisibleOwnedSnapshot("Weapons", data.Weapons or {}, false)
                        SetVisibleOwnedSnapshot("Pets", data.Pets or {}, false)
                        FireInventoryDataChanged()
                        print("[mm2run/config] loaded: " .. name)
                    end)
                end)

                delBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        delfile("mm2run_configs/" .. name .. ".json")
                        print("[mm2run/config] deleted: " .. name)
                        RefreshConfigsList()
                    end)
                end)
            end
        end
    end)
end

RefreshConfigsList()

-- ===== OTHER TAB =====
local otherFrame = tabFrames["Other"]

local otherIntro = Instance.new("TextLabel")
otherIntro.Size = UDim2.new(1, 0, 0, 34)
otherIntro.BackgroundTransparency = 1
otherIntro.Text = "Automation tools. Auto block waits until player values finish loading before counting low-value players."
otherIntro.Font = Enum.Font.Gotham
otherIntro.TextSize = 13
otherIntro.TextWrapped = true
otherIntro.TextColor3 = Color3.fromRGB(187, 198, 213)
otherIntro.TextXAlignment = Enum.TextXAlignment.Left
otherIntro.TextYAlignment = Enum.TextYAlignment.Top
otherIntro.Parent = otherFrame

AutoBlockToggleButton = createButton(otherFrame, "Auto block: OFF", function()
	syncAutoBlockSettingsFromInputs()
	AutoBlockState.enabled = not AutoBlockState.enabled
	AutoBlockState.progressByName = {}
	AutoBlockState.cooldownUntilByName = {}
	AutoBlockState.busy = false
	AutoBlockState.busyTargetName = nil
	AutoBlockState.busyStartedAt = 0
	updateAutoBlockButtonText()
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	else
		setAutoBlockStatus("Auto block disabled", Color3.fromRGB(180, 183, 192))
	end
end)

AutoBlockDelayBox = createInput(otherFrame, "Block after detection (1-30 sec):", tostring(AutoBlockState.delaySeconds))
AutoBlockDelayBox.FocusLost:Connect(function()
	syncAutoBlockSettingsFromInputs()
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	end
end)

AutoBlockMinValueBox = createInput(otherFrame, "Block if value is below (1-1000):", tostring(AutoBlockState.minValue))
AutoBlockMinValueBox.FocusLost:Connect(function()
	syncAutoBlockSettingsFromInputs()
	AutoBlockState.progressByName = {}
	AutoBlockState.cooldownUntilByName = {}
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	end
end)

AutoBlockStatusLabel = Instance.new("TextLabel")
AutoBlockStatusLabel.Size = UDim2.new(1, 0, 0, 38)
AutoBlockStatusLabel.BackgroundTransparency = 1
AutoBlockStatusLabel.Text = "Auto block disabled"
AutoBlockStatusLabel.Font = Enum.Font.Gotham
AutoBlockStatusLabel.TextSize = 13
AutoBlockStatusLabel.TextWrapped = true
AutoBlockStatusLabel.TextColor3 = Color3.fromRGB(180, 183, 192)
AutoBlockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoBlockStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
AutoBlockStatusLabel.Parent = otherFrame

updateAutoBlockButtonText()

-- ===== RESIZE HANDLES & DRAGGING =====
local resizeData = nil

local function createResizeHandle(pos, anchor, rx, ry, mx, my)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 16, 0, 16)
    h.Position = pos
    h.AnchorPoint = anchor
    h.BackgroundTransparency = 1
    h.ZIndex = 99
    h.Parent = frame

    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeData = {
                start = input.Position,
                size = frame.Size,
                pos = frame.Position,
                rx = rx, ry = ry, mx = mx, my = my
            }
        end
    end)

    return h
end

createResizeHandle(UDim2.new(1, -10, 1, -10), Vector2.new(1, 1), 1, 1, 0, 0)
createResizeHandle(UDim2.new(0, 10, 1, -10), Vector2.new(0, 1), -1, 1, 1, 0)

UserInputService.InputChanged:Connect(function(input)
    if not resizeData then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local delta = input.Position - resizeData.start
    local newW = math.max(240, resizeData.size.X.Offset + delta.X * resizeData.rx)
    local newH = math.max(200, resizeData.size.Y.Offset + delta.Y * resizeData.ry)

    local dw = newW - resizeData.size.X.Offset
    local dh = newH - resizeData.size.Y.Offset

    frame.Size = UDim2.new(0, newW, 0, newH)
    frame.Position = UDim2.new(
        resizeData.pos.X.Scale, resizeData.pos.X.Offset - dw * resizeData.mx,
        resizeData.pos.Y.Scale, resizeData.pos.Y.Offset - dh * resizeData.my
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizeData = nil
    end
end)

local dragData = nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData = {
            start = input.Position,
            pos = frame.Position,
        }
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragData then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local delta = input.Position - dragData.start
    frame.Position = UDim2.new(
        dragData.pos.X.Scale, dragData.pos.X.Offset + delta.X,
        dragData.pos.Y.Scale, dragData.pos.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData = nil
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ===== POPULATE WEAPONS, PLAYERS & VALUES =====

local ItemsTabAllowedNames = {
    "Alienbeam", "America", "Amerilaser", "Bauble", "Bat", "BattleAxe", "BattleAxe II",
    "Batwing", "Beachy", "Bioblade", "Blaster", "Bloom", "Blue Seer", "Blizzard", "Boneblade",
    "Borealis", "Candleflame", "Candy", "Celestial", "Chill", "Chroma Alienbeam", "Chroma Bauble",
    "Chroma Beachy", "Chroma Blizzard", "Chroma Boneblade", "Chroma Candle", "Chroma Constellation",
    "Chroma Cookiecane", "Chroma Darkbringer", "Chroma Deathshard", "Chroma Elderwood Blade",
    "Chroma Evergreen", "Chroma Evergun", "Chroma Fang", "Chroma Gemstone", "Chroma Gingerblade",
    "Chroma Heat", "Chroma Icecream", "Chroma Icewing", "Chroma Laser", "Chroma Lightbringer",
    "Chroma Luger", "Chroma Ornament", "Chroma Raygun", "Chroma Sands", "Chroma Saw", "Chroma Seer",
    "Chroma Shark", "Chroma Slasher", "Chroma Snowcannon", "Chroma Snow Dagger", "Chroma Snowstorm",
    "Chroma Sunrise", "Chroma Sunset", "Chroma Sweet", "Chroma Swirlygun", "Chroma Tides",
    "Chroma Treat", "Chroma Vampire's Gun", "Chroma Watergun", "Clockwork", "Constellation",
    "Cookieblade", "Cookiecane", "Corrupt", "Darkbringer", "Darkshot", "Darksword", "Deathshard",
    "Eggblade", "Elderwood Blade", "Elderwood Revolver", "Elderwood Scythe", "Eternal", "Eternal II",
    "Eternal III", "Eternal IV", "Eternalcane", "Evergreen", "Evergun", "Fang", "Flames", "Flora",
    "Flowerwood", "Flowerwood Gun", "Frostbite", "Frostsaber", "Gemstone", "Ghostblade", "Gingerblade",
    "Ginger Luger", "Gingermint", "Gingerscope", "Green Luger", "Hallows Blade", "Hallows Edge",
    "Hallowscythe", "Hallowgun", "Handsaw", "Harvester", "Heart Wand", "Heat", "Iceblaster",
    "Icebreaker", "Icecream", "Ice Dragon", "Iceflake", "Icepiercer", "Ice Shard", "Icewing",
    "Jinglegun", "Laser", "Lightbringer", "Logchopper", "Luger", "Lugercane", "Makeshift", "Minty",
    "Nebula", "Nightblade", "Niks Scythe", "Ocean", "Old Glory", "Orange Seer", "Ornament", "Pearl",
    "Pearlshine", "Peppermint", "Phantom", "Pixel", "Plasma Beam", "Plasma Blade", "Prismatic",
    "Pumpking", "Purple Seer", "Rainbow", "Rainbow Gun", "Raygun", "Red Luger", "Red Seer", "Rune",
    "Sakura", "Sands", "Saw", "Seer", "Shark", "Slasher", "Snowcannon", "Snow Dagger", "Snowflake",
    "Snowstorm", "Spectre", "Spider", "Sugar", "Sunrise", "Sunset", "Sweet", "Swirly Axe",
    "Swirly Blade", "Swirlygun", "Tides", "Traveler's Axe", "Traveler's Gun", "Treat", "Turkey",
    "Vampire's Axe", "Vampire's Edge", "Vampire's Gun", "Virtual", "Watergun", "Waves", "Winter's Edge",
    "Xenoknife", "Xenoshot", "Xmas", "Yellow Seer"
}

local RarityTint = {
    Chroma    = Color3.fromRGB(70, 40, 95),
    Godly     = Color3.fromRGB(110, 70, 30),
    Ancient   = Color3.fromRGB(60, 25, 90),
    Unique    = Color3.fromRGB(140, 50, 90),
    Legendary = Color3.fromRGB(95, 55, 25),
    Classic   = Color3.fromRGB(70, 70, 90),
    Vintage   = Color3.fromRGB(80, 75, 30),
    Rare      = Color3.fromRGB(35, 60, 95),
    Uncommon  = Color3.fromRGB(35, 70, 50),
    Common    = Color3.fromRGB(50, 50, 70),
}

local _rarityRank = {
    Chroma = 10, Godly = 9, Ancient = 8, Unique = 7,
    Classic = 6, Legendary = 5, Vintage = 4,
    Rare = 3, Uncommon = 2, Common = 1,
}

local allWeaponsList = {}
local _seenKeys = {}
for _, name in ipairs(ItemsTabAllowedNames) do
    local target = _itemsTabNormalize(name)
    local wantsChroma = string.find(target, "^chroma ") ~= nil
    local targetStripped = string.gsub(target, "^chroma ", "")

    local best, bestRank = nil, -1
    for _, entry in ipairs(WeaponCatalog) do
        local entryName = _itemsTabNormalize(entry.name)
        local entryIsChroma = entry.chroma == true

        local nameOk = false
        if wantsChroma then
            if entryIsChroma and (entryName == target or entryName == targetStripped) then
                nameOk = true
            end
        else
            if (not entryIsChroma) and entryName == target then
                nameOk = true
            end
        end

        if nameOk then
            local rank = _rarityRank[entry.rarity] or 0
            if rank > bestRank then
                best, bestRank = entry, rank
            end
        end
    end

    if best and not _seenKeys[best.key] then
        table.insert(allWeaponsList, best)
        _seenKeys[best.key] = true
    end
end

for i, entry in ipairs(allWeaponsList) do
	local wKey = entry.key
	local wName = entry.name
	local baseColor = RarityTint[entry.rarity] or RarityTint.Common
	local label = wName .. (entry.chroma and " [Chroma]" or "") .. "   (" .. entry.rarity .. " " .. entry.type .. ")"

    local weaponBtn = Instance.new("TextButton")
    weaponBtn.Size = UDim2.new(1, -6, 0, 22)
    weaponBtn.BackgroundColor3 = baseColor
    weaponBtn.BackgroundTransparency = 0.2
    weaponBtn.Text = label
    weaponBtn.Font = Enum.Font.SourceSans
    weaponBtn.TextSize = 12
    weaponBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponBtn.TextXAlignment = Enum.TextXAlignment.Left
    weaponBtn.TextTruncate = Enum.TextTruncate.AtEnd
    weaponBtn.Parent = weaponScrollFrame

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 6)
    btnPadding.PaddingRight = UDim.new(0, 6)
    btnPadding.Parent = weaponBtn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = weaponBtn

    weaponBtn.MouseButton1Click:Connect(function()
        OfferItemAnotherPlayer(wKey, "Weapons")
    end)

    weaponButtons[#weaponButtons + 1] = {button = weaponBtn, entry = entry}
end

local function GetSpawnerCatalogItem(entry)
	return findCatalogValueForInventoryItem({
		Name = entry.name,
		Key = entry.key,
		Type = entry.type,
		Rarity = entry.rarity,
		Chroma = entry.chroma,
	})
end

local function GetSpawnerValueText(entry)
	local item = GetSpawnerCatalogItem(entry)
	if not item then
		return "?"
	end
	return FormatCatalogValue(item.value)
end

local function GetSpawnerValueNumber(entry)
	local item = GetSpawnerCatalogItem(entry)
	if not item then
		return -1
	end
	return item._numericValue or tonumber(item.value) or -1
end

local function BuildSpawnerButtonLabel(entry, valueText)
	return entry.name .. (entry.chroma and " [Chroma]" or "")
		.. "   (" .. entry.rarity .. " " .. entry.type .. " | " .. tostring(valueText or GetSpawnerValueText(entry)) .. ")"
end

RefreshSpawnerButtons = function()
	local query = normalizeWeaponName(SpawnerSearchBox and SpawnerSearchBox.Text or "")
	local ordered = {}
	for _, info in ipairs(spawnerButtons) do
		info.valueText = GetSpawnerValueText(info.entry)
		info.sortValue = GetSpawnerValueNumber(info.entry)
		table.insert(ordered, info)
	end

	table.sort(ordered, function(a, b)
		if SpawnerSortMode == "value_desc" then
			if a.sortValue ~= b.sortValue then
				return a.sortValue > b.sortValue
			end
		elseif SpawnerSortMode == "value_asc" then
			local av = a.sortValue
			local bv = b.sortValue
			local aMissing = av < 0
			local bMissing = bv < 0
			if aMissing ~= bMissing then
				return not aMissing
			end
			if av ~= bv then
				return av < bv
			end
		else
			if a.defaultOrder ~= b.defaultOrder then
				return a.defaultOrder < b.defaultOrder
			end
		end
		return a.entry.name < b.entry.name
	end)

	local visibleOrder = 0
	for index, info in ipairs(ordered) do
		local btn = info.button
		btn.Text = BuildSpawnerButtonLabel(info.entry, info.valueText)
		local haystack = normalizeWeaponName(("%s %s %s %s"):format(
			tostring(info.entry.name or ""),
			tostring(info.entry.rarity or ""),
			tostring(info.entry.type or ""),
			tostring(info.valueText or "")
		))
		local visible = query == "" or string.find(haystack, query, 1, true) ~= nil
		btn.Visible = visible
		if visible then
			visibleOrder = visibleOrder + 1
			btn.LayoutOrder = visibleOrder
		else
			btn.LayoutOrder = #ordered + index
		end
	end
end

for _, entry in ipairs(WeaponCatalog) do
    local wKey = entry.key
    local wData = Sync.Weapons[wKey]
    if not _isSpawnerAllowed(entry.name) then continue end
    local baseColor = RarityTint[entry.rarity] or RarityTint.Common
    local tradable = _isTradable(wData)
    local label = BuildSpawnerButtonLabel(entry)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 22)
    btn.BackgroundColor3 = baseColor
    btn.BackgroundTransparency = tradable and 0.2 or 0.6
    btn.Text = label
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = spawnerScrollFrame

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 6)
    btnPad.PaddingRight = UDim.new(0, 6)
    btnPad.Parent = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local typed = tonumber(SpawnerAmountBox.Text)
        local amt = (typed and typed > 0) and typed or _randomAmount(entry.rarity, false)
        SpawnItem(wKey, amt, "Weapons")
    end)

    spawnerButtons[#spawnerButtons + 1] = {
		button = btn,
		entry = entry,
		tradable = tradable,
		defaultOrder = #spawnerButtons + 1,
	}
end

SpawnerSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if RefreshSpawnerButtons then
		RefreshSpawnerButtons()
	end
end)

if RefreshSpawnerButtons then
	RefreshSpawnerButtons()
end

-- === PLAYERS TAB VALUES ===
local playersStatusLabel = Instance.new("TextLabel")
playersStatusLabel.Size = UDim2.new(1, 0, 0, 16)
playersStatusLabel.BackgroundTransparency = 1
playersStatusLabel.Text = "Catalog loading..."
playersStatusLabel.Font = Enum.Font.Gotham
playersStatusLabel.TextSize = 12
playersStatusLabel.TextColor3 = Color3.fromRGB(187, 198, 213)
playersStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
playersStatusLabel.Parent = playersFrame

local playersListLabel = Instance.new("TextLabel")
playersListLabel.Size = UDim2.new(1, 0, 0, 18)
playersListLabel.BackgroundTransparency = 1
playersListLabel.Text = "Players in server"
playersListLabel.Font = Enum.Font.GothamMedium
playersListLabel.TextSize = 14
playersListLabel.TextColor3 = Color3.fromRGB(212, 220, 233)
playersListLabel.TextXAlignment = Enum.TextXAlignment.Left
playersListLabel.Parent = playersFrame

local playersScroll2 = Instance.new("ScrollingFrame")
playersScroll2.Size = UDim2.new(1, 0, 0, 220)
playersScroll2.BackgroundTransparency = 1
playersScroll2.BorderSizePixel = 0
playersScroll2.ScrollBarThickness = 6
playersScroll2.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
playersScroll2.CanvasSize = UDim2.new(0, 0, 0, 0)
playersScroll2.AutomaticCanvasSize = Enum.AutomaticSize.Y
playersScroll2.Parent = playersFrame

do
	local playersScrollLayout = Instance.new("UIListLayout")
	playersScrollLayout.FillDirection = Enum.FillDirection.Vertical
	playersScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	playersScrollLayout.Padding = UDim.new(0, 4)
	playersScrollLayout.Parent = playersScroll2
end

local function ClearPlayerValueRows()
	for _, child in pairs(playersScroll2:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	playerValueRows = {}
end

local function SortPlayerValueRows()
	local rows = {}
	for _, row in pairs(playerValueRows) do
		table.insert(rows, row)
	end

	table.sort(rows, function(a, b)
		local at = a.total or -1
		local bt = b.total or -1
		if at ~= bt then
			return at > bt
		end
		return a.player.Name < b.player.Name
	end)

	for index, row in ipairs(rows) do
		row.frame.LayoutOrder = index
		row.nameLabel.Text = ("#%d  %s"):format(index, row.player.Name)
	end
end

local function CreatePlayerValueRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	row.BackgroundTransparency = 0.3
	row.Parent = playersScroll2

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = row

	local pName = Instance.new("TextLabel")
	pName.Size = UDim2.new(0.5, -10, 1, 0)
	pName.Position = UDim2.new(0, 10, 0, 0)
	pName.BackgroundTransparency = 1
	pName.Text = player.Name
	pName.Font = Enum.Font.GothamBold
	pName.TextSize = 12
	pName.TextColor3 = Color3.fromRGB(240, 240, 250)
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.TextTruncate = Enum.TextTruncate.AtEnd
	pName.Parent = row

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0.18, 0, 1, 0)
	valueLbl.Position = UDim2.new(0.5, 0, 0, 0)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "..."
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 12
	valueLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.TextTruncate = Enum.TextTruncate.AtEnd
	valueLbl.Parent = row

	local pBtn = Instance.new("TextButton")
	pBtn.Size = UDim2.new(0, 74, 0, 24)
	pBtn.Position = UDim2.new(1, -80, 0.5, -12)
	pBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
	pBtn.Text = "Select"
	pBtn.Font = Enum.Font.Gotham
	pBtn.TextSize = 11
	pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	pBtn.Parent = row

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = pBtn

	pBtn.MouseButton1Click:Connect(function()
		TradeTable.Player2.Player = player.Name
		PartnerUserBox.Text = player.Name
		setActiveTab("Control")
	end)

	return {
		player = player,
		frame = row,
		nameLabel = pName,
		valueLabel = valueLbl,
		total = -1,
	}
end

local function UpdatePlayerValueRow(row)
	if not Values or not Values.byName then
		row.total = -1
		row.valueLabel.Text = "catalog"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		return
	end

	row.valueLabel.Text = "..."
	row.valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

	local okFetch, invOrErr = pcall(FetchPlayerInventory, row.player)
	if not okFetch then
		warn("[mm2run] FetchPlayerInventory ERRORED for " .. row.player.Name .. ": " .. tostring(invOrErr))
		row.total = -1
		row.valueLabel.Text = "err"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end

	if not invOrErr then
		row.total = -1
		row.valueLabel.Text = "?"
		row.valueLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
		return
	end

	local okCalc, total = pcall(function()
		local sum = CalculateInventoryValue(invOrErr, nil)
		return sum
	end)
	if not okCalc then
		warn("[mm2run] CalculateInventoryValue ERRORED for " .. row.player.Name .. ": " .. tostring(total))
		row.total = -1
		row.valueLabel.Text = "err"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end

	row.total = total
	row.valueLabel.Text = FormatValue(total)
	row.valueLabel.TextColor3 = (total > 0) and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(180, 180, 180)
end

RefreshPlayerValues = function()
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	local playersToShow = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer then
			table.insert(playersToShow, p)
		end
	end

	playerValuesRefreshInProgress = true
	ClearPlayerValueRows()
	for _, p in ipairs(playersToShow) do
		playerValueRows[p.Name] = CreatePlayerValueRow(p)
	end

	if #playersToShow == 0 then
		playerValuesRefreshInProgress = false
		playersStatusLabel.Text = "No other players in server"
		playersStatusLabel.TextColor3 = Color3.fromRGB(205, 171, 132)
		return
	end

	playersStatusLabel.Text = Values and Values.byName and "Refreshing values..." or "Catalog loading..."
	playersStatusLabel.TextColor3 = Color3.fromRGB(187, 198, 213)

	local pending = #playersToShow
	for _, row in pairs(playerValueRows) do
		task.spawn(function()
			UpdatePlayerValueRow(row)
			SortPlayerValueRows()
			pending = pending - 1
			if pending <= 0 then
				playerValuesRefreshInProgress = false
				local priced = 0
				local unknown = 0
				for _, finishedRow in pairs(playerValueRows) do
					if (finishedRow.total or -1) >= 0 then
						priced = priced + 1
					else
						unknown = unknown + 1
					end
				end
				playersStatusLabel.Text = ("Loaded %d player values, %d unknown"):format(priced, unknown)
				playersStatusLabel.TextColor3 = Color3.fromRGB(150, 220, 150)
			end
		end)
	end
end

createButton(playersFrame, "Refresh values", function()
	RefreshPlayerValues()
end)

PlayerAutoRefreshToggleButton = createButton(playersFrame, "Auto refresh: OFF", function()
	syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.enabled = not PlayerValuesAutoRefreshState.enabled
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	updatePlayerAutoRefreshButtonText()
	if PlayerValuesAutoRefreshState.enabled then
		setPlayerAutoRefreshStatus(("Auto refresh every %ss"):format(PlayerValuesAutoRefreshState.intervalSeconds), Color3.fromRGB(180, 220, 255))
	else
		setPlayerAutoRefreshStatus("Auto refresh disabled", Color3.fromRGB(190, 194, 205))
	end
end)

PlayerAutoRefreshSecondsBox = createInput(playersFrame, "Auto refresh every (1-300 sec):", tostring(PlayerValuesAutoRefreshState.intervalSeconds))
PlayerAutoRefreshSecondsBox.FocusLost:Connect(function()
	syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	if PlayerValuesAutoRefreshState.enabled then
		setPlayerAutoRefreshStatus(("Auto refresh every %ss"):format(PlayerValuesAutoRefreshState.intervalSeconds), Color3.fromRGB(180, 220, 255))
	end
end)

PlayerAutoRefreshStatusLabel = Instance.new("TextLabel")
PlayerAutoRefreshStatusLabel.Size = UDim2.new(1, 0, 0, 18)
PlayerAutoRefreshStatusLabel.BackgroundTransparency = 1
PlayerAutoRefreshStatusLabel.Text = "Auto refresh disabled"
PlayerAutoRefreshStatusLabel.Font = Enum.Font.GothamMedium
PlayerAutoRefreshStatusLabel.TextSize = 13
PlayerAutoRefreshStatusLabel.TextColor3 = Color3.fromRGB(190, 194, 205)
PlayerAutoRefreshStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerAutoRefreshStatusLabel.Parent = playersFrame

updatePlayerAutoRefreshButtonText()

task.defer(function()
	RefreshPlayerValues()
end)

Players.PlayerAdded:Connect(function()
	task.defer(function()
		RefreshPlayerValues()
	end)
end)

Players.PlayerRemoving:Connect(function()
	task.defer(function()
		RefreshPlayerValues()
	end)
end)

task.spawn(function()
	while true do
		task.wait(0.2)

		if not PlayerValuesAutoRefreshState.enabled then
			continue
		end

		syncPlayerAutoRefreshSettingsFromInputs()

		if playerValuesRefreshInProgress then
			setPlayerAutoRefreshStatus("Auto refresh paused: table is updating", Color3.fromRGB(255, 220, 100))
			continue
		end

		if not Values or not Values.byName then
			setPlayerAutoRefreshStatus("Auto refresh paused: catalog is loading", Color3.fromRGB(255, 220, 100))
			continue
		end

		local now = tick()
		local elapsed = now - (PlayerValuesAutoRefreshState.lastRefreshAt or 0)
		local remaining = PlayerValuesAutoRefreshState.intervalSeconds - elapsed

		if remaining <= 0 then
			PlayerValuesAutoRefreshState.lastRefreshAt = now
			setPlayerAutoRefreshStatus("Auto refreshing player table...", Color3.fromRGB(180, 220, 255))
			task.defer(function()
				RefreshPlayerValues()
			end)
		else
			setPlayerAutoRefreshStatus(("Next auto refresh in %.1fs"):format(remaining), Color3.fromRGB(180, 220, 255))
		end
	end
end)

task.spawn(function()
	local lastTick = tick()
	while true do
		task.wait(0.2)

		local now = tick()
		local delta = now - lastTick
		lastTick = now

		if not AutoBlockState.enabled then
			AutoBlockState.progressByName = {}
			AutoBlockState.cooldownUntilByName = {}
			AutoBlockState.busy = false
			AutoBlockState.busyTargetName = nil
			AutoBlockState.busyStartedAt = 0
			continue
		end

		syncAutoBlockSettingsFromInputs()

		if playerValuesRefreshInProgress or not Values or not Values.byName then
			local suffix = playerValuesRefreshInProgress and "values are loading" or "catalog is loading"
			setAutoBlockStatus("Timer paused: " .. suffix, Color3.fromRGB(255, 220, 100))
			continue
		end

		local activeNames = {}
		local bestCandidate = nil
		local bestProgress = 0

		for playerName, row in pairs(playerValueRows) do
			local playerObject = row.player
			local total = row.total or -1
			local cooldownUntil = AutoBlockState.cooldownUntilByName[playerName] or 0
			local coolingDown = cooldownUntil > now
			local qualified = playerObject
				and playerObject.Parent == Players
				and total >= 0
				and total < AutoBlockState.minValue
				and not AutoBlockState.blockedByName[playerName]
				and not coolingDown

			if qualified then
				activeNames[playerName] = true
				local nextProgress = math.min(AutoBlockState.delaySeconds, (AutoBlockState.progressByName[playerName] or 0) + delta)
				AutoBlockState.progressByName[playerName] = nextProgress
				if (not bestCandidate) or total > (bestCandidate.total or -1) then
					bestCandidate = row
					bestProgress = nextProgress
				end
			end
		end

		for playerName, _ in pairs(AutoBlockState.progressByName) do
			if not activeNames[playerName] then
				AutoBlockState.progressByName[playerName] = nil
			end
		end

		for playerName, cooldownUntil in pairs(AutoBlockState.cooldownUntilByName) do
			if cooldownUntil <= now then
				AutoBlockState.cooldownUntilByName[playerName] = nil
			end
		end

		if AutoBlockState.busy then
			if (now - (AutoBlockState.busyStartedAt or 0)) >= AutoBlockState.busyTimeoutSeconds then
				local stuckName = AutoBlockState.busyTargetName
				if stuckName and stuckName ~= "" then
					AutoBlockState.cooldownUntilByName[stuckName] = now + 5
					AutoBlockState.progressByName[stuckName] = nil
				end
				AutoBlockState.busy = false
				AutoBlockState.busyTargetName = nil
				AutoBlockState.busyStartedAt = 0
				setAutoBlockStatus("Previous block timed out, resuming scan", Color3.fromRGB(255, 150, 100))
			else
				local targetLabel = AutoBlockState.busyTargetName or "player"
				setAutoBlockStatus(("Blocking %s..."):format(targetLabel), Color3.fromRGB(255, 160, 120))
			end
			continue
		end

		if not bestCandidate then
			setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
			continue
		end

		local remaining = math.max(0, AutoBlockState.delaySeconds - bestProgress)
		setAutoBlockStatus(("Detected %s (%s). Blocking in %.1fs"):format(
			bestCandidate.player.Name,
			FormatValue(bestCandidate.total or 0),
			remaining
		), Color3.fromRGB(255, 220, 100))

		if bestProgress >= AutoBlockState.delaySeconds then
			local targetPlayer = bestCandidate.player
			if targetPlayer and targetPlayer.Parent == Players then
				AutoBlockState.busy = true
				AutoBlockState.busyTargetName = targetPlayer.Name
				AutoBlockState.busyStartedAt = now
				AutoBlockState.busyAttemptId = AutoBlockState.busyAttemptId + 1
				local attemptId = AutoBlockState.busyAttemptId
				AutoBlockState.progressByName[targetPlayer.Name] = nil
				setAutoBlockStatus(("Blocking %s..."):format(targetPlayer.Name), Color3.fromRGB(255, 160, 120))
				task.spawn(function()
					local ok, err = pcall(function()
						SilentBlockPlayer(targetPlayer)
					end)
					if attemptId ~= AutoBlockState.busyAttemptId then
						return
					end
					if ok then
						AutoBlockState.blockedByName[targetPlayer.Name] = true
						AutoBlockState.progressByName[targetPlayer.Name] = nil
						setAutoBlockStatus(("Blocked %s"):format(targetPlayer.Name), Color3.fromRGB(120, 255, 160))
					else
						AutoBlockState.cooldownUntilByName[targetPlayer.Name] = tick() + 5
						AutoBlockState.progressByName[targetPlayer.Name] = nil
						setAutoBlockStatus(("Block failed for %s"):format(targetPlayer.Name), Color3.fromRGB(255, 100, 100))
						warn("[mm2run/autoblock] failed to block " .. targetPlayer.Name .. ": " .. tostring(err))
					end
					AutoBlockState.busy = false
					AutoBlockState.busyTargetName = nil
					AutoBlockState.busyStartedAt = 0
				end)
			end
		end
	end
end)

print("[mm2run] System merged and running successfully!")




