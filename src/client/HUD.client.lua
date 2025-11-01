--!strict
-- HUD principal : barre dB, timer de nuit, ?v?nements actifs, ?tat Granny

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)

local DecibelUpdate = ReplicatedStorage.Remotes.DecibelUpdate
local NightUpdate = ReplicatedStorage.Remotes.NightUpdate
local EventSpawn = ReplicatedStorage.Remotes.EventSpawn
local GrannyState = ReplicatedStorage.Remotes.GrannyState

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cr?er l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Barre de d?cibels
local decibelFrame = Instance.new("Frame")
decibelFrame.Name = "DecibelFrame"
decibelFrame.Size = UDim2.new(0, 400, 0, 40)
decibelFrame.Position = UDim2.new(0.5, -200, 0, 20)
decibelFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
decibelFrame.BorderSizePixel = 2
decibelFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
decibelFrame.Parent = screenGui

local decibelBar = Instance.new("Frame")
decibelBar.Name = "Bar"
decibelBar.Size = UDim2.new(0, 0, 1, 0)
decibelBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
decibelBar.BorderSizePixel = 0
decibelBar.Parent = decibelFrame

local decibelLabel = Instance.new("TextLabel")
decibelLabel.Name = "Label"
decibelLabel.Size = UDim2.new(1, 0, 1, 0)
decibelLabel.BackgroundTransparency = 1
decibelLabel.Text = "0 dB / 70 dB"
decibelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
decibelLabel.TextScaled = true
decibelLabel.Font = Enum.Font.GothamBold
decibelLabel.Parent = decibelFrame

-- Timer de nuit
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(0, 200, 0, 40)
timerLabel.Position = UDim2.new(1, -220, 0, 20)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
timerLabel.BorderSizePixel = 2
timerLabel.BorderColor3 = Color3.fromRGB(200, 200, 200)
timerLabel.Text = "Nuit 1 - 3:30"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = screenGui

-- ?tat de Granny
local grannyLabel = Instance.new("TextLabel")
grannyLabel.Name = "GrannyState"
grannyLabel.Size = UDim2.new(0, 200, 0, 40)
grannyLabel.Position = UDim2.new(0, 20, 0, 20)
grannyLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
grannyLabel.BorderSizePixel = 2
grannyLabel.BorderColor3 = Color3.fromRGB(200, 200, 200)
grannyLabel.Text = "Granny: ??"
grannyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
grannyLabel.TextScaled = true
grannyLabel.Font = Enum.Font.GothamBold
grannyLabel.Parent = screenGui

-- Feed d'?v?nements actifs
local eventsFeed = Instance.new("ScrollingFrame")
eventsFeed.Name = "EventsFeed"
eventsFeed.Size = UDim2.new(0, 300, 0, 400)
eventsFeed.Position = UDim2.new(0, 20, 0.5, -200)
eventsFeed.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
eventsFeed.BackgroundTransparency = 0.3
eventsFeed.BorderSizePixel = 2
eventsFeed.BorderColor3 = Color3.fromRGB(200, 200, 200)
eventsFeed.ScrollBarThickness = 8
eventsFeed.Parent = screenGui

local eventsLayout = Instance.new("UIListLayout")
eventsLayout.Padding = UDim.new(0, 5)
eventsLayout.Parent = eventsFeed

-- ?tat
local currentDb = 0
local currentThreshold = 70
local nightData = { night = 1, duration = 210 }
local nightStartTime = tick()
local activeEventsData: { [string]: any } = {}

-- ?couter les remotes
DecibelUpdate.OnClientEvent:Connect(function(db, threshold, trend)
	currentDb = db
	currentThreshold = threshold
	updateDecibelBar()
end)

NightUpdate.OnClientEvent:Connect(function(data)
	if data.phase == "start" then
		nightData = data
		nightStartTime = tick()
	elseif data.phase == "victory" then
		-- Afficher victoire
		showNotification("Victoire ! +" .. tostring(data.reward) .. " Coins", Color3.fromRGB(0, 255, 0))
	elseif data.phase == "defeat" then
		showNotification("D?faite ! Granny vous a attrap?", Color3.fromRGB(255, 0, 0))
	end
end)

EventSpawn.OnClientEvent:Connect(function(data)
	activeEventsData[data.eventId] = data
	updateEventsFeed()
end)

GrannyState.OnClientEvent:Connect(function(data)
	updateGrannyState(data.state)
end)

function updateDecibelBar()
	local ratio = currentDb / 100
	decibelBar.Size = UDim2.new(ratio, 0, 1, 0)

	-- Couleur selon le niveau
	if currentDb < currentThreshold * 0.5 then
		decibelBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	elseif currentDb < currentThreshold * 0.8 then
		decibelBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	else
		decibelBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end

	decibelLabel.Text = string.format("%d dB / %d dB", math.floor(currentDb), currentThreshold)
end

function updateTimer()
	local elapsed = tick() - nightStartTime
	local remaining = math.max(0, nightData.duration - elapsed)
	timerLabel.Text = string.format("Nuit %d - %s", nightData.night, Util.formatTime(remaining))
end

function updateGrannyState(state: string)
	local emoji = "??"
	if state == "Searching" then
		emoji = "???"
	elseif state == "Chasing" then
		emoji = "??"
	elseif state == "Cooldown" then
		emoji = "??"
	end
	grannyLabel.Text = "Granny: " .. emoji
end

function updateEventsFeed()
	-- Nettoyer
	for _, child in ipairs(eventsFeed:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Ajouter les ?v?nements actifs
	for eventId, data in pairs(activeEventsData) do
		local frame = Instance.new("Frame")
		frame.Name = eventId
		frame.Size = UDim2.new(1, -10, 0, 40)
		frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		frame.BorderSizePixel = 1
		frame.Parent = eventsFeed

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = data.eventName
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.Gotham
		label.Parent = frame
	end
end

function showNotification(text: string, color: Color3)
	local notification = Instance.new("TextLabel")
	notification.Size = UDim2.new(0, 400, 0, 60)
	notification.Position = UDim2.new(0.5, -200, 0.8, 0)
	notification.BackgroundColor3 = color
	notification.Text = text
	notification.TextColor3 = Color3.fromRGB(255, 255, 255)
	notification.TextScaled = true
	notification.Font = Enum.Font.GothamBold
	notification.Parent = screenGui

	task.delay(3, function()
		notification:Destroy()
	end)
end

-- Boucle de mise ? jour
task.spawn(function()
	while true do
		updateTimer()
		task.wait(0.5)
	end
end)
