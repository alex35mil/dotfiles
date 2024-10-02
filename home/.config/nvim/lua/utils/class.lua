---@generic T : table, B : table
---@param base_class B?
---@return T
function Class(base_class)
    local new_class = {}

    new_class.__index = new_class

    if base_class then
        setmetatable(new_class, { __index = base_class })
    end

    function new_class:new(...)
        local instance = setmetatable({}, self)

        if self.init then
            self.init(instance, ...)
        end

        return instance
    end

    return new_class
end
