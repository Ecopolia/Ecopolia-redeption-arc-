-- local G = {}
HEX = require 'systems/HEX'

function Game:set_globals()

    self.UIT = {
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

    self.TILESIZE = 20
    self.TILESCALE = 3.65
    
    self.LANG = 'fr'

    self.SETTINGS = {
        WINDOW = {
            screenmode = 'Borderless',
            vsync = 1,
            selected_display = 1,
            display_names = {'[NONE]'},
            DISPLAYS = {
                {
                    name = '[NONE]',
                    screen_res = {w = 1000, h = 650},
                }
            },
        },
        GRAPHICS = {
            texture_scaling = 2,
            shadows = 'On',
            crt = 70,
            bloom = 1
        }
    }
    

    self.TIMERS = {
        TOTAL=0,
        REAL_SHADER = 0,
        BACKGROUND = 0,
        REAL = 0,
        UPTIME = 0,
    }

    self.ARGS = {
        spin = {
            amount = 0,
            eased = 0,
            real = 0,
        },
    }
    self.C = {
        BLUE = HEX:HEX("009dff"),
        RED = HEX:HEX('FE5F55'),
        WHITE = HEX:HEX('FFFFFF'),
        DARK_GREEN = HEX:HEX('059212'),
        LIGHT_GREEN = HEX:HEX('9BEC00'),
    }
        
    self.SANDBOX = {
        vort_time = 7,
        vort_speed = 0,
        col_op = {'DARK_GREEN','LIGHT_GREEN','RED','BLUE','GREEN','BLACK','L_BLACK','WHITE','EDITION','DARK_EDITION','ORANGE','PURPLE'},
        mid_flash = 0,
        edition = 'base',
        tilt = 1,
        card_size = 1,
        gamespeed = 0
    }
    
    self.FONTS = {
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

    self.TILESIZE = 20
    self.TILESCALE = 3.65
    self.TILE_W = 20
    self.TILE_H = 11.5
    self.DRAW_HASH_BUFF = 2
    self.COLLISION_BUFFER = 0.05


    self.STATES = {
        MENU = 1,
        TUTORIAL = 2,
        SPLASH = 3,
        SANDBOX = 4,
    }
    self.STAGES = {
        MAIN_MENU = 1,
        RUN = 2,
        SANDBOX = 3
    }
    self.STAGE_OBJECTS = {
        {},{},{}
    }
    self.STAGE = G.STAGES.MAIN_MENU
    self.STATE = G.STATES.SPLASH
    self.STATE_COMPLETE = false
    
    self.ASSET_ATLAS = {}
    self.MOVEABLES = {}
    self.DRAW_HASH = {}

    self.I = {
        NODE = {},
        MOVEABLE = {},
        SPRITE = {},
        UIBOX = {},
        POPUP = {},
        ALERT = {}
    }
    self.FRAMES = {
        DRAW = 0,
        MOVE = 0
    }

    self.exp_times = {xy = 0, scale = 0, r = 0}

end

G = Game()