local Composer = require( "composer" )
local TileEngine = require "plugin.wattageTileEngine"
local Utils = TileEngine.Utils

local scene = Composer.newScene()

local CAMERA_VELOCITY   = 5 / 1000          -- Camera velocity in tiles per second
local CAMERA_START_X    = 15                -- The start of the camera movement range
local CAMERA_END_X      = 60                -- The end of the camera movement range

local tileEngine                            -- Reference to the tile engine
local lightingModel                         -- Reference to the lighting model
local tileEngineViewControl                 -- Reference to the UI view control
local lastTime                              -- Used to track how much time passes between frames
local rowCount                              -- Row count of the environment
local columnCount                           -- Column count of the environment

-- -----------------------------------------------------------------------------------
-- This will load in the example sprite sheet.  Replace this with the sprite
-- sheet needed for your application.
-- -----------------------------------------------------------------------------------
local spriteSheetInfo = require "tiles"
local spriteSheet = graphics.newImageSheet("tiles.png", spriteSheetInfo:getSheet())

-- -----------------------------------------------------------------------------------
-- A sprite resolver is required by the engine.  Its function is to create a
-- SpriteInfo object for the supplied key.  This function will utilize the
-- example sprite sheet.
-- -----------------------------------------------------------------------------------
local spriteResolver = {}
spriteResolver.resolveForKey = function(key)
    local frame = spriteSheetInfo.sheet.frames[key]
    local displayObject = display.newImageRect(spriteSheet, key, frame.width, frame.height)
    return TileEngine.SpriteInfo.new({
        imageRect = displayObject,
        width = frame.width,
        height = frame.height
    })
end

-- -----------------------------------------------------------------------------------
-- This is a callback required by the lighting model to determine whether a tile
-- is transparent.  In this implementation, the cells with a value of zero are
-- transparent.  The engine may ask about the transparency of tiles that are outside
-- the boundaries of our environment, so the implementation must handle these cases.
-- That is why nil is checked for in this example callback.
-- -----------------------------------------------------------------------------------
local function isTileTransparent(column, row)
    return true
end

-- -----------------------------------------------------------------------------------
-- This is a callback required by the lighting model to determine whether a tile
-- should be affected by ambient light.  This simple implementation always returns
-- true which indicates that all tiles are affected by ambient lighting.  If an
-- environment had a section which should not be affected by ambient lighting, this
-- callback can be used to indicate that.  For example, the environment my be
-- an outdoor environment where the ambient lighting is the sun.  A few tiles in this
-- environment may represent the inside of a cabin, and these tiles would need to
-- not be affected by ambient lighting.
-- -----------------------------------------------------------------------------------
local function allTilesAffectedByAmbient(column, row)
    return true
end

-- -----------------------------------------------------------------------------------
-- This function is a convenience function to retrieve a layer from a Tiled file.
-- -----------------------------------------------------------------------------------
local function getLayerByName(name, levelDefinition)
    for i=1,#levelDefinition.layers do
        local curLayer = levelDefinition.layers[i]
        if curLayer.name == name then
            return curLayer
        end
    end
    return nil
end

-- -----------------------------------------------------------------------------------
-- This function is a convenience function to load tiles into a layer.
-- -----------------------------------------------------------------------------------
local function loadTilesIntoLayer(layer, layerData)
    for row=1, rowCount do
        for col=1, columnCount do
            local tileType = layerData.data[(row - 1) * columnCount + col]
            if tileType ~= 0 then
                layer.updateTile(
                    row,
                    col,
                    TileEngine.Tile.new({
                        resourceKey = tileType
                    }))
            end
        end
    end
end

