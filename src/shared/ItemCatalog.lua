--!strict
-- Catalogue complet des 30 items avec prix et effets

local ItemCatalog = {}

-- IDs placeholders pour IAP (remplacer avant production)
local GamePassIds = {
	silent_shoes = 1234567890,
	clock_tuner_pro = 1234567891,
	soft_close_hinges = 1234567892,
}

local DevProductIds = {
	radio_lullaby = 9876543210,
	earplugs_granny = 9876543211,
	pro_insoles_v2 = 9876543212,
	white_noise_box = 9876543213,
	panic_button_radio = 9876543214,
}

export type ItemType = "pass" | "consumable" | "booster"

export type Item = {
	id: string,
	name: string,
	itemType: ItemType,
	effectId: string,
	durationSec: number?,
	priceCoins: number?,
	devProductId: number?,
	gamePassId: number?,
	description: string,
}

ItemCatalog.Items = {
	-- 1
	{
		id = "earplugs_granny",
		name = "Bouchons d'oreilles (Granny)",
		itemType = "consumable",
		effectId = "granny_sensitivity_reduce",
		durationSec = 300,
		priceCoins = 250,
		devProductId = DevProductIds.earplugs_granny,
		description = "R?duit la sensibilit? auditive de Granny pendant 5 minutes",
	},
	-- 2
	{
		id = "radio_lullaby",
		name = "Poste radio (berceuse)",
		itemType = "consumable",
		effectId = "db_tick_negative",
		durationSec = 120,
		priceCoins = 200,
		devProductId = DevProductIds.radio_lullaby,
		description = "R?duit progressivement les d?cibels pendant 2 minutes",
	},
	-- 3
	{
		id = "silent_shoes",
		name = "Chaussures silencieuses",
		itemType = "pass",
		effectId = "step_noise_reduce",
		gamePassId = GamePassIds.silent_shoes,
		description = "R?duit le bruit des pas de 50% en permanence",
	},
	-- 4
	{
		id = "anti_creak_spray",
		name = "Spray anti-grincement",
		itemType = "consumable",
		effectId = "door_noise_reduce",
		durationSec = 180,
		priceCoins = 150,
		description = "R?duit les bruits de porte pendant 3 minutes",
	},
	-- 5
	{
		id = "door_draft_blocker",
		name = "Boudin de porte",
		itemType = "consumable",
		effectId = "door_seal",
		durationSec = 180,
		priceCoins = 120,
		description = "Bloque les sons passant sous les portes (placeable)",
	},
	-- 6
	{
		id = "felt_rug_drop",
		name = "Tapis feutre portable",
		itemType = "consumable",
		effectId = "area_silence",
		durationSec = 120,
		priceCoins = 100,
		description = "Cr?e une zone de silence temporaire",
	},
	-- 7
	{
		id = "cuckoo_decoy",
		name = "Leurre coucou",
		itemType = "consumable",
		effectId = "event_resolve_clock",
		durationSec = 90,
		priceCoins = 150,
		description = "R?sout automatiquement les ?v?nements d'horloge",
	},
	-- 8
	{
		id = "baby_milk_instant",
		name = "Lait instant b?b?",
		itemType = "consumable",
		effectId = "event_resolve_baby",
		priceCoins = 120,
		description = "Calme instantan?ment le b?b?",
	},
	-- 9
	{
		id = "neighbor_text_note",
		name = "Mot pour le voisin",
		itemType = "consumable",
		effectId = "event_resolve_neighbor",
		durationSec = 90,
		priceCoins = 120,
		description = "Calme le voisin pendant 90 secondes",
	},
	-- 10
	{
		id = "acoustic_foam_kit",
		name = "Mousse acoustique",
		itemType = "consumable",
		effectId = "wall_noise_reduce",
		durationSec = 180,
		priceCoins = 180,
		description = "R?duit la transmission sonore ? travers les murs",
	},
	-- 11
	{
		id = "clock_tuner_pro",
		name = "R?glage pro horloges",
		itemType = "pass",
		effectId = "clock_immunity",
		gamePassId = GamePassIds.clock_tuner_pro,
		description = "Immunit? permanente contre les ?v?nements d'horloge",
	},
	-- 12
	{
		id = "pro_insoles_v2",
		name = "Semelles pro v2",
		itemType = "booster",
		effectId = "step_noise_boost",
		durationSec = 120,
		priceCoins = 180,
		devProductId = DevProductIds.pro_insoles_v2,
		description = "R?duit drastiquement le bruit des pas pendant 2 minutes",
	},
	-- 13
	{
		id = "player_earmuffs",
		name = "Casque anti-bruit (joueur)",
		itemType = "consumable",
		effectId = "player_audio_filter",
		durationSec = 60,
		priceCoins = 100,
		description = "Filtre les sons ambiants pour mieux entendre Granny",
	},
	-- 14
	{
		id = "catnip",
		name = "Herbe ? chat",
		itemType = "consumable",
		effectId = "event_resolve_cat",
		durationSec = 90,
		priceCoins = 120,
		description = "Distrait le chat pendant 90 secondes",
	},
	-- 15
	{
		id = "squeak_oil_kit",
		name = "Kit huile anti-couine",
		itemType = "consumable",
		effectId = "furniture_noise_reduce",
		durationSec = 180,
		priceCoins = 150,
		description = "?limine les grincements des meubles",
	},
	-- 16
	{
		id = "shock_absorber_feet",
		name = "Amortisseurs de pas",
		itemType = "consumable",
		effectId = "step_dampening",
		durationSec = 180,
		priceCoins = 180,
		description = "Amortit l'impact des pas sur le sol",
	},
	-- 17
	{
		id = "white_noise_box",
		name = "Bo?te bruit blanc",
		itemType = "consumable",
		effectId = "db_mask",
		durationSec = 120,
		priceCoins = 150,
		devProductId = DevProductIds.white_noise_box,
		description = "Masque les autres bruits avec du bruit blanc",
	},
	-- 18
	{
		id = "weighted_doormat",
		name = "Paillasson lest?",
		itemType = "consumable",
		effectId = "entrance_silence",
		durationSec = 180,
		priceCoins = 120,
		description = "R?duit le bruit ? l'entr?e des pi?ces",
	},
	-- 19
	{
		id = "anti_rattle_clips",
		name = "Clips anti-cliquetis",
		itemType = "consumable",
		effectId = "object_stabilize",
		durationSec = 180,
		priceCoins = 150,
		description = "Stabilise les objets qui vibrent",
	},
	-- 20
	{
		id = "soft_close_hinges",
		name = "Charni?res soft-close",
		itemType = "pass",
		effectId = "door_silent_permanent",
		priceCoins = 600,
		gamePassId = GamePassIds.soft_close_hinges,
		description = "Toutes les portes se ferment silencieusement (premium soft currency)",
	},
	-- 21
	{
		id = "granny_sedative_tea",
		name = "Tisane calmante (Granny)",
		itemType = "consumable",
		effectId = "granny_slowdown",
		durationSec = 90,
		priceCoins = 200,
		description = "Ralentit Granny pendant 90 secondes",
	},
	-- 22
	{
		id = "night_vision_candle",
		name = "Bougie vision douce",
		itemType = "consumable",
		effectId = "vision_enhance",
		durationSec = 120,
		priceCoins = 120,
		description = "Am?liore la vision dans le noir",
	},
	-- 23
	{
		id = "toolkit_quickfix",
		name = "Trousse quick-fix",
		itemType = "consumable",
		effectId = "repair_speed",
		durationSec = 60,
		priceCoins = 150,
		description = "Acc?l?re la r?solution des ?v?nements",
	},
	-- 24
	{
		id = "rubber_pads_pack",
		name = "Patins caoutchouc",
		itemType = "consumable",
		effectId = "furniture_pads",
		durationSec = 180,
		priceCoins = 120,
		description = "Emp?che les meubles de grincer",
	},
	-- 25
	{
		id = "wire_clamps_set",
		name = "Serre-c?bles anti-vibrations",
		itemType = "consumable",
		effectId = "wire_stabilize",
		durationSec = 120,
		priceCoins = 120,
		description = "Stabilise les c?bles ?lectriques",
	},
	-- 26
	{
		id = "rat_trap_auto",
		name = "Pi?ge ? rat auto",
		itemType = "consumable",
		effectId = "event_resolve_rat",
		priceCoins = 150,
		description = "Capture automatiquement les rats",
	},
	-- 27
	{
		id = "grandfather_clock_key",
		name = "Cl? d'horloge",
		itemType = "consumable",
		effectId = "event_resolve_grandfather_clock",
		priceCoins = 100,
		description = "Arr?te l'horloge grand-p?re",
	},
	-- 28
	{
		id = "heavy_curtain_kit",
		name = "Rideaux lourds",
		itemType = "consumable",
		effectId = "window_noise_reduce",
		durationSec = 180,
		priceCoins = 180,
		description = "Bloque les sons venant des fen?tres",
	},
	-- 29
	{
		id = "soft_steps_training",
		name = "Entra?nement pas doux",
		itemType = "booster",
		effectId = "step_training",
		durationSec = 90,
		priceCoins = 150,
		description = "Am?liore la technique de marche silencieuse",
	},
	-- 30
	{
		id = "panic_button_radio",
		name = "Bouton panique (radio)",
		itemType = "consumable",
		effectId = "db_burst_negative",
		priceCoins = 250,
		devProductId = DevProductIds.panic_button_radio,
		description = "R?duit instantan?ment les d?cibels de fa?on significative",
	},
}

-- Prix IAP sugg?r?s en Robux (? configurer dans Roblox Studio)
ItemCatalog.SuggestedRobuxPrices = {
	-- Game Passes
	silent_shoes = 149,
	clock_tuner_pro = 149,
	soft_close_hinges = 149,

	-- Dev Products
	earplugs_granny = 100,
	radio_lullaby = 60,
	pro_insoles_v2 = 100,
	white_noise_box = 60,
	panic_button_radio = 100,
}

function ItemCatalog.getById(itemId: string): Item?
	for _, item in ipairs(ItemCatalog.Items) do
		if item.id == itemId then
			return item
		end
	end
	return nil
end

function ItemCatalog.getByGamePassId(gamePassId: number): Item?
	for _, item in ipairs(ItemCatalog.Items) do
		if item.gamePassId == gamePassId then
			return item
		end
	end
	return nil
end

function ItemCatalog.getByDevProductId(devProductId: number): Item?
	for _, item in ipairs(ItemCatalog.Items) do
		if item.devProductId == devProductId then
			return item
		end
	end
	return nil
end

return ItemCatalog
