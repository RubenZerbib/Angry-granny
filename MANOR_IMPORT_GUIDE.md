# ??? Guide d'importation du Manoir

Votre manoir personnalis? est pr?t! Suivez ces ?tapes simples pour l'importer dans votre jeu Roblox.

## ?? M?thode 1: Construction directe dans Studio (RECOMMAND?E)

### ?tape 1: Ouvrir Roblox Studio
1. Lancez Roblox Studio
2. Ouvrez votre projet AngryGranny (ou cr?ez un nouveau place)

### ?tape 2: Cr?er le mod?le Manor
1. Dans l'explorateur, cr?ez un **Model** dans `Workspace`
2. Renommez-le `Manor`

### ?tape 3: Ajouter les markers essentiels

Cr?ez ces **Part** directement dans le mod?le `Manor`:

#### PlayerSpawn (Point d'apparition du joueur)
```
- Name: PlayerSpawn
- Position: (0, 6, 0)
- Size: (1, 1, 1)
- Anchored: true
- CanCollide: false
- Transparency: 1
- Material: Neon
```

#### GrannySpawn (Point d'apparition de Granny - sous-sol)
```
- Name: GrannySpawn
- Position: (0, -4, 0)
- Size: (1, 1, 1)
- Anchored: true
- CanCollide: false
- Transparency: 1
- Material: Neon
```

#### PatrolPoints (12 points de patrouille pour l'IA)
Cr?ez des Parts nomm?es `PatrolPoint_1` ? `PatrolPoint_12` avec:
- Positions sugg?r?es:
  - PatrolPoint_1: (0, 3, 0) - Hall central
  - PatrolPoint_2: (-15, 3, 0) - Cuisine
  - PatrolPoint_3: (-20, 3, 0) - Cuisine profonde
  - PatrolPoint_4: (-20, 3, -10) - Passage secret
  - PatrolPoint_5: (0, 3, -20) - Couloir principal
  - PatrolPoint_6: (10, 5, -20) - Escaliers
  - PatrolPoint_7: (10, 15, -25) - ?tage 1
  - PatrolPoint_8: (-15, 15, -30) - Chambre A
  - PatrolPoint_9: (15, 15, -30) - Chambre B
  - PatrolPoint_10: (0, 15, -40) - Salle de bain
  - PatrolPoint_11: (10, 5, -20) - Retour escaliers
  - PatrolPoint_12: (0, 3, -10) - Retour hall
- Propri?t?s: Anchored, CanCollide=false, Transparency=1

### ?tape 4: Construire les pi?ces

Pour chaque pi?ce (Hall, Kitchen, DiningRoom, Bedroom_A, Bedroom_B, etc.), cr?ez un **Model** dans `Manor` et ajoutez:

#### Structure de base
- **Floor** (sol): Part avec Material=WoodPlanks, Color=Brown
- **Ceiling** (plafond): Part avec Material=WoodPlanks
- **Walls** (murs): Parts avec Material=Brick, Color=Gray
  - North_Wall, South_Wall, East_Wall, West_Wall

#### Exemple: Hall (pi?ce principale)
```
Hall (Model)
?? Hall_Floor (Part)
?  ?? Position: (0, 0, 0)
?  ?? Size: (16, 0.5, 16)
?  ?? Material: WoodPlanks
?? Hall_Ceiling (Part)
?  ?? Position: (0, 10, 0)
?? North_Wall (Part)
?  ?? Position: (0, 5, -8)
?? South_Wall (Part)
?  ?? Position: (0, 5, 8)
?? East_Wall (Part)
?  ?? Position: (8, 5, 0)
?? West_Wall (Part)
   ?? Position: (-8, 5, 0)
```

