--!strict
-- Gestionnaire d'inputs global (si n?cessaire pour des contr?les avanc?s)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- D?sactiver le shift lock pour encourager la marche lente
UserInputService.MouseBehavior = Enum.MouseBehavior.Default

-- ?couter les mouvements pour d?tecter la course
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

-- R?duire la vitesse de marche par d?faut pour encourager le silence
humanoid.WalkSpeed = 12 -- Au lieu de 16 par d?faut

print("[Input] Syst?me d'input initialis?")
