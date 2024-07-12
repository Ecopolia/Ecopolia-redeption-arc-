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

return G