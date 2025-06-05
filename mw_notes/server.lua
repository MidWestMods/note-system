RegisterServerEvent("note:logNote")
AddEventHandler("note:logNote", function(text)
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(src)

    logToConsoleAndDiscord(string.format("Player %s (ID %d | Discord: %s | Steam: %s) wrote a note: \"%s\"",
        name, src, ids.discord or "N/A", ids.steam or "N/A", text))
end)

RegisterServerEvent("note:sendNote")
AddEventHandler("note:sendNote", function(targetId, note)
    TriggerClientEvent("note:receiveNote", targetId, note)
end)

function logToConsoleAndDiscord(msg)
    print("[NoteLog] " .. msg)
    if Config.EnableDiscordLogging and Config.DiscordWebhook ~= "" then
        PerformHttpRequest(Config.DiscordWebhook, function() end, "POST", json.encode({
            username = "Note Logger",
            embeds = {{
                title = "Note Log",
                description = msg,
                color = 3447003
            }}
        }), { ["Content-Type"] = "application/json" })
    end
end

function ExtractIdentifiers(src)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:match("discord:") then ids.discord = id:gsub("discord:", "") end
        if id:match("steam:") then ids.steam = id:gsub("steam:", "") end
    end
    return ids
end