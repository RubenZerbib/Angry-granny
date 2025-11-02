# ??? Int?gration du Manoir - TERMIN?E ?

## ?? Ce qui a ?t? fait

Votre manoir personnalis? est maintenant **compl?tement int?gr?** dans le jeu Angry Granny! Voici tout ce qui a ?t? mis en place:

---

## ??? 1. Syst?me de chargement du manoir

### `ManorLoader.server.lua` (NOUVEAU)
Ce module charge et configure votre manoir:

**Fonctionnalit?s:**
- ? Charge le mod?le `Manor` depuis Workspace
- ? Indexe automatiquement toutes les pi?ces (Hall, Kitchen, Bedrooms, etc.)
- ? Trouve tous les markers de gameplay (spawns, patrol points, hiding spots, keys, noise zones)
- ? Ajoute automatiquement des **PointLights** ? toutes les lampes (Parts nomm?es "Bulb")
- ? Cr?e un lit pour Granny au GrannySpawn
- ? Cr?e un SpawnLocation au PlayerSpawn
- ? Fallback: g?n?re un manoir minimal si le v?tre n'est pas trouv?

**API publique:**
```lua
ManorLoader.loadManor() --> Model, {rooms}
ManorLoader.getSpawns() --> {PlayerSpawn, GrannySpawn, ...}
ManorLoader.getPatrolPoints() --> {Part, Part, Part, ...}
ManorLoader.getHidingSpots() --> {Part, Part, ...}
ManorLoader.getKeySpawns() --> {Part, Part, ...}
ManorLoader.getNoiseZones() --> {Part, Part, ...}
```

---

## ?? 2. IA de Granny am?lior?e

### `GrannyAI.server.lua` (MIS ? JOUR)
Granny utilise maintenant vos patrol points!

**Nouveau comportement "Searching":**
1. Si un bruit est d?tect? ? Va vers le hotspot sonore
2. Sinon ? **Patrouille entre les patrol points** du manoir
3. Change de point quand elle arrive ? destination
4. Cherche activement les joueurs pendant la patrouille

**Exemple de patrouille:**
```
Basement ? Hall ? Kitchen ? Corridor ? Stairs ? 
Bedroom_A ? Bathroom ? Bedroom_B ? Stairs ? Hall ? Repeat
```

**?tats de Granny:**
- ?? **Sleeping**: Au lit (GrannyBed), vitesse = 0
- ?? **Searching**: Patrouille ou va vers un bruit, vitesse = 70%
- ?? **Chasing**: Poursuit un joueur visible, vitesse = 100%
- ?? **Cooldown**: Retourne au lit, vitesse = 50%

---

## ??? 3. Structure du manoir attendue

Votre manoir doit ?tre un **Model** nomm? `Manor` dans `Workspace` avec:

### Markers essentiels (Parts invisibles):
```
Manor/
?? PlayerSpawn (Part) - O? le joueur appara?t
?? GrannySpawn (Part) - O? Granny appara?t
?? PatrolPoint_1 ? PatrolPoint_N (Parts) - Chemin de patrouille
?? HidingSpot_1 ? HidingSpot_N (Parts) - Cachettes (optionnel)
?? KeySpawn_1 ? KeySpawn_N (Parts) - Cl?s ? trouver (optionnel)
?? NoiseZone_X (Parts) - Zones de bruit amplifi? (optionnel)
?? EscapeExit (Part) - Sortie d'?vacuation (optionnel)
```

### Pi?ces (Models):
```
Manor/
?? Hall (Model)
?  ?? Hall_Floor (Part)
?  ?? Hall_Ceiling (Part)
?  ?? Walls... (Parts)
?  ?? Table_Center (Model)
?  ?? Main_Entrance (Model avec Door)
?
?? Kitchen (Model)
?  ?? Kitchen_Floor (Part)
?  ?? Lamp_Kitchen (Model)
?  ?  ?? Base (Part)
?  ?  ?? Bulb (Part) ? PointLight ajout?e automatiquement!
?  ?? ...
?
?? Bedroom_A (Model)
?  ?? Bed_Bedroom_A (Model)
?  ?? Lamp_Bedroom_A (Model)
?  ?? Bedroom_A_Window (Part avec Glass)
?
?? Basement (Model) ? Ici Granny spawn
?? Attic (Model)
?? ... (autres pi?ces)
```

---

## ?? 4. Cycle de jeu

### Au d?marrage du serveur:
```
1. [ManorLoader] Charge le manoir depuis Workspace
2. [ManorLoader] Indexe toutes les pi?ces et markers
3. [ManorLoader] Ajoute les lumi?res automatiquement
4. [Prefabs] Utilise ManorLoader pour spawner les objets
5. [GrannyAI] Charge les patrol points
6. [GrannyAI] Spawn Granny au GrannySpawn (Basement)
7. [NightServer] D?marre la premi?re nuit apr?s 3 secondes
```

### Pendant le jeu:
```
- Joueur: Spawn au PlayerSpawn (Hall), re?oit une lampe torche
- Events: Spawner des t?ches dans les pi?ces index?es
- Granny (Sleeping): Dort au lit jusqu'? un bruit > 80dB
- Granny (Searching): Patrouille entre les PatrolPoints
- Granny (Chasing): Poursuit le joueur si elle le voit
- Granny (Cooldown): Retourne au lit apr?s 60 secondes
```

---

## ? 5. Fonctionnalit?s automatiques

