# Granny Stealth - Jeu Roblox Production-Ready

Jeu de furtivit? et gestion du bruit inspir? de "Granny", enti?rement d?velopp? en **Luau** avec **Rojo**. Ce projet est pr?t pour la production et inclut tous les syst?mes essentiels : IA de Granny, syst?me de d?cibels, progression de nuits, 180 d?fis dynamiques, 30 items avec ?conomie IAP, s?curit? anti-triche, et interface utilisateur compl?te.

## ?? Vue d'ensemble

### Gameplay
- **Objectif** : Survivre ? chaque nuit en g?rant le niveau de bruit (d?cibels) pour ne pas r?veiller Granny
- **M?caniques principales** :
  - Syst?me de d?cibels serveur-only avec hotspots de bruit
  - IA de Granny (?tats : Sleeping ? Searching ? Chasing ? Cooldown)
  - 180 ?v?nements dynamiques (60 bases + variantes Hard/Chain)
  - 30 items avec monnaie douce (Coins) et IAP Roblox
  - Progression de nuits avec difficult? croissante
  
### Fonctionnalit?s cl?s
- ? Autorit? serveur compl?te (anti-triche)
- ? 180 d?fis uniques avec auto-g?n?ration
- ? ?conomie avec Coins + IAP (Game Passes & Dev Products)
- ? Map placeholder g?n?r?e automatiquement
- ? UX/HUD professionnelle (barre dB, boussole, boutique, tutoriels)
- ? Tests unitaires (TestEZ)
- ? CI/CD GitHub Actions
- ? Respect StyLua & Selene

---

## ?? Installation et Configuration

