
TORCH_TIMEOUT = (60 * 20);

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

new_torch.on_construct = function ( pos )
    local tmr = minetest.env:get_node_timer(pos);
    tmr:start(TORCH_TIMEOUT);
end

new_torch.on_timer = function ( pos )
    minetest.env:remove_node(pos);
    if (minetest.spawn_item) then
        minetest.spawn_item(pos, "default:torch");
    else
        minetest.env:add_entity(pos, "burning_torch:item");
    end
end;

minetest.register_node(":default:torch", new_torch);
