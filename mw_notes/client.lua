local lastNote = nil
local receivedNote = nil
local isUINoteOpen = false

RegisterCommand("note", function()
    if isUINoteOpen then
        -- If already open, close the UI
        SetNuiFocus(false, false)
        SendNUIMessage({ type = "close" })
        isUINoteOpen = false
        return
    end

    -- Otherwise, open it
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "open", placeholder = Config.UIPlaceholder or "Write your note here..." })
    isUINoteOpen = true
end)


RegisterNUICallback("submitNote", function(data, cb)
    SetNuiFocus(false, false)
    isUINoteOpen = false
    local text = string.sub(data.note, 1, Config.MaxNoteLength or 250)
    lastNote = text
    playNotepadAnimation()
    TriggerServerEvent("note:logNote", text)
    TriggerEvent('chat:addMessage', {
        args = { '^3[Note]', 'You wrote: ' .. text }
    })
    cb("ok")
end)

RegisterNUICallback("closeUI", function(_, cb)
    SetNuiFocus(false, false)
    isUINoteOpen = false
    cb("ok")
end)

function playNotepadAnimation()
    local ped = PlayerPedId()
    RequestAnimDict("missheistdockssetup1clipboard@base")
    while not HasAnimDictLoaded("missheistdockssetup1clipboard@base") do Wait(100) end

    TaskPlayAnim(ped, "missheistdockssetup1clipboard@base", "base", 8.0, -8, -1, 49, 0, false, false, false)

    local noteProp = CreateObject(GetHashKey("prop_notepad_01"), GetEntityCoords(ped), true, true, true)
    local penProp = CreateObject(GetHashKey("prop_pencil_01"), GetEntityCoords(ped), true, true, true)

    AttachEntityToEntity(noteProp, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.05, 80.0, 0.0, 360.0, true, true, false, true, 1, true)
    AttachEntityToEntity(penProp, ped, GetPedBoneIndex(ped, 58866), 0.1, 0.0, 0.0, 0.0, 0.0, -90.0, true, true, false, true, 1, true)

    Wait(Config.NoteAnimDuration or 5000)
    ClearPedTasks(ped)
    DeleteEntity(noteProp)
    DeleteEntity(penProp)
end

RegisterCommand("gnote", function()
    if not lastNote then
        TriggerEvent('chat:addMessage', { args = { '^1[Note]', 'You haven’t written a note yet.' } })
        return
    end

    local closestPlayer, closestDist = -1, Config.NearbyNoteDistance or 3.0
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped ~= myPed then
            local dist = #(GetEntityCoords(ped) - myCoords)
            if dist < closestDist then
                closestPlayer = player
                closestDist = dist
            end
        end
    end

    if closestPlayer ~= -1 then
        local targetId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent("note:sendNote", targetId, lastNote)
        TriggerEvent('chat:addMessage', { args = { '^2[Note]', 'Note sent to nearby player.' } })
    else
        TriggerEvent('chat:addMessage', { args = { '^1[Note]', 'No one nearby to give the note to.' } })
    end
end)

RegisterNetEvent("note:receiveNote", function(noteText)
    receivedNote = noteText
    TriggerEvent('chat:addMessage', {
        args = { '^5[Note]', 'You received a note. Use /lastnote to view it.' }
    })
end)

RegisterCommand("lastnote", function()
    if receivedNote then
        TriggerEvent('chat:addMessage', {
            args = { '^6[Note]', 'Last note you received: ' .. receivedNote }
        })
    else
        TriggerEvent('chat:addMessage', {
            args = { '^1[Note]', 'You haven’t received a note yet.' }
        })
    end
end)