--!strict
-- Interface de la boutique

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ItemCatalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Purchase = ReplicatedStorage.Remotes.Purchase

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cr?er l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Shop"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 600, 0, 500)
shopFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopFrame.BorderSizePixel = 2
shopFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
shopFrame.Visible = false
shopFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.Text = "Boutique"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = shopFrame

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

local itemsList = Instance.new("ScrollingFrame")
itemsList.Name = "ItemsList"
itemsList.Size = UDim2.new(1, -20, 1, -70)
itemsList.Position = UDim2.new(0, 10, 0, 60)
itemsList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
itemsList.BorderSizePixel = 1
itemsList.ScrollBarThickness = 10
itemsList.Parent = shopFrame

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.Padding = UDim.new(0, 5)
itemsLayout.Parent = itemsList

-- Remplir la boutique
for _, item in ipairs(ItemCatalog.Items) do
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = item.id
	itemFrame.Size = UDim2.new(1, -10, 0, 80)
	itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	itemFrame.BorderSizePixel = 1
	itemFrame.Parent = itemsList

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = itemFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
	descLabel.Position = UDim2.new(0, 5, 0.5, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = item.description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextScaled = false
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = itemFrame

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
	priceLabel.Position = UDim2.new(0.65, 0, 0, 5)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = if item.priceCoins then tostring(item.priceCoins) .. " Coins" else "IAP"
	priceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	priceLabel.TextScaled = true
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.Parent = itemFrame

	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.25, 0, 0.4, 0)
	buyButton.Position = UDim2.new(0.7, 0, 0.5, 0)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	buyButton.Text = "Acheter"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextScaled = true
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = itemFrame

	buyButton.MouseButton1Click:Connect(function()
		purchaseItem(item)
	end)
end

-- G?rer ouverture/fermeture
closeButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.B then
		shopFrame.Visible = not shopFrame.Visible
	end
end)

function purchaseItem(item: ItemCatalog.Item)
	-- Envoyer au serveur
	Purchase:FireServer(item.id)
end
