Config = {
    stores = {
        --- NOTE: subtract 1.0 from the Z coord in your manual empty coords to counteract you not be placed on the ground.

        [196865] = { -- davis (innocence) store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(24.088, -1345.6227, 29.5082, 269.5), manualEmptyCoords = vec4(24.5, -1344.98, 29.5 - 1.0, 275.16)
        },
        [176641] = { -- southern chumash store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-3040.14, 583.71, 7.91, 19.61), manualEmptyCoords = vec4(-3041.20, 583.76, 7.91 - 1.0, 12.99)
        },
        [198401] = { -- davis (grove) store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-45.88, -1757.60, 29.42, 51.31), manualEmptyCoords = vec4(-46.81, -1758.04, 29.42 - 1.0, 52.01)
        },
        [175105] = { -- GOH chumash liquor store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-2965.94, 391.53, 15.04, 82.77), manualEmptyCoords = vec4(-2966.34, 390.85, 15.04 - 1.0, 83.67)
        },
        [177153] = { -- northen chumsash store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-3243.76, 999.90, 12.83, 356.06), manualEmptyCoords = vec4(-3244.61, 1000.19, 12.83 - 1.0, 355.34)
        },
        [200449] = { -- sandy shores store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(1959.07, 3741.03, 32.34, 294.55), manualEmptyCoords = vec4(1958.82, 3742.00, 32.34 - 1.0, 301.48)
        },
        [155649] = { -- mirror park store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(1164.92, -321.67, 69.21, 102.71), manualEmptyCoords = vec4(1164.95, -322.79, 69.21 - 1.0, 102.42)
        },
        [139777] = { -- vinewood store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(372.49, 327.82, 103.57, 255.04), manualEmptyCoords = vec4(373.09, 328.73, 103.57 - 1.0, 254.29)
        },
        [168449] = { -- northen del perro store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-1486.67, -377.25, 40.16, 138.64), manualEmptyCoords = vec4(-1486.19, -378.03, 40.16 - 1.0, 133.81)
        },
        [170753] = { -- southern del perro store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(-1221.17, -908.15, 12.33, 35.23), manualEmptyCoords = vec4(-1221.99, -908.36, 12.33 - 1.0, 30.23)
        },
        [154113] = { -- murrieta heights store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(1134.02, -983.33, 46.42, 278.62), manualEmptyCoords = vec4(1134.05, -982.51, 46.42 - 1.0, 282.98)
        },
        [178945] = { -- tataviam mountains fwy store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(2555.92, 380.52, 108.62, 356.53), manualEmptyCoords = vec4(2554.83, 380.83, 108.62 - 1.0, 352.39)
        },
        [203265] = { -- route 68 store (next to fleeca)
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(1165.10, 2711.11, 38.16, 179.43), manualEmptyCoords = vec4(1165.98, 2710.90, 38.16 - 1.0, 177.91)
        },
        [204801] = { -- other route 68 store
            model = `mp_m_shopkeep_01`, clerkCoords = vec4(549.42, 2670.08, 42.16, 97.66), manualEmptyCoords = vec4(549.49, 2669.05, 42.16 - 1.0, 96.36)
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