-- -----------------------------------------------------------------------------------
-- This will be called every frame.  It is responsible for setting the camera
-- positiong, updating the lighting model, rendering the tiles, and reseting
-- the dirty tiles on the lighting model.
-- -----------------------------------------------------------------------------------
local function onFrame(event)
    local camera = tileEngineViewControl.getCamera()
    local lightingModel = tileEngine.getActiveModule().lightingModel

    if lastTime ~= 0 then
        -- Determine the amount of time that has passed since the last frame and
        -- record the current time in the lastTime variable to be used in the next
        -- frame.
        local curTime = event.time
        local deltaTime = curTime - lastTime
        lastTime = curTime

        -- Update camera location
        local newX = camera.getX() + deltaTime * CAMERA_VELOCITY
        if newX > CAMERA_END_X then
            newX = newX - (newX - CAMERA_END_X)
            CAMERA_VELOCITY = -1 * CAMERA_VELOCITY
        elseif newX < CAMERA_START_X then
            newX = newX + (CAMERA_START_X - newX)
            CAMERA_VELOCITY = -1 * CAMERA_VELOCITY
        end
        camera.setLocation(newX, camera.getY())

        -- Update the lighting model passing the amount of time that has passed since
        -- the last frame.
        lightingModel.update(deltaTime)
    else
        -- This is the first call to onFrame, so lastTime needs to be initialized.
        lastTime = event.time

        -- This is the initial position of the camera
        camera.setLocation(CAMERA_START_X, 10)

        -- Since a time delta cannot be calculated on the first frame, 1 is passed
        -- in here as a placeholder.
        lightingModel.update(1)
    end

    -- Render the tiles visible to the passed in camera.
    tileEngine.render(camera)

    -- The lighting model tracks changes, then acts on all accumulated changes in
    -- the lightingModel.update() function.  This call resets the change tracking
    -- and must be called after lightingModel.update().
    lightingModel.resetDirtyFlags()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view

    -- Create a group to act as the parent group for all tile engine DisplayObjects.
    local tileEngineLayer = display.newGroup()

    -- Create an instance of TileEngine.
    tileEngine = TileEngine.Engine.new({
        parentGroup=tileEngineLayer,
        tileSize=32,
        spriteResolver=spriteResolver,
        compensateLightingForViewingPosition=false,
        hideOutOfSightElements=false
    })

    -- The tile engine needs at least one Module.  It can support more than
    -- one, but this template sets up only one which should meet most use cases.
    -- A module is composed of a LightingModel and a number of Layers
    -- (TileLayer or EntityLayer).  An instance of the lighting model is created
    -- first since it is needed to instantiate the Module.
    lightingModel = TileEngine.LightingModel.new({
        isTransparent = isTileTransparent,
        isTileAffectedByAmbient = allTilesAffectedByAmbient,
        useTransitioners = false,
        compensateLightingForViewingPosition = false
    })

    -- Load the Tiled JSON file
    local levelDefinition = Utils.loadJsonFile("map.json")
    rowCount = levelDefinition.height
    columnCount = levelDefinition.width

    -- Instantiate the module.
    local module = TileEngine.Module.new({
        name="moduleMain",
        rows= rowCount,
        columns= columnCount,
        lightingModel=lightingModel,
        losModel=TileEngine.LineOfSightModel.ALL_VISIBLE
    })

    -- Next, layers will be added to the Module...

    -- Create a TileLayer for the clouds.
    local cloudLayer = TileEngine.TileLayer.new({
        rows = rowCount,
        columns = columnCount
    })
    local cloudData = getLayerByName("Clouds", levelDefinition)
    loadTilesIntoLayer(cloudLayer, cloudData)

    -- Create a TileLayer for the leaves.
    local leavesLayer = TileEngine.TileLayer.new({
        rows = rowCount,
        columns = columnCount
    })
    local leavesData = getLayerByName("Leaves", levelDefinition)
    loadTilesIntoLayer(leavesLayer, leavesData)

    -- Create a TileLayer for the trees.
    local treeLayer = TileEngine.TileLayer.new({
        rows = rowCount,
        columns = columnCount
    })
    local treeData = getLayerByName("Trees", levelDefinition)
    loadTilesIntoLayer(treeLayer, treeData)

    -- Create a TileLayer for the platform 1.
    local platform1Layer = TileEngine.TileLayer.new({
        rows = rowCount,
        columns = columnCount
    })
    local platform1Data = getLayerByName("Platform1", levelDefinition)
    loadTilesIntoLayer(platform1Layer, platform1Data)

    -- Create a TileLayer for the platform 2.
    local platform2Layer = TileEngine.TileLayer.new({
        rows = rowCount,
        columns = columnCount
    })
    local platform2Data = getLayerByName("Platform2", levelDefinition)
    loadTilesIntoLayer(platform2Layer, platform2Data)

    -- It is necessary to reset dirty tile tracking after the layer has been
    -- fully initialized.  Not doing so will result in unnecessary processing
    -- when the scene is first rendered which may result in an unnecessary
    -- delay (especially for larger scenes).
    cloudLayer.resetDirtyTileCollection()
    leavesLayer.resetDirtyTileCollection()
    treeLayer.resetDirtyTileCollection()
    platform1Layer.resetDirtyTileCollection()
    platform2Layer.resetDirtyTileCollection()

    -- Add the layers to the module starting at index 1 (indexes start at 1, not 0).
    -- Set the scaling deltas to zero and stagger the X coefficients to create
    -- parallax.
    module.insertLayerAtIndex(cloudLayer, 1, 0, 0.6)
    module.insertLayerAtIndex(leavesLayer, 2, 0, 0.7)
    module.insertLayerAtIndex(treeLayer, 3, 0, 0.8)
    module.insertLayerAtIndex(platform1Layer, 4, 0, 0.9)
    module.insertLayerAtIndex(platform2Layer, 5, 0, 1)

    -- Add the module to the engine.
    tileEngine.addModule({module = module})

    -- Set the module as the active module.
    tileEngine.setActiveModule({
        moduleName = "moduleMain"
    })

    -- To render the tiles to the screen, create a ViewControl.  This example
    -- creates a ViewControl to fill the entire screen, but one may be created
    -- to fill only a portion of the screen if needed.
    tileEngineViewControl = TileEngine.ViewControl.new({
        parentGroup = sceneGroup,
        centerX = display.contentCenterX,
        centerY = display.contentCenterY,
        pixelWidth = display.actualContentWidth,
        pixelHeight = display.actualContentHeight,
        tileEngineInstance = tileEngine
    })

    -- Finally, set the ambient light to white light with medium-high intensity.
    lightingModel.setAmbientLight(1,1,1,0.7)
end


-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

        -- Set the lastTime variable to 0.  This will indicate to the onFrame event handler
        -- that it is the first frame.
        lastTime = 0

        -- Register the onFrame event handler to be called before each frame.
        Runtime:addEventListener( "enterFrame", onFrame )
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

        -- Remove the onFrame event handler.
        Runtime:removeEventListener( "enterFrame", onFrame )
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

    -- Destroy the tile engine instance to release all of the resources it is using
    tileEngine.destroy()
    tileEngine = nil

    -- Destroy the ViewControl to release all of the resources it is using
    tileEngineViewControl.destroy()
    tileEngineViewControl = nil

    -- Set the reference to the lighting model to nil.
    lightingModel = nil
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene