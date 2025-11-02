# ??? Angry Granny Manor - Votre Manoir Personnalis?

## ?? R?sum?

Votre jeu Angry Granny est maintenant configur? pour charger **votre propre manoir personnalis?** depuis Roblox Studio! Le syst?me s'adapte automatiquement ? votre layout et fait fonctionner toutes les m?caniques de jeu.

---

## ?? Fichiers importants

### Guides d'utilisation (lisez dans cet ordre):
1. **`QUICK_START.md`** ? - D?marrage ultra-rapide (5 min)
2. **`MANOR_IMPORT_GUIDE.md`** ?? - Guide complet de construction
3. **`MANOR_INTEGRATION_COMPLETE.md`** ?? - D?tails techniques

### Code principal:
- **`src/server/ManorLoader.server.lua`** - Charge et configure le manoir
- **`src/server/GrannyAI.server.lua`** - IA avec patrouille intelligente
- **`src/server/Prefabs.server.lua`** - Spawn des objets dans les pi?ces

---

## ? D?marrage rapide

### Ce dont vous avez besoin (minimum):
```
Workspace/
?? Manor (Model)
   ?? PlayerSpawn (Part invisible au sol)
   ?? GrannySpawn (Part invisible au sous-sol)
   ?? PatrolPoint_1, PatrolPoint_2... (Parts invisibles)
   ?? Floor (Part avec CanCollide)
```

**C'est tout!** Le syst?me fait le reste automatiquement.

### Lancer le jeu:
```bash
rojo serve
# Dans Studio: Rojo ? Connect ? Sync In ? Play
```

---

## ?? Ce qui fonctionne automatiquement

### ? Chargement du manoir
- Trouve le Model `Manor` dans Workspace
- Indexe toutes les pi?ces (Models)
- Trouve tous les markers (PlayerSpawn, GrannySpawn, PatrolPoints, etc.)
- Cr?e un lit pour Granny au spawn point
- Cr?e un spawn location pour le joueur

### ? Lumi?res automatiques
- Trouve toutes les Parts nomm?es `Bulb`
- Ajoute un `PointLight` ? chacune
- ?clairage dynamique dans tout le manoir

### ? Patrouille de Granny
- Charge les patrol points
- Patrouille intelligemment entre eux
- Va vers les bruits d?tect?s
- Retourne au lit apr?s un timeout

### ? Spawn des t?ches
- Place les events dans les bonnes pi?ces
- Adapte le type d'event ? la pi?ce
- G?re les interactions automatiquement

---

## ??? Structure du manoir recommand?e

### Markers essentiels (Parts):
```
Manor/
?? PlayerSpawn (0, 6, 0) - Hall entrance
?? GrannySpawn (0, -4, 0) - Basement
?? PatrolPoint_1 (0, 3, 0) - Hall center
?? PatrolPoint_2 (-15, 3, 0) - Kitchen
?? PatrolPoint_3 (15, 3, 0) - Dining room
?? PatrolPoint_4 (0, 3, -20) - Main corridor
?? PatrolPoint_5 (10, 5, -20) - Stairs bottom
?? PatrolPoint_6 (10, 15, -25) - Stairs top
?? PatrolPoint_7+ ... (?tage, chambres, etc.)
```

### Pi?ces (Models):
```
Manor/
?? Hall (Model) - Entr?e principale
?  ?? Hall_Floor, Hall_Ceiling, Walls...
?  ?? Table_Center (Model)
?  ?? Main_Entrance (Model avec Door)
?
?? Kitchen (Model) - Cuisine
?  ?? Lamp_Kitchen (Model)
?  ?  ?? Bulb (Part) ? Auto-?clairage!
?  ?? ...
?
?? Bedroom_A, Bedroom_B (Models) - Chambres
?? Bathroom (Model) - Salle de bain
?? Basement (Model) - Sous-sol (spawn Granny)
?? ... autres pi?ces
```

---

## ?? Personnalisation

### Changer la vitesse de Granny:
`src/shared/AIParams.lua` ligne 7:
```lua
speed = 20,  -- Default. Augmentez pour plus difficile!
```

