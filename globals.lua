local G = {}
HEX = require 'systems/HEX'
G.UIT = {
    T=1, --text
    B=2, --box (can be rounded)
    C=3, --column
    R=4, --row
    O=5, --object - must be a Node
    ROOT=7,
    S=8, --slider
    I=9, --input text box
    padding = 0, --default padding
}

G.TILESIZE = 20
G.TILESCALE = 3.65

G.LANG = 'fr'

G.SETTINGS = {}

G.SETTINGS.GRAPHICS = {
    texture_scaling = 2,
    shadows = 'On',
    crt = 70,
    bloom = 1
}
G.TIMERS = {
    REAL_SHADER = 0,
    BACKGROUND = 0,
    REAL = 0,
}

G.ARGS = {
    spin = {
        amount = 0,
        eased = 0,
        real = 0,
    },
}

G.C = {
    BLUE = HEX:HEX("009dff"),
    RED = HEX:HEX('FE5F55'),
    WHITE = HEX:HEX('FFFFFF'),
}

G.SANDBOX = {
    vort_time = 7,
    vort_speed = 0,
    col_op = {'RED','BLUE','GREEN','BLACK','L_BLACK','WHITE','EDITION','DARK_EDITION','ORANGE','PURPLE'},
    col1 = G.C.RED,col2 = G.C.BLUE,
    mid_flash = 0,
    edition = 'base',
    tilt = 1,
    card_size = 1,
    gamespeed = 0
}

G.FONTS = {
    file = "resources/fonts/m6x11plus.ttf", render_scale = G.TILESIZE*10, TEXT_HEIGHT_SCALE = 0.83, TEXT_OFFSET = {x=10,y=-20}, FONTSCALE = 0.1, squish = 1, DESCSCALE = 1
    -- {file = "resources/fonts/NotoSansSC-Bold.ttf", render_scale = G.TILESIZE*7, TEXT_HEIGHT_SCALE = 0.7, TEXT_OFFSET = {x=0,y=-35}, FONTSCALE = 0.12, squish = 1, DESCSCALE = 1.1},
    -- {file = "resources/fonts/NotoSansTC-Bold.ttf", render_scale = G.TILESIZE*7, TEXT_HEIGHT_SCALE = 0.7, TEXT_OFFSET = {x=0,y=-35}, FONTSCALE = 0.12, squish = 1, DESCSCALE = 1.1},
    -- {file = "resources/fonts/NotoSansKR-Bold.ttf", render_scale = G.TILESIZE*7, TEXT_HEIGHT_SCALE = 0.8, TEXT_OFFSET = {x=0,y=-20}, FONTSCALE = 0.12, squish = 1, DESCSCALE = 1},
    -- {file = "resources/fonts/NotoSansJP-Bold.ttf", render_scale = G.TILESIZE*7, TEXT_HEIGHT_SCALE = 0.8, TEXT_OFFSET = {x=0,y=-20}, FONTSCALE = 0.12, squish = 1, DESCSCALE = 1},
    -- {file = "resources/fonts/NotoSans-Bold.ttf", render_scale = G.TILESIZE*7, TEXT_HEIGHT_SCALE = 0.65, TEXT_OFFSET = {x=0,y=-40}, FONTSCALE = 0.12, squish = 1, DESCSCALE = 1},
    -- {file = "resources/fonts/m6x11plus.ttf", render_scale = G.TILESIZE*10, TEXT_HEIGHT_SCALE = 0.9, TEXT_OFFSET = {x=10,y=15}, FONTSCALE = 0.1, squish = 1, DESCSCALE = 1},
    -- {file = "resources/fonts/GoNotoCurrent-Bold.ttf", render_scale = G.TILESIZE*10, TEXT_HEIGHT_SCALE = 0.8, TEXT_OFFSET = {x=10,y=-20}, FONTSCALE = 0.1, squish = 1, DESCSCALE = 1},
    -- {file = "resources/fonts/GoNotoCJKCore.ttf", render_scale = G.TILESIZE*10, TEXT_HEIGHT_SCALE = 0.8, TEXT_OFFSET = {x=10,y=-20}, FONTSCALE = 0.1, squish = 1, DESCSCALE = 1},
}
G.STATES = {
    MENU = 1,
    TUTORIAL = 2,
    SPLASH = 3,
    SANDBOX = 4,
}
G.STAGES = {
    MAIN_MENU = 1,
    RUN = 2,
    SANDBOX = 3
}
G.STAGE_OBJECTS = {
    {},{},{}
}
G.STAGE = G.STAGES.MAIN_MENU
G.STATE = G.STATES.SPLASH
G.STATE_COMPLETE = false

return G