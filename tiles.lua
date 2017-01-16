--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:fdc4b8953ea89c1165970570feb5b3e4:1c0ecbe0be52494462efbe9de9ba3110:f4492607ea55a754477543692c89a688$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- platformer_00
            x=1,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_01
            x=37,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_02
            x=73,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_03
            x=109,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_04
            x=145,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_05
            x=181,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_06
            x=217,
            y=1,
            width=32,
            height=32,

        },
        {
            -- platformer_07
            x=1,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_08
            x=37,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_09
            x=73,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_10
            x=109,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_11
            x=145,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_12
            x=181,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_13
            x=217,
            y=37,
            width=32,
            height=32,

        },
        {
            -- platformer_14
            x=1,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_15
            x=37,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_16
            x=73,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_17
            x=109,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_18
            x=145,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_19
            x=181,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_20
            x=217,
            y=73,
            width=32,
            height=32,

        },
        {
            -- platformer_21
            x=1,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_22
            x=37,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_23
            x=73,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_24
            x=109,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_25
            x=145,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_26
            x=181,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_27
            x=217,
            y=109,
            width=32,
            height=32,

        },
        {
            -- platformer_28
            x=1,
            y=145,
            width=32,
            height=32,

        },
        {
            -- platformer_29
            x=37,
            y=145,
            width=32,
            height=32,

        },
        {
            -- platformer_30
            x=73,
            y=145,
            width=32,
            height=32,

        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["platformer_00"] = 1,
    ["platformer_01"] = 2,
    ["platformer_02"] = 3,
    ["platformer_03"] = 4,
    ["platformer_04"] = 5,
    ["platformer_05"] = 6,
    ["platformer_06"] = 7,
    ["platformer_07"] = 8,
    ["platformer_08"] = 9,
    ["platformer_09"] = 10,
    ["platformer_10"] = 11,
    ["platformer_11"] = 12,
    ["platformer_12"] = 13,
    ["platformer_13"] = 14,
    ["platformer_14"] = 15,
    ["platformer_15"] = 16,
    ["platformer_16"] = 17,
    ["platformer_17"] = 18,
    ["platformer_18"] = 19,
    ["platformer_19"] = 20,
    ["platformer_20"] = 21,
    ["platformer_21"] = 22,
    ["platformer_22"] = 23,
    ["platformer_23"] = 24,
    ["platformer_24"] = 25,
    ["platformer_25"] = 26,
    ["platformer_26"] = 27,
    ["platformer_27"] = 28,
    ["platformer_28"] = 29,
    ["platformer_29"] = 30,
    ["platformer_30"] = 31,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