### Ajouter une nouvelle pi?ce:
1. Cr?ez un Model dans `Manor`
2. Ajoutez Floor, Ceiling, Walls
3. Ajoutez des PatrolPoints dedans
4. C'est tout! Le syst?me la d?tecte automatiquement

### Ajouter un type de t?che:
1. Cr?ez la fonction dans `src/server/InteractivePrefabs.server.lua`
2. Ajoutez-la ? `EventRegistry.lua`
3. Le syst?me l'utilise automatiquement

---

## ?? D?pannage

| Probl?me | Solution |
|----------|----------|
| "Manor not found" | Model doit s'appeler `Manor` (M majuscule) |
| Granny ne patrouille pas | Cr?ez des `PatrolPoint_1`, `PatrolPoint_2`, etc. |
| Joueur tombe dans le vide | Cr?ez un Floor ? Y=0 avec CanCollide=true |
| Pas de lumi?res | Parts `Bulb` doivent ?tre dans des Models de lampes |
| Granny ne spawn pas | Cr?ez une Part `GrannySpawn` |

**Output console doit afficher:**
```
[ManorLoader] ? Manor found! Indexing...
[ManorLoader] ? Loaded: X rooms, Y patrol points...
[GrannyAI] Loaded Y patrol points
[SERVER] ? Init complete!
```

---

## ?? Documentation compl?te

### Pour commencer:
- **`QUICK_START.md`** - 5 minutes pour jouer

### Pour construire:
- **`MANOR_IMPORT_GUIDE.md`** - Guide complet avec exemples

### Pour comprendre:
- **`MANOR_INTEGRATION_COMPLETE.md`** - Architecture technique

### Autres guides:
- **`GAMEPLAY_GUIDE.md`** - M?caniques de jeu
- **`BUILD_INSTRUCTIONS.md`** - Build et d?ploiement
- **`PROJECT_SUMMARY.md`** - Vue d'ensemble du projet

---

## ?? Checklist de d?marrage

- [ ] Rojo install? et configur?
- [ ] Model `Manor` cr?? dans Workspace
- [ ] `PlayerSpawn` cr?? (Part, Y=6)
- [ ] `GrannySpawn` cr?? (Part, Y=-4)
- [ ] 4+ `PatrolPoint_X` cr??s
- [ ] Un Floor cr?? (Part, CanCollide=true)
- [ ] `rojo serve` lanc?
- [ ] Sync In dans Studio
- [ ] Appuy? sur Play

**Si tous les ? sont OK, le jeu fonctionne!**

---

## ?? Prochaines ?tapes

1. **Testez le minimum viable** (QUICK_START.md)
2. **Construisez progressivement:**
   - Hall simple (1 pi?ce, 4 patrol points)
   - Ajoutez Kitchen, Dining room
   - Ajoutez l'?tage avec bedrooms
   - Ajoutez le basement pour Granny
   - Ajoutez l'attic, secret passages, etc.
3. **Peaufinez:**
   - Mat?riaux et couleurs
   - D?corations et furniture
   - Hiding spots, keys, noise zones
   - Lumi?res et ambiance
4. **Balancez la difficult?:**
   - Vitesse de Granny
   - Nombre de patrol points
   - Dur?e de recherche
   - Vision range

---

## ?? Astuces

### Pour un bon layout:
- **4-6 patrol points** par ?tage
- **1 patrol point** par pi?ce importante
- **Chemins logiques** entre les points (pas de t?l?portation)
- **Variez les hauteurs** (Y different pour chaque ?tage)

### Pour l'ambiance:
- **Lumi?res faibles** (Brightness = 0.8-1.2)
- **Fog** pour limiter la visibilit?
- **Mat?riaux us?s** (WoodPlanks vieilli, Brick)
- **Couleurs sombres** (Marrons, gris, noirs)

### Pour la difficult?:
- **Facile**: Speed=15, SearchDuration=20, 8 patrol points
- **Normal**: Speed=20, SearchDuration=30, 12 patrol points
- **Difficile**: Speed=25, SearchDuration=40, 16 patrol points

---

## ? C'est pr?t!

Votre jeu est **100% fonctionnel** et **pr?t ? personnaliser**!

**Amusez-vous bien! ?????**

---

*Pour toute question, consultez la documentation compl?te ou v?rifiez l'Output console dans Studio.*
