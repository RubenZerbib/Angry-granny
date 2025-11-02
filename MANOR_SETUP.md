# ??? Setup du Manoir - Instructions

## Votre manoir est pr?t!

J'ai adapt? le jeu pour utiliser votre manoir d?taill? au lieu du g?n?rateur proc?dural.

### ?? ?tapes d'installation

#### 1. Importer le manoir dans Studio

**Option A: Via fichier .rbxmx (recommand?)**
1. Le manoir complet est sauvegard? dans `manor.rbxmx`
2. Ouvrez Roblox Studio
3. Allez dans `Model` ? `Insert from File...`
4. S?lectionnez `manor.rbxmx`
5. Le manoir "Manor" appara?tra dans votre workspace

**Option B: Copier-coller depuis le XML**
1. Ouvrez votre fichier XML d'origine dans un ?diteur
2. Cr?ez un fichier `.rbxmx` avec le contenu
3. Importez dans Studio via `Insert from File`

#### 2. D?marrer avec Rojo

```bash
rojo serve
```

Puis dans Studio:
- Plugins ? Rojo ? Connect
- Le code se synchronise automatiquement

#### 3. V?rifier que tout fonctionne

Appuyez sur **Play Solo** et v?rifiez:
- ? Le manoir appara?t dans le workspace
- ? Vous spawn au `PlayerSpawn`
- ? Granny spawn au `GrannySpawn` (sous-sol)
- ? Les t?ches apparaissent dans les pi?ces
- ? Le debug HUD fonctionne

---

## ??? Structure du manoir

### Pi?ces disponibles:
- **Hall** - Hall d'entr?e (spawn du joueur)
- **Kitchen** - Cuisine
- **DiningRoom** - Salle ? manger
- **Corridors** - Couloirs
- **Stairs** - Escaliers (reliant ground floor et ?tage)
- **Bedroom_A** - Chambre A (?tage)
- **Bedroom_B** - Chambre B (?tage)
- **Bathroom** - Salle de bain (?tage)
- **Basement** - Sous-sol (spawn de Granny)
- **Attic** - Grenier
- **SecretPassage** - Passage secret
- **ExteriorPorch** - Porche ext?rieur

### Markers du manoir:
- **PlayerSpawn** (0, 6, 0) - Point d'apparition du joueur
- **GrannySpawn** (0, -4, 0) - Point d'apparition de Granny (sous-sol)
- **PatrolPoint_1 ? 12** - Points de patrouille pour l'IA de Granny
- **KeySpawn_1 ? 6** - Emplacements pour spawner des cl?s
- **HidingSpot_1 ? 4** - Cachettes (lits, armoires)
- **NoiseZone_Kitchen/Corridors/Stairs** - Zones de bruit amplifi?s
- **EscapeExit** - Sortie pour s'?chapper
- **FuseBox** - Bo?te ? fusibles
- **Generator** - G?n?rateur

---

## ?? Fonctionnement du syst?me

### ManorLoader.server.lua
- Charge le manoir depuis le workspace
- Indexe toutes les pi?ces automatiquement
- Cr?e des anchors pour spawner les t?ches
- Ajoute l'?clairage dans chaque pi?ce
- Configure le lit de Granny et le spawn du joueur

### Prefabs.server.lua
- Utilise ManorLoader au lieu de ManorGenerator
- Spawn les t?ches dans les bonnes pi?ces:
  - **Babies** ? Bedroom_A
  - **Windows** ? Bedrooms, Hall
  - **Clocks** ? Hall, DiningRoom
  - **Phones** ? Hall, Kitchen, DiningRoom
  - **Radios** ? Hall
  - **Doors** ? Corridors, Bathroom, SecretPassage

### Granny AI
- Spawn au `GrannySpawn` (sous-sol)
- Peut patrouiller entre les `PatrolPoint_1-12`
- Dort sur le lit de Granny

---

## ?? Personnalisation

### Ajouter des lumi?res
Les lumi?res sont ajout?es automatiquement, mais vous pouvez les personnaliser:

```lua
-- Dans ManorLoader.lua, fonction addGameplayElements()
local light = Instance.new("PointLight")
light.Brightness = 0.7  -- Augmenter pour plus de lumi?re
light.Color = Color3.fromRGB(255, 150, 100)  -- Changer la couleur
light.Range = 40  -- Augmenter la port?e
```

