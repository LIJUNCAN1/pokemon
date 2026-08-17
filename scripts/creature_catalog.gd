class_name CreatureCatalog
extends RefCounted

const LEGACY_ROOT := "res://素材/宝可梦图/"
const NEW_ROOT := "res://素材/图鉴/角色/"
const NEW_TRAIT_ROOT := "res://assets/characters/creatures/new_traits/"
const LEGACY_STABLE_ROOT := "res://assets/characters/creatures/legacy_stable/"

const SYNERGY_ORDER: Array[String] = ["自然", "火", "水", "雷", "冰", "岩", "月影", "星辉", "格斗", "飞行", "亡灵", "风", "晶石", "植物", "机械", "灵体", "野兽", "守护", "龙族", "虫群"]
const ELEMENTS: Array[String] = ["自然", "火", "水", "雷", "冰", "岩", "月影", "星辉", "格斗", "飞行", "亡灵", "风", "晶石"]
const RACES: Array[String] = ["植物", "机械", "灵体", "野兽", "守护", "龙族", "虫群"]
const RARITY_NAMES: Array[String] = ["普通", "优秀", "稀有", "史诗", "传说"]
const RARITY_STAT_MULTIPLIERS: Array[float] = [1.0, 1.12, 1.25, 1.42, 1.62]
const RARITY_CHARGE_MULTIPLIERS: Array[float] = [1.0, 1.04, 1.08, 1.12, 1.16]
const STAR_GROWTH: Array[Dictionary] = [
	{"hp": 1.0, "damage": 1.0, "charge": 1.0},
	{"hp": 1.65, "damage": 1.55, "charge": 1.08},
	{"hp": 2.55, "damage": 2.35, "charge": 1.16},
]
const TRAIT_OVERRIDES: Dictionary = {
	"烛灵": ["火", "灵体"], "岩甲龟": ["岩", "守护"], "夜翼兽": ["雷", "灵体"],
	"冰角鹿": ["冰", "野兽"], "深海贤者": ["水", "龙族"], "绵云羊": ["雷", "野兽"],
	"烈焰犬": ["火", "野兽"], "森冠鹿": ["自然", "野兽"], "潮汐王": ["水", "龙族"],
	"潮汐卫": ["水", "龙族"], "泡泡灵": ["水", "灵体"], "水滴灵": ["水", "灵体"],
	"炽焰狼王": ["火", "野兽"], "炎鬃狼": ["火", "野兽"], "赤尾狐": ["火", "野兽"],
	"小火狐": ["火", "野兽"], "小冰企鹅": ["冰", "野兽"], "冰冠企鹅": ["冰", "守护"],
	"苔岩守卫": ["自然", "岩", "守护"], "晶背龟": ["岩", "守护"],
}
const SYNERGY_PRESENTATION: Dictionary = {
	"自然": ["res://assets/ui/trait_icons/new_set/nature.png", "a8a8a8"],
	"火": ["res://assets/ui/trait_icons/new_set/fire.png", "fc9833"],
	"水": ["res://assets/ui/trait_icons/new_set/water.png", "4f9be6"],
	"雷": ["res://assets/ui/trait_icons/new_set/lightning.png", "f7d542"],
	"冰": ["res://assets/ui/trait_icons/new_set/ice.png", "76d4c9"],
	"岩": ["res://assets/ui/trait_icons/new_set/rock.png", "d77e47"],
	"植物": ["res://assets/ui/trait_icons/new_set/plant.png", "57c061"],
	"机械": ["res://assets/ui/trait_icons/new_set/mechanical.png", "5195a1"],
	"灵体": ["res://assets/ui/trait_icons/new_set/spirit.png", "646dc2"],
	"野兽": ["res://assets/ui/trait_icons/beast.png", "697078"],
	"守护": ["res://assets/ui/trait_icons/guardian.png", "d09a3d"],
	"龙族": ["res://assets/ui/trait_icons/new_set/dragon.png", "137ed3"],
	"虫群": ["res://assets/ui/trait_icons/new_set/insect.png", "96c025"],
	"月影": ["res://assets/ui/trait_icons/new_set/moon.png", "70717e"],
	"星辉": ["res://assets/ui/trait_icons/new_set/starlight.png", "eb7ada"],
	"格斗": ["res://assets/ui/trait_icons/new_set/fighter.png", "dc3d4b"],
	"飞行": ["res://assets/ui/trait_icons/new_set/flying.png", "91aee6"],
	"亡灵": ["res://assets/ui/trait_icons/new_set/undead.png", "b65cce"],
	"风": ["res://assets/ui/trait_icons/new_set/wind.png", "fd7c7a"],
	"晶石": ["res://assets/ui/trait_icons/new_set/crystal.png", "ceb984"],
}
const AVAILABLE_SYNERGY_PRESENTATION: Dictionary = {}
static var runtime_trait_overrides: Dictionary = {}

