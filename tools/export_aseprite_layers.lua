local source = app.params["source"]
local output = app.params["output"]
if source == nil or output == nil then
  error("source and output parameters are required")
end

local sprite = app.open(source)
if sprite == nil then
  error("could not open " .. source)
end

local layers = {}
local function collect(list)
  for _, layer in ipairs(list) do
    table.insert(layers, layer)
    if layer.isGroup then
      collect(layer.layers)
    end
  end
end
collect(sprite.layers)

for _, layer in ipairs(layers) do
  layer.isVisible = false
end

for index, layer in ipairs(layers) do
  layer.isVisible = true
  local safe_name = string.gsub(layer.name, "[\\/:*?\"<>|]", "_")
  sprite:saveCopyAs(string.format("%s/%02d-%s.png", output, index, safe_name))
  layer.isVisible = false
end

sprite:close()
