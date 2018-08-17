local snuma=1
for ii = 0, 9, 1 do
if ii==1 then snuma=0 end
minetest.register_node("portalgun:sign_numa".. ii, {
	description = "Sign number (" .. ii ..")",
	tiles = {"portalgun_snum" .. ii ..".png"},
	drop="portalgun:sign_numa1",
	drawtype = "nodebox",
	groups = {mesecon=2,portalnuma=1,dig_immediate = 3, not_in_creative_inventory=snuma},
	sounds = default.node_sound_wood_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = 3,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.4375, 0, 0.5, 0.5},
		}
	},
after_place_node = function(pos, placer, itemstack)
		local param2=minetest.get_node(pos).param2
		local pos2=portalgun_param2(pos,param2)
		if minetest.get_node(pos2) and minetest.get_node(pos2).name=="air" then
			minetest.set_node(pos2,{name="portalgun:sign_numb1",param2=param2})
			minetest.swap_node(pos, {name="portalgun:sign_numa0", param2=minetest.get_node(pos).param2})
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_protected(pos,clicker:get_player_name()) then
		local iin=ii+1
			if iin==10 then iin=0 end
			minetest.swap_node(pos, {name="portalgun:sign_numa".. iin, param2=minetest.get_node(pos).param2})
		end
	end,
	on_punch = function(pos, node, player, pointed_thing)
		local param2=minetest.get_node(pos).param2
		local pos2=portalgun_param2(pos,param2)
		local node=minetest.get_node(pos2)
		if node and minetest.get_node_group(node.name, "portalnumb")>0 then
			minetest.set_node(pos2, {name = "air"})
		end
	end,


})
if snuma==0 then snuma=1 end
minetest.register_node("portalgun:sign_numb".. ii, {
	description = "Sign number",
	tiles = {"portalgun_snum" .. ii ..".png"},
	drop="portalgun:sign_numa1",
	drawtype = "nodebox",
	groups = {mesecon=2,portalnumb=1,dig_immediate = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = 3,
	node_box = {
		type = "fixed",
		fixed = {
			{-1, -0.5, 0.4375, -0.5, 0.5, 0.5},
		}
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_protected(pos,clicker:get_player_name()) then
		local iin=ii+1
			if iin==10 then iin=0 end
			minetest.swap_node(pos, {name="portalgun:sign_numb".. iin, param2=minetest.get_node(pos).param2})
		end
	end,
	on_punch = function(pos, node, player, pointed_thing)
		local param2=minetest.get_node(pos).param2
		local pos2=portalgun_param2(pos,param2,true)
		local node=minetest.get_node(pos2)
		if node and minetest.get_node_group(node.name, "portalnuma")>0 then
			minetest.set_node(pos2, {name = "air"})
		end
	end,
})
end

minetest.register_node("portalgun:turretgun2", {
	description = "Sentry turret",
	groups = {cracky=3,not_in_creative_inventory=1},
	drop="portalgun:turretgun",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_defaults(),
	tiles = {"portalgun_sentry_turret.png"},
	drawtype = "mesh",
	mesh="torret2.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 1,0.3},
		}
	},
	on_timer=function(pos, elapsed)
		local p=minetest.get_node(pos).param2
		local pos1={x=pos.x,y=pos.y+0.5,z=pos.z}
		local d
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 10)) do
			if portalgun_visiable(pos1,ob) and (ob:is_player() or (ob:get_luaentity() and (ob:get_luaentity().type or ob:get_luaentity().portalgun==nil))) then
				local a=ob:get_pos()
				if a.y<pos.y+2 and a.y>pos.y-1 then
					a={x=math.floor(a.x),y=math.floor(a.y),z=math.floor(a.z)}
					if p==3 and a.x>pos.x and a.z==pos.z then
						d={x=20,y=0,z=0}
						break
					elseif p==1 and a.x<pos.x and a.z==pos.z then
						d={x=-20,y=0,z=0}
						break
					elseif p==2 and a.z>pos.z and a.x==pos.x then
						d={x=0,y=0,z=20}
						break
					elseif p==0 and a.z<pos.z and a.x==pos.x then
						d={x=0,y=0,z=-20}
						break
					end
				end
			end
		end
		local m=minetest.get_meta(pos)
		if d then
			m:set_int("stop",0)
			minetest.add_entity(pos1, "portalgun:bullet1"):set_velocity(d)
			minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
			for i=2,5,1 do
				minetest.after(i*0.1, function(pos,d)
					minetest.add_entity(pos1, "portalgun:bullet1"):set_velocity(d)
					minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
				end, pos,d)
			end
		else
			if m:get_int("stop")==1 then
				minetest.set_node(pos,{name="portalgun:turretgun",param2=p})
				minetest.get_node_timer(pos):start(0.2)
			else
				m:set_int("stop",1)
			end
		end
		return true
	end
})