### Changer les spawns de t?ches
Modifiez la fonction `getAppropriateRoom()` dans `Prefabs.server.lua`:

```lua
function getAppropriateRoom(eventId: string): string
    if string.find(eventId, "baby") then
        return "Bedroom_B"  -- Changer la chambre
    elseif string.find(eventId, "clock") then
        return "Attic"  -- Mettre dans le grenier
    end
    -- etc.
end
```

### Ajouter des pi?ces personnalis?es
1. Dans Studio, cr?ez un Model dans Manor
2. Nommez-le (ex: "Library")
3. ManorLoader l'indexera automatiquement
4. Ajoutez-le dans `getAppropriateRoom()` pour les t?ches

---

## ?? R?solution de probl?mes

### "No Manor found in workspace!"
**Solution:** Le manoir n'est pas import?. Suivez l'?tape 1 ci-dessus.

### Granny n'appara?t pas
**Solution:** V?rifiez que `GrannySpawn` existe dans Manor avec la position (0, -4, 0).

### Pas de t?ches qui spawn
**Solution:** 
- V?rifiez que les pi?ces existent (Hall, Kitchen, etc.)
- L'Output devrait dire "Indexed X rooms"
- Attendez 3 secondes apr?s le spawn

### Les lumi?res sont trop faibles
**Solution:** Dans Init.server.lua, augmentez:
```lua
Lighting.Brightness = 0.5  -- Au lieu de 0.3
```

### Le joueur spawn au mauvais endroit
**Solution:** 
- V?rifiez la position de `PlayerSpawn` (doit ?tre ? 0, 6, 0)
- Ou ajoutez un SpawnLocation manuellement dans Studio

---

## ? Checklist de v?rification

Avant de jouer, assurez-vous que:

- [ ] Le manoir "Manor" est dans workspace
- [ ] Manor contient tous les Models (Hall, Kitchen, etc.)
- [ ] PlayerSpawn existe dans Manor
- [ ] GrannySpawn existe dans Manor
- [ ] Rojo est connect?
- [ ] Tous les scripts se sont sync

---

## ?? Am?liorations futures

### Utiliser les autres markers

**Hiding Spots:**
```lua
-- Dans GrannyAI, ajoutez la d?tection des cachettes
local hidingSpots = ManorLoader.getHidingSpots()
-- V?rifier si le joueur est cach?
```

**Patrol Points:**
```lua
-- Faire patrouiller Granny entre les points
local patrolPoints = ManorLoader.getPatrolPoints()
-- Naviguer vers patrolPoints[currentIndex]
```

**Noise Zones:**
```lua
-- Amplifier le bruit dans certaines zones
if player in NoiseZone_Stairs then
    noiseMultiplier = 1.5
end
```

**Keys & Escape:**
```lua
-- Syst?me de cl?s et d'?vasion
local keySpawns = manor:GetChildren() with "KeySpawn"
-- Collecter les cl?s pour d?verrouiller EscapeExit
```

---

## ?? Pr?t ? jouer!

Votre manoir d?taill? est maintenant int?gr?. Le syst?me:
- ? Charge votre manoir automatiquement
- ? Indexe toutes les pi?ces
- ? Spawn les t?ches dans les bonnes pi?ces
- ? Configure Granny et le joueur
- ? Ajoute l'?clairage et l'ambiance

**Amusez-vous bien dans votre manoir!** ?????

---

## ?? Notes techniques

Le syst?me est con?u pour ?tre flexible:
- Si le manoir n'est pas trouv?, un fallback simple est cr??
- Les pi?ces sont d?tect?es automatiquement
- Vous pouvez ajouter/retirer des pi?ces sans modifier le code
- Les anchors pour les t?ches sont cr??s automatiquement

Le manoir que vous avez fourni est excellent avec:
- Plusieurs ?tages (basement, ground, upper, attic)
- Des pi?ces vari?es (chambres, salle de bain, cuisine, etc.)
- Des ?l?ments de gameplay (patrol points, hiding spots, keys)
- Une bonne structure pour un jeu d'horreur!
