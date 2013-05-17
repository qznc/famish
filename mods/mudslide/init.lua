YearPerMudslide = minetest.setting_get("mudtime")
MudslidePanic = false


timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 60 and MudslidePanic == true then
		minetest.chat_send_all("This server is on mudslide panic mode. After everything is controlled, please do /mudslide_panic to end the panic mode.")
	timer = 0
	end
end)


minetest.register_chatcommand("mudslide_panic", {
	params = "",
	description = "Set MudslidePanic to true if false",
	privs = {mudcontroal=true},
	func = function(name, param)
	if MudslidePanic == false then
	MudslidePanic = true
	minetest.chat_send_all("This server is on mudslide panic mode. After everything is controlled, please do /mudslide_panic to end the panic mode.")
	elseif MudslidePanic == true then
	MudsliedPanic = false
	minetest.chat_send_all("Mudslide Panic mode is turnd off.")
	end
end,
})


if minetest.setting_get("mudtime") == nil then
	YearPerMudslide = 100000
end


minetest.register_on_shutdown(function()
	minetest.setting_set("mudtime", YearPerMudslide)
end)

minetest.register_privilege("mudcontroal", {
	description = "Player can controal how frequent mudslide occurs.",
	give_to_singleplayer= false,
})

minetest.register_chatcommand("get_mudtime", {
	params = "",
	description = "Get how long dirt will not turn in to mud.",
	privs = {mudcontroal=true},
	func = function(name, param)
	if minetest.setting_get("mudtime") == nil then
	minetest.setting_set("mudtime", "100000")
	end
	YearPerMudslide = minetest.setting_get("mudtime")
	minetest.chat_send_player(name,"("..YearPerMudslide.."years)")
	end,
})

minetest.register_chatcommand("set_mudtime", {
	params = "<year>",
	description = "Set how long dirt will not turn in to mud as <year>.",
	privs = {mudcontroal=true},
	func = function(name, param)
	if param == "" then
	param = 100000
	end
	YearPerMudslide = param
	minetest.setting_set("mudtime", YearPerMudslide)
	minetest.chat_send_player(name,"Set to ("..YearPerMudslide.."years)")
	end,
})



