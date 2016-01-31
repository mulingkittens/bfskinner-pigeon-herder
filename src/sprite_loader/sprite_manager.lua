return function(spriteSheetFile)
    local spriteSheet = love.graphics.newImage(spriteSheetFile)
    local mtable = {
        sprites = {},
        spriteSheet = spriteSheet,
        spriteBatch = nil,
    }

    return mtable
    end