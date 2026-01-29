local dutyPlayers = {}
local discordCache = {}

-- ================================
-- CHAT NOTIFY SYSTEM
-- ================================
local function notify(src, msg, msgType)
    local prefix = '^3[DUTY]^7 '

    if msgType == 'success' then
        prefix = '^2[DUTY]^7 '
    elseif msgType == 'error' then
        prefix = '^1[DUTY]^7 '
    end

    TriggerClientEvent('chat:addMessage', src, {
        args = { prefix .. msg }
    })
end

-- ================================
-- UTILITIES
-- ================================
local function getDiscordId(src)
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == 'discord:' then
            return id:gsub('discord:', '')
        end
    end
    return nil
end

local function hasRole(playerRoles, allowedRoles)
    if not playerRoles or not allowedRoles then return false end

    for _, role in pairs(playerRoles) do
        for _, allowed in pairs(allowedRoles) do
            if role == allowed then
                return true
            end
        end
    end

    return false
end

local function getDepartmentConfig(deptValue)
    for _, dept in pairs(Config.Departments) do
        if dept.value == deptValue then
            return dept
        end
    end
    return nil
end

local function fetchDiscordRoles(discordId, cb)
    if discordCache[discordId] then
        cb(discordCache[discordId])
        return
    end

    local endpoint = ('https://discord.com/api/v10/guilds/%s/members/%s')
        :format(Config.Discord.GuildId, discordId)

    PerformHttpRequest(endpoint, function(status, response)
        if status == 200 and response then
            local data = json.decode(response)
            local roles = data.roles or {}
            discordCache[discordId] = roles
            cb(roles)
        else
            print('[DUTY ERROR] Discord API failed:', status)
            cb({})
        end
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. Config.Discord.BotToken,
        ['Content-Type'] = 'application/json'
    })
end

-- ================================
-- DUTY EVENTS
-- ================================
RegisterNetEvent('x1s_duty:onDuty', function(data)
    local src = source
    print('[DUTY] onDuty triggered:', json.encode(data))

    local discordId = getDiscordId(src)
    if not discordId then
        notify(src, 'Discord is not linked to your FiveM account.', 'error')
        return
    end

    local dept = getDepartmentConfig(data.department)
    if not dept then
        notify(src, 'Invalid department selected.', 'error')
        return
    end

    fetchDiscordRoles(discordId, function(roles)
        if not hasRole(roles, dept.roles) then
            notify(src, 'You do not have the required Discord role.', 'error')
            return
        end

        dutyPlayers[src] = {
            name = data.name,
            callsign = data.callsign,
            department = dept.label,
            logo = dept.logo
        }

        TriggerClientEvent('x1s_duty:setDuty', src, true, {
            blip = dept.blip
        })

        notify(src, 'You are now ON DUTY with ' .. dept.label .. '.', 'success')
        sendWebhook(src, 'ON DUTY', dutyPlayers[src])
    end)
end)

RegisterNetEvent('x1s_duty:offDuty', function()
    local src = source

    if dutyPlayers[src] then
        sendWebhook(src, 'OFF DUTY', dutyPlayers[src])
        dutyPlayers[src] = nil
    end

    TriggerClientEvent('x1s_duty:setDuty', src, false)
    notify(src, 'You are now OFF DUTY.', 'info')
end)

AddEventHandler('playerDropped', function()
    local src = source
    if dutyPlayers[src] then
        sendWebhook(src, 'OFF DUTY (DISCONNECT)', dutyPlayers[src])
        dutyPlayers[src] = nil
    end
end)

-- ================================
-- WEBHOOK
-- ================================
function sendWebhook(src, status, data)
    local playerName = GetPlayerName(src)
    local discordMention = 'Unknown'

    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:find('discord:') then
            discordMention = '<@' .. id:gsub('discord:', '') .. '>'
            break
        end
    end

    local embed = {
        {
            title = 'Duty Status Update',
            color = status:find('ON') and 3066993 or 15158332,
            thumbnail = { url = data.logo },
            fields = {
                { name = 'Player', value = playerName, inline = true },
                { name = 'Discord', value = discordMention, inline = true },
                { name = 'Department', value = data.department, inline = true },
                { name = 'Name', value = data.name, inline = true },
                { name = 'Callsign', value = data.callsign, inline = true },
                { name = 'Status', value = status }
            },
            footer = Config.WebhookFooter,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }
    }

    PerformHttpRequest(Config.Webhook, function() end, 'POST',
        json.encode({ embeds = embed }),
        { ['Content-Type'] = 'application/json' }
    )
end
