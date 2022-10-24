-- TODO: in singleplayer make it reload dynamicly, so if player changed atts it will be drawn there

OLDKilliconDraw = OLDKilliconDraw or killicon.Draw
local killicons_cachednames = {}
local killicons_cachedicons = {}
local killiconmat = Material("arc9/arc9_sus.png", "mips smooth")

NEWKillicondraw = function(x, y, name, alpha)
    if killicons_cachednames[name] == true then
        local w, h = 96, 96
        x = x - 48
        y = y - 34

        cam.Start2D()

        local selecticon = killicons_cachedicons[name]

        if !selecticon then -- not cached
            local filename = ARC9.PresetPath .. name .. "_icon." .. ARC9.PresetIconFormat
            local loadedmat = Material("data/" .. filename, "smooth")

            if loadedmat:IsError() then -- there is no fucking icon in data folder!!!!
                local found

                if game.SinglePlayer() then -- trying find in your hands
                    local probablythegun = LocalPlayer():GetActiveWeapon()

                    if IsValid(probablythegun) and probablythegun:GetClass() == name then
                        loadedmat = probablythegun:DoIconCapture()
                        found = true
                    end
                end

                if !found then -- nah, bruteforcing all ents until we find gun with same classname
                    for _, v in ipairs(ents.GetAll()) do
                        if v:GetClass() == name then
                            loadedmat = v:DoIconCapture()
                        end
                    end
                end
            end

            killicons_cachedicons[name] = loadedmat
            selecticon = loadedmat
        end

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(selecticon or killiconmat)
        surface.DrawTexturedRectUV( x, y, w, h, 1, 0, 0, 1 ) -- fliping
        cam.End2D()
    else
        if killicons_cachednames[name] == nil then -- not cached yet, checking for arc9
            killicons_cachednames[name] = (weapons.Get(name) and weapons.Get(name).ARC9) or false -- weapons.get() will return nil for any hl2 base gun
        else -- we know it is totally not arc9 gun
            return OLDKilliconDraw(x, y, name, alpha)
        end
    end
end

timer.Simple(5, function() -- to make Autoicons addon not override our stuff
    killicon.Draw = NEWKillicondraw
end)