----------------------
--- Module: tracker
--- Author: Zads
--- All rights reserved, 2020
----------------------


-- Esse modulo cuida atualmente da:
--   * ping recorrente
--   * tracking do usuário no app
--   * resolução da identidade e seção
--   * report experiment results

local http = require('app/shared/utils/ncluahttp')
local uuid4 = require('app/shared/utils/uuid4')
local logging = require('app/shared/utils/logging')
local json = require('app/shared/utils/json')



local ExecutableAppTracker = {
    parent = {},
    debug_mode = false,
    name = nil, -- type str
    state = 'ready', -- type enum['ready', 'running', 'finished']; blocked state?
    child_list = {}, --type List[Executable]

    max_exibition_area = {
        x = 0,
        y = 0,
        w = 0,
        h = 0
    }, --TODO
    -- quem irá forçar essa area ser respeitada?
    tracker_url = nil,
	app_id = nil,
	user_id = nil,
	publisher_id = nil,
	campaign_id = nil,
	session_id = nil,
	settings = '',
	delay_window = 30000, --type: int, in ms
	delay_offset = 0, --type: int, in ms
	recurrent_callback_responses = 0, --type: int
	report_sample_proportion = 100, --type: int, from 0 to 100, 100 means all reports are sent
}

function ExecutableAppTracker:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local core = {
	legacy_model = false,
	timer = function(self, delay, func) return event.timer(delay, func) end,
	uptime = function(self) return event.uptime() end
}

