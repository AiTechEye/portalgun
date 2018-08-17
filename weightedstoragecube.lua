
local ptgwsc={
{"weightedstoragecube.png","portalgun_presplat.png","(blue)"},
{"weightedstoragecube2.png","portalgun_presplat2.png","(orange)"},
{"weightedstoragecube3.png","portalgun_presplat3.png","(yellow)"},
{"weightedstoragecube4.png","portalgun_presplat4.png","(green)"},
}


for ii = 1, #ptgwsc, 1 do


minetest.register_craftitem("portalgun:wscube" ..ii, {
	description = "Weighted storage cube " .. ptgwsc[ii][3],
	inventory_image = minetest.inventorycube(ptgwsc[ii][1]),
on_place=function(itemstack, user, pointed_thing)
	if pointed_thing.type=="node" then
		portalgun.new=1
		local m=minetest.add_entity(pointed_thing.above, "portalgun:wsc"..ii)
		m:set_acceleration({x=0,y=-10,z=0})
		itemstack:take_item()
	end
	return itemstack
end,
})

minetest.register_node("portalgun:wscspawner2_" .. ii, {
	description = "Weighted storage cube spawner2 " ..ptgwsc[ii][3],
	tiles = {"default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png",ptgwsc[ii][1]},
	groups = {cracky=2,mesecon_receptor_off = 1, mesecon_effector_off = 1},
	mesecons = {receptor = {state = "off"}},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	mesecons = {effector = {
		action_on = function (pos, node)
			local dir=minetest.get_node(pos).param2
			local v={x=0, y=0, z=0}
			if dir==0 then v.z=-1
			elseif dir==1 then v.x=-1.2
			elseif dir==2 then v.z=1.2
			elseif dir==3 then v.x=1.2
			elseif dir==8 then v.y=-1.2
			elseif dir==4 then v.y=1.2
			end
			local pv={x=pos.x+v.x, y=pos.y+v.y, z=pos.z+v.z}
			portalgun.new=1
			local m=minetest.add_entity(pv, "portalgun:wsc" ..ii)
			m:set_acceleration({x=0, y=-10, z=0})
		end
	}}
})

minetest.register_entity("portalgun:wsc" ..ii,{
	hp_max = 100,
	physical = true,
	weight = 5,
	collisionbox = {-0.6,-0.6,-0.6, 0.6,0.6,0.6},
	visual = "cube",
	visual_size = {x=1.1, y=1.1},
	textures = {ptgwsc[ii][1],ptgwsc[ii][1],ptgwsc[ii][1],ptgwsc[ii][1],ptgwsc[ii][1],ptgwsc[ii][1]},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
	automatic_rotate = false,
	portalgun=2,
	wsc=ii,
on_activate= function(self, staticdata)
	if portalgun.new==0 then
		self.object:remove()
		return self
	end
	portalgun.new=0
end,
on_step= function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<1 then return self end
		self.timer=0
		self.object:set_acceleration({x=0, y=-10, z=0})
		self.timer2=self.timer2+1
		if self.timer2>10 then
			self.timer2=0
			for i, ob in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 20)) do
				if ob:is_player() then
					return true
				end
			end
			self.object:set_hp(0)
			self.object:punch(self.object, 1, "default:bronze_pick", nil)
		end
	end,
	timer=0,
	timer2=0,
})

minetest.register_node("portalgun:wscspawner"..ii, {
	description = "Weighted storage cube spawner " ..ptgwsc[ii][3],
	tiles = {ptgwsc[ii][1]},
	groups = {cracky = 1, not_in_creative_inventory=0},
	paramtype = "light",
	paramtype2="facedir",
	sunlight_propagates = true,
	light_source = default.LIGHT_MAX - 1,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.7, -0.5, -0.7, 0.7, -0.375, 0.7},
			{0.7, -0.5, -0.1875, 0.9, -0.4375, 0.1875},
			{-0.9, -0.5, -0.1875, -0.7, -0.4375, 0.1875},
			{-0.1875, -0.5, -0.9, 0.1875, -0.4375, -0.7},
			{-0.1875, -0.5, 0.7, 0.1875, -0.4375, 0.9},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 40)) do
				if ob:get_luaentity() and ob:get_luaentity().wsc==ii then
					return true
				end
		end
		portalgun.new=1
		local m=minetest.add_entity(pos, "portalgun:wsc" ..ii)
		m:set_acceleration({x=0,y=-10,z=0})
		return true
	end,
})

minetest.register_node("portalgun:plantform1_" ..ii, {
	description = "Pressure platform " .. ptgwsc[ii][3],
	tiles = {ptgwsc[ii][2],"default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png"},
	groups = {mesecon = 2,cracky = 1, not_in_creative_inventory=0},
	mesecons = {receptor = {state = "off"}},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.7, -0.5, -0.7, 0.7, -0.375, 0.7},
			{0.7, -0.5, -0.1875, 0.9, -0.4375, 0.1875},
			{-0.9, -0.5, -0.1875, -0.7, -0.4375, 0.1875},
			{-0.1875, -0.5, -0.9, 0.1875, -0.4375, -0.7},
			{-0.1875, -0.5, 0.7, 0.1875, -0.4375, 0.9},
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		if not mesecon then return false end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if ob:get_luaentity() and ob:get_luaentity().wsc==ii then
				local node=minetest.get_node(pos)
				mesecon.receptor_on(pos)
				minetest.set_node(pos, {name ="portalgun:plantform2_"..ii, param1 = node.param1, param2 = node.param2})
			end
			return true
		end
		return true
	end,
})

