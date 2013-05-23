
TORCH_TIMEOUT = (60 * 10);

local function deepcopy ( t )
    local nt = { };
    for k, v in pairs(t) do
        if (type(v) == "table") then
            nt[k] = deepcopy(v);
        else
            nt[k] = v;
        end
    end
    return nt;
end

local new_torch = deepcopy(minetest.registered_nodes["default:torch"]);

minetest.register_entity("burning_torch:item", {
    drawtype = "sprite";
    textures = { "default_torch_inv.png" };
    on_punch = function ( self, puncher )
        local inv = puncher:get_inventory();
        inv:add_item("main", ItemStack("default:torch"));
    end;
    itemstring = "";
});

local function same_position (p0, p1)
   return p0 and p1 and (p0.x == p1.x) and (p0.y == p1.y) and (p0.z == p1.z)
end

local function try_ignite_above ( pos )
    if minetest.setting_getbool("disable_fire") then return end
    -- fire enabled
    local above = {x=pos.x, y=pos.y+1, z=pos.z}
    local p = minetest.env:find_node_near(above, 1, {"group:flammable"})
    if (not p) or same_position(p,pos) then return end
    -- flammable node is near
    local p2 = fire.find_pos_for_flame_around(p)
    if not p2 then return end
    -- position for flame found
    minetest.env:set_node(p2, {name="fire:basic_flame"})
    fire.on_flame_add_at(p2)
end

new_torch.on_construct = function ( pos )
    local tmr = minetest.env:get_node_timer(pos);
    tmr:start(TORCH_TIMEOUT);
    try_ignite_above(pos)
end

new_torch.on_timer = function ( pos )
    minetest.env:remove_node(pos);
end;

minetest.register_node(":default:torch", new_torch);

-- vim: expandtab
