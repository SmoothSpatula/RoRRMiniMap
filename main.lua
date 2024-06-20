-- Minimap v1.0.9
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        toggle_map_key = 77,
        toggle_interactables = false,
        toggle_teleporter = false,
        toggle_player_names = true,
        zoom_scale = 0.8,
        background_alpha = 0,
        foreground_alpha = 0.8,
        minimap_enabled = true,
        toggle_center_on_player = false,
        toggle_hide_yourself = false,
        x_offset = 0,
        y_offset = 0
        
    }

    params = Toml.config_update(_ENV["!guid"], params)
end)

-- ======== Parameters ========

local surf_map = -1
local surf_player = -1
local toggle_show_map = false
local redraw = false
local chat_open = false
local multiplayer_colours = {255, 16711680, 65535, 65280}

-- ========== ImGui ==========

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Minimap", params['minimap_enabled'])
    if clicked then
        params['minimap_enabled'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputFloat("Zoom scale of the map", params['zoom_scale'], 0.02, 0.05, "%.2f", 0)
    if isChanged and new_value >= -0.001 then -- due to floating point precision error, checking against 0 does not work
        params['zoom_scale'] = math.abs(new_value) -- same as above, so it display -0.0
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.DragInt("X position from the  left part of the screen", params['x_offset'], 1, -2000, gm.display_get_gui_width())
    if clicked then
        params['x_offset'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.DragInt("Y position from the  left part of the screen", params['y_offset'], 1, -2000, gm.display_get_gui_height())
    if clicked then
        params['y_offset'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputFloat("Background alpha", params['background_alpha'], 0.01, 0.05, "%.2f", 0)
    if isChanged and new_value >= -0.01 and new_value <= 1 then -- due to floating point precision error, checking against 0 does not work
        params['background_alpha'] = math.abs(new_value) -- same as above, so it display -0.0
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputFloat("Foreground alpha", params['foreground_alpha'], 0.01, 0.05, "%.2f", 0)
    if isChanged and new_value >= -0.01 and new_value <= 1 then -- due to floating point precision error, checking against 0 does not work
        params['foreground_alpha'] = math.abs(new_value) -- same as above, so it display -0.0
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local isChanged, keybind_value = ImGui.Hotkey("Toggle Map Key", params['toggle_map_key'])
    if isChanged then
        params['toggle_map_key'] = keybind_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Show Interactables", params['toggle_interactables'])
    if clicked then
        params['toggle_interactables'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Show Teleporter", params['toggle_teleporter'])
    if clicked then
        params['toggle_teleporter'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Show Player Names", params['toggle_player_names'])
    if clicked then
        params['toggle_player_names'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Center on player", params['toggle_center_on_player'])
    if clicked then
        params['toggle_center_on_player'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_to_menu_bar(function()
local new_value, clicked = ImGui.Checkbox("Hide yourself", params['toggle_hide_yourself'])
    if clicked then
        params['toggle_hide_yourself'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
        redraw = true
    end
end)

gui.add_always_draw_imgui(function()
    if ImGui.IsKeyPressed(params['toggle_map_key']) and not chat_open then
        toggle_show_map = not toggle_show_map
    end
end)

-- ========== Utils ==========

local function draw_map(cam, xscale, yscale, xoffset, yoffset)
    surf_map = gm.surface_create(gm.camera_get_view_width(cam), gm.camera_get_view_height(cam))
    gm.surface_set_target(surf_map)
    gm.draw_clear_alpha(0, 0)
    
    --gm.draw_text(gm.camera_get_view_width(cam)/2, 10, "MINIMAP") 

    local x, y, width, height = nil
    -- Display the floors and walls
    local oB = Helper.find_active_instance_all(gm.constants.oB)
    if oB then 
        for _, inst in ipairs(oB) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end
    
    local oBNoSpawn = Helper.find_active_instance_all(gm.constants.oBNoSpawn)
    if oBNoSpawn then 
        for _, inst in ipairs(oBNoSpawn) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end

    local oBFloorNoSpawn = Helper.find_active_instance_all(gm.constants.oBFloorNoSpawn)
    if oBFloorNoSpawn then 
        for _, inst in ipairs(oBFloorNoSpawn) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y,x+width, y+height, false)
        end
    end
    
    local oBNoSpawn2 = Helper.find_active_instance_all(gm.constants.oBNoSpawn2)
    if oBNoSpawn2 then 
        for _, inst in ipairs(oBNoSpawn2) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end
    
    local oBNoSpawnHalf = Helper.find_active_instance_all(gm.constants.oBNoSpawnHalf)
    if oBNoSpawnHalf then 
        for _, inst in ipairs(oBNoSpawnHalf) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end
    
    local oBFloorNoSpawn2 = Helper.find_active_instance_all(gm.constants.oBFloorNoSpawn2)
    if oBFloorNoSpawn2 then 
        for _, inst in ipairs(oBFloorNoSpawn2) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end
    
    local oBInteractableSpawn = Helper.find_active_instance_all(gm.constants.oBInteractableSpawn)
    if oBInteractableSpawn then 
        for _, inst in ipairs(oBInteractableSpawn) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            width = inst.width_box * xscale * 32
            height = inst.height_box * yscale * 32

            gm.draw_rectangle(x, y, x+width, y+height, false)
        end
    end
    
    -- Display the ropes
    local oRope = Helper.find_active_instance_all(gm.constants.oRope)
    if oRope then 
        for _, inst in ipairs(oRope) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            local rope_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 2
            height = inst.height_box * yscale * 32

            gm.draw_rectangle_colour(x-rope_xscale, y, x+rope_xscale, y+height, 4235519, 4235519, 4235519, 4235519, false)
        end
    end
    
    -- Display the geysers
    local oGeyser = Helper.find_active_instance_all(gm.constants.oGeyser)
    if oGeyser then 
        for _, inst in ipairs(oGeyser) do
            x = xoffset + inst.x * xscale
            y = yoffset + inst.y * yscale
            local geyser_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 4
            local geyser_yscale = gm.sprite_get_height(inst.sprite_index) * yscale

            gm.draw_rectangle_colour(x-geyser_xscale, y-geyser_yscale, x+geyser_xscale, y, 16776960, 16776960, 16776960, 16776960, false)
        end
    end
    
    -- Display all interactables
    local pInteractable = Helper.find_active_instance_all(gm.constants.pInteractable)
    if pInteractable and params['toggle_interactables'] then 
        for _, inst in ipairs(pInteractable) do




            if not (inst.active == 2.0 or inst.object_name == "oTeleporter") 
                and not (inst.object_name == "oChest4" and inst.active == 3.0) 
                and not (inst.object_name == "oShop1" or inst.object_name == "oShop2" and (inst.spawn[1].active == 2.0 or inst.spawn[2].active == 2.0))  then
                x = xoffset + inst.x * xscale
                y = yoffset + inst.y * yscale
                local interactable_xscale = gm.sprite_get_width(inst.sprite_index) * xscale / 4
                local interactable_yscale = gm.sprite_get_height(inst.sprite_index) * yscale / 2
                gm.draw_rectangle_colour(x-interactable_xscale, y-interactable_yscale, x+interactable_xscale, y, 65535, 65535, 65535, 65535, false)
            end
        end
    end

    -- Display the teleporter
    local tp = Helper.get_teleporter()
    if tp and params['toggle_teleporter'] then 
        x = xoffset + tp.x * xscale
        y = yoffset + tp.y * yscale
        local tp_xscale = gm.sprite_get_width(tp.sprite_index) * xscale / 2
        local tp_yscale = gm.sprite_get_height(tp.sprite_index) * yscale * 2

        gm.draw_rectangle_colour(x-tp_xscale, y-tp_yscale, x+tp_xscale-1, y-1, 8388736, 8388736, 8388736, 8388736, false)
        gm.draw_text_colour(x-tp_xscale+5, y-tp_yscale-12, "TP", 16711935, 16711935, 16711935, 16711935, 1)
    end

    gm.surface_reset_target()
end

local player_x, player_y, player_xscale, player_yscale, player_colour, local_player, local_player_x, local_player_y = nil
local function draw_player(cam, players, xscale, yscale, xoffset, yoffset)
    surf_player = gm.surface_create(gm.camera_get_view_width(cam), gm.camera_get_view_height(cam))
    gm.surface_set_target(surf_player)
    gm.draw_clear_alpha(0, params['background_alpha']) --put this here because I can't draw it with the map

    -- Display the players
    for i, player in ipairs(players) do
        if not (params['toggle_hide_yourself'] and player.id == local_player.id) then
            player_x = xoffset + player.x * xscale
            player_y = yoffset + player.y * yscale
            player_xscale = gm.sprite_get_width(player.sprite_index) * xscale
            player_yscale = gm.sprite_get_height(player.sprite_index) * yscale * 2
            player_colour = multiplayer_colours[player.player_p_number]


            if params['toggle_player_names'] and player.user_name then
                gm.draw_text_colour(player_x-player_xscale+5, player_y-player_yscale-13, player.user_name, player_colour, player_colour, player_colour, player_colour, 1)
            end

            gm.draw_rectangle_colour(player_x-player_xscale, player_y-player_yscale, player_x+player_xscale, player_y, player_colour, player_colour, player_colour, player_colour, false)
        end
    end
    
    gm.surface_reset_target()
    gm.draw_surface(surf_player, gm.camera_get_view_x(cam) + params['x_offset'] - local_player_x, gm.camera_get_view_y(cam) + params['y_offset'] - local_player_y)
    gm.surface_free(surf_player) --do this or run out of memory
end

-- ========== Main ==========

-- Draw the map surface and the player surface every frame
-- Refresh the map surface when redraw is true
local cam, ratio, surf_width, surf_height, xscale, yscale, xoffset, yoffset, players = nil
gm.post_code_execute(function(self, other, code, result, flags)
    if not toggle_show_map or not params['minimap_enabled']then return end

    if code.name:match("oInit_Draw_7") then
        players = Helper.find_active_instance_all(gm.constants.oP)
        if not players then return end
        
        cam = gm.view_get_camera(0)
        ratio = gm._mod_room_get_current_width() / gm._mod_room_get_current_height()
        surf_width = params['zoom_scale'] * gm.camera_get_view_width(cam)
        surf_height = surf_width / ratio
        if ratio*gm.camera_get_view_height(cam) < gm.camera_get_view_width(cam) then
            surf_height = params['zoom_scale'] * gm.camera_get_view_height(cam)
            surf_width = surf_height * ratio
        end
        
        xscale = surf_width / gm._mod_room_get_current_width()
        yscale = surf_height / gm._mod_room_get_current_height()
        
        xoffset = (gm.camera_get_view_width(cam) - surf_width) / 2
        yoffset = (gm.camera_get_view_height(cam) - surf_height) / 2

        if gm.surface_exists(surf_map) == 0.0 or redraw then
            local_player = Helper.get_client_player()
            if gm.surface_exists(surf_map) ~= 0.0 then
                gm.surface_free(surf_map)
            end
            draw_map(cam, xscale, yscale, xoffset, yoffset) 
            redraw = false
        end

        if params['toggle_center_on_player'] then
            local_player_x = local_player.x * xscale - surf_width/2
            local_player_y = local_player.y * yscale - surf_height/2
        else 
            local_player_x = 0
            local_player_y = 0
        end


        gm.draw_set_alpha(1)
        draw_player(cam, players, xscale, yscale, xoffset, yoffset)
        gm.draw_set_alpha(params['foreground_alpha'])
        gm.draw_surface(surf_map, gm.camera_get_view_x(cam) + params['x_offset'] - local_player_x, gm.camera_get_view_y(cam) + params['y_offset'] - local_player_y)
    end
end)

gm.pre_code_execute(function(self, other, code, result, flags)
    if code.name:match("oInit") then
        chat_open = self.chat_talking
    end
end)

-- Redraw the map for each new stage
gm.post_script_hook(gm.constants.texture_flush_group, function()
    redraw = true
end)

-- Disable mod when run ends
gm.pre_script_hook(gm.constants.run_destroy, function()
    toggle_show_map = false
end)

-- Redraw the map when zoom scale changes, works with quickzoom mod
gm.post_script_hook(gm.constants.prefs_set_zoom_scale, function()
    redraw = true
end)



gm.post_script_hook(gm.constants.interactable_set_active, function(self, other, result, args)
    if params['toggle_interactables'] then
        redraw = true
    end
end)

gm.post_script_hook(gm.constants.interactable_sync, function(self, other, result, args)
    if params['toggle_interactables'] then
        redraw = true
    end
end)
