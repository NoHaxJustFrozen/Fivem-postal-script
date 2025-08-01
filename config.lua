Config = {
    PostalFile = 'postal.json',
    Text = {
        Format = '~y~Yakındaki Parsel~w~: %s (~g~%.0fm~w~)', -- yazı biçimi
        PosX = 0.22,
        PosY = 0.963,
        Scale = 0.42,
        Font = 4,
        Colour = {255,255,255}, -- R,G,B
        Alpha = 255,            -- Opaklık (0-255)
        Outline = true          -- Kontur açık/kapalı
    },
    Blip = {
        Sprite = 8,
        Color = 3,
        DistToDelete = 100.0
    },
    Refresh = 1000 -- ms
}
