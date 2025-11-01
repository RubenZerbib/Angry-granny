--!strict
-- Tutoriels contextuels pour la nuit 1

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NightUpdate = ReplicatedStorage.Remotes.NightUpdate

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local tutorialShown = false

NightUpdate.OnClientEvent:Connect(function(data)
	if data.phase == "start" and data.night == 1 and not tutorialShown then
		tutorialShown = true
		showTutorial()
	end
end)

function showTutorial()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Tutorial"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local tips = {
		"Marchez doucement pour r?duire le bruit",
		"Utilisez la boussole pour trouver les ?v?nements",
		"Appuyez sur [B] pour ouvrir la boutique",
		"Appuyez sur [E] pour interagir avec les objets",
		"Surveillez la barre de d?cibels en haut",
	}

	for i, tip in ipairs(tips) do
		task.delay((i - 1) * 12, function()
			showTip(tip, screenGui)
		end)
	end

	-- Nettoyer apr?s 60s
	task.delay(60, function()
		screenGui:Destroy()
	end)
end

function showTip(text: string, parent: ScreenGui)
	local tipFrame = Instance.new("Frame")
	tipFrame.Size = UDim2.new(0, 500, 0, 80)
	tipFrame.Position = UDim2.new(0.5, -250, 0.3, 0)
	tipFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	tipFrame.BackgroundTransparency = 0.2
	tipFrame.BorderSizePixel = 2
	tipFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
	tipFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "?? " .. text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = tipFrame

	task.delay(10, function()
		tipFrame:Destroy()
	end)
end
