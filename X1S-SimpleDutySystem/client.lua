local onDuty = false
local dutyBlip = nil

RegisterCommand(Config.MenuCommand, function()
    openDutyMenu()
end)

function openDutyMenu()
    local options = {}

    for _, dept in pairs(Config.Departments) do
        table.insert(options, {
            title = dept.label,
            onSelect = function()
                selectDepartment(dept)
            end
        })
    end

    lib.registerContext({
        id = 'duty_menu',
        title = 'X1S Duty Menu',
        options = options
    })

    lib.showContext('duty_menu')
end

function selectDepartment(dept)
    lib.registerContext({
        id = 'dept_menu',
        title = dept.label,
        options = {
            {
                title = onDuty and 'Go Off Duty' or 'Go On Duty',
                icon = onDuty and 'toggle-off' or 'toggle-on',
                onSelect = function()
                    if onDuty then
                        TriggerServerEvent('x1s_duty:offDuty')
                    else
                        enterDutyInfo(dept)
                    end
                end
            }
        }
    })

    lib.showContext('dept_menu')
end

function enterDutyInfo(dept)
    local input = lib.inputDialog('Duty Information', {
        { type = 'input', label = 'Name', required = true },
        { type = 'input', label = 'Callsign', required = true }
    })

    if not input then return end

    TriggerServerEvent('x1s_duty:onDuty', {
        name = input[1],
        callsign = input[2],
        department = dept.value, -- MUST be value, not label
        logo = dept.logo,
        blip = dept.blip
    })
end

RegisterNetEvent('x1s_duty:setDuty', function(state, dept)
    onDuty = state

    if onDuty and dept and dept.blip then
        createDutyBlip(dept.blip)
    else
        removeDutyBlip()
    end
end)

-- BLIP CREATION
function createDutyBlip(blipData)
    if not blipData then return end

    removeDutyBlip()

    local ped = PlayerPedId()
    if not ped or ped == -1 then return end

    dutyBlip = AddBlipForEntity(ped)
    if not dutyBlip then return end

    SetBlipSprite(dutyBlip, blipData.sprite)
    SetBlipColour(dutyBlip, blipData.color)
    SetBlipScale(dutyBlip, blipData.scale)
    SetBlipAsShortRange(dutyBlip, false)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('On Duty')
    EndTextCommandSetBlipName(dutyBlip)
end

function removeDutyBlip()
    if dutyBlip then
        RemoveBlip(dutyBlip)
        dutyBlip = nil
    end
end

RegisterNetEvent('ox_lib:notify', function(data)
    lib.notify({
        title = data.title or 'X1S Duty System',
        description = data.description or '',
        type = data.type or 'info',
        position = 'top'
    })
end)
