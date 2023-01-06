Config = {
    stores = {
        [196865] = { -- strawbery (innocence) store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(24.088, -1345.6227, 29.5082, 269.5), manualEmptyCoords = vec4(24.5, -1344.98, 29.5 - 1.0, 275.16)
        },
        [176641] = { -- southern chumash store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-3040.14, 583.71, 7.91, 19.61), manualEmptyCoords = vec4(-3041.20, 583.76, 7.91 - 1.0, 12.99)
        },
        [198401] = { -- davis (grove) ltd
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-45.88, -1757.60, 29.42, 51.31), manualEmptyCoords = vec4(-46.81, -1758.04, 29.42 - 1.0, 52.01)
        },
        [175105] = { -- GOH chumas liquor store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-2965.94, 391.53, 15.04, 82.77), manualEmptyCoords = vec4(-2966.34, 390.85, 15.04 - 1.0, 83.67)
        }
    },
    clerkVoiceLines = {
        'SHOP_GREET',
        'SHOP_GREET_START',
        'SHOP_GREET_END'
    },
    weaponsClerkCouldHave = {
        `WEAPON_PISTOL`,
        `WEAPON_COMBATPISTOl`,
        `WEAPON_MICROSMG`,
        `WEAPON_BAT`,
        `WEAPON_ASSUALTRIFLE`,
        `WEAPON_COMBATMG`,
        `WEAPON_SAWNOFFSHOTGUN`,
        `WEAPON_PUMPSHOTGUN`
    }
}