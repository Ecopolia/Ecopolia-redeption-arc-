local map = {}
local mapLoaded = false
local loadingCoroutine = nil
local gamemap = nil
local camera = nil
local zoomFactor = 40
local mapscale = 0.5
local mapCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

local function setupMapPipeline()
    local pipeline = Pipeline.new(love.graphics.getWidth(), love.graphics.getHeight())

    -- Stage 1: Clear the screen and handle the loading screen
    pipeline:addStage(nil, function()
        love.graphics.clear(0.1, 0.1, 0.1, 1)
        if not mapLoaded then
            love.graphics.print("Chargement de la carte...", 400, 300)
        end
    end)

    -- Stage 2: Apply the camera transformation and draw the map
    pipeline:addStage(nil, function()
        if mapLoaded and gamemap then
            camera:zoomTo(zoomFactor)
            camera:attach()

            -- Calculate visible boundaries
            local screen_width = love.graphics.getWidth() / zoomFactor
            local screen_height = love.graphics.getHeight() / zoomFactor

            local cam_x, cam_y = camera:position()

            local start_x = math.floor((cam_x - screen_width / 2) / gamemap.tilewidth)
            local start_y = math.floor((cam_y - screen_height / 2) / gamemap.tileheight)
            local end_x = math.ceil((cam_x + screen_width / 2) / gamemap.tilewidth)
            local end_y = math.ceil((cam_y + screen_height / 2) / gamemap.tileheight)

            -- Draw the visible portion of the map
            gamemap:draw(start_x, start_y, end_x, end_y)

            camera:detach()
        end
    end)

    -- Stage 3: Draw the UI layer on top of the map
    pipeline:addStage(nil, function()
        if mapLoaded then
            -- Draw the map-specific UI
            uiManager:draw("map")
        end
    end)

    return pipeline
end

function map:load(args)
    -- Initialize the map loading coroutine
    loadingCoroutine = coroutine.create(function()
        -- Simulate loading delay
        love.timer.sleep(2)
        -- Load the map
        gamemap = sti('assets/maps/MainMap.lua')

        -- Create and center the camera on an initial position
        camera = Camera(0, 0)
        mapLoaded = true
    end)

    -- Setup the render pipeline
    self.pipeline = setupMapPipeline()
end

function map:draw()
    if self.pipeline then
        -- Run the pipeline for the map rendering
        self.pipeline:run()
    end
end

function map:update(dt)
    -- Resume loading coroutine if it's still active
    if loadingCoroutine and coroutine.status(loadingCoroutine) ~= "dead" then
        coroutine.resume(loadingCoroutine)
    end

    -- Update logic for the map once it is loaded
    if mapLoaded and gamemap then
        -- Mettre à jour la carte (par exemple, si elle contient des éléments interactifs ou de la physique)
        gamemap:update(dt)

    end
end

-- -- Gestion du zoom avec la molette de la souris
-- function love.wheelmoved(x, y)
--     if y < 0 then
--         -- DéZoomer
--         zoomFactor = zoomFactor * 1.1
--     elseif y > 0 then
--         -- Zoomer
--         zoomFactor = zoomFactor * 0.9
--     end

--     if(zoomFactor > 40) then
--         zoomFactor = 40
--     end

--     if(zoomFactor < 1) then
--         zoomFactor = 1
--     end

--     print(zoomFactor)
-- end

return map
