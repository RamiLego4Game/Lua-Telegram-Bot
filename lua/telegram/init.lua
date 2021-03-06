--- Lua-Telegram-Bot API.
-- Supports Bot API 4.8
-- @module telegram
local telegram = {}

-- Load the submodules.
telegram.request = require("telegram.modules.request")

-- Load the structures.
telegram.structures = require("telegram.structures")

--- Upload files using `multipart/form-data`.
-- @field filename The filename (string).
-- @field data The file content, can be a string, or a io.* file, or a ltn12 source.
-- @field len The file's content length, can be ommited when data is just a string.
-- @table InputFile

--- Set the bot's authorization token
-- @tparam string token The bot's authorization token, e.x: (`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`).
function telegram.setToken(token)
    telegram.request("setToken", token)
end

--- Get the bot's authorization token
-- @treturn ?string The bot's authorization token, e.x: (`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`).
function telegram.getToken()
    return select(2, telegram.request("getToken"))
end

--- Set the default timeout used for the API requests
-- @tparam number timeout The new timeout value, -1 for no timeout.
function telegram.setTimeout(timeout)
    telegram.request("setTimeout", timeout)
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
    local ok, data = telegram.request("getUpdates", {offset=offset, limit=limit, timeout=timeout, allowed_updates=allowedUpdates}, (timeout or 0) + 5)
    if not ok then return error(data) end
    for k,v in ipairs(data) do data[k] = telegram.structures.Update(v) end
    return data
end

--- A simple method for testing your bot's auth token, get information about the bot's user itself.
-- @treturn User The bot's user object.
-- @raise Error on failure.
function telegram.getMe()
    local ok, data = telegram.request("getMe")
    if not ok then return error(data) end
    return telegram.structures.User(data)
end