minetest.register_node("mudslide:mud_source", {
	description = "Mud Source",
	inventory_image = minetest.inventorycube("mud_mud.png"),
		tiles = {
			{name="mud_sliding.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}
		},
		special_tiles = {
		{name="mud_mud.png", backface_culling=false},
	},
	drawtype = "liquid",
	alpha = 250,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquidtype = "source",
	liquid_alternative_flowing = "mudslide:mud_flowing",
	liquid_alternative_source = "mudslide:mud_source",
	liquid_viscosity = 7,
	liquid_renewable = true,
	post_effect_color = {a=250, r=139, g=69, b=19},
	groups = {liquid=3, puts_out_fire=1},
})



minetest.register_node("mudslide:mud_flowing", {
	description = "Flowing Mud",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "flowingliquid",
	tiles = {"mud_mud.png"},
	special_tiles = {
		{
			image="mud_sliding.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
		{
			image="mud_sliding.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
	},
	alpha = 250,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquidtype = "flowing",
	liquid_alternative_flowing = "mudslide:mud_flowing",
	liquid_alternative_source = "mudslide:mud_source",
	liquid_viscosity = 7,
	liquid_renewable = true,
	post_effect_color = {a=250, r=139, g=69, b=19},
	groups = {liquid=3, puts_out_fire=1},
})


minetest.register_node("mudslide:drying", {
	description = "Drying Mud",
	tiles = {"mud_mud.png"},
	is_ground_content = true,
	groups = {crumbly=3},
})



minetest.register_abm({
	nodenames = {"default:dirt","default:dirt_with_grass"},
	neighbors = {"mudslide:mud_flowing", "mudslide:mud_source"},
	interval = 15,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if minetest.setting_get("mudtime") == nil then
	minetest.setting_set("mudtime", "100000")
	end
 	local maxp = {x = pos.x, y = pos.y + 5, z = pos.z}
	local ppos = {x = pos.x, y = pos.y + 1, z = pos.z}
	if minetest.env:find_node_near(maxp, 4, "default:tree") == nil and minetest.env:find_node_near(maxp, 5, {"mudslide:mud_source", "mudslide:mud_flowing"}) ~= nil  then
		minetest.env:set_node(pos, {name = "mudslide:mud_source"})
	end
end,
})


minetest.register_abm({
	nodenames = {"mudslide:mud_flowing", "mudslide:mud_source"},
	interval = 120,
	chance = 10,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:set_node(pos, {name = "mudslide:drying"})
	end,
})

minetest.register_abm({
	nodenames = {"default:dirt_with_grass"},
	interval = 7200,
	chance = 4380*YearPerMudslide,
	action = function(pos, node, active_object_count, active_object_count_wider)
	local maxp = {x = pos.x, y = pos.y + 5, z = pos.z}
	local ppos = {x = pos.x, y = pos.y + 1, z = pos.z}
	if minetest.env:find_node_near(maxp, 4, "default:dirt_with_grass") == nil and minetest.env:find_node_near(maxp, 4, "default:tree") == nil then
	minetest.env:set_node(ppos, {name = "mudslide:mud_source"})
	end
end,
})

minetest.register_abm({
	nodenames = {"mudslide:drying"},
	interval = 300,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if minetest.env:find_node_near(pos, 2, "mudslide:mud_flowing") == nil and minetest.env:find_node_near(pos, 2, "mudslide:mud_source") == nil then
	minetest.env:set_node(pos, {name = "default:dirt"})
	end
end,
})

minetest.register_abm({
	nodenames = {"mudslide:mud_flowing", "mudslide:mud_source"},
	neighbors = {"mudslide:drying", "default:tree"},
	interval = 10,
	chance = 6,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:set_node(pos, {name = "mudslide:drying"})
	end,
})


minetest.register_node("mudslide:sand_source", {
	description = "Sand Source",
	inventory_image = minetest.inventorycube("mud_sand.png"),
		tiles = {
			{name="mud_slidingsand.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}
		},
		special_tiles = {
		{name="mud_mud.png", backface_culling=false},
	},
	drawtype = "liquid",
	alpha = 250,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquidtype = "source",
	liquid_alternative_flowing = "mudslide:sand_flowing",
	liquid_alternative_source = "mudslide:sand_source",
	liquid_viscosity = 2,
	liquid_renewable = true,
	post_effect_color = {a=250, r=139, g=69, b=19},
	groups = {liquid=3, puts_out_fire=1},
})



minetest.register_node("mudslide:sand_flowing", {
	description = "Flowing Sand",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "flowingliquid",
	tiles = {"mud_mud.png"},
	special_tiles = {
		{
			image="mud_slidingsand.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
		{
			image="mud_slidingsand.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.8}
		},
	},
	alpha = 250,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	liquidtype = "flowing",
	liquid_alternative_flowing = "mudslide:sand_flowing",
	liquid_alternative_source = "mudslide:sand_source",
	liquid_viscosity = 2,
	liquid_renewable = true,
	post_effect_color = {a=250, r=139, g=69, b=19},
	groups = {liquid=3, puts_out_fire=1},
})


minetest.register_abm({
	nodenames = {"group:sand"},
	interval = 600,
	chance = 2000*YearPerMudslide,
	action = function(pos, node, active_object_count, active_object_count_wider)
	local maxp = {x = pos.x, y = pos.y + 5, z = pos.z}
	local ppos = {x = pos.x, y = pos.y + 1, z = pos.z} 
	minetest.env:set_node(ppos, {name = "mudslide:sand_source"})
end,
})

minetest.register_abm({
	nodenames = {"mudslide:sand_flowing", "mudslide:sand_source"},
	interval = 120,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:set_node(pos, {name = "default:sand"})
	end,
})

minetest.register_abm({
	nodenames = {"mudslide:sand_flowing", "mudslide:sand_source"},
	neighbors = {"default:desert_sand"},
	interval = 60,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:set_node(pos, {name = "default:desert_sand"})
	end,
})


minetest.register_abm({
	nodenames = {"mudslide:drying", "mudslide:mud_flowing", "mudslide:mud_source"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if MudslidePanic == true then
	minetest.env:set_node(pos, {name = "default:dirt"})
	end
end,
})

minetest.register_abm({
	nodenames = {"mudslide:sand_flowing", "mudslide:sand_source"},
	neighbors = {"default:desert_sand"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if MudslidePanic == true then
	minetest.env:set_node(pos, {name = "default:desert_sand"})
	end
end,
})


minetest.register_abm({
	nodenames = {"mudslide:sand_flowing", "mudslide:sand_source"},
	neighbors = {"default:sand"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if MudslidePanic == true then
	minetest.env:set_node(pos, {name = "default:sand"})
	end
end,
})

minetest.register_abm({
	nodenames = {"mudslide:sand_flowing", "mudslide:sand_source"},
	interval = 3,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
	if MudslidePanic == true then
	minetest.env:set_node(pos, {name = "default:sand"})
	end
end,
})
