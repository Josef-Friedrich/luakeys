local inspect = require('inspect')

function trim(input_string)
  return input_string:gsub('^%s*(.-)%s*$', '%1')
end

function get_array_size(raw)
  local count = 0
  if type(raw) == 'table' then
    for _ in ipairs(raw) do count = count + 1 end
  end
  return count
end

function get_table_size(raw)
  local count = 0
  if type(raw) == 'table' then
    for _ in pairs(raw) do count = count + 1 end
  end
  return count
end

function grab_value_from_array(input)
  if get_array_size(input) == 1 and get_table_size(input) == 1 and type(input[1]) ~= 'table' then
    return input[1]
  end
  return input
end

function normalize(raw)
  local function normalize_recursive(raw, result)
    for key, value in pairs(raw) do
      if type(value) == 'table' then
        result[key] = normalize_recursive(value, {})
      elseif type(value) == 'string' then
        result[key] = trim(value)
      else
        result[key] = value
      end
    end
    return result
  end

  return normalize_recursive(raw, {})
end

r = {
  'lol', 'troll ',
  request = {
      headers = 'a ',
      body = ' \n \tb',
      'lol trol',
      level = {
        ' lol lol '
      }
  }
}
result = normalize(r)
print(inspect(result))

print(get_table_size({1}))
print(get_table_size({}))
print(get_table_size({['einz'] = 1}))
print(get_table_size({['einz'] = 1, 2}))

print(inspect(grab_value_from_array({ 'text' })))
print(inspect(grab_value_from_array({ 'text', 'zwei' })))
print(inspect(grab_value_from_array({ 1 })))
print(inspect(grab_value_from_array({ 1,  2 })))
print(inspect(grab_value_from_array({ {1},  {2} })))

print(inspect(grab_value_from_array({ ['one'] = 'one' })))
print(inspect(grab_value_from_array({ one = 'one' })))
