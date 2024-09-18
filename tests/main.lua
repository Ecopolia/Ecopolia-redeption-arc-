local sourceBaseDir = love.filesystem.getSourceBaseDirectory()
package.path = package.path .. ';' .. sourceBaseDir .. '/?.lua'

lust = require 'libs/lust'

describe, it, expect = lust.describe, lust.it, lust.expect

local testsFinished = false

-- Function to load all test files from the tests directory
local function loadTests()
    local testFiles = love.filesystem.getDirectoryItems('tests')
    for _, file in ipairs(testFiles) do
        if file:match('^test_.*%.lua$') then
            local path = 'tests/' .. file
            local module = require(path:sub(1, -5))  -- Remove '.lua' extension
        end
    end
    testsFinished = true  -- Set flag when tests are done loading
end

function love.load()
    -- Load all test files
    loadTests()
end

function love.update(dt)
    if testsFinished then
        -- Quit Love2D after a short delay to let the "Running tests..." message display
        love.timer.sleep(1)
        love.event.quit()
    end
end