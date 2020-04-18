--- Lua-Telegram-Bot API.
-- @module telegram
local telegram = {}

-- Load the submodules.
telegram.json = require("telegram.modules.json")
telegram.request = require("telegram.modules.request")

-- Load the structures.
telegram.structures = require("telegram.structures")

--- Requests timeout in seconds (number).
telegram.timeout = 5

--- Set the bot's authorization token
-- @tparam string token The bot's authorization token, e.x: (`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`).
function telegram.setToken(token)
    telegram.request("setToken", token)
end

--- A simple method for testing your bot's auth token, get information about the bot's user itself.
-- @treturn User The bot's user object.
-- @raise Error on failure.
function telegram.getMe()
    local ok, data = telegram.request("getMe")
    if not ok then return error(data) end
    return telegram.structures.User(data)
end

--- Use this method to receive incoming updates using long polling ([wiki](https://en.wikipedia.org/wiki/Push_technology#Long_polling)).
--
-- **Notes:**
--
-- 1. This method will not work if an outgoing webhook is set up.
--
-- 2. In order to avoid getting duplicate updates, recalculate offset after each server response.
--
-- @tparam ?number offset Identifier of the first update to be returned.
-- Must be greater by one than the highest among the identifiers of previously received updates.
-- By default, updates starting with the earliest unconfirmed update are returned.
-- An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id.
-- The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue.
-- All previous updates will forgotten.
-- @tparam ?number limit Limits the number of updates to be retrieved. Values between 1—100 are accepted. Defaults to 100.
-- @tparam ?number timeout Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
-- @tparam ?{string} allowedUpdates An array of the update types you want your bot to receive.
-- For example, specify `{“message”, “edited_channel_post”, “callback_query”}` to only receive updates of these types.
-- See Update for a complete list of available update types.
-- Specify an empty list to receive all updates regardless of type (default).
-- If not specified, the previous setting will be used.
-- @treturn {Update} Array of Update objects.
-- @raise Error on failure.
function telegram.getUpdates(offset, limit, timeout, allowedUpdates)
    local ok, data = telegram.request("getUpdates", {offset=offset, limit=limit, timeout=timeout, allowed_updates=allowedUpdates}, telegram.timeout, timeout+2)
    if not ok then return error(data) end
    for k,v in ipairs(data) do data[k] = telegram.structures.Update(v) end
    return data
end

--- Use this method to get up to date information about the chat (current name of the user for one-on-one conversations, current username of a user, group or channel, etc.).
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @treturn Chat The requested chat object on success.
-- @raise Error on failure.
function telegram.getChat(chatID)
    local ok, data = telegram.request("getChat", {chat_id = chatID}, telegram.timeout)
    if not ok then return error(data) end
    return telegram.structures.Chat(data)
end

--- Use this method to generate a new invite link for a chat; any previously generated link is revoked.
-- The bot must be an administrator in the chat for this to work and must have the appropriate admin rights.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @treturn string The exported invite link on success.
-- @raise Error on failure.
function telegram.exportChatInviteLink(chatID)
    local ok, data = telegram.request("exportChatInviteLink", {chat_id = chatID}, telegram.timeout)
    if not ok then return error(data) end
    return data
end

return telegram