minetest.register_node("portalgun:turretgun", {
	description = "Sentry turret",
	groups = {cracky=3},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_defaults(),
	tiles = {"portalgun_sentry_turret.png"},
	drawtype = "mesh",
	mesh="torret1.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 1,0.3},
		}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.2)
	end,
	on_timer=function(pos, elapsed)
		local p=minetest.get_node(pos).param2
		local pos1={x=pos.x,y=pos.y+0.5,z=pos.z}
		local d
		for i, ob in pairs(minetest.get_objects_inside_radius(pos1, 10)) do
			if portalgun_visiable(pos1,ob) and (ob:is_player() or (ob:get_luaentity() and (ob:get_luaentity().type or ob:get_luaentity().portalgun==nil))) then
				local a=ob:get_pos()
				if a.y<pos.y+2 and a.y>pos.y-1 then
					a={x=math.floor(a.x),y=math.floor(a.y),z=math.floor(a.z)}
					if p==3 and a.x>pos.x and a.z==pos.z then
						d={x=20,y=0,z=0}
						break
					elseif p==1 and a.x<pos.x and a.z==pos.z then
						d={x=-20,y=0,z=0}
						break
					elseif p==2 and a.z>pos.z and a.x==pos.x then
						d={x=0,y=0,z=20}
						break
					elseif p==0 and a.z<pos.z and a.x==pos.x then
						d={x=0,y=0,z=-20}
						break
					end
				end
			end
		end

		if d then
			minetest.add_entity(pos1, "portalgun:bullet1"):set_velocity(d)
			minetest.set_node(pos,{name="portalgun:turretgun2",param2=p})
			minetest.get_node_timer(pos):start(1)
			minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
			for i=2,5,1 do
				minetest.after(i*0.1, function(pos,d)
					minetest.add_entity(pos1, "portalgun:bullet1"):set_velocity(d)
					minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15})
				end, pos,d)
			end
		end
		return true
	end
})


minetest.register_node("portalgun:warntape", {
	description = "Warntape",
	groups = {dig_immediate = 3,not_in_creative_inventory=0},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_defaults(),
	tiles = {"portalgun_warntape.png",},
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.3125, 0.5, -0.4375, 0.5},
		}
	}
})