### Pr?requis
- [Roblox Studio](https://www.roblox.com/create)
- [Aftman](https://github.com/LPGhatguy/aftman) (gestionnaire d'outils)
- Git

### 1. Cloner le projet
```bash
git clone <url-du-repo>
cd <nom-du-repo>
```

### 2. Installer les outils
```bash
aftman install
```

Cela installe automatiquement :
- **Rojo** (sync code ? Roblox Studio)
- **StyLua** (formatage)
- **Selene** (linter)

### 3. D?marrer le serveur Rojo
```bash
rojo serve default.project.json
```

### 4. Connecter Roblox Studio
1. Ouvrir Roblox Studio
2. Installer le plugin **Rojo** depuis le [marketplace](https://create.roblox.com/marketplace/asset/13916111004/Rojo)
3. Cliquer sur "Connect" dans le plugin Rojo
4. Le code se synchronise automatiquement

### 5. Lancer le jeu
- Appuyer sur **Play Solo** dans Roblox Studio
- La Nuit 1 d?marre apr?s 3 secondes

---

## ??? Structure du projet

```
/workspace/
??? src/
?   ??? shared/          # Modules partag?s (client + serveur)
?   ?   ??? Config.lua              # Param?tres globaux
?   ?   ??? Decibel.lua             # Logique de d?cibels
?   ?   ??? NightDirector.lua       # Calcul des param?tres par nuit
?   ?   ??? RNG.lua                 # Utilitaires al?atoires
?   ?   ??? ItemCatalog.lua         # 30 items avec prix
?   ?   ??? AIParams.lua            # Param?tres IA Granny
?   ?   ??? EventRegistry.lua       # 180 ?v?nements
?   ?   ??? Util.lua                # Utilitaires g?n?raux
?   ??? server/          # Scripts serveur
?   ?   ??? Init.server.lua         # Point d'entr?e
?   ?   ??? DecibelServer.server.lua
?   ?   ??? NightServer.server.lua
?   ?   ??? GrannyAI.server.lua
?   ?   ??? EventsServer.server.lua
?   ?   ??? Economy.server.lua
?   ?   ??? Purchases.server.lua
?   ?   ??? Leaderstats.server.lua
?   ?   ??? Prefabs.server.lua      # G?n?ration de map
?   ?   ??? AntiCheat.server.lua
?   ??? client/          # Scripts client
?   ?   ??? HUD.client.lua          # Interface principale
?   ?   ??? Shop.client.lua         # Boutique
?   ?   ??? Compass.client.lua      # Boussole vers ?v?nements
?   ?   ??? Interact.client.lua     # Raycast + touche E
?   ?   ??? Audio.client.lua        # Sons d'ambiance
?   ?   ??? VFX.client.lua          # Vignette/flashs
?   ?   ??? Tutorials.client.lua    # Tutoriels Nuit 1
?   ?   ??? Notifier.client.lua     # Toasts
?   ?   ??? Input.client.lua        # Contr?les
?   ??? remotes/         # RemoteEvents
?       ??? DecibelUpdate.lua
?       ??? NightUpdate.lua
?       ??? EventSpawn.lua
?       ??? PlayerAction.lua
?       ??? GrannyState.lua
?       ??? Purchase.lua
?       ??? Reward.lua
??? tests/               # Tests unitaires
?   ??? decibel.spec.lua
?   ??? nightdirector.spec.lua
?   ??? itemcatalog.spec.lua
??? .github/workflows/   # CI/CD
?   ??? ci.yml
??? default.project.json # Configuration Rojo
??? aftman.toml
??? .stylua.toml
??? selene.toml
??? README.md
```

---

## ?? Syst?mes principaux

### 1. Syst?me de d?cibels
- **Autorit? serveur uniquement**
- Accumulation de bruit (pas du joueur, ?v?nements)
- Decay progressif selon la nuit
- Hotspots (top 3 sources de bruit des 5 derni?res secondes)
- Seuil de r?veil de Granny diminue avec les nuits

**Configuration** : `src/shared/Config.lua` ? `NightBase` et `Curves`

### 2. IA de Granny
- **?tats** :
  - `Sleeping` : Immobile, attend d?passement du seuil dB
  - `Searching` : Pathfinding vers le dernier hotspot
  - `Chasing` : Poursuite d'un joueur visible (c?ne de vision)
  - `Cooldown` : Retour au lit

- **Vitesse** : Augmente avec les nuits (Config.Curves.GrannySpeed)
- **Frappe** : Contact ? KO ? Fin de nuit (d?faite)

### 3. ?v?nements dynamiques (180 total)
- **60 bases** : Volets, sonnette, b?b?, chat, horloge, etc.
- **Variantes auto-g?n?r?es** :
  - `_Hard` : dbPulse ?1.25, resolveTime ?0.8, +1 ?tape
  - `_Chain` : Deux sous-objectifs encha?n?s

**Spawn** : Pond?ration par difficultyTier (1?5), respectant EventBudget et MaxConcurrent

**R?solution** : Interactions valid?es par AntiCheat (distance, LOS, cooldown)

### 4. Items & ?conomie (30 items)
#### Monnaie douce : Coins
- Gagn?s en fin de nuit (25 + 5?(nuit-1))
- Petites r?compenses par ?v?nement r?solu (+5 Coins)

#### IAP Roblox
- **Game Passes** (permanents) : silent_shoes, clock_tuner_pro, soft_close_hinges
- **Dev Products** (consommables) : radio_lullaby, earplugs_granny, pro_insoles_v2, etc.

**Prix sugg?r?s (Robux)** :
- Passes : 149
- Boosters forts : 100
- Consommables mid : 60
- Petits : 30

**?? Avant production** : Remplacer les IDs placeholders dans `src/shared/ItemCatalog.lua`

```lua
local GamePassIds = {
  silent_shoes = 1234567890,  -- Remplacer par votre ID
  clock_tuner_pro = 1234567891,
}
local DevProductIds = {
  radio_lullaby = 9876543210,  -- Remplacer par votre ID
  -- ...
}
```

**Cr?ation des IAP** :
1. Publier le jeu sur Roblox
2. Aller dans **Cr?ations** ? **Exp?riences** ? Votre jeu
3. **Mon?tisation** ? **Passes** / **Produits d?veloppeur**
4. Cr?er chaque item, noter les IDs, les ins?rer dans ItemCatalog.lua

#### Liste des 30 items

| ID | Nom | Type | Prix Coins | IAP | Effet |
|----|-----|------|-----------|-----|-------|
| earplugs_granny | Bouchons d'oreilles (Granny) | consumable | 250 | DevProduct | R?duit sensibilit? Granny 5min |
| radio_lullaby | Poste radio (berceuse) | consumable | 200 | DevProduct | -dB 2min |
| silent_shoes | Chaussures silencieuses | pass | - | GamePass | -50% bruit pas (permanent) |
| anti_creak_spray | Spray anti-grincement | consumable | 150 | - | R?duit bruits portes 3min |
| door_draft_blocker | Boudin de porte | consumable | 120 | - | Bloque sons sous portes 3min |
| felt_rug_drop | Tapis feutre portable | consumable | 100 | - | Zone silence 2min |
| cuckoo_decoy | Leurre coucou | consumable | 150 | - | R?sout events horloge 90s |
| baby_milk_instant | Lait instant b?b? | consumable | 120 | - | Calme b?b? instantan? |
| neighbor_text_note | Mot pour le voisin | consumable | 120 | - | Calme voisin 90s |
| acoustic_foam_kit | Mousse acoustique | consumable | 180 | - | R?duit transmission murs 3min |
| clock_tuner_pro | R?glage pro horloges | pass | - | GamePass | Immunit? events horloge |
| pro_insoles_v2 | Semelles pro v2 | booster | 180 | DevProduct | -70% bruit pas 2min |
| player_earmuffs | Casque anti-bruit (joueur) | consumable | 100 | - | Filtre audio 1min |
| catnip | Herbe ? chat | consumable | 120 | - | Distrait chat 90s |
| squeak_oil_kit | Kit huile anti-couine | consumable | 150 | - | ?limine grincements meubles 3min |
| shock_absorber_feet | Amortisseurs de pas | consumable | 180 | - | Amortit pas 3min |
| white_noise_box | Bo?te bruit blanc | consumable | 150 | DevProduct | Masque bruits 2min |
| weighted_doormat | Paillasson lest? | consumable | 120 | - | R?duit bruit entr?es 3min |
| anti_rattle_clips | Clips anti-cliquetis | consumable | 150 | - | Stabilise objets 3min |
| soft_close_hinges | Charni?res soft-close | pass | 600 | - | Portes silencieuses (permanent) |
| granny_sedative_tea | Tisane calmante (Granny) | consumable | 200 | - | Ralentit Granny 90s |
| night_vision_candle | Bougie vision douce | consumable | 120 | - | Am?liore vision 2min |
| toolkit_quickfix | Trousse quick-fix | consumable | 150 | - | Acc?l?re r?solution 1min |
| rubber_pads_pack | Patins caoutchouc | consumable | 120 | - | Emp?che grincements meubles 3min |
| wire_clamps_set | Serre-c?bles anti-vibrations | consumable | 120 | - | Stabilise c?bles 2min |
| rat_trap_auto | Pi?ge ? rat auto | consumable | 150 | - | Capture rats instantan? |
| grandfather_clock_key | Cl? d'horloge | consumable | 100 | - | Arr?te horloge grand-p?re |
| heavy_curtain_kit | Rideaux lourds | consumable | 180 | - | Bloque sons fen?tres 3min |
| soft_steps_training | Entra?nement pas doux | booster | 150 | - | Am?liore marche 90s |
| panic_button_radio | Bouton panique (radio) | consumable | 250 | DevProduct | -20dB instantan? |

### 5. Progression des nuits

**Param?tres de base (Nuit 1)** :
- Dur?e : 210s (3min30)
- Seuil r?veil : 70 dB
- Decay : 4 dB/s
- Vitesse Granny : 9 studs/s
- Max concurrent : 1 ?v?nement
- Budget : 3 ?v?nements total
- R?compense : 25 Coins

**?volution** (formules dans `Config.Curves`) :
- Seuil : Diminue de 2 dB/nuit (min 48)
- Decay : Diminue de 0.18/nuit (min 1.2)
- Vitesse Granny : +1.1/nuit
- Concurrent : +1 tous les 2 nuits (max 5)
- Budget : +1 toutes les 1.3 nuits
- Dur?e : +10s/nuit (max 360s)
- R?compense : +5 Coins/nuit

**Tuning** : Modifier les fonctions dans `src/shared/Config.lua` ? `Curves`

---

## ??? S?curit? & Anti-triche

### Principes
1. **Autorit? serveur** : D?cibels, ?tats Granny, ?conomie, r?solution ?v?nements
2. **Validation** : Toutes les actions joueur (PlayerAction) passent par AntiCheat
3. **Ratelimits** : Cooldowns configurables (Config.Ratelimits)
4. **V?rifications** :
   - Distance max (16 studs)
   - Line of Sight (raycast)
   - Cooldown par type d'action (250ms par d?faut)

### Configuration
`src/shared/Config.lua` :
```lua
Ratelimits = {
  PlayerAction = 120,  -- ms
  Purchase = 500,
  Interact = 120,
},
Interaction = {
  MaxDistance = 16,
  RequireLineOfSight = true,
  CooldownMs = 250,
}
```

---

## ?? Tests

### Ex?cution
Les tests utilisent **TestEZ** (framework Roblox). Pour l'instant, les tests sont fournis mais n?cessitent un runner compatible (ex: `TestService` dans Studio ou un runner CI custom).

### Tests inclus
- **decibel.spec.lua** : Decay, clamp, cumul, hotspots
- **nightdirector.spec.lua** : Bornes, monotonicit? des courbes
- **itemcatalog.spec.lua** : Sch?ma items, coh?rence types, prix

### CI
GitHub Actions (`.github/workflows/ci.yml`) :
- ? StyLua --check
- ? Selene
- ? Rojo build
- (Tests n?cessitent un runner Roblox, d?sactiv?s par d?faut)

---

## ?? Publication sur Roblox

### 1. Build local
```bash
rojo build default.project.json -o build.rbxl
```

### 2. Ouvrir dans Studio
- Ouvrir `build.rbxl`
- Tester en Play Solo

### 3. Publier
1. **Fichier** ? **Publier sur Roblox**
2. Choisir "Cr?er une nouvelle exp?rience" ou mettre ? jour une existante
3. Configurer les m?tadonn?es (nom, description, ic?ne)

### 4. Configurer les IAP
1. Aller sur [Roblox Creator Hub](https://create.roblox.com/dashboard/creations)
2. **Mon?tisation** ? Cr?er Game Passes & Dev Products
3. Noter les IDs, les ins?rer dans `src/shared/ItemCatalog.lua`
4. Re-publier

### 5. Remplacer la map (optionnel)
- Supprimer le mod?le "House" g?n?r? automatiquement dans workspace
- Ins?rer votre propre map
- Ajouter des Parts tagg?s "EventAnchor" pour les spawns d'?v?nements
- Ajouter un mod?le tagg? "Granny" avec un Humanoid
- Ajouter une Part tagg?e "GrannyBed" pour la position de d?part

---

## ?? Personnalisation

### Changer les param?tres de difficult?
**Fichier** : `src/shared/Config.lua`

Exemples :
```lua
-- Rendre le jeu plus difficile
Curves = {
  ThresholdDb = function(n) return math.max(40, 70 - (n-1)*3) end,  -- Seuil baisse plus vite
  DecayPerSecond = function(n) return math.max(1, 4 - (n-1)*0.25) end,  -- Decay plus lent
  GrannySpeed = function(n) return 10 + (n-1)*1.5 end,  -- Granny plus rapide
}

-- Rendre le jeu plus facile
NightBase = {
  DurationSec = 300,  -- 5 minutes
  ThresholdDb = 80,   -- Seuil plus ?lev?
  DecayPerSecond = 6, -- Decay plus rapide
}
```

### Ajouter des items
1. ?diter `src/shared/ItemCatalog.lua`
2. Ajouter une entr?e dans `ItemCatalog.Items`
3. Impl?menter l'effet dans `src/server/Economy.server.lua` ? `applyEffect()`

### Ajouter des ?v?nements
1. ?diter `src/shared/EventRegistry.lua`
2. Ajouter une entr?e dans `BaseEvents`
3. Cr?er le prefab correspondant dans `src/server/Prefabs.server.lua`

---

## ?? Debug & Logs

### Output serveur
V?rifier la console Output dans Roblox Studio :
```
[Server] Initialisation des syst?mes...
[Server] Tous les syst?mes initialis?s
[Server] Nuit 1 d?marr?e
```

### Output client
Les clients affichent :
- Connexions aux remotes
- ?v?nements spawn/resolve
- Achats

### Erreurs communes
| Erreur | Solution |
|--------|----------|
| "Granny introuvable" | Ajouter un mod?le tagg? "Granny" dans workspace |
| "Aucun anchor disponible" | Ajouter des Parts tagg?s "EventAnchor" |
| "Action rejet?e" | V?rifier distance/LOS, respecter cooldown |
| IAP ?choue | Remplacer les IDs placeholders par vos vrais IDs |

---

## ?? Ressources

- [Documentation Rojo](https://rojo.space/docs/)
- [API Roblox](https://create.roblox.com/docs)
- [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [Luau Style Guide](https://roblox.github.io/lua-style-guide/)

---

## ?? Licence

Ce projet est fourni "tel quel" pour usage ?ducatif et commercial. Vous ?tes libre de le modifier et de le publier sur Roblox.

---

## ?? Cr?dits

D?velopp? par Cursor AI selon les sp?cifications fournies.

- **Architecture** : Mod?le serveur-client avec Rojo
- **Outils** : Luau, Rojo, StyLua, Selene, TestEZ
- **CI/CD** : GitHub Actions

---

## ?? Checklist de lancement

- [ ] Remplacer les IDs IAP placeholders
- [ ] Tester Play Solo (Nuit 1 compl?te)
- [ ] V?rifier boutique (achat Coins + IAP)
- [ ] Tester au moins 5 nuits (progression)
- [ ] Remplacer la map placeholder (optionnel)
- [ ] Configurer les ic?nes/thumbnails
- [ ] Publier sur Roblox
- [ ] Cr?er Game Passes & Dev Products
- [ ] Tester en production (serveur public)
- [ ] Ajuster les prix selon le feedback joueurs

---

**Bon jeu ! ??**