#### Pi?ces recommand?es ? cr?er:
1. **Hall** (0, 0, 0) - 16x10x16 - Entr?e principale
2. **Kitchen** (-20, 0, 0) - 12x10x10 - Cuisine ? l'ouest
3. **DiningRoom** (20, 0, 0) - 14x10x12 - Salle ? manger ? l'est
4. **Corridors** (0, 0, -20) - 4x10x30 - Couloir nord
5. **Stairs** (10, 0, -20) - Escaliers (12 marches)
6. **Bedroom_A** (-15, 12, -30) - 10x10x12 - Chambre A (?tage)
7. **Bedroom_B** (15, 12, -30) - 10x10x12 - Chambre B (?tage)
8. **Bathroom** (0, 12, -40) - 8x10x8 - Salle de bain (?tage)
9. **Basement** (0, -10, 0) - 20x8x16 - Sous-sol (Granny)
10. **Attic** (0, 24, -20) - 16x8x12 - Grenier

### ?tape 5: Ajouter les lumi?res (optionnel mais recommand?)

Pour chaque pi?ce, cr?ez un Model nomm? `Lamp_[RoomName]` avec:
- **Base** (Part): Fixation au plafond
- **Bulb** (Part): Ampoule avec Material=Neon, Transparency=0.3, Color=Warm white

Le syst?me ajoutera automatiquement des **PointLight** ? toutes les ampoules!

### ?tape 6: Tester
1. Sauvegardez votre place
2. Utilisez Rojo pour synchroniser: `rojo serve`
3. Lancez le jeu et v?rifiez que:
   - Le joueur spawn dans le Hall
   - Granny spawn dans le Basement
   - Les lumi?res s'allument automatiquement
   - Les patrol points sont utilis?s par l'IA

---

## ?? M?thode 2: Utiliser votre XML (Avanc?)

Si vous avez d?j? construit votre manoir dans un outil externe et avez un fichier XML:

### Option A: Importer via InsertService (recommand?)
1. Publiez votre manoir comme Model sur Roblox
2. R?cup?rez l'Asset ID
3. Modifiez `ManorLoader.server.lua` ligne 16:
```lua
-- Remplacez ceci:
manor = workspace:FindFirstChild("Manor")

-- Par ceci (avec votre Asset ID):
local InsertService = game:GetService("InsertService")
manor = InsertService:LoadAsset(YOUR_ASSET_ID):GetChildren()[1]
manor.Parent = workspace
```

### Option B: Copier-coller dans Studio
1. Construisez le manoir dans une place s?par?e
2. S?lectionnez tout le mod?le Manor
3. Ctrl+C pour copier
4. Ouvrez votre place AngryGranny
5. Ctrl+V dans Workspace

---

## ? V?rification

Apr?s l'importation, v?rifiez dans l'Output Console:
```
[ManorLoader] ? Manor found! Indexing...
[ManorLoader] ? Loaded: 10 rooms, 12 patrol points, 4 hiding spots
[ManorLoader] Added light to Workspace.Manor.Kitchen.Lamp_Kitchen.Bulb
...
[GrannyAI] Loaded 12 patrol points
[SERVER] ? Init complete! Manor generated, Granny sleeping, ready to play!
```

## ?? Pr?t ? jouer!

Votre manoir est maintenant int?gr?! Le jeu va:
- ? Charger votre manoir du Workspace
- ? Ajouter automatiquement les lumi?res
- ? Configurer les spawn points
- ? Faire patrouiller Granny entre les points
- ? Faire fonctionner toutes les m?caniques de jeu

**Conseil**: Commencez avec une version simple (Hall + Basement + quelques patrol points) puis ajoutez progressivement les autres pi?ces!

## ?? D?pannage

### "Manor not found"
? V?rifiez que le Model s'appelle exactement `Manor` (majuscule M) dans Workspace

### "No patrol points"
? Cr?ez au moins 3-4 Parts nomm?s `PatrolPoint_1`, `PatrolPoint_2`, etc.

### Granny ne bouge pas
? V?rifiez que les patrol points sont dans `Manor` (pas dans un sous-mod?le)

### Pas de lumi?res
? V?rifiez que vos lampes ont une Part nomm?e `Bulb` avec Material=Neon

---

**Bon jeu! ??**