minetest.register_node("portalgun:toxwater_1", {
	description = "Toxic water",
	drawtype = "liquid",
	tiles = {"portalgun_toxwat.png"},
	post_effect_color = {a = 200, r = 119, g = 70, b = 16},
	alpha = 190,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	damage_per_second = 20,
	liquidtype = "source",
	liquid_alternative_flowing = "portalgun:toxwater_2",
	liquid_alternative_source = "portalgun:toxwater_1",
	liquid_viscosity = 2,
	liquid_renewable = false,
	liquid_range = 3,
	post_effect_color = {a = 200, r = 119, g = 70, b = 16},
	groups = {water = 3, liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("portalgun:toxwater_2", {
	description = "Toxic water 2",
	drawtype = "flowingliquid",
	tiles = {"portalgun_toxwat.png"},
	tiles = {name = "portalgun_toxwat.png",backface_culling=false},
	special_tiles = {{name = "portalgun_toxwat.png",backface_culling=true},{name = "portalgun_toxwat.png",backface_culling=false}},
	alpha = 190,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	damage_per_second = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "portalgun:toxwater_2",
	liquid_alternative_source = "portalgun:toxwater_1",
	liquid_viscosity = 2,
	liquid_renewable = false,
	liquid_range = 3,
	post_effect_color = {a = 200, r = 119, g = 70, b = 16},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_tool("portalgun:ed", {
	description = "Entity Destroyer",
	inventory_image = "portalgun_edestroyer.png",
	range = 15,
on_use = function(itemstack, user, pointed_thing)
	local pos=user:get_pos()
	if pointed_thing.type=="node" then
		pos=pointed_thing.above
	end
	if pointed_thing.type=="object" then
		pos=pointed_thing.ref:get_pos()
	end
	local name=user:get_player_name()
	if minetest.check_player_privs(name, {kick=true})==false then
		minetest.chat_send_player(name, "You need the kick privilege to use this tool!")
		return itemstack
	end
	for ii, ob in pairs(minetest.get_objects_inside_radius(pos, 7)) do
		if ob:get_luaentity() then
			ob:set_hp(0)
			ob:punch(ob, {full_punch_interval=1.0,damage_groups={fleshy=9000}}, "default:bronze_pick", nil)
		end
	end
	return itemstack
end
})

minetest.register_node("portalgun:cake", {
	description = "Cake",
	groups = {dig_immediate = 3,not_in_creative_inventory=0},
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {type = "fixed",fixed = { -0.3, -0.5, -0.3, 0.3, 0, 0.3 }},
	sounds = default.node_sound_defaults(),
tiles = {
		"default_dirt.png^portalgun_cake1.png",
		"default_dirt.png^portalgun_cake2.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.375, 0.3125, -0.125, 0.4375},
			{-0.3125, -0.5, -0.4375, 0.3125, -0.125, -0.375},
			{-0.4375, -0.5, -0.3125, -0.375, -0.125, 0.3125},
			{0.375, -0.5, -0.3125, 0.4375, -0.125, 0.3125},
			{-0.375, -0.5, -0.375, 0.375, -0.125, 0.375},
			{-0.25, -0.5, 0.4375, 0.25, -0.125, 0.5},
			{-0.25, -0.5, -0.5, 0.25, -0.125, -0.4375},
			{0.4375, -0.5, -0.25, 0.5, -0.125, 0.25},
			{-0.5, -0.5, -0.25, -0.4375, -0.125, 0.25},
			{0, -0.125, -0.0625, 0.0625, 0.1875, 0},
		}
	}
})


minetest.register_node("portalgun:testblock", {
	description = "Test block",
	tiles = {"portalgun_testblock.png"},
	groups = {cracky = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("portalgun:apb", {
	description = "Anti portal block",
	tiles = {"portalgun_testblock.png^[colorize:#ffffffaa"},
	groups = {cracky = 3,antiportal=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("portalgun:apg", {
	description = "Anti portal glass",
	drawtype="glasslike",
	paramtype="light",
	sunlight_propagates = true,
	tiles = {"default_glass.png^[colorize:#ffffffaa"},
	groups = {cracky = 1,antiportal=1},
	sounds = default.node_sound_glass_defaults(),
})
minetest.register_node("portalgun:hard_glass", {
	description = "Hard glass",
	drawtype="glasslike",
	paramtype="light",
	sunlight_propagates = true,
	tiles = {"default_glass.png^[colorize:#ddddddaa"},
	groups = {cracky = 1},
	sounds = default.node_sound_glass_defaults(),
})

function portalgun_visiable(pos,ob)
	if ob==nil or ob:get_pos()==nil or ob:get_pos().y==nil then return false end
	local ta=ob:get_pos()
	local v = {x = pos.x - ta.x, y = pos.y - ta.y-1, z = pos.z - ta.z}
	v.y=v.y-1
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=math.sqrt((pos.x-ta.x)*(pos.x-ta.x) + (pos.y-ta.y)*(pos.y-ta.y)+(pos.z-ta.z)*(pos.z-ta.z))
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		local node=minetest.registered_nodes[minetest.get_node({x=pos.x+(v.x*i),y=pos.y+(v.y*i),z=pos.z+(v.z*i)}).name]
		if node.walkable then
			return false
		end
	end
	return true
end

function portalgun_round(x)
if x%2 ~= 0.5 then
return math.floor(x+0.5)
end
return x-0.5
end


function portalgun_ra2shoot(pos,ob)
		local op=ob:get_pos()
		local m=minetest.get_meta(pos)
		local x=m:get_int("x")
		local y=m:get_int("y")
		local z=m:get_int("z")
		local ox=portalgun_round(op.x)
		local oy=portalgun_round(op.y)
		local oz=portalgun_round(op.z)
		if x==1 and ox==pos.x and oz<=pos.z then
			return true
		end
		if x==-1 and ox==pos.x and oz>=pos.z then
			return true
		end
		if z==-1 and oz==pos.z and ox<=pos.x then
			return true
		end
		if z==1 and oz==pos.z and ox>=pos.x then
			return true
		end
		return false
end

minetest.register_node("portalgun:secam_off", {
	description = "Security cam (off)" ,
	tiles = {"portalgun_scam.png"},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}
	},
	on_place = minetest.rotate_node,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","click to activate")
	end,
on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	minetest.set_node(pos, {name ="portalgun:secam", param1 = node.param1, param2 = node.param2})
	minetest.get_node_timer(pos):start(1)
end,
})

minetest.register_node("portalgun:secam", {
	description = "Security cam",
	tiles = {"portalgun_scam.png"},
	drawtype = "nodebox",
	walkable=false,
	groups = {dig_immediate = 3,stone=1,not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	drop="portalgun:secam_off",
	node_box = {type="fixed",
		fixed={	{-0.2, -0.5, -0.2, 0.2, -0.4, 0.2},
			{-0.1, -0.2, -0.1, 0.1, -0.4, 0.1}}
	},
on_timer=function(pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 10)) do
			if ob:is_player() or (ob:get_luaentity() and ob:get_luaentity().itemstring==nil and ob:get_luaentity().portalgun==nil) then
				if portalgun_visiable(pos,ob) then
					local v=ob:get_pos()
					if not ob:get_luaentity() then v.y=v.y+1 end
					local s={x=(v.x-pos.x)*3,y=(v.y-pos.y)*3,z=(v.z-pos.z)*3}
					local m=minetest.add_entity(pos, "portalgun:bullet1")
					m:set_velocity(s)
					m:set_acceleration(s)
					minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15,})
					minetest.after((math.random(1,9)*0.1), function(pos,s,v)
					local m=minetest.add_entity(pos, "portalgun:bullet1")
					m:set_velocity(s)
					m:set_acceleration(s)
					minetest.sound_play("portalgun_bullet1", {pos=pos, gain = 1, max_hear_distance = 15,})
					end, pos,s,v)
				end
			end
		end
		return true
	end,
})

minetest.register_entity("portalgun:bullet1",{
	hp_max = 1,
	--physical = true,
	--collisionbox={-0.01,-0.01,-0.01,0.01,0.01,0.01},
	pointable=false,
	visual = "sprite",
	visual_size = {x=0.1, y=0.1},
	textures = {"default_mese_block.png"},
	initial_sprite_basepos = {x=0, y=0},
	portalgun=2,
	bullet=1,
on_step= function(self, dtime)
	self.timer=self.timer+dtime
	self.timer2=self.timer2+dtime
	local pos=self.object:get_pos()
	local n=minetest.registered_nodes[minetest.get_node(self.object:get_pos()).name]
	if self.timer>1 or (n and n.walkable) then
		self.object:remove()
		return
	end
	for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
		if  ob:is_player() or (ob:get_luaentity() and ob:get_luaentity().bullet~=1) then
			ob:set_hp(ob:get_hp()-7)
			ob:punch(self.object, 1,{full_punch_interval=1.0,damage_groups={fleshy=4}}, "default:bronze_pick", nil)
			self.object:remove()
			return
		end
	end
	end,
	timer=0,
	timer2=0,
})

minetest.register_node("portalgun:sign1", {
	description = "Portal sign blue",
	tiles = {"portalgun_testblock.png^portalgun_sign1.png"},
	inventory_image = "portalgun_testblock.png^portalgun_sign1.png",
	drawtype = "nodebox",
	groups = {snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_wood_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {
	type="fixed",
	fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}},
})

minetest.register_node("portalgun:sign2", {
	description = "Portal sign orange",
	tiles = {"portalgun_testblock.png^portalgun_sign2.png"},
	inventory_image = "portalgun_testblock.png^portalgun_sign2.png",
	drawtype = "nodebox",
	groups = {snappy = 3, not_in_creative_inventory=0},
	sounds = default.node_sound_wood_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {
	type="fixed",
	fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}},
})
