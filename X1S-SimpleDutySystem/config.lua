Config = {}

-- ================================
-- DISCORD BOT CONFIG
-- ================================
Config.Discord = {
    BotToken = 'DISCORD_BOT_TOKEN',
    GuildId = 'REPLACE_WITH_GUILDID'
}

-- =====================
-- Webhook
-- =====================
Config.Webhook = 'REPLACE_WITH_WEBHOOK_URL'

Config.WebhookFooter = {
    text = 'X1Studios • Simple Duty System Using OX_Lib',
    icon = 'https://imgur.com/G4WAX8q.png'
}

-- ================================
-- DEPARTMENTS
-- ================================
Config.Departments = {
    {
        label = 'Los Santos Police Department',
        value = 'LSPD',
        roles = {
            'REPLACE_ME_WITH_LSPD_ROLE_ID', -- LSPD Role
            'REPLACE_ME_WITH_LSPD_ROLE_ID'  -- LSPD Supervisor (optional)
        },
        logo = 'https://i.imgur.com/PCRR7pN.png', -- thumbnail
        blip = { sprite = 60, color = 3, scale = 0.8 }
    },
    {
        label = 'Blaine County Sheriff Office',
        value = 'BCSO',
        roles = {
            'REPLACE_ME_WITH_BCSO_ROLE_ID'
        },
        logo = 'https://i.imgur.com/MWL8fOL.png',
        blip = { sprite = 60, color = 5, scale = 0.8 }
    },
    {
        label = 'San Andreas State Police',
        value = 'SASP',
        roles = {
            'REPLACE_ME_WITH_SASP_ROLE_ID'
        },
        logo = 'https://i.imgur.com/qwjPGhj.png',
        blip = { sprite = 436, color = 1, scale = 0.8 }
    }
}

-- ================================
Config.MenuCommand = 'dutymenu'
-- ================================