function ExecutableAppTracker:start()
    assert(self.publisher_id, 'publisherID is required')
    assert(self.app_id, 'appID is required')
    assert(self.tracker_url, 'baseURL is required')
    assert(self.session_id, 'sessionID is required')


    -- Identity
    if not core.legacy_mode then
        local worked, result = pcall(function()
            if (persistent.shared.zadsUserID and #(persistent.shared.zadsUserID)>2) then
                self.user_id = persistent.shared.zadsUserID
            else
                self.user_id = uuid4.getUUID()
                persistent.shared.zadsUserID = self.user_id
            end
        end )
        worked, result = pcall(function()
            self.user_id = self.user_id or uuid4.getUUID()
        end )
    else
        self.user_id = ''
    end


    -- Connectivity
    if not core.legacy_mode then
        self.delay_offset = math.random(self.delay_window)
    else
        self.delay_offset = 0
    end
    core:timer(
        self.delay_offset,
        function () self:send_recurrent() end
    )
end

function ExecutableAppTracker:add_settings(key, value)
    if not core.legacy_mode then
        value = value or 'none'
        if #self.settings < 8000 then --limit the size of the setting log
            self.settings = self.settings .. '\"' .. tostring(key) .. '\":\"' .. tostring(value) .. '\", '
        end
    end
end

function ExecutableAppTracker:send_settings(settings)
    settings = settings or ""
    -- After collecting all settings (when we'll known that we collected all?), we can send a hash or it or something like that
    if not core.legacy_mode then
        local query = '?endpoint=ctv-settings&publisherID=' .. self.publisher_id
        .. '&eventType=' .. 'ctv-settings'
        .. '&campaignID=' .. self.campaign_id
        .. '&appID=' .. self.app_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&settings={' .. settings .. '}'

        http.request(
            self.tracker_url .. query,
            function(header, body) self.settings_sent = true end,
            "GET"
        )
        self.settings_sent = true
        if self.debug_mode then
            logging.callback('[Tracker] settings sent')
            logging.network_request(query)
        end
    end
end

function ExecutableAppTracker:send_transition(origin, destiny)
    if not core.legacy_mode then
        local time = core:uptime()
        local query = '?endpoint=ctv-transition&publisherID=' .. self.publisher_id
        .. '&campaignID=' .. self.campaign_id
        .. '&appID=' .. self.app_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&origin=' .. origin
        .. '&destiny=' .. destiny
        .. '&time=' .. time
        http.request(self.tracker_url .. query,
            function(header, body) end,
            "GET")
            if self.debug_mode then
                logging.callback('[Tracker] transition sent')
                logging.network_request(query)
            end
    end
end

function ExecutableAppTracker:send_recurrent()
    core:timer(self.delay_window, function () self:send_recurrent() end)
    local query = '?endpoint=ctv-recurrent-ping&publisherID=' .. self.publisher_id
    .. '&campaignID=' .. self.campaign_id
    .. '&appID=' .. self.app_id
    ..'&userID=' .. self.user_id
    .. '&sessionID=' .. self.session_id
    http.request(
        self.tracker_url .. query,
        function(header, body) self:recurrent_callback(header, body) end,
        "GET"
    )
    if self.debug_mode then
        logging.callback('[Tracker] recurrent sent')
        logging.network_request(query)
    end

    if not core.legacy_mode then
        if not self.settings_sent then
            self:send_settings(self.parent.settings)
        end
    end
end

function ExecutableAppTracker:send_result(status, name, runtime, result)
    if not core.legacy_mode then
        memory = collectgarbage("count")
    else
        memory = -1
    end
    core:timer(
        self.delay_offset,
        function()
            if math.random(100) <= self.report_sample_proportion then
                local body = {
                    name = tostring(name),
                    worked = status,
                    runtime = runtime,
                    memory = memory,
                    sessionID = tostring(self.session_id),
                    settings = self.settings,
                    data = tostring(result)
                }
---@diagnostic disable-next-line: cast-local-type
                body = json.encode(body)

                local headers = "Content-Type: application/json"
                if self.debug_mode then
                    logging.info("[Tracker] Sending results: \n" .. body)
                end
                http.request(self.tracker_url, function() end, "POST", body, nil, headers)
            end
        end
    )
end

function ExecutableAppTracker:recurrent_callback(header, body)
    self.recurrent_callback_responses = self.recurrent_callback_responses + 1
    if self.debug_mode then
        logging.callback('[Tracker] Recurrent response received')
        logging.info(body)
    end
end

function ExecutableAppTracker:send_question_answer(answer)

    if core.capability_internet then
        local time = core:uptime()
        local query = '?endpoint=ctv-question-answer'
            .. '&eventType=' .. 'ctv-question-answer'
            .. '&eventTypeExtra=' ..  answer
            .. '&publisherID=' .. self.publisher_id
            .. '&campaign=' .. self.campaign_id
            .. '&appID=' .. self.app_id
            .. '&userID=' .. self.user_id
            .. '&sessionID=' .. self.session_id
            .. '&time=' .. time
        http.request(self.tracker_url .. query,
            function(header, body) end,
            "GET")
    end
end

function ExecutableAppTracker:send_click_event(key)
local current = ''

    if key then current = key end
        local time = core:uptime()
        local query = '?endpoint=ctv-control-key'
            .. '&eventType=' .. 'ctv-control-key'
            .. '&eventTypeExtra=' ..  current
            .. '&publisherID=' .. self.publisher_id
            .. '&campaign=' .. self.campaign_id
            .. '&appID=' .. self.app_id
            .. '&userID=' .. self.user_id
            .. '&sessionID=' .. self.session_id
            .. '&time=' .. time
        http.request(self.tracker_url .. query,
            function(header, body) end,
            "GET")
end

--------- Zedia Ads
--------- ADVERTISING EVENTS

function ExecutableAppTracker:send_ad_impression_event()
        local time = core:uptime()
        local query = '?endpoint=ad-impression'
            .. '&eventType=' .. 'ad-impression'
            .. '&publisherID=' .. self.publisher_id
            .. '&campaign=' .. self.campaign_id
            .. '&appID=' .. self.app_id
            .. '&userID=' .. self.user_id
            .. '&sessionID=' .. self.session_id
            .. '&time=' .. time

        if self.debug_mode then
            logging.network_request(self.tracker_url .. query)
        end

        http.request(self.tracker_url .. query,
            function(header, body)
                if self.debug_mode then
                    logging.callback('[Tracker] Ad Impression Sent')
                end
            end,
            "GET")
end

function ExecutableAppTracker:send_ad_click_event(key)
local current = ''
if key then current = key end

        local time = core:uptime()
        local query = '?endpoint=ad-click'
            .. '&eventType=' .. 'ad-click'
            .. '&eventTypeExtra=' .. current
            .. '&publisherID=' .. self.publisher_id
            .. '&campaign=' .. self.campaign_id
            .. '&appID=' .. self.app_id
            .. '&userID=' .. self.user_id
            .. '&sessionID=' .. self.session_id
            .. '&time=' .. time

        http.request(self.tracker_url .. query,
            function(header, body)
                if self.debug_mode then
                    logging.callback('[Tracker] Ad Click Sent')
                end
            end,
            "GET")

end

--------- Zedia Content
--------- CONTENT EVENTS

function ExecutableAppTracker:send_content_reaction_event(key)
    local current = key
    if key then current = key end

    local time = core:uptime()
    local query = '?endpoint=ctv-reaction-click'
        .. '&eventType=' .. 'ctv-reaction-click'
        .. '&eventTypeExtra=' .. current
        .. '&publisherID=' .. self.publisher_id
        .. '&campaign=' .. '59835dd2-27d1-40f9-8a9f-948e4cb4ca26'
        .. '&appID=' .. self.app_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&time=' .. time

    http.request(self.tracker_url .. query,
        function(header, body) if self.debug_mode then logging.callback('[Tracker] reaction sent: ' .. current) end end,
        "GET")

end

function ExecutableAppTracker:send_poll_answer(poll_id, poll_response)
    local time = core:uptime()
    local query = '?endpoint=ctv-poll-answer'
        .. '&eventType=' .. 'poll-answer'
        .. '&eventTypeExtra=' .. poll_response
        .. '&publisherID=' .. self.publisher_id
        .. '&campaign=' .. poll_id
        .. '&appID=' .. poll_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&time=' .. time

    http.request(self.tracker_url .. query,
        function(header, body) if self.debug_mode then logging.callback('[Tracker] poll answer sent: ' .. poll_response) end end,
        "GET")
end

function ExecutableAppTracker:send_poll_impression(poll_id)
    local time = core:uptime()
    local query = '?endpoint=ctv-poll-impression'
        .. '&eventType=' .. 'poll-impression'
        .. '&eventTypeExtra=' .. ''
        .. '&publisherID=' .. self.publisher_id
        .. '&campaign=' .. poll_id
        .. '&appID=' .. poll_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&time=' .. time

    http.request(self.tracker_url .. query,
        function(header, body) if self.debug_mode then logging.callback('[Tracker] poll impression sent') end end,
        "GET")
end

function ExecutableAppTracker:send_survey_impression(survey_id)
    local time = core:uptime()
    local query = '?endpoint=ctv-survey-impression'
        .. '&eventType=' .. 'survey-impression'
        .. '&eventTypeExtra=' .. ''
        .. '&publisherID=' .. self.publisher_id
        .. '&campaign=' .. survey_id
        .. '&appID=' .. survey_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&time=' .. time

    http.request(self.tracker_url .. query,
        function(header, body) if self.debug_mode then logging.callback('[Tracker] survey impression sent') end end,
        "GET")
end

function ExecutableAppTracker:send_widget_event(widget_name, event_key, event_value)
    if widget_name == nil then widget_name = 'widget-undefined' end
    if event_key == nil then event_key = '' end
    if event_value == nil then event_value = '' end


    if not core.legacy_mode then
        local event_name = 'ctv-experimental-widget-event'
        local query = '?endpoint=' .. event_name
        .. '&publisherID=exp-' .. self.publisher_id
        .. '&appID=' .. self.app_id
        .. '&sessionID=' .. self.session_id
        .. '&widget=' ..  widget_name
        .. '&eventType=' .. event_key
        .. '&eventTypeExtra=' ..  event_value
        .. '&settings={' .. self.settings .. '}'

        http.request(
            self.tracker_url .. query,
            function(header, body)  end,
            "GET"
        )
        if self.debug_mode then
            logging.callback('[Tracker] ' .. widget_name .. ' event sent')
            logging.network_request(query)
        end
    end
end

--------- Zedia Opening
--------- OPENING EVENTS

function ExecutableAppTracker:send_opening_impression_event(user_call)
        local time = core:uptime()
        if user_call == nil then
            user_call = ''
        else
            user_call = 'user-call'
        end
        local query = '?endpoint=opening-impression'
            .. '&eventType=' .. 'opening-impression'
            .. '&eventTypeExtra=' ..  tostring(user_call)
            .. '&publisherID=' .. self.publisher_id
            .. '&appID=' .. self.app_id
            .. '&userID=' .. self.user_id
            .. '&sessionID=' .. self.session_id
            .. '&time=' .. time

        if self.debug_mode then
            logging.network_request(self.tracker_url .. query)
        end

        http.request(self.tracker_url .. query,
            function(header, body)
                if self.debug_mode then
                    logging.callback('[Tracker] Opening impression sent')
                end
            end,
            "GET")
end

function ExecutableAppTracker:send_opening_click_event(key)
    local current = ''
    if key then current = key end

    local time = core:uptime()
    local query = '?endpoint=opening-click'
        .. '&eventType=' .. 'opening-click'
        .. '&eventTypeExtra=' .. current
        .. '&publisherID=' .. self.publisher_id
        .. '&campaign=' .. self.campaign_id
        .. '&appID=' .. self.app_id
        .. '&userID=' .. self.user_id
        .. '&sessionID=' .. self.session_id
        .. '&time=' .. time

    http.request(self.tracker_url .. query,
        function(header, body)
            if self.debug_mode then
                logging.callback('[Tracker] Opening click sent!')
            end
        end,
        "GET")

end

local P = {}
P.ExecutableAppTracker = ExecutableAppTracker

return P;
