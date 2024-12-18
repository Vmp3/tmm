local canvas = canvas
local event = event
-- Calculate the rate at which the circle's radius should decrease per second

local CircleTimer = {
  initialRadius = 50,
  radius = 0,
  centerX = 150,
  centerY = 150,
  borderSize = 2,
  timerDuration = 30,
  frameRate = 30,
  interval = 1 * 1000,
}
local radiusChange = (CircleTimer.initialRadius - CircleTimer.borderSize) / (CircleTimer.timerDuration * CircleTimer.frameRate)

function CircleTimer:drawCircle()
 canvas:attrColor("black")
    canvas:drawRect("fill", 0, 0, 300, 300) -- Clear the canvas with a black background

    canvas:attrColor("white")

   for x = self.centerX - self.radius, self.centerX + self.radius do
        for y = self.centerY - self.radius, self.centerY + self.radius do
            local distanceSquared = (x - self.centerX)^2 + (y - self.centerY)^2
            if distanceSquared >= (self.radius - self.borderSize)^2 and distanceSquared <= self.radius^2 then
                canvas:drawRect("fill", x, y, 1, 1)
            end
        end
    end

    canvas:flush()
  end

function CircleTimer:animateCircle()
 self.radius = self.initialRadius


    event.timer(self.interval, self.update) -- Start the animation
end

function CircleTimer:startAnimation()
  self:animateCircle()
end

function CircleTimer:start()
   self:drawCircle()
end

function CircleTimer:update()
  -- self:drawCircle()
  print("Raio: " .. self.radius .. "Change: " .. radiusChange)
  self.radius = self.radius - (radiusChange * 10)
  print("Raio: " .. self.radius .. "Change: " .. radiusChange)

  -- if self.radius >= self.borderSize then
  --     event.timer(self.interval, function() self:update() end)
  -- else
  --     canvas:drawRect("fill", 0, 0, 300, 300) -- Clear the canvas after the timer is done
  --     canvas:flush()
  -- end
end

function CircleTimer:animate()
   self:update()
   self:drawCircle()
end

function CircleTimer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---------------------------------
------- // Instance \\ -----------
local P = {}
P.CircleTimer = CircleTimer

return P;