minetest.register_node("portalgun:plantform2_"..ii, {
	description = "Pressure platform",
	tiles = {ptgwsc[ii][2],"default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png"},
	drop="portalgun:plantform1_"..ii,
	groups = {mesecon = 2,cracky = 1, not_in_creative_inventory=1},
	mesecons = {receptor = {state = "on"}},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = default.LIGHT_MAX - 1,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.7, -0.5, -0.7, 0.7, -0.375, 0.7},
			{0.7, -0.5, -0.1875, 0.9, -0.4375, 0.1875},
			{-0.9, -0.5, -0.1875, -0.7, -0.4375, 0.1875},
			{-0.1875, -0.5, -0.9, 0.1875, -0.4375, -0.7},
			{-0.1875, -0.5, 0.7, 0.1875, -0.4375, 0.9},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if ob:get_luaentity() and ob:get_luaentity().wsc==ii then
				return true
			end
		end
			mesecon.receptor_off(pos)
			local node=minetest.get_node(pos)
			minetest.set_node(pos, {name ="portalgun:plantform1_"..ii, param1 = node.param1, param2 = node.param2})
		return true
	end,
})


end --  of for #


minetest.register_node("portalgun:plantform_nu1", {
	description = "Pressure platform (player or cube)",
	tiles = {"portalgun_presplat5.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png"},
	groups = {mesecon = 2,cracky = 1, not_in_creative_inventory=0},
	mesecons = {receptor = {state = "off"}},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.7, -0.5, -0.7, 0.7, -0.375, 0.7},
			{0.7, -0.5, -0.1875, 0.9, -0.4375, 0.1875},
			{-0.9, -0.5, -0.1875, -0.7, -0.4375, 0.1875},
			{-0.1875, -0.5, -0.9, 0.1875, -0.4375, -0.7},
			{-0.1875, -0.5, 0.7, 0.1875, -0.4375, 0.9},
			{-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		if not mesecon then return false end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if ob:is_player() or (ob:get_luaentity() and ob:get_luaentity().wsc) then
				local node=minetest.get_node(pos)
				mesecon.receptor_on(pos)
				minetest.set_node(pos, {name ="portalgun:plantform_nu2", param1 = node.param1, param2 = node.param2})
			end
			return true
		end
		return true
	end,
})

minetest.register_node("portalgun:plantform_nu2", {
	description = "Pressure platform",
	tiles = {"portalgun_presplat5.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png"},
	drop="portalgun:plantform_nu1",
	groups = {mesecon = 2,cracky = 1, not_in_creative_inventory=1},
	mesecons = {receptor = {state = "on"}},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = default.LIGHT_MAX - 1,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.7, -0.5, -0.7, 0.7, -0.375, 0.7},
			{0.7, -0.5, -0.1875, 0.9, -0.4375, 0.1875},
			{-0.9, -0.5, -0.1875, -0.7, -0.4375, 0.1875},
			{-0.1875, -0.5, -0.9, 0.1875, -0.4375, -0.7},
			{-0.1875, -0.5, 0.7, 0.1875, -0.4375, 0.9},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if ob:is_player() or (ob:get_luaentity() and ob:get_luaentity().wsc) then
				return true
			end
		end
			mesecon.receptor_off(pos)
			local node=minetest.get_node(pos)
			minetest.set_node(pos, {name ="portalgun:plantform_nu1", param1 = node.param1, param2 = node.param2})
		return true
	end,
})


minetest.register_node("portalgun:planthole", {
	description = "Plathole (activate by any cube, 2 blocks under)",
	tiles = {"default_cloud.png"},
	groups = {mesecon = 2,cracky = 1},
	mesecons = {receptor = {state = "off"}},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 0.5, -0.25, -1.3},
			{-1.5, -0.5, 0.3, 0.5, -0.25, 0.5}, 
			{0.3, -0.5, -1.5, 0.5, -0.25, 0.5},
			{-1.5, -0.5, -1.5, -1.3, -0.25, 0.5},
			{0.5, -0.5, -0.9, 0.7, -0.375, -0.0625},
			{-1.7, -0.5, -0.9, -1.5, -0.3125, -0.0625},
			{-0.9, -0.5, -1.7, -0.0625, -0.375, -1.5},
			{-1, -0.5, 0.5, -0.0625, -0.375, 0.7},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer = function (pos, elapsed)
		local pos2={x=pos.x,y=pos.y-2,z=pos.z}
		for i, ob in pairs(minetest.get_objects_inside_radius(pos2, 1)) do
			if ob:get_luaentity() and ob:get_luaentity().wsc then
				mesecon.receptor_on(pos)
				return true
			end
		end
		mesecon.receptor_off(pos)
		return true
	end,
})



minetest.register_node("portalgun:objdestroyer_1", {
	description = "Object destroyer (destroys on active)",
	tiles = {"portalgun_testblock.png^[colorize:#FF0000aa"},
	groups = {cracky = 2,mesecon=1},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			minetest.set_node(pos, {name ="portalgun:objdestroyer_2"})
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
				if ob:get_luaentity() then
					ob:set_hp(0)
					ob:punch(ob, {full_punch_interval=1.0,damage_groups={fleshy=9000}}, "default:bronze_pick", nil)
				end
			end
		end
	}}
})
minetest.register_node("portalgun:objdestroyer_2", {
	description = "Obj destroyer",
	tiles = {"portalgun_testblock.png^[colorize:#FF0000cc"},
	groups = {cracky=2,mesecon=1,not_in_creative_inventory=1},
	sunlight_propagates = true,
	drop="portalgun:objdestroyer_1",
	paramtype="light",
	light_source = default.LIGHT_MAX - 1,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "portalgun:objdestroyer_1",
	}},
})
