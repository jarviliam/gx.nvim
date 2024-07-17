local notifier = require("gx.notifier")
local M = {
  name = "tf",
  filetype = { "terraform" },
  filename = nil,
}

local function getSubLineFromIdentifier(identifier)
  local iden_row, iden_col, iden_end, col_end = identifier:range()
  local line = vim.api.nvim_buf_get_lines(0, iden_row, iden_end + 1, false)[1]
  return line:sub(iden_col, col_end)
end

local function getBlockNode(node)
  if node and node:type() ~= "block" then
    return getBlockNode(node:parent())
  end
  return node
end

local function getResourceFromIdentifier(identifier)
  local iden_row, iden_col, iden_end, col_end = identifier:range()
  local line = vim.api.nvim_buf_get_lines(0, iden_row, iden_end + 1, false)[1]
  return line:sub(iden_col + 2, col_end - 1)
end

--- Finds the `source = xxx` attribute inside of a body node
---@param node TSNode Body Node
local function find_source_attribute(node)
  if node:type() == "body" then
    for child, _ in node:iter_children() do
      if child:type() == "attribute" then
        local name_node = child:child(0)
        if name_node and vim.treesitter.get_node_text(name_node, 0) == "source" then
          local value_node = child:child(2)
          if value_node then
            return vim.treesitter.get_node_text(value_node, 0)
          end
        end
      end
    end
  end
end

local function handleModule(blockNode)
  for child, _ in blockNode:iter_children() do
    if child:type() == "body" then
      local attribute = find_source_attribute(child)
      if not attribute then
        notifier.info("Attribute not found")
        return
      end
      return "https://registry.terraform.io/modules/"
        .. attribute:sub(2, #attribute - 1)
        .. "/latest"
    end
  end
end

local function handleData(blockNode)
  local resourceLiteral = blockNode:child(1)
  if resourceLiteral == nil or resourceLiteral:type() ~= "string_lit" then
    return
  end
  local resource_name = getResourceFromIdentifier(resourceLiteral)
  local split_resource = vim.split(resource_name, "_")
  if #split_resource < 2 then
    return
  end
  local prefix = split_resource[1]
  local trailing = split_resource[2]
  for i = 3, #split_resource do
    trailing = trailing .. "_" .. split_resource[i]
  end
  return "https://registry.terraform.io/providers/hashicorp/"
    .. prefix
    .. "/latest/docs/data-sources/"
    .. trailing
end

local function handleResource(blockNode)
  local resourceLiteral = blockNode:child(1)
  if resourceLiteral == nil or resourceLiteral:type() ~= "string_lit" then
    return
  end
  local resource_name = getResourceFromIdentifier(resourceLiteral)
  local split_resource = vim.split(resource_name, "_")
  if #split_resource < 2 then
    return
  end
  local prefix = split_resource[1]
  local trailing = split_resource[2]
  for i = 3, #split_resource do
    trailing = trailing .. "_" .. split_resource[i]
  end
  return "https://registry.terraform.io/providers/hashicorp/"
    .. prefix
    .. "/latest/docs/resources/"
    .. trailing
end

function M.handle()
  local node = vim.treesitter.get_node()
  if not node then
    return nil
  end
  -- Get parent block
  local blockNode = getBlockNode(node)
  if not blockNode then
    return nil
  end
  local count = blockNode:child_count()
  if count == 0 then
    return
  end
  local identifierNode = blockNode:child(0)
  local name = getSubLineFromIdentifier(identifierNode)
  if not vim.tbl_contains({ "data", "resource", "module" }, name) then
    return
  end
  if name == "module" then
    return handleModule(blockNode)
  elseif name == "resource" then
    return handleResource(blockNode)
  else
    return handleData(blockNode)
  end
end

return M
