deep = require 'libs/deep'
local UiManager = require 'engine/ui_manager'

describe('UiManager', function()

    -- Test UiManager.new()
    it('should initialize correctly', function()
        local uiManager = UiManager.new()
        expect(uiManager.scopedElements).to.be.a('table')
        expect(uiManager.layerManager).to.exist()
    end)

    -- Test UiManager:registerElement()
    it('should register a UI element with scope and Z-layer', function()
        local uiManager = UiManager.new()
        local dummyElement = { z = 5, draw = function() end }
        uiManager:registerElement('testScope', 'testElement', dummyElement)
        expect(uiManager.scopedElements['testScope']).to.be.a('table')
        expect(uiManager.scopedElements['testScope']['testElement']).to.exist()
        expect(uiManager.scopedElements['testScope']['testElement'].element).to.equal(dummyElement)
        expect(uiManager.scopedElements['testScope']['testElement'].z).to.equal(5)
    end)

    -- Test UiManager:draw()
    it('should draw elements according to their Z-layer', function()
        local uiManager = UiManager.new()
        local drawCalled = false
        local dummyElement = {
            z = 5,
            visible = true,
            draw = function() drawCalled = true end
        }
        uiManager:registerElement('testScope', 'testElement', dummyElement)
        
        -- Mocking deep system methods
        deep = {
            new = function() return { queue = function() end, restrict = function() end, draw = function() end } end
        }
        
        uiManager:draw('testScope', 0, 10)
        expect(drawCalled).to.be.truthy()
    end)

    -- Test UiManager:update()
    it('should update elements in a scope', function()
        local uiManager = UiManager.new()
        local updateCalled = false
        local dummyElement = {
            update = function() updateCalled = true end
        }
        uiManager:registerElement('testScope', 'testElement', dummyElement)
        
        uiManager:update('testScope', 1)
        expect(updateCalled).to.be.truthy()
    end)

    -- Test UiManager:mousepressed()
    it('should handle mouse presses correctly', function()
        local uiManager = UiManager.new()
        local mousepressedCalled = false
        local dummyElement = {
            z = 5,
            mousepressed = function() mousepressedCalled = true end
        }
        uiManager:registerElement('testScope', 'testElement', dummyElement)
        
        uiManager:mousepressed(100, 100, 1)
        expect(mousepressedCalled).to.be.truthy()
    end)

    -- Test UiManager:removeElement()
    it('should remove a UI element from a scope', function()
        local uiManager = UiManager.new()
        local dummyElement = { visible = true }
        uiManager:registerElement('testScope', 'testElement', dummyElement)
        uiManager:removeElement('testScope', 'testElement')
        expect(uiManager.scopedElements['testScope']['testElement']).to_not.exist()
    end)

end)
