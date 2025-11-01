--!strict
-- Syst?me de notifications pour spawn/resolve/fail d'?v?nements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventSpawn = ReplicatedStorage.Remotes.EventSpawn
local Reward = ReplicatedStorage.Remotes.Reward

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cr?er l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Notifications"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local notificationsFrame = Instance.new("Frame")
notificationsFrame.Name = "NotificationsFrame"
notificationsFrame.Size = UDim2.new(0, 400, 0, 300)
notificationsFrame.Position = UDim2.new(1, -420, 0, 100)
notificationsFrame.BackgroundTransparency = 1
notificationsFrame.Parent = screenGui

local notificationsLayout = Instance.new("UIListLayout")
notificationsLayout.Padding = UDim.new(0, 5)
notificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notificationsLayout.Parent = notificationsFrame

EventSpawn.OnClientEvent:Connect(function(data)
	showNotification("?? " .. data.eventName, Color3.fromRGB(255, 100, 0))
end)

Reward.OnClientEvent:Connect(function(data)
	if data.type == "event_resolved" then
		showNotification("? " .. data.eventName .. " r?solu ! +" .. tostring(data.coins) .. " Coins", Color3.fromRGB(0, 255, 0))
	elseif data.type == "item_purchased" then
		showNotification("?? " .. data.itemName .. " achet? !", Color3.fromRGB(0, 200, 255))
	elseif data.type == "purchase_failed" then
		showNotification("? Pas assez de Coins", Color3.fromRGB(255, 0, 0))
	end
end)

function showNotification(text: string, color: Color3)
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 50)
	notification.BackgroundColor3 = color
	notification.BorderSizePixel = 2
	notification.BorderColor3 = Color3.fromRGB(255, 255, 255)
	notification.Parent = notificationsFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = notification

	task.delay(5, function()
		notification:Destroy()
	end)
end
