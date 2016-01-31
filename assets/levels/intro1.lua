local level = Game.Level
Pen = require("src/levels/pen")
DarkGrass = require("src/levels/dark_grass")
IntroA  = require("src/levels/intro/intro_a")
IntroB = require("src/levels/intro/intro_b")
IntroC = require("src/levels/intro/intro_c")
IntroD = require("src/levels/intro/intro_d")
IntroE = require("src/levels/intro/intro_e")
IntroF = require("src/levels/intro/intro_f")

return {
map = [[
|-------------|
|P           P|
|     abc     |
|     def     |
|P           P|
|-------------|
]],

constructors = {
        P = Pen(40, level), --Additionally takes number of pigeons to spawn, can override on level specifics
        [" "] = DarkGrass(level), 
        a = IntroA(level),
        b = IntroB(level),
        c = IntroC(level),
        d = IntroD(level),
        e = IntroE(level),
        f = IntroF(level),
    }
}