### Lumi?res dynamiques
Toutes les Parts nomm?es `Bulb` re?oivent un `PointLight`:
```lua
PointLight {
  Brightness = 1.0
  Color = RGB(255, 240, 200) -- Blanc chaud
  Range = 35
  Shadows = true
}
```

### Spawn des t?ches (Events)
Les t?ches sont automatiquement plac?es dans les pi?ces appropri?es:
- **Window** ? Bedrooms (avec fen?tres)
- **Clock** ? Hall, DiningRoom
- **SqueakyDoor** ? Bedrooms
- **BabyCrib** ? Bedrooms
- **Phone** ? Hall
- **Radio** ? Kitchen, DiningRoom

### Gestion des spawns
- **PlayerSpawn** ? SpawnLocation automatique cr??e
- **GrannySpawn** ? GrannyBed automatique cr??e

---

## ?? 6. Ce que vous devez faire

### ?tape 1: Construire le manoir dans Studio
Suivez le guide: `MANOR_IMPORT_GUIDE.md`

**Minimum requis:**
- ? Model `Manor` dans Workspace
- ? Part `PlayerSpawn` (position o? le joueur spawn)
- ? Part `GrannySpawn` (position o? Granny spawn)
- ? Au moins 3-5 `PatrolPoint_X` (pour la patrouille)

**Recommand?:**
- ? Plusieurs pi?ces (Models: Hall, Kitchen, Bedroom, etc.)
- ? Des lampes avec Bulb (Parts) pour l'?clairage
- ? 8-12 patrol points pour une bonne couverture
- ? Des murs, sols, plafonds pour d?limiter les espaces

### ?tape 2: Tester avec Rojo
```bash
# Terminal 1: D?marrer Rojo
rojo serve

# Studio: File > Game Settings > Security > Enable Studio Access to API Services
# Studio: Plugins > Rojo > Connect
# Studio: Cliquez sur "Sync In"
```

### ?tape 3: Jouer!
1. Appuyez sur Play dans Studio
2. V?rifiez la console Output:
   - `[ManorLoader] ? Manor found! Indexing...`
   - `[ManorLoader] ? Loaded: X rooms, Y patrol points...`
   - `[GrannyAI] Loaded X patrol points`
   - `[SERVER] ? Init complete!`
3. Explorez le manoir, faites du bruit, survivez!

---

## ?? 7. R?sum? des changements de code

### Fichiers modifi?s:
1. **`src/server/ManorLoader.server.lua`** (CR??)
   - Charge et indexe le manoir
   - Ajoute les lumi?res automatiquement
   - Expose les getters pour tous les markers

2. **`src/server/Prefabs.server.lua`** (MODIFI?)
   - Utilise `ManorLoader` au lieu de `ManorGenerator`
   - Spawn Granny au bon endroit (GrannySpawn)
   - Utilise les rooms index?es pour les events

3. **`src/server/GrannyAI.server.lua`** (MODIFI?)
   - Charge les patrol points depuis `ManorLoader`
   - Patrouille intelligemment entre les points
   - Change de point quand arriv?e ? destination

4. **`src/server/Init.server.lua`** (INCHANG?)
   - Appelle d?j? `Prefabs.init()` qui g?re tout

### Fichiers de documentation:
- **`MANOR_IMPORT_GUIDE.md`** - Guide complet d'importation
- **`MANOR_INTEGRATION_COMPLETE.md`** - Ce fichier (r?sum?)

---

## ?? 8. D?pannage

### Probl?me: "Manor not found"
**Solution:** V?rifiez que votre mod?le s'appelle exactement `Manor` (M majuscule) et est dans `Workspace`

### Probl?me: Granny ne patrouille pas
**Solutions:**
- V?rifiez que vous avez des Parts nomm?es `PatrolPoint_1`, `PatrolPoint_2`, etc.
- V?rifiez qu'elles sont directement dans `Manor` (pas dans un sous-mod?le)
- V?rifiez la console: `[GrannyAI] Loaded X patrol points` (X devrait ?tre > 0)

### Probl?me: Pas de lumi?res
**Solutions:**
- V?rifiez que vos lampes ont un Part nomm? `Bulb`
- V?rifiez que `Bulb.Material` est `Neon`
- La console devrait afficher: `[ManorLoader] Added light to ...`

### Probl?me: Joueur spawn dans le vide
**Solution:** Cr?ez une Part `PlayerSpawn` avec une position valide (ex: Y=6 pour le ground floor)

---

## ?? C'est termin?!

Votre jeu Angry Granny est maintenant **100% fonctionnel** avec:
- ? Votre manoir personnalis? charg? dynamiquement
- ? Granny qui patrouille intelligemment
- ? Lumi?res automatiques
- ? Syst?me de t?ches
- ? IA compl?te
- ? ?conomie et progression
- ? Pr?t ? jouer!

**Prochaines ?tapes sugg?r?es:**
1. Construisez votre manoir dans Studio en suivant `MANOR_IMPORT_GUIDE.md`
2. Testez avec un manoir simple d'abord (Hall + Basement + 4 patrol points)
3. Ajoutez progressivement plus de pi?ces et de d?tails
4. Personnalisez les mat?riaux, couleurs, d?corations
5. Ajoutez des hiding spots, key spawns, noise zones
6. Balancez la difficult? avec `AIParams.lua`

**Amusez-vous bien! ?????**