# Every entry is a complete gameplay definition. Paths are intentionally stored
# in full because the new collection contains filenames also used by legacy art.
const CREATURE_DATA: Array[Dictionary] = [
	{"path": LEGACY_ROOT + "1 (1).png", "name": "芽叶兽", "traits": ["自然", "植物"], "range": "melee", "rarity": 0, "hp": 72, "damage": [9, 15], "cooldown": 4.2, "skill": "seed_burst", "skill_name": "种子爆破", "skill_text": "攻击目标并对另一名敌人造成溅射伤害"},
	{"path": LEGACY_ROOT + "1 (2).png", "name": "钢甲象", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 92, "damage": [8, 13], "cooldown": 4.8, "skill": "shield_self", "skill_name": "钢铁壁垒", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_ROOT + "1 (3).png", "name": "烛灵", "traits": ["火", "亡灵"], "range": "ranged", "rarity": 0, "hp": 62, "damage": [11, 17], "cooldown": 3.8, "skill": "burn", "skill_name": "幽火", "skill_text": "攻击并为目标附加额外燃烧"},
	{"path": LEGACY_ROOT + "1 (4).png", "name": "岩甲龟", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 98, "damage": [7, 12], "cooldown": 5.0, "skill": "shield_self", "skill_name": "缩壳防御", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_ROOT + "1 (5).png", "name": "夜翼兽", "traits": ["雷", "亡灵"], "range": "ranged", "rarity": 0, "hp": 66, "damage": [10, 18], "cooldown": 3.6, "skill": "double_hit", "skill_name": "夜袭", "skill_text": "对目标追加一次 55% 伤害的攻击"},
	{"path": LEGACY_ROOT + "1 (6).png", "name": "冰角鹿", "traits": ["自然", "雷", "龙族"], "range": "ranged", "rarity": 2, "hp": 76, "damage": [10, 16], "cooldown": 4.0, "skill": "slow", "skill_name": "寒角冲击", "skill_text": "降低目标的技能充能"},
	{"path": LEGACY_ROOT + "1 (7).png", "name": "菌盖兽", "traits": ["自然", "植物"], "range": "ranged", "rarity": 0, "hp": 70, "damage": [8, 14], "cooldown": 4.3, "skill": "heal_ally", "skill_name": "孢子治愈", "skill_text": "治疗生命比例最低的友军"},
	{"path": LEGACY_ROOT + "1 (8).png", "name": "深海贤者", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 1, "hp": 74, "damage": [11, 16], "cooldown": 4.1, "skill": "team_charge", "skill_name": "潮汐启迪", "skill_text": "为其他友军补充技能充能"},
	{"path": LEGACY_ROOT + "1 (9).png", "name": "绵云羊", "traits": ["雷", "植物"], "range": "ranged", "rarity": 1, "hp": 78, "damage": [12, 19], "cooldown": 3.7, "skill": "chain", "skill_name": "云间闪电", "skill_text": "攻击并跳跃至额外敌人"},
	{"path": LEGACY_ROOT + "1 (10).png", "name": "烈焰犬", "traits": ["火", "龙族"], "range": "melee", "rarity": 2, "hp": 94, "damage": [14, 22], "cooldown": 3.8, "skill": "burn", "skill_name": "烈焰撕咬", "skill_text": "重击目标并附加额外燃烧"},
	{"path": LEGACY_STABLE_ROOT + "flower_beast.png", "name": "花叶兽", "traits": ["自然", "植物"], "range": "melee", "rarity": 1, "hp": 88, "damage": [11, 18], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "花叶祝福", "skill_text": "治疗生命比例最低的友军"},
	{"path": LEGACY_STABLE_ROOT + "iron_spider.png", "name": "铁壳蛛", "traits": ["岩", "虫群"], "range": "melee", "rarity": 2, "hp": 102, "damage": [10, 17], "cooldown": 4.6, "skill": "shield_self", "skill_name": "铁网甲壳", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": LEGACY_STABLE_ROOT + "nebula_beast.png", "name": "星云兽", "traits": ["雷", "火", "机械"], "range": "ranged", "rarity": 4, "hp": 92, "damage": [18, 28], "cooldown": 3.4, "skill": "aoe", "skill_name": "星云爆发", "skill_text": "对所有敌人造成范围伤害"},
	{"path": LEGACY_STABLE_ROOT + "flower_beetle.png", "name": "花甲虫", "traits": ["自然", "虫群"], "range": "melee", "rarity": 3, "hp": 118, "damage": [15, 23], "cooldown": 3.7, "skill": "team_charge", "skill_name": "虫群号令", "skill_text": "攻击并为其他友军补充技能充能"},
	{"path": LEGACY_ROOT + "图层 6.png", "name": "熔岩蛛", "traits": ["火", "岩", "虫群"], "range": "ranged", "rarity": 3, "hp": 108, "damage": [17, 26], "cooldown": 3.6, "skill": "aoe_burn", "skill_name": "熔岩喷发", "skill_text": "灼烧所有敌人并造成范围伤害"},

	{"path": NEW_ROOT + "1 (1).png", "name": "森冠鹿", "traits": ["自然", "植物"], "range": "ranged", "rarity": 4, "hp": 126, "damage": [17, 26], "cooldown": 3.8, "skill": "heal_ally", "skill_name": "森林恩泽", "skill_text": "重击目标并治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "1 (2).png", "name": "花芽鹿", "traits": ["自然", "植物"], "range": "ranged", "rarity": 2, "hp": 88, "damage": [12, 19], "cooldown": 3.9, "skill": "team_charge", "skill_name": "花芽共鸣", "skill_text": "为其他友军补充技能充能"},
	{"path": NEW_ROOT + "1 (3).png", "name": "青芽团", "traits": ["自然", "植物"], "range": "melee", "rarity": 0, "hp": 82, "damage": [9, 14], "cooldown": 4.4, "skill": "shield_self", "skill_name": "嫩叶护体", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "1 (4).png", "name": "潮汐王", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 4, "hp": 120, "damage": [18, 29], "cooldown": 3.5, "skill": "aoe", "skill_name": "王者海啸", "skill_text": "对所有敌人造成范围伤害"},
	{"path": NEW_ROOT + "1 (5).png", "name": "潮汐卫", "traits": ["雷", "龙族"], "range": "ranged", "rarity": 2, "hp": 94, "damage": [13, 21], "cooldown": 3.8, "skill": "team_charge", "skill_name": "潮流号令", "skill_text": "为其他友军补充技能充能"},
	{"path": NEW_ROOT + "1 (6).png", "name": "泡泡灵", "traits": ["自然", "亡灵"], "range": "ranged", "rarity": 0, "hp": 74, "damage": [9, 15], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "治愈泡泡", "skill_text": "治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "1 (7).png", "name": "水滴灵", "traits": ["雷", "亡灵"], "range": "ranged", "rarity": 0, "hp": 64, "damage": [10, 16], "cooldown": 3.6, "skill": "slow", "skill_name": "水压冲击", "skill_text": "降低目标的技能充能"},
	{"path": NEW_ROOT + "1 (8).png", "name": "炽焰狼王", "traits": ["火", "龙族"], "range": "melee", "rarity": 4, "hp": 138, "damage": [20, 31], "cooldown": 3.4, "skill": "aoe_burn", "skill_name": "炼狱咆哮", "skill_text": "灼烧所有敌人并造成范围伤害"},
	{"path": NEW_ROOT + "1 (9).png", "name": "炎鬃狼", "traits": ["火", "龙族"], "range": "melee", "rarity": 2, "hp": 104, "damage": [15, 23], "cooldown": 3.6, "skill": "burn", "skill_name": "炎牙", "skill_text": "重击目标并附加额外燃烧"},
	{"path": NEW_ROOT + "1 (10).png", "name": "赤尾狐", "traits": ["火", "植物"], "range": "ranged", "rarity": 2, "hp": 86, "damage": [14, 22], "cooldown": 3.5, "skill": "double_hit", "skill_name": "狐火连击", "skill_text": "对目标追加一次 55% 伤害的攻击"},
	{"path": NEW_ROOT + "1 (11).png", "name": "小火狐", "traits": ["火", "植物"], "range": "ranged", "rarity": 0, "hp": 68, "damage": [10, 17], "cooldown": 3.8, "skill": "burn", "skill_name": "火花", "skill_text": "攻击并为目标附加额外燃烧"},
	{"path": NEW_ROOT + "1 (12).png", "name": "小冰企鹅", "traits": ["雷", "植物"], "range": "ranged", "rarity": 0, "hp": 70, "damage": [9, 15], "cooldown": 4.1, "skill": "slow", "skill_name": "冰雪球", "skill_text": "降低目标的技能充能"},
	{"path": NEW_ROOT + "1 (13).png", "name": "冰冠企鹅", "traits": ["雷", "机械"], "range": "ranged", "rarity": 3, "hp": 88, "damage": [13, 20], "cooldown": 3.7, "skill": "chain", "skill_name": "寒潮权杖", "skill_text": "攻击并跳跃至额外敌人"},
	{"path": NEW_ROOT + "1 (14).png", "name": "紫晶巨像", "traits": ["岩", "机械"], "range": "melee", "rarity": 4, "hp": 156, "damage": [18, 27], "cooldown": 4.2, "skill": "aoe", "skill_name": "晶核震荡", "skill_text": "对所有敌人造成范围伤害"},
	{"path": NEW_ROOT + "1 (15).png", "name": "苔岩守卫", "traits": ["岩", "植物"], "range": "melee", "rarity": 2, "hp": 124, "damage": [12, 19], "cooldown": 4.5, "skill": "shield_self", "skill_name": "苔岩壁垒", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "1 (16).png", "name": "小石怪", "traits": ["岩", "机械"], "range": "melee", "rarity": 1, "hp": 96, "damage": [8, 14], "cooldown": 4.8, "skill": "shield_self", "skill_name": "滚石护体", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "图层 3.png", "name": "苔心傀儡", "traits": ["自然", "机械"], "range": "ranged", "rarity": 2, "hp": 92, "damage": [12, 19], "cooldown": 4.0, "skill": "heal_ally", "skill_name": "苔心脉冲", "skill_text": "治疗生命比例最低的友军"},
	{"path": NEW_ROOT + "图层 4.png", "name": "晶背龟", "traits": ["岩", "虫群"], "range": "melee", "rarity": 3, "hp": 116, "damage": [12, 18], "cooldown": 4.4, "skill": "shield_self", "skill_name": "晶壳反射", "skill_text": "攻击后获得最大生命值 18% 的护盾"},
	{"path": NEW_ROOT + "图层 10.png", "name": "林角幼兽", "traits": ["自然", "龙族"], "range": "ranged", "rarity": 3, "hp": 90, "damage": [13, 20], "cooldown": 3.8, "skill": "seed_burst", "skill_name": "林风飞叶", "skill_text": "攻击目标并对另一名敌人造成溅射伤害"},

	{"path": NEW_TRAIT_ROOT + "moon_fox.png", "name": "月痕灵狐", "traits": ["月影", "野兽"], "range": "ranged", "rarity": 2, "hp": 84, "damage": [14, 22], "cooldown": 3.5, "skill": "double_hit", "skill_name": "月影追袭", "skill_text": "穿行月影，对目标追加一次55%伤害的攻击"},
	{"path": NEW_TRAIT_ROOT + "starlight_mage.png", "name": "星辉术师", "traits": ["星辉", "灵体"], "range": "ranged", "rarity": 3, "hp": 88, "damage": [16, 25], "cooldown": 3.6, "skill": "team_charge", "skill_name": "星辉共鸣", "skill_text": "释放星光，为其他友军恢复16%技能充能"},
	{"path": NEW_TRAIT_ROOT + "fighter_fox.png", "name": "赤拳斗士", "traits": ["格斗", "野兽"], "range": "melee", "rarity": 2, "hp": 108, "damage": [16, 24], "cooldown": 3.4, "skill": "double_hit", "skill_name": "烈拳连打", "skill_text": "以连续拳击追击目标，追加一次55%伤害"},
	{"path": NEW_TRAIT_ROOT + "flying_griffin.png", "name": "苍羽狮鹫", "traits": ["飞行", "野兽"], "range": "ranged", "rarity": 2, "hp": 82, "damage": [15, 23], "cooldown": 3.5, "skill": "seed_burst", "skill_name": "俯冲风刃", "skill_text": "俯冲攻击目标，并以风刃追击另一名敌人"},
	{"path": NEW_TRAIT_ROOT + "undead_wraith.png", "name": "幽焰亡灵", "traits": ["亡灵", "灵体"], "range": "ranged", "rarity": 3, "hp": 86, "damage": [17, 27], "cooldown": 3.8, "skill": "aoe_burn", "skill_name": "幽焰葬礼", "skill_text": "以幽焰灼烧所有敌人并造成范围伤害"},
	{"path": NEW_TRAIT_ROOT + "wind_sylph.png", "name": "翠风精灵", "traits": ["风", "植物"], "range": "ranged", "rarity": 3, "hp": 90, "damage": [13, 21], "cooldown": 3.7, "skill": "heal_ally", "skill_name": "翠风祝祷", "skill_text": "唤起治愈之风，治疗生命比例最低的友军"},
	{"path": NEW_TRAIT_ROOT + "crystal_golem.png", "name": "晶铠巨人", "traits": ["晶石", "守护"], "range": "melee", "rarity": 4, "hp": 154, "damage": [18, 28], "cooldown": 4.2, "skill": "shield_self", "skill_name": "晶簇壁垒", "skill_text": "凝聚晶簇，攻击后获得最大生命18%的护盾"},
]

# Skills are keyed by creature name so legacy art paths can change without
# invalidating combat data. Every entry has a unique id, display name and
# effect signature built for the basic-attack -> energy -> cast loop.
const UNIQUE_SKILLS: Dictionary = {
	"芽叶兽": {"id": "leaf_seed_volley", "name": "连芽飞种", "energy": 0.25, "text": "追击另一名敌人，造成45%技能伤害。", "effects": [{"type": "splash", "ratio": 0.45, "count": 1}]},
	"钢甲象": {"id": "steel_purify_wall", "name": "净钢壁垒", "energy": 0.22, "text": "获得22%最大生命护盾，并清除自身燃烧、减速和眩晕。", "effects": [{"type": "shield_self", "ratio": 0.22}, {"type": "cleanse_self"}]},
	"烛灵": {"id": "candle_soul_flame", "name": "摄魂烛火", "energy": 0.28, "text": "施加2层燃烧，并恢复本次伤害12%的生命。", "effects": [{"type": "burn", "stacks": 2}, {"type": "lifesteal", "ratio": 0.12}]},
	"岩甲龟": {"id": "tortoise_stone_shell", "name": "玄岩缩壳", "energy": 0.20, "text": "获得28%最大生命护盾，并恢复8%已损失生命。", "effects": [{"type": "shield_self", "ratio": 0.28}, {"type": "heal_missing_self", "ratio": 0.08}]},
	"夜翼兽": {"id": "nightwing_echo_strike", "name": "夜翼回响", "energy": 0.30, "text": "追加65%技能伤害，并立即恢复10%能量。", "effects": [{"type": "extra_hit", "ratio": 0.65}, {"type": "charge_self", "amount": 0.10}]},
	"冰角鹿": {"id": "frost_antler_lock", "name": "霜角封流", "energy": 0.24, "text": "使目标减速3秒，并削减25%能量。", "effects": [{"type": "slow", "duration": 3.0}, {"type": "drain_charge", "amount": 0.25}]},
	"菌盖兽": {"id": "mushroom_cleanse_spore", "name": "净愈孢子", "energy": 0.23, "text": "治疗生命比例最低友军20%施法者最大生命，并清除其负面状态。", "effects": [{"type": "heal_lowest", "ratio": 0.20}, {"type": "cleanse_lowest"}]},
	"深海贤者": {"id": "abyssal_tidal_wisdom", "name": "深潮启迪", "energy": 0.22, "text": "其他友军恢复18%能量，能量最低友军获得10%施法者最大生命护盾。", "effects": [{"type": "charge_team", "amount": 0.18}, {"type": "shield_lowest", "ratio": 0.10}]},
	"绵云羊": {"id": "cloud_triple_arc", "name": "云链三闪", "energy": 0.27, "text": "向随机敌人跳跃2次，每次造成38%技能伤害。", "effects": [{"type": "random_hits", "ratio": 0.38, "count": 2}]},
	"烈焰犬": {"id": "blazing_execution_bite", "name": "焚命裂咬", "energy": 0.26, "text": "施加3层燃烧；目标生命低于35%时追加35%技能伤害。", "effects": [{"type": "burn", "stacks": 3}, {"type": "execute", "threshold": 0.35, "ratio": 0.35}]},
	"花叶兽": {"id": "petal_shelter_bloom", "name": "花叶庇护", "energy": 0.24, "text": "全队恢复6%施法者最大生命，生命最低友军额外获得12%护盾。", "effects": [{"type": "heal_team", "ratio": 0.06}, {"type": "shield_lowest", "ratio": 0.12}]},
	"铁壳蛛": {"id": "ironweb_stun_shell", "name": "震荡铁网", "energy": 0.21, "text": "获得20%最大生命护盾，并眩晕目标1.2秒。", "effects": [{"type": "shield_self", "ratio": 0.20}, {"type": "stun", "duration": 1.2}]},
	"星云兽": {"id": "nebula_energy_collapse", "name": "星云坍缩", "energy": 0.32, "text": "对其他所有敌人造成58%技能伤害，并削减其12%能量。", "effects": [{"type": "aoe", "ratio": 0.58}, {"type": "drain_all", "amount": 0.12}]},
	"花甲虫": {"id": "beetle_vital_command", "name": "繁花虫令", "energy": 0.29, "text": "其他友军恢复12%能量，全队恢复6%施法者最大生命。", "effects": [{"type": "charge_team", "amount": 0.12}, {"type": "heal_team", "ratio": 0.06}]},
	"熔岩蛛": {"id": "magma_web_eruption", "name": "熔网喷发", "energy": 0.27, "text": "其他所有敌人受到42%技能伤害，所有敌人获得1层燃烧。", "effects": [{"type": "aoe", "ratio": 0.42}, {"type": "burn_all", "stacks": 1}]},
	"森冠鹿": {"id": "forest_crown_sanctuary", "name": "森冠圣域", "energy": 0.28, "text": "治疗生命最低友军28%施法者最大生命，并为全队提供8%护盾。", "effects": [{"type": "heal_lowest", "ratio": 0.28}, {"type": "shield_team", "ratio": 0.08}]},
	"花芽鹿": {"id": "bud_resonance_transfer", "name": "花芽灌注", "energy": 0.30, "text": "能量最低友军恢复35%能量并恢复12%施法者最大生命。", "effects": [{"type": "charge_lowest", "amount": 0.35}, {"type": "heal_lowest", "ratio": 0.12}]},
	"青芽团": {"id": "sprout_growth_guard", "name": "新芽生长", "energy": 0.25, "text": "获得18%最大生命护盾，并永久提高6%基础最大生命。", "effects": [{"type": "shield_self", "ratio": 0.18}, {"type": "max_hp_growth", "ratio": 0.06}]},
	"潮汐王": {"id": "tidal_king_decree", "name": "沧海王令", "energy": 0.30, "text": "其他所有敌人受到65%技能伤害，并被减速2秒。", "effects": [{"type": "aoe", "ratio": 0.65}, {"type": "slow_all", "duration": 2.0}]},
	"潮汐卫": {"id": "tidal_guard_phalanx", "name": "潮卫方阵", "energy": 0.24, "text": "全队获得12%施法者最大生命护盾，并恢复10%能量。", "effects": [{"type": "shield_team", "ratio": 0.12}, {"type": "charge_team", "amount": 0.10}]},
	"泡泡灵": {"id": "bubble_spirit_cycle", "name": "灵泡循环", "energy": 0.26, "text": "治疗生命最低友军16%施法者最大生命，自身恢复15%能量。", "effects": [{"type": "heal_lowest", "ratio": 0.16}, {"type": "charge_self", "amount": 0.15}]},
	"水滴灵": {"id": "droplet_pressure_theft", "name": "涡压夺能", "energy": 0.29, "text": "削减目标30%能量，并使其减速2.5秒。", "effects": [{"type": "drain_charge", "amount": 0.30}, {"type": "slow", "duration": 2.5}]},
	"炽焰狼王": {"id": "inferno_alpha_roar", "name": "狱焰王啸", "energy": 0.33, "text": "其他所有敌人受到50%技能伤害，所有敌人获得2层燃烧。", "effects": [{"type": "aoe", "ratio": 0.50}, {"type": "burn_all", "stacks": 2}]},
	"炎鬃狼": {"id": "flamemane_blood_bite", "name": "炎鬃血牙", "energy": 0.27, "text": "施加2层燃烧，并恢复本次伤害25%的生命。", "effects": [{"type": "burn", "stacks": 2}, {"type": "lifesteal", "ratio": 0.25}]},
	"赤尾狐": {"id": "redtail_foxfire_dance", "name": "赤尾狐火舞", "energy": 0.31, "text": "对随机敌人追击3次，每次造成28%技能伤害。", "effects": [{"type": "random_hits", "ratio": 0.28, "count": 3}]},
	"小火狐": {"id": "kit_flame_rekindle", "name": "余烬复燃", "energy": 0.34, "text": "施加1层燃烧，并立即恢复20%能量。", "effects": [{"type": "burn", "stacks": 1}, {"type": "charge_self", "amount": 0.20}]},
	"小冰企鹅": {"id": "penguin_snowguard", "name": "雪球冰障", "energy": 0.25, "text": "使目标减速3.5秒，并获得10%最大生命护盾。", "effects": [{"type": "slow", "duration": 3.5}, {"type": "shield_self", "ratio": 0.10}]},
	"冰冠企鹅": {"id": "frostcrown_royal_tide", "name": "冰冠寒潮", "energy": 0.29, "text": "其他所有敌人受到36%技能伤害，并被减速2秒。", "effects": [{"type": "aoe", "ratio": 0.36}, {"type": "slow_all", "duration": 2.0}]},
	"紫晶巨像": {"id": "amethyst_core_bulwark", "name": "紫晶核爆", "energy": 0.23, "text": "其他所有敌人受到50%技能伤害，自身获得25%最大生命护盾。", "effects": [{"type": "aoe", "ratio": 0.50}, {"type": "shield_self", "ratio": 0.25}]},
	"苔岩守卫": {"id": "mossrock_guardian_oath", "name": "苔岩守誓", "energy": 0.21, "text": "生命最低友军获得22%施法者最大生命护盾并恢复10%生命。", "effects": [{"type": "shield_lowest", "ratio": 0.22}, {"type": "heal_lowest", "ratio": 0.10}]},
	"小石怪": {"id": "pebble_armor_growth", "name": "砾甲增生", "energy": 0.22, "text": "获得16%最大生命护盾，并永久获得4%减伤，最多20%。", "effects": [{"type": "shield_self", "ratio": 0.16}, {"type": "damage_reduction", "amount": 0.04}]},
	"苔心傀儡": {"id": "mossheart_purifying_pulse", "name": "苔心净脉", "energy": 0.24, "text": "清除全队燃烧、减速和眩晕，并恢复7%施法者最大生命。", "effects": [{"type": "cleanse_team"}, {"type": "heal_team", "ratio": 0.07}]},
	"晶背龟": {"id": "crystalback_shell_crash", "name": "晶壳反震", "energy": 0.20, "text": "获得24%最大生命护盾，并根据当前护盾对目标追加伤害。", "effects": [{"type": "shield_self", "ratio": 0.24}, {"type": "shield_bash", "ratio": 0.35}]},
	"林角幼兽": {"id": "woodhorn_gale_leaves", "name": "林角叶岚", "energy": 0.28, "text": "追击最多2名其他敌人，各造成40%技能伤害。", "effects": [{"type": "splash", "ratio": 0.40, "count": 2}]},
	"月痕灵狐": {"id": "moontrace_phase_assault", "name": "月痕相袭", "energy": 0.31, "text": "追加60%技能伤害，并永久获得8%闪避，最多32%。", "effects": [{"type": "extra_hit", "ratio": 0.60}, {"type": "dodge_growth", "amount": 0.08}]},
	"星辉术师": {"id": "starlight_orbit_resonance", "name": "星轨共振", "energy": 0.30, "text": "其他友军恢复20%能量，自身在施法后保留15%能量。", "effects": [{"type": "charge_team", "amount": 0.20}, {"type": "charge_self", "amount": 0.15}]},
	"赤拳斗士": {"id": "scarlet_fist_combo", "name": "赤拳震连", "energy": 0.32, "text": "随机追击2次，每次造成50%技能伤害，并眩晕主目标0.6秒。", "effects": [{"type": "random_hits", "ratio": 0.50, "count": 2}, {"type": "stun", "duration": 0.6}]},
	"苍羽狮鹫": {"id": "azure_griffin_dive", "name": "苍羽穿阵", "energy": 0.30, "text": "追击另一名敌人造成55%技能伤害，并削减主目标15%能量。", "effects": [{"type": "splash", "ratio": 0.55, "count": 1}, {"type": "drain_charge", "amount": 0.15}]},
	"幽焰亡灵": {"id": "wraith_funeral_pyres", "name": "亡焰葬阵", "energy": 0.29, "text": "其他所有敌人受到40%技能伤害，全体获得2层燃烧，并恢复8%总伤害生命。", "effects": [{"type": "aoe", "ratio": 0.40}, {"type": "burn_all", "stacks": 2}, {"type": "lifesteal", "ratio": 0.08}]},
	"翠风精灵": {"id": "verdant_wind_benediction", "name": "翠风净祷", "energy": 0.27, "text": "全队恢复12%施法者最大生命，并净化生命比例最低友军。", "effects": [{"type": "heal_team", "ratio": 0.12}, {"type": "cleanse_lowest"}]},
	"晶铠巨人": {"id": "crystal_aegis_domain", "name": "晶铠领域", "energy": 0.20, "text": "全队获得15%施法者最大生命护盾，自身额外获得20%最大生命护盾。", "effects": [{"type": "shield_team", "ratio": 0.15}, {"type": "shield_self", "ratio": 0.20}]},
}

const THRESHOLDS: Dictionary = {
	"自然": [3, 5], "火": [2, 4, 6], "水": [2, 3, 5], "雷": [2, 3], "冰": [2, 3], "岩": [2, 4, 6],
	"植物": [2, 4, 5], "机械": [2, 3, 5], "灵体": [2, 3, 4], "野兽": [2, 4, 6],
	"守护": [2, 4], "龙族": [2, 4], "虫群": [2, 3],
	"月影": [1], "星辉": [1], "格斗": [1], "飞行": [1], "亡灵": [1], "风": [1], "晶石": [1],
}

const EFFECT_VALUES: Dictionary = {
	"自然": [0.06, 0.08], "火": [0.12, 0.16, 0.35], "水": [0.12, 0.18, 0.30],
	"雷": [0.40, 1.0], "冰": [0.20, 1.20], "岩": [0.15, 0.25, 0.06],
	"植物": [0.03, 0.05, 0.35], "机械": [0.20, 0.12, 0.04],
	"灵体": [0.08, 0.08, 0.30], "野兽": [0.08, 0.08, 0.10],
	"守护": [0.12, 0.22], "龙族": [0.18, 0.30], "虫群": [0.08, 0.12],
	"月影": [0.12], "星辉": [0.15], "格斗": [0.10], "飞行": [0.12], "亡灵": [0.08], "风": [0.12], "晶石": [0.18],
}

const EFFECT_LINES: Dictionary = {
	"自然": ["每4秒治疗生命比例最低的友军，恢复其最大生命6%", "治疗最低生命的2名友军各8%；过量治疗转化为最多20%最大生命的护盾"],
	"火": ["攻击有概率点燃", "燃烧可叠加", "燃烧目标死亡后爆炸"],
	"水": ["施放技能后为充能最低的其他友军恢复12%充能", "恢复18%充能和5%最大生命", "水元素开局获得30%充能；全队每3次技能触发潮汐治疗与充能"],
	"雷": ["技能40%概率连锁1名敌人，造成60%伤害", "必定连锁最多2名敌人，造成65%伤害并削减8%当前充能"],
	"冰": ["技能施加4秒寒冷，使充能速度降低20%", "对寒冷目标再次施放冰技能时冻结1.2秒；解除后5秒免疫冻结"],
	"岩": ["开局获得15%最大生命护盾", "护盾提高到25%；首次破裂伤害并减速同排敌人", "每4秒恢复6%最大生命护盾；满盾时获得15%减伤"],
	"植物": ["每5秒生长，提高3%初始最大生命并恢复等量生命，最多5次", "每层提高5%生命和3%伤害，最多7次", "首次死亡后以35%生命复活，每场一次"],
	"机械": ["机械开局获得20%充能", "额外获得12%生命护盾；首次破裂使攻击者眩晕0.6秒", "每个存活机械为全队提供4%充能速度，最多20%；机械自身双倍"],
	"灵体": ["技能后恢复实际伤害8%的生命，单次上限10%最大生命", "首名灵体死亡时使其他友军恢复8%生命和15%充能", "每名灵体首次死亡后以30%生命复活，伤害降低15%"],
	"野兽": ["技能后获得1层狩猎，4秒内伤害与充能速度提高8%", "狩猎最多3层并持续6秒，获得新层刷新时间", "开局1层；半血时获得满层和10%伤害吸血，每场一次"],
	"守护": ["自身获得12%减伤，身后同排友军获得6%减伤", "减伤提高到22%和12%；开战前2.5秒敌方近战优先攻击守护"],
	"龙族": ["技能伤害和治疗提高18%", "提高到30%，忽略20%减伤并对同排另一敌人造成35%溅射"],
	"虫群": ["施放技能时其他虫群获得8%充能", "提高到12%；虫群死亡时其他虫群获得15%伤害和20%充能，最多2层"],
	"月影": ["自身获得12%闪避率"],
	"星辉": ["自身充能速度提高15%"],
	"格斗": ["自身伤害和最大生命提高10%"],
	"飞行": ["自身获得12%闪避率，且远程攻击优先尝试攻击后排目标"],
	"亡灵": ["施放技能后恢复自身8%最大生命"],
	"风": ["自身充能速度提高12%"],
	"晶石": ["开局获得18%最大生命护盾，并获得8%伤害减免"],
}


static func all_textures() -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		result.append(String(entry["path"]))
	return result


static func synergy_ids() -> Array[String]:
	return SYNERGY_ORDER.duplicate()


static func synergy_thresholds(synergy: String) -> Array:
	return Array(THRESHOLDS.get(synergy, [])).duplicate()


static func synergy_effect_lines(synergy: String) -> Array:
	return Array(EFFECT_LINES.get(synergy, [])).duplicate()


static func synergy_icon_path(synergy: String) -> String:
	var data: Array = SYNERGY_PRESENTATION.get(synergy, AVAILABLE_SYNERGY_PRESENTATION.get(synergy, ["", "737983"]))
	return String(data[0])


static func synergy_color(synergy: String) -> Color:
	var data: Array = SYNERGY_PRESENTATION.get(synergy, AVAILABLE_SYNERGY_PRESENTATION.get(synergy, ["", "737983"]))
	return Color(String(data[1]))


static func available_synergy_ids() -> Array[String]:
	var result: Array[String] = []
	for synergy in AVAILABLE_SYNERGY_PRESENTATION:
		result.append(String(synergy))
	return result


static func set_trait_override(creature_name: String, traits: Array[String]) -> void:
	runtime_trait_overrides[creature_name] = traits.duplicate()


static func clear_trait_override(creature_name: String) -> void:
	runtime_trait_overrides.erase(creature_name)


static func all_names() -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		result.append(String(entry["name"]))
	return result


static func textures_for_rarity(rarity: int) -> Array[String]:
	var result: Array[String] = []
	for entry in CREATURE_DATA:
		if int(entry["rarity"]) == clampi(rarity, 0, RARITY_NAMES.size() - 1):
			result.append(String(entry["path"]))
	return result


static func data_for_texture(texture_path: String) -> Dictionary:
	for entry in CREATURE_DATA:
		if String(entry["path"]) == texture_path:
			return entry
	return {}


static func name_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("name", "未知怪兽"))


static func traits_for_texture(texture_path: String) -> PackedStringArray:
	var data := data_for_texture(texture_path)
	var creature_name := String(data.get("name", ""))
	if runtime_trait_overrides.has(creature_name):
		return PackedStringArray(runtime_trait_overrides[creature_name])
	return PackedStringArray(TRAIT_OVERRIDES.get(creature_name, data.get("traits", [])))


static func attack_range_for_texture(texture_path: String) -> String:
	return String(data_for_texture(texture_path).get("range", "melee"))


static func combat_role_name(texture_path: String) -> String:
	return "远程" if attack_range_for_texture(texture_path) == "ranged" else "近战"


static func rarity_for_texture(texture_path: String) -> int:
	return clampi(int(data_for_texture(texture_path).get("rarity", 0)), 0, RARITY_NAMES.size() - 1)


static func base_hp_for_texture(texture_path: String) -> int:
	return int(data_for_texture(texture_path).get("hp", 72))


static func damage_range_for_texture(texture_path: String) -> Vector2i:
	var values: Array = data_for_texture(texture_path).get("damage", [9, 17])
	return Vector2i(int(values[0]), int(values[1]))


static func cooldown_for_texture(texture_path: String) -> float:
	return float(data_for_texture(texture_path).get("cooldown", 4.0))


static func target_rule_for_texture(texture_path: String) -> String:
	var data := data_for_texture(texture_path)
	if data.has("target_rule"):
		return String(data["target_rule"])
	return "rear_chance" if String(data.get("range", "melee")) == "ranged" else "front_row"


static func trigger_rule_for_texture(texture_path: String) -> String:
	if not unique_skill_for_texture(texture_path).is_empty():
		return "on_full_charge"
	var data := data_for_texture(texture_path)
	if data.has("trigger_rule"):
		return String(data["trigger_rule"])
	return "on_attack" if String(data.get("skill", "basic")) != "basic" else "on_full_charge"


static func star_growth(level: int) -> Dictionary:
	return STAR_GROWTH[clampi(level - 1, 0, STAR_GROWTH.size() - 1)]


static func star_growth_for_texture(texture_path: String, level: int) -> Dictionary:
	var data := data_for_texture(texture_path)
	if data.has("star_growth"):
		var custom: Array = data["star_growth"]
		if not custom.is_empty():
			return Dictionary(custom[clampi(level - 1, 0, custom.size() - 1)])
	return star_growth(level)


static func skill_id_for_texture(texture_path: String) -> String:
	var unique_skill := unique_skill_for_texture(texture_path)
	if not unique_skill.is_empty():
		return String(unique_skill.get("id", "basic"))
	return String(data_for_texture(texture_path).get("skill", "basic"))


static func skill_name_for_texture(texture_path: String) -> String:
	var unique_skill := unique_skill_for_texture(texture_path)
	if not unique_skill.is_empty():
		return String(unique_skill.get("name", "基础攻击"))
	return String(data_for_texture(texture_path).get("skill_name", "基础攻击"))


static func skill_text_for_texture(texture_path: String) -> String:
	var unique_skill := unique_skill_for_texture(texture_path)
	if not unique_skill.is_empty():
		return String(unique_skill.get("text", "对目标造成伤害。"))
	return String(data_for_texture(texture_path).get("skill_text", "对目标造成伤害"))


static func skill_detail_for_texture(texture_path: String) -> String:
	var unique_skill := unique_skill_for_texture(texture_path)
	if not unique_skill.is_empty():
		return String(unique_skill.get("text", "对目标造成伤害。"))
	# Keep the encyclopedia wording synchronized with the actual coefficients in
	# battle.gd instead of showing a vague one-line summary.
	match skill_id_for_texture(texture_path):
		"shield_self":
			return "攻击后获得相当于自身最大生命值 18% 的护盾。"
		"heal_ally":
			return "治疗生命比例最低的友军，治疗量为施法者最大生命值的 16%。"
		"team_charge":
			return "为其他所有存活友军恢复 16% 技能充能。"
		"burn":
			return "命中目标并施加 2 层燃烧。"
		"slow":
			return "使目标减速 3 秒，并削减其 20% 技能充能。"
		"double_hit":
			return "对目标追加一次相当于本次伤害 55% 的攻击。"
		"seed_burst":
			return "随机追击另一名敌人，造成相当于本次伤害 45% 的伤害。"
		"chain":
			return "随机跳跃至另一名敌人，造成相当于本次伤害 55% 的伤害。"
		"aoe":
			return "对主目标外的所有敌人造成相当于本次伤害 48% 的范围伤害。"
		"aoe_burn":
			return "对主目标外的所有敌人造成相当于本次伤害 38% 的范围伤害，并对所有目标施加 1 层燃烧。"
		_:
			return skill_text_for_texture(texture_path)


static func unique_skill_for_texture(texture_path: String) -> Dictionary:
	return Dictionary(UNIQUE_SKILLS.get(name_for_texture(texture_path), {}))


static func skill_effects_for_texture(texture_path: String) -> Array:
	return Array(unique_skill_for_texture(texture_path).get("effects", [])).duplicate(true)


static func energy_per_attack_for_texture(texture_path: String) -> float:
	return clampf(float(unique_skill_for_texture(texture_path).get("energy", 0.25)), 0.05, 1.0)


static func rarity_stat_multiplier(texture_path: String) -> float:
	return RARITY_STAT_MULTIPLIERS[rarity_for_texture(texture_path)]


static func rarity_charge_multiplier(texture_path: String) -> float:
	return RARITY_CHARGE_MULTIPLIERS[rarity_for_texture(texture_path)]


static func elements_for_texture(texture_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for trait_name in traits_for_texture(texture_path):
		if trait_name in ELEMENTS:
			result.append(trait_name)
	return result


static func races_for_texture(texture_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for trait_name in traits_for_texture(texture_path):
		if trait_name in RACES:
			result.append(trait_name)
	return result


static func count_synergies(team: Array[String]) -> Dictionary:
	var counts: Dictionary = {}
	var counted_creatures: Dictionary = {}
	for synergy in SYNERGY_ORDER:
		counts[synergy] = 0
	for texture_path in team:
		if texture_path.is_empty() or counted_creatures.has(texture_path):
			continue
		counted_creatures[texture_path] = true
		for tag in traits_for_texture(texture_path):
			counts[tag] = int(counts.get(tag, 0)) + 1
	return counts


static func active_tier(synergy: String, count: int) -> int:
	var tier := -1
	var thresholds := synergy_thresholds(synergy)
	for index in thresholds.size():
		if count >= thresholds[index]:
			tier = index
	return tier


static func effect_value(synergy: String, count: int) -> float:
	var tier := active_tier(synergy, count)
	if tier < 0:
		return 0.0
	var values: Array = EFFECT_VALUES.get(synergy, [])
	if tier >= values.size():
		return 0.0
	return values[tier]


static func tooltip_text(synergy: String, current_count: int) -> String:
	var lines: Array[String] = ["当前数量：%d" % current_count]
	var thresholds := synergy_thresholds(synergy)
	var effects := synergy_effect_lines(synergy)
	for index in thresholds.size():
		var marker := "●" if current_count >= thresholds[index] else "○"
		lines.append("%s %d：%s" % [marker, thresholds[index], effects[index]])
	return "\n".join(lines)
