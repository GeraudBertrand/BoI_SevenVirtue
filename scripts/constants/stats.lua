local s = {}

---comment
---@param maxFireDelay integer
---@return integer
function s.toTearsPerSecond(maxFireDelay)
  return 30 / (maxFireDelay + 1)
end

---comment
---@param tearsPerSecond integer
---@return integer
function s.toMaxFireDelay(tearsPerSecond)
  return (30 / tearsPerSecond) - 1
end


return s