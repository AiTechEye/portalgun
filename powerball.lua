minetest.register_node("portalgun:powerballspawner", {
	description = "Power ball spawner" ,
	tiles = {"default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","portalgun_powerballspawner.png"},
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(10)
	end,
	on_timer = function (pos, elapsed)
		local dir=minetest.get_node(pos).param2
		local v={x=0, y=0, z=0}
		if dir==0 then v.z=-1
		elseif dir==1 then v.x=-1
		elseif dir==2 then v.z=1
		elseif dir==3 then v.x=1
		elseif dir==8 then v.y=-1
		elseif dir==4 then v.y=1
		end
		local pv={x=pos.x+v.x, y=pos.y+v.y, z=pos.z+v.z}
		portalgun.new=1
		local m=minetest.add_entity(pv, "portalgun:powerball")
		m:set_velocity({x=v.x*4, y=v.y*4, z=v.z*4})
		return true
	end,
})

minetest.register_node("portalgun:powerballspawner2", {
	description = "Power ball spawner (spawn on activate)" ,
	tiles = {"default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","default_steel_block.png","portalgun_powerballspawner.png^[colorize:#aaaa0055"},
	groups = {cracky=2,mesecon=1},
	sounds = default.node_sound_glass_defaults(),
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	mesecons = {effector = {
		action_on = function (pos, node)
			local dir=minetest.get_node(pos).param2
			local v={x=0, y=0, z=0}
			if dir==0 then v.z=-1
			elseif dir==1 then v.x=-1
			elseif dir==2 then v.z=1
			elseif dir==3 then v.x=1
			elseif dir==8 then v.y=-1
			elseif dir==4 then v.y=1
			end
			local pv={x=pos.x+v.x, y=pos.y+v.y, z=pos.z+v.z}
			portalgun.new=1
			local m=minetest.add_entity(pv, "portalgun:powerball")
			m:set_velocity({x=v.x*4, y=v.y*4, z=v.z*4})
		end
	}}
})


minetest.register_entity("portalgun:powerball",{
	hp_max = 1000,
	physical = true,
	weight = 0,
	collisionbox = {-0.4,-0.4,-0.4, 0.4,0.4,0.4},
	visual = "sprite",
	visual_size = {x=1.1, y=1.1},
	textures = {"portalgun_powrball.png"},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	portalgun=2,
	powerball=1,
on_activate= function(self, staticdata)
	if portalgun.new==0 then
		self.object:remove()
		return self
	end
	portalgun.new=0
	local pos=self.object:get_pos()
	self.sound=minetest.sound_play("portalgun_powerball", {pos=pos,max_hear_distance = 10, gain = 0.5})
	minetest.sound_play("portalgun_powerballbonce", {pos=pos,max_hear_distance = 10, gain = 1})
end,
on_step= function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.2 then return self end
		self.timer=0
		local pos=self.object:get_pos()
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if ob:is_player() or (ob:get_luaentity() and ob:get_luaentity().portalgun~=1 and ob:get_luaentity().wsc==nil and ob:get_luaentity().powerball~=1) then
				ob:set_hp(0)
				ob:punch(ob, {full_punch_interval=1.0,damage_groups={fleshy=9000}}, "default:bronze_pick", nil)

			end
		end
		self.timer2=self.timer2+1
		self.timer3=self.timer3+1
		if self.timer3>=9 then
			self.timer3=0
			minetest.sound_stop(self.sound)
			self.sound=minetest.sound_play("portalgun_powerball", {pos=pos,max_hear_distance = 10, gain = 0.5})
		end
		if self.timer2>40 then
			minetest.sound_stop(self.sound)
			self.object:set_hp(0)
			self.object:punch(self.object, {full_punch_interval=1.0,damage_groups={fleshy=9000}}, "default:bronze_pick", nil)
			return self
		end
		local v=self.object:get_velocity()
		local nextn={x=pos.x+(v.x)/3, y=pos.y+(v.y)/3, z=pos.z+(v.z)/3}
		local nname=minetest.get_node(nextn).name
		if minetest.registered_nodes[nname].walkable then

			if nname=="portalgun:powerballtarget" and mesecon then
				mesecon.receptor_on(nextn)
				minetest.get_node_timer(nextn):start(5)
			end
			self.object:set_velocity({x=v.x*-1, y=v.y*-1, z=v.z*-1})
			minetest.sound_play("portalgun_powerballbonce", {pos=pos,max_hear_distance = 10, gain = 1})
		end
	end,
	timer=0,
	timer2=0,
	timer3=0,
	sound={}
})

minetest.register_node("portalgun:powerballtarget", {
	description = "Power ball target" ,
	tiles = {"portalgun_powerballstarget.png"},
	groups = {mesecon = 2,cracky=2},
	mesecons = {receptor = {state = "off"}},
	sounds = default.node_sound_stone_defaults(),
	is_ground_content = false,
	on_timer = function (pos, elapsed)
		mesecon.receptor_off(pos)
		return false
	end,
})
