local fonts = {}

--[[
    This is actually just marker felt regular. I am too lazy to change the name and each usage.
]]--
function fonts.getMarkerFeltBold()
    local font = ""

    if system.getInfo( "platformName" ) == "Android" then
        -- Android
        font = "Marker Felt"
    else
        -- iOS, Mac
        font = "MarkerFelt"
    end

    return font
end

function fonts.getSystemFont()
    return native.systemFont
end

function fonts.getSystemFontBold()
    return native.systemFontBold
end

--[[
    Searches for a font and prints out the results.
]]--
function fonts.searchFonts(searchString)
    local systemFonts = native.getFontNames()

    -- Display each font in the Terminal/console
    for i, fontName in ipairs( systemFonts ) do

        local j, k = string.find( string.lower(fontName), string.lower(searchString) )

        if ( j ~= nil ) then
            print( "Font Name = " .. tostring( fontName ) )
        end
    end
end

return fonts