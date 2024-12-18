local ChannelInfo = require('app/ui/widgets/channel_info').ChannelInfo
local OpeningAds = require ('app/ui/widgets/opening_ads').OpeningAds
local HalfOpeningAds = require ('app/ui/widgets/halfopening_ads').HalfOpeningAds
local Reactions = require('app/ui/widgets/reactions').Reactions
local Background = require('app/ui/components/background').Background
local Season = require('app/ui/widgets/season_and_date_element').SeasonAndDatesElement
local Render = require('app/shared/utils/render')
local Image = require('app/ui/components/image')
local logging = require('app/shared/utils/logging')
local util = require('app/shared/utils/util')

local Home = {
  opening_ads = nil,
  halfopen_ads = nil,
  opening_channel_info = nil,
  opening_reactions = nil,
  season_and_date_element = nil,
  background = nil
}

function Home:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.background = Background:load_opening_bg()
  self.opening_reactions = Reactions:new({})
  self.opening_channel_info = ChannelInfo:new({})
  self.season_and_date_element = Season:new({})
  self.opening_ads = OpeningAds:new({})
  self.halfopen_ads = HalfOpeningAds:new({})
  if OpeningAds.opening_image.file_name == 'opening' and not HalfOpeningAds.visibility then
    self:load_navigator()
  end
  return o
end

function Home:load_navigator(up)
  local  x, y = 1073, 600
  if up then
    x, y = 1073, 480
  end

  local navigator = Image:new({
      parent = self,
      position = {
        x = x,
        y = y,
      },
      path = 'local/system/',
      extension = '.png',
      file_name = 'navigation'
    })
    Render.image(navigator)
end

function Home:load_opening_bg_gradient()
  local opening_background = Image:new({
    parent = self,
    position = {
      x = 0,
      y = 218,
    },
    path = 'local/system/',
    extension = '.png',
    file_name = 'opening_background'
  })
  Render.image(opening_background)
end

function Home:flush()
  util.printable(self.halfopen_ads)
  Render.flush()
end


local P = {}
P.Home = Home

return P;