--- Use this method to send text messages.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam string text Text of the message to be sent, 1-4096 characters after entities parsing.
-- @tparam ?string parseMode `Markdown` or `HTML` if you want some markdown in the bot's messages.
-- @tparam ?boolean disableWebPagePreview Disables link previews for links in this message.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendMessage(chatID, text, parseMode, disableWebPagePreview, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local ok, data = telegram.request("sendMessage", {chat_id=chatID, text=text, parse_mode=parseMode,
    disable_web_page_preview=disableWebPagePreview, disable_notification=disableNotification,
    reply_to_message_id=replyToMessageID, reply_markup=replyMarkup})
    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to forward messages of any kind.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target channel (in the format `@channelusername`).
-- @tparam number|string fromChatID Unique identifier for the chat where the original message was sent (or channel username in the format `@channelusername`).
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam number messageID Message identifier in the chat specified in `fromChatID`.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.forwardMessage(chatID, fromChatID, disableNotification, messageID)
    local ok, data = telegram.request("forwardMessage", {chat_id=chatID, from_chat_id=fromChatID, disable_notification=disableNotification, message_id=messageID})
    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to send photos.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam InputFile|string photo Photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. [More info on Sending Files](https://core.telegram.org/bots/api#sending-files).
-- @tparam ?string caption Photo caption (may also be used when resending photos by file_id), 0-1024 characters after entities parsing
-- @tparam ?string parseMode `Markdown` or `HTML` if you want some markdown in the file's caption.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendPhoto(chatID, photo, caption, parseMode, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local parameters = {chat_id=chatID, caption=caption, parse_mode=parseMode, disable_notification=disableNotification,
    reply_to_message_id=replyToMessageID, reply_markup=replyMarkup}

    local ok, data
    if type(photo) == "table" then
        ok, data = telegram.request("sendPhoto", parameters, nil, {photo=photo})
    else
        parameters.photo = photo
        ok, data = telegram.request("sendPhoto", parameters)
    end

    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to send audio files, if you want Telegram clients to display them in the music player.
-- Your audio must be in the .MP3 or .M4A format.
-- Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.
-- For sending voice messages, use the `sendVoice` method instead.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam InputFile|string audio Audio file to send. Pass a file_id as String to send an audio file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an audio file from the Internet, or upload a new one using multipart/form-data.
-- @tparam ?string caption Audio caption, 0-1024 characters after entities parsing.
-- @tparam ?string parseMode `Markdown` or `HTML` if you want some markdown in the audio's caption.
-- @tparam ?number duration Duration of the audio in seconds.
-- @tparam ?string performer Performer.
-- @tparam ?string title Track name.
-- @tparam ?InputFile|string|nil thumb Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass `attach://<file_attach_name>` if the thumbnail was uploaded using multipart/form-data under `<file_attach_name>`.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendAudio(chatID, audio, caption, parseMode, duration, performer, title, thumb, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local parameters = {chat_id=chatID, caption=caption, parse_mode=parseMode, duration=duration,
    performer=performer, title=title, disable_notification=disableNotification,
    reply_to_message_id=replyToMessageID, reply_markup=replyMarkup}

    local ok, data
    if type(audio) == "table" or type(thumb) == "table" then
        local files = {}
        if type(audio) == "table" then
            files.audio = audio
        else
            parameters.audio = audio
        end
        if type(thumb) == "table" then
            files.thumb = thumb
            parameters.thumb = "attach://"..thumb.filename
        else
            parameters.thumb = thumb
        end
        ok, data = telegram.request("sendAudio", parameters, nil, files)
    else
        parameters.audio = audio
        parameters.thumb = thumb
        ok, data = telegram.request("sendAudio", parameters)
    end
    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to send general files.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam InputFile|string document File to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. [More info on Sending Files](https://core.telegram.org/bots/api#sending-files).
-- @tparam ?InputFile|string|nil thumb Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file. [More info on Sending Files](https://core.telegram.org/bots/api#sending-files).
-- @tparam ?string caption Document caption (may also be used when resending documents by file_id), 0-1024 characters after entities parsing.
-- @tparam ?string parseMode `Markdown` or `HTML` if you want some markdown in the file's caption.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendDocument(chatID, document, thumb, caption, parseMode, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local parameters = {chat_id=chatID, caption=caption, parse_mode=parseMode, disable_notification=disableNotification,
    reply_to_message_id=replyToMessageID, reply_markup=replyMarkup}

    local ok, data
    if type(document) == "table" or type(thumb) == "table" then
        local files = {}

        if type(document) == "table" then
            files.document = document
        else
            parameters.document = document
        end

        if type(thumb) == "table" then
            files.thumb = thumb
            parameters.thumb = "attach://"..thumb.filename
        end

        ok, data = telegram.request("sendDocument", parameters, nil, files)
    else
        parameters.document = document
        ok, data = telegram.request("sendDocument", parameters)
    end

    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to send point on the map.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam number latidude Latitude of the location.
-- @tparam number longitude Longitude of the location.
-- @tparam ?number livePeriod Period in seconds for which the location will be updated (see [Live Locations](https://telegram.org/blog/live-locations)), should be between 60 and 86400.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendLocation(chatID, latidude, longitude, livePeriod, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local ok, data = telegram.request("sendLocation", {chat_id=chatID, latidude=latidude, longitude = longitude,
    live_period=livePeriod, disable_notification=disableNotification, reply_to_message_id=replyToMessageID, reply_markup=replyMarkup})
    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to send a dice, which will have a random value from 1 to 6.
-- (Yes, we're aware of the “_proper_” singular of die. But it's awkward, and we decided to help it change. One dice at a time!).
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam ?string emoji Emoji on which the dice throw animation is based. Currently, must be one of “🎲” or “🎯”. Defaults to “🎲”.
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent message.
-- @raise Error on failure.
function telegram.sendDice(chatID, emoji, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local ok, data = telegram.request("sendDice", {chat_id=chatID, emoji=emoji, disable_notification=disableNotification,
    reply_to_message_id=replyToMessageID, reply_markup = replyMarkup})
    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method when you need to tell the user that something is happening on the bot's side.
-- Available actions:
--
-- - `typing` for text messages.
--
-- - `upload_photo` for photos.
--
-- - `upload_video` for videos.
--
-- - `record_audio` or `upload_audio` for audio files.
--
-- - `upload_document` for general files.
--
-- - `find_location` for location data.
--
-- - `record_video_note` or `upload_video_note` for video notes.
---
-- The status is set for 5 seconds or less (when a message arrives from your bot, Telegram clients clear its typing status).
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam string action Type of action to broadcast.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.sendChatAction(chatID, action)
    local ok, data = telegram.request("sendChatAction", {chat_id=chatID, action=action})
    if not ok then return error(data) end
    return data
end

--- Use this method to get basic info about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size.
-- @tparam string fileID File identifier to get info about.
-- @treturn File The requested file object.
-- @raise Error on failure.
function telegram.getFile(fileID)
    local ok, data = telegram.request("getFile", {file_id=fileID})
    if not ok then return error(data) end
    return telegram.structures.File(data)
end

--- Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam number userID Unique identifier of the target user.
-- @tparam string customTitle New custom title for the administrator; 0-16 characters, emoji are not allowed.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.setChatAdministratorCustomTitle(chatID, userID, customTitle)
    local ok, data = telegram.request("setChatAdministratorCustomTitle", {chat_id=chatID, user_id=userID, custom_title=customTitle})
    if not ok then return error(data) end
    return data
end

--- Use this method to generate a new invite link for a chat; any previously generated link is revoked.
-- The bot must be an administrator in the chat for this to work and must have the appropriate admin rights.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @treturn string The exported invite link on success.
-- @raise Error on failure.
function telegram.exportChatInviteLink(chatID)
    local ok, data = telegram.request("exportChatInviteLink", {chat_id = chatID})
    if not ok then return error(data) end
    return data
end

--- Use this method to pin a message in a group, a supergroup, or a channel.
-- he bot must be an administrator in the chat for this to work and must have the `canPinMessages` admin right in the supergroup or `canEditMessages` admin right in the channel.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam number messageID Identifier of a message to pin.
-- @tparam ?boolean disableNotification Pass True, if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.pinChatMessage(chatID, messageID, disableNotification)
    local ok, data = telegram.request("pinChatMessage", {chat_id=chatID, message_id=messageID, disable_notification=disableNotification})
    if not ok then return error(data) end
    return data
end

--- Use this method to unpin a message in a group, a supergroup, or a channel.
-- he bot must be an administrator in the chat for this to work and must have the `canPinMessages` admin right in the supergroup or `canEditMessages` admin right in the channel.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.unpinChatMessage(chatID)
    local ok, data = telegram.request("unpinChatMessage", {chat_id=chatID})
    if not ok then return error(data) end
    return data
end

--- Use this method to get up to date information about the chat (current name of the user for one-on-one conversations, current username of a user, group or channel, etc.).
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @treturn Chat The requested chat object on success.
-- @raise Error on failure.
function telegram.getChat(chatID)
    local ok, data = telegram.request("getChat", {chat_id = chatID})
    if not ok then return error(data) end
    return telegram.structures.Chat(data)
end

--- Use this method to send answers to callback queries sent from [inline keyboards](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
-- The answer will be displayed to the user as a notification at the top of the chat screen or as an alert.
-- @tparam string callbackQueryID Unique identifier for the query to be answered.
-- @tparam ?string text Text of the notification. If not specified, nothing will be shown to the user, 0-200 characters.
-- @tparam ?boolean showAlert If `true`, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to `false`.
-- @tparam ?string url URL that will be opened by the user's client. If you have created a Game and accepted the conditions via @Botfather, specify the URL that opens your game — note that this will only work if the query comes from a callback_game button.
-- Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
-- @tparam ?number cacheTime The maximum amount of time in seconds that the result of the callback query may be cached client-side. Telegram apps will support caching starting in version 3.14. Defaults to `0`.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.answerCallbackQuery(callbackQueryID, text, showAlert, url, cacheTime)
    local ok, data = telegram.request("answerCallbackQuery", {callback_query_id=callbackQueryID, text=text,
        show_alert=showAlert, url=url, cache_time=cacheTime})
    if not ok then return error(data) end
    return data
end

--- Use this method to change the list of the bot's commands.
-- Command name must be between 1 and 32 characters.
-- Command description must be between 3 and 256 characters.
-- @tparam table commands A table which keys are the commands names, and values are the commands descriptions.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.setMyCommands(commands)
    local botCommands = {}
    for commandName, commandDescription in pairs(commands) do
        table.insert(botCommands, {command=commandName, description=commandDescription})
    end
    local ok, data = telegram.request("setMyCommands", {commands=botCommands})
    if not ok then return error(data) end
    return data
end

--- Use this method to get the current list of the bot's commands.
-- @treturn table A table which keys are the commands names, and values are the commands descriptions.
-- @raise Error on failure.
function telegram.getMyCommands()
    local ok, data = telegram.request("getMyCommands")
    if not ok then return error(data) end
    local commands = {}
    for _, command in ipairs(data) do
        commands[command.command] = command.description
    end
    return commands
end

--- Updating messages Functions.
-- @section updating_messages

--- Use this method to edit text and game messages.
-- @tparam ?number|string chatID Required if `inlineMessageID` is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`).
-- @tparam ?number messageID Required if `inlineMessageID` is not specified. Identifier of the message to edit.
-- @tparam ?string inlineMessageID Required if `chatID` and `messageID` are not specified. Identifier of the inline message.
-- @tparam ?string text New text of the message, 1-4096 characters after entities parsing.
-- @tparam ?string parseMode Mode for parsing entities in the message text. See [formatting options](https://core.telegram.org/bots/api#formatting-options) for more details.
-- @tparam ?boolean disableWebPagePreview Disables link previews for links in this message.
-- @tparam ?InlineKeyboardMarkup replyMarkup The reply markup for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
-- @treturn Message|boolean If edited message is sent by the bot, the edited Message is returned, otherwise `true` is returned.
-- @raise error on failure.
function telegram.editMessageText(chatID, messageID, inlineMessageID, text, parseMode, disableWebPagePreview, replyMarkup)
    local ok, data = telegram.request("editMessageText", {chat_id=chatID, message_id=messageID, inline_message_id=inlineMessageID, text=text, parse_mode=parseMode, disable_web_page_preview=disableWebPagePreview, reply_markup=replyMarkup})
    if not ok then return error(data) end
    if type(data) == "table" then
        return telegram.structures.Message(data)
    else
        return data
    end
end

--TODO: editMessageCaption
--TODO: editMessageMedia
--TODO: editMessageReplayMarkup
--TODO: stopPoll

--- Use this method to delete a message, including service messages.
-- With the following limitations:
-- A message can only be deleted if it was sent less than 48 hours ago.
--
-- - A dice message in a private chat can only be deleted if it was sent more than 24 hours ago.
--
-- - Bots can delete outgoing messages in private chats, groups, and supergroups.
--
-- - Bots can delete incoming messages in private chats.
--
-- - Bots granted `canPostMessages` permissions can delete outgoing messages in channels.
--
-- - If the bot is an administrator of a group, it can delete any message there.
--
-- - If the bot has `canDeleteMessages` permission in a supergroup or a channel, it can delete any message there.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target channel (in the format `@channelusername`).
-- @tparam number messageID Identifier of the message to delete.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.deleteMessage(chatID, messageID)
    local ok, data = telegram.request("deleteMessage", {chat_id=chatID, message_id=messageID})
    if not ok then return error(data) end
    return data
end

--- Stickers Functions.
-- @section stickers

--- Use this method to send static .WEBP or animated .TGS stickers.
-- @tparam number|string chatID Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`).
-- @tparam InputFile|string sticker Sticker to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a .WEBP file from the Internet, or upload a new one using multipart/form-data. [More info on Sending Files](https://core.telegram.org/bots/api#sending-files).
-- @tparam ?boolean disableNotification Sends the message silently. Users will receive a notification with no sound.
-- @tparam ?number replyToMessageID If the message is a reply, ID of the original message.
-- @tparam ?InlineKeyboardMarkup|ReplyKeyboardMarkup|ReplyKeyboardRemove|ForceReply|nil replyMarkup Additional interface options. An object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
-- @treturn Message The sent Message.
-- @raise Error on failure.
function telegram.sendSticker(chatID, sticker, disableNotification, replyToMessageID, replyMarkup)
    replyMarkup = replyMarkup and replyMarkup:getData()
    local parameters = {chat_id=chatID, disable_notification=disableNotification, reply_to_message_id=replyToMessageID, reply_markup=replyMarkup}

    local ok, data
    if type(sticker) == "table" then
        ok, data = telegram.request("sendSticker", parameters, nil, {sticker=sticker})
    else
        parameters.sticker = sticker
        ok, data = telegram.request("sendSticker", parameters)
    end

    if not ok then return error(data) end
    return telegram.structures.Message(data)
end

--- Use this method to get a sticker set.
-- @tparam string name Name of the sticker set.
-- @treturn StickerSet The requested sticker set.
-- @raise Error on failure.
function telegram.getStickerSet(name)
    local ok, data = telegram.request("getStickerSet", {name=name})
    if not ok then return error(data) end
    return telegram.structures.StickerSet(data)
end

--- Use this method to upload a .PNG file with a sticker for later use in createNewStickerSet and addStickerToSet methods (can be used multiple times).
-- @tparam number userID User identifier of sticker file owner.
-- @tparam InputFile pngSticker **PNG** image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px.
-- @treturn File The uploaded file.
-- @raise Error on failure.
function telegram.uploadStickerFile(userID, pngSticker)
    local ok, data = telegram.request("uploadStickerFile", {user_id=userID}, nil, {png_sticker=pngSticker})
    if not ok then return error(data) end
    return telegram.structures.File(data)
end

--- Use this method to create a new sticker set owned by a user.
-- The bot will be able to edit the sticker set thus created.
-- You **must** use exactly one of the fields `pngSticker` or `tgsSticker`.
-- @tparam number userID User identifier of created sticker set owner.
-- @tparam string name Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals). Can contain only english letters, digits and underscores. Must begin with a letter, can't contain consecutive underscores and must end in ` by <bot username>`. `<bot_username>` is case insensitive. 1-64 characters.
-- @tparam string title Sticker set title, 1-64 characters.
-- @tparam ?InputFile|string|nil pngSticker **PNG** image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data.
-- @tparam ?InputFile tgsSticker **TGS** animation with the sticker, uploaded using multipart/form-data. See https://core.telegram.org/animated_stickers#technical-requirements for technical requirements.
-- @tparam string emojis One or more emoji corresponding to the sticker.
-- @tparam ?boolean containsMasks Pass True, if a set of mask stickers should be created.
-- @tparam ?MaskPosition maskPosition A MaskPosition object for position where the mask should be placed on faces.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.createNewStickerSet(userID, name, title, pngSticker, tgsSticker, emojis, containsMasks, maskPosition)
    maskPosition = maskPosition and maskPosition:getData()
    local parameters = {user_id=userID, name=name, title=title, emojis=emojis, contains_masks=containsMasks, mask_position=maskPosition}
    local ok, data
    if type(pngSticker) == "string" then
        parameters.png_sticker = pngSticker
        ok, data = telegram.request("createNewStickerSet", parameters)
    else
        ok, data = telegram.request("createNewStickerSet", parameters, nil, {png_sticker=pngSticker, tgs_sticker=tgsSticker})
    end
    if not ok then return error(data) end
    return data
end

--- Use this method to add a new sticker to a set created by the bot.
-- You **must** use exactly one of the fields `pngSticker` or `tgsSticker`.
-- Animated stickers can be added to animated sticker sets and only to them.
-- Animated sticker sets can have up to 50 stickers. Static sticker sets can have up to 120 stickers.
-- @tparam number userID User identifier of sticker set owner.
-- @tparam string name Sticker set name.
-- @tparam ?InputFile|string|nil pngSticker **PNG** image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data.
-- @tparam ?InputFile tgsSticker **TGS** animation with the sticker, uploaded using multipart/form-data. See https://core.telegram.org/animated_stickers#technical-requirements for technical requirements.
-- @tparam string emojis One or more emoji corresponding to the sticker.
-- @tparam ?MaskPosition maskPosition A MaskPosition object for position where the mask should be placed on faces.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.addStickerToSet(userID, name, pngSticker, tgsSticker, emojis, maskPosition)
    maskPosition = maskPosition and maskPosition:getData()
    local parameters = {user_id=userID, name=name, emojis=emojis, mask_position=maskPosition}
    local ok, data
    if type(pngSticker) == "string" then
        parameters.png_sticker = pngSticker
        ok, data = telegram.request("addStickerToSet", parameters)
    else
        ok, data = telegram.request("addStickerToSet", parameters, nil, {png_sticker=pngSticker, tgs_sticker=tgsSticker})
    end
    if not ok then return error(data) end
    return data
end

--- Use this method to move a sticker in a set created by the bot to a specific position.
-- @tparam string sticker File identifier of the sticker.
-- @tparam number position New sticker position in the set, zero-based.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.setStickerPositionInSet(sticker, position)
    local ok, data = telegram.request("setStickerPositionInSet", {sticker=sticker, position=position})
    if not ok then return error(data) end
    return data
end

--- Use this method to delete a sticker from a set created by the bot.
-- @tparam string sticker File identifier of the sticker.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.deleteStickerFromSet(sticker)
    local ok, data = telegram.request("deleteStickerFromSet", {sticker=sticker})
    if not ok then return error(data) end
    return data
end

--- Use this method to set the thumbnail of a sticker set. Animated thumbnails can be set for animated sticker sets only.
-- @tparam string name Sticker set name.
-- @tparam number userID User identifier of the sticker set owner.
-- @tparam ?InputFile|string|nil thumb A PNG image with the thumbnail, must be up to 128 kilobytes in size and have width and height exactly 100px, or a TGS animation with the thumbnail up to 32 kilobytes in size; see https://core.telegram.org/animated_stickers#technical-requirements for animated sticker technical requirements. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. Animated sticker set thumbnail can't be uploaded via HTTP URL.
-- @treturn boolean `true` on success.
-- @raise Error on failure.
function telegram.setStickerThumb(name, userID, thumb)
    local parameters = {name=name, user_id=userID}
    local ok, data
    if type(thumb) == "string" then
        parameters.thumb = thumb
        ok, data = telegram.request("setStickerThumb", parameters)
    else
        ok, data = telegram.request("setStickerThumb", parameters, nil, {thumb=thumb})
    end
    if not ok then return error(data) end
    return data
end

return telegram