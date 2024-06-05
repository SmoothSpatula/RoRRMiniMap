log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        toggle_map = "M",
        zoom_scale = 0.6,
        minimap_enabled = true
    }

    params = Toml.config_update(_ENV["!guid"], params)
end)

-- ========== ImGui ==========

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Minimap", params['minimap_enabled'])
    if clicked then
        params['minimap_enabled'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputFloat("Zoom scale of the map", params['zoom_scale'], 0.001, 0.05, "%.4f", 0)
    if isChanged and new_value >= -0.001 then -- due to floating point precision error, checking against 0 does not work
        params['zoom_scale'] = math.abs(new_value) -- same as above, so it display -0.0
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputText("Toggle Map Key", params['toggle_map'], 20)
    if isChanged then
        params['toggle_map'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

local toggle_show_map = false
gui.add_always_draw_imgui(function()
    if ImGui.IsKeyPressed(ImGuiKey[params['toggle_map']]) then
        toggle_show_map = not toggle_show_map
    end
end)

-- ========== Main ==========

gm.post_code_execute(function(self, other, code, result, flags)
    if not toggle_show_map or not params['minimap_enabled']then return end

    if code.name:match("oInit_Draw_7") then
        
        local player = Helper.get_client_player()
        
        if not player then return end
        
        local cam = gm.view_get_camera(0)
        local ratio = gm._mod_room_get_current_width() / gm._mod_room_get_current_height()
        local surf_width = params['zoom_scale'] * gm.camera_get_view_width(cam)
        local surf_height = surf_width / ratio

        print(gm._mod_room_get_current_height())
        if gm._mod_room_get_current_width() < gm._mod_room_get_current_height() then
            print("HELLO")
            surf_height = params['zoom_scale'] * gm.camera_get_view_height(cam)
            surf_width = surf_height * ratio
        end
        
        if gm.surface_exists(surf) == 0.0 then surf = gm.surface_create(gm.camera_get_view_width(cam), gm.camera_get_view_height(cam)) end
        gm.surface_set_target(surf)
        gm.draw_clear_alpha(0, 0.8)
        
        gm.draw_text(gm.camera_get_view_width(cam)/2, 10, "MINIMAP") 

        local xscale = surf_width / gm._mod_room_get_current_width()
        local yscale = surf_height / gm._mod_room_get_current_height()
        
        local xoffset = (gm.camera_get_view_width(cam) - surf_width) / 2
        local yoffset = (gm.camera_get_view_height(cam) - surf_height) / 2
        
        -- Display the floors and walls
        local oB = Helper.find_active_instance_all(gm.constants.oB)
        if oB then 
            for _, inst in ipairs(oB) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end
        
        local oBNoSpawn = Helper.find_active_instance_all(gm.constants.oBNoSpawn)
        if oBNoSpawn then 
            for _, inst in ipairs(oBNoSpawn) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end

        local oBFloorNoSpawn = Helper.find_active_instance_all(gm.constants.oBFloorNoSpawn)
        if oBFloorNoSpawn then 
            for _, inst in ipairs(oBFloorNoSpawn) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y,x+width, y+height, false)
            end
        end
        
        local oBNoSpawn2 = Helper.find_active_instance_all(gm.constants.oBNoSpawn2)
        if oBNoSpawn2 then 
            for _, inst in ipairs(oBNoSpawn2) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end
        
        local oBNoSpawnHalf = Helper.find_active_instance_all(gm.constants.oBNoSpawnHalf)
        if oBNoSpawnHalf then 
            for _, inst in ipairs(oBNoSpawnHalf) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end
        
        local oBFloorNoSpawn2 = Helper.find_active_instance_all(gm.constants.oBFloorNoSpawn2)
        if oBFloorNoSpawn2 then 
            for _, inst in ipairs(oBFloorNoSpawn2) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end
        
        local oBInteractableSpawn = Helper.find_active_instance_all(gm.constants.oBInteractableSpawn)
        if oBInteractableSpawn then 
            for _, inst in ipairs(oBInteractableSpawn) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local width = inst.width_box * xscale * 32
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle(x, y, x+width, y+height, false)
            end
        end
        
        -- Display the ropes
        local oRope = Helper.find_active_instance_all(gm.constants.oRope)
        if oRope then 
            for _, inst in ipairs(oRope) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local rope_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 2
                local height = inst.height_box * yscale * 32
                gm.draw_rectangle_colour(x-rope_xscale, y, x+rope_xscale, y+height, 4235519, 4235519, 4235519, 4235519, false)
            end
        end
        
        -- Display the geysers
        local oGeyser = Helper.find_active_instance_all(gm.constants.oGeyser)
        if oGeyser then 
            for _, inst in ipairs(oGeyser) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local geyser_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 4
                local geyser_yscale = gm.sprite_get_height(inst.sprite_index) * yscale
                gm.draw_rectangle_colour(x-geyser_xscale, y-geyser_yscale, x+geyser_xscale, y, 16776960, 16776960, 16776960, 16776960, false)
            end
        end
        
        -- Display all interactables
        local pInteractable = Helper.find_active_instance_all(gm.constants.pInteractable)
        if pInteractable then 
            for _, inst in ipairs(pInteractable) do
                local x = xoffset + inst.x * xscale
                local y = yoffset + inst.y * yscale
                local interactable_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 4
                local interactable_yscale = gm.sprite_get_height(inst.sprite_index) * yscale / 2

                gm.draw_rectangle_colour(x-interactable_xscale, y-interactable_yscale, x+interactable_xscale, y, 65535, 65535, 65535, 65535, false)
            end
        end
        
        -- Display the teleporter
        local tp = Helper.get_teleporter()
        if tp then 
                local x = xoffset + tp.x * xscale
                local y = yoffset + tp.y * yscale
                local tp_xscale = gm.sprite_get_width(tp.sprite_index) * xscale / 2
                local tp_yscale = gm.sprite_get_height(tp.sprite_index) * yscale * 2

                gm.draw_rectangle_colour(x-tp_xscale, y-tp_yscale, x+tp_xscale-1, y-1, 255, 255, 255, 255, false)
        end
        
        -- Display the player
        local player_x = xoffset + player.x * xscale
        local player_y = yoffset + player.y * yscale
        local player_xscale = gm.sprite_get_width(player.sprite_index) * xscale
        local player_yscale = gm.sprite_get_height(player.sprite_index) * yscale * 2

        gm.draw_rectangle_colour(player_x-player_xscale, player_y-player_yscale, player_x+player_xscale, player_y, 65280, 65280, 65280, 65280, false)


        gm.surface_reset_target()
        gm.draw_surface(surf, gm.camera_get_view_x(cam), gm.camera_get_view_y(cam))
    end
end)

-- Disable mod when run ends
gm.pre_script_hook(gm.constants.run_destroy, function(self, other, result, args)
    toggle_show_map = false
end)