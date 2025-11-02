# ? Quick Start - Angry Granny Manor

## ?? D?marrage rapide (5 minutes)

### 1. Ouvrir dans Studio
```bash
rojo serve
```
Puis dans Roblox Studio:
- Plugins ? Rojo ? Connect
- Cliquez "Sync In"

### 2. Cr?er le manoir minimal

Dans l'explorateur de Studio, cr?ez dans **Workspace**:

```
Workspace/
?? Manor (Model)
   ?? PlayerSpawn (Part)
   ?  ?? Position: 0, 6, 0
   ?     Anchored: true
   ?     CanCollide: false
   ?     Transparency: 1
   ?
   ?? GrannySpawn (Part)
   ?  ?? Position: 0, -4, 0
   ?     Anchored: true
   ?     CanCollide: false
   ?     Transparency: 1
   ?
   ?? PatrolPoint_1 (Part)
   ?  ?? Position: 0, 3, 0
   ?
   ?? PatrolPoint_2 (Part)
   ?  ?? Position: -15, 3, 0
   ?
   ?? PatrolPoint_3 (Part)
   ?  ?? Position: 15, 3, 0
   ?
   ?? PatrolPoint_4 (Part)
      ?? Position: 0, 3, -15
```

**Toutes les Parts de patrol doivent avoir:**
- Anchored = true
- CanCollide = false  
- Transparency = 1 (invisibles)
- Size = (1, 1, 1)

### 3. Ajouter un sol simple

Dans **Manor**, cr?ez:
```
Floor (Part)
?? Size: 60, 1, 60
?? Position: 0, 0, 0
?? Anchored: true
?? Material: WoodPlanks
?? Color: Brown
```

### 4. Play!

Appuyez sur **Play** dans Studio. Vous devriez voir dans Output:
```
[ManorLoader] ? Manor found! Indexing...
[ManorLoader] ? Loaded: 1 rooms, 4 patrol points, 0 hiding spots
[GrannyAI] Loaded 4 patrol points
[SERVER] ? Init complete! Manor generated, Granny sleeping, ready to play!
```

**Le jeu fonctionne!** ??

---

## ?? Que faire maintenant?

### Test 1: Faire du bruit
- Courez (Shift) dans le manoir
- Observez l'indicateur de d?cibels en haut ? droite
- Quand il atteint 80dB, Granny se r?veille!

### Test 2: Observer Granny
- Elle patrouille entre vos 4 patrol points
- Elle vous cherche pendant 30 secondes
- Si elle ne trouve personne, elle retourne au lit

### Test 3: Compl?ter une t?che
- Attendez 10-15 secondes
- Une t?che appara?t (Window, Clock, Door, etc.)
- Approchez-vous et maintenez [E]
- +50 coins!

---

## ?? Pour aller plus loin

### Construire un vrai manoir
Lisez `MANOR_IMPORT_GUIDE.md` pour:
- Cr?er plusieurs pi?ces (Hall, Kitchen, Bedrooms...)
- Ajouter des murs et des plafonds
- Installer des lampes automatiques
- Placer 12+ patrol points
- Ajouter des hiding spots et keys

### Personnaliser le gameplay
Modifiez `src/shared/AIParams.lua`:
```lua
speed = 20,           -- Vitesse de Granny
visionRange = 40,     -- Distance de vision
searchDuration = 30,  -- Dur?e de recherche
```

### Ajouter du contenu
- Nouvelle t?che: ?ditez `src/server/InteractivePrefabs.server.lua`
- Nouvel item: ?ditez `src/shared/ItemCatalog.lua`
- Nouvelle m?canique: Cr?ez un nouveau server script

---

## ? Checklist minimum viable

- [ ] Model `Manor` dans Workspace
- [ ] Part `PlayerSpawn` (o? le joueur spawn)
- [ ] Part `GrannySpawn` (o? Granny spawn)
- [ ] 3-4 Parts `PatrolPoint_X` (pour la patrouille)
- [ ] Un sol (Part avec CanCollide=true)
- [ ] Rojo connect? et synchronis?
- [ ] Game lanc? avec Play

**Une fois ces 7 ?l?ments OK, le jeu fonctionne! ??**

---

## ?? Aide rapide

### Erreur: "Manor not found"
? V?rifiez le nom exact: `Manor` (M majuscule)

### Erreur: "Granny model has no Humanoid"
? Attendez 5 secondes, Granny est en train de spawn

### Granny ne bouge pas
? V?rifiez que PatrolPoint_X sont dans Manor (pas ailleurs)

### Joueur tombe dans le vide
? Cr?ez un Floor (Part) ? Y=0 avec CanCollide=true

---

**Temps estim?: 5-10 minutes ?**

Pour un manoir complet avec 10+ pi?ces: `MANOR_IMPORT_GUIDE.md`  
Pour comprendre l'int?gration: `MANOR_INTEGRATION_COMPLETE.md`
