local testground = {}

local stars = {} -- Table to store star positions and animations
local numStars = 20 -- Number of stars to draw

function testground:load()
    -- Load the star sprite sheet
    star = love.graphics.newImage("assets/spritesheets/star.png")
    
    -- Create a grid for the animation frames
    local star_grid = anim8.newGrid(32, 32, star:getWidth(), star:getHeight())
    
    -- Generate random positions for the stars and create individual animations
    for i = 1, numStars do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        local frameDuration = math.random(10, 20) / 100 -- Random frame duration between 0.1 and 0.2 seconds
        local animation = anim8.newAnimation(star_grid('1-4', 1), frameDuration)
        table.insert(stars, {x = x, y = y, animation = animation})
    end
end

function testground:draw()
    -- Clear the screen with black color
    love.graphics.clear(0, 0, 0, 1)

    -- Draw each star at its random position with its assigned animation
    for _, starData in ipairs(stars) do
        starData.animation:draw(star, starData.x, starData.y, 0, 1, 1, 16, 16)
    end
    
    -- ButtonManager.drawButtons('testground')
end

function testground:outsideShaderDraw()
    -- This function is currently empty
end

function testground:update(dt)
    -- Update the button manager
    ButtonManager.updateButtons('testground', dt)
    
    -- Update each star's animation
    for _, starData in ipairs(stars) do
        starData.animation:update(dt)
    end
end

function testground:mousepressed(x, y, button)
    -- Handle mouse press events for buttons
    ButtonManager.mousepressed('testground', x, y, button)
end

return testground