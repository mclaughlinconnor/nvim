-- TODO: unicode is breaking on >= 128 codepoints
-- TODO: just use vim.diff('', '', {linematch=true, result_type="indicies"})?

local diff = require("google.diff-match-patch")
local utf8 = require("utf8")

local function diff_linesToChars(text1, text2)
  local lineArray = {}
  local lineHash = {}

  -- '\x00' is a valid character, but various debuggers don't like it.
  -- So we'll insert a junk entry to avoid generating a null character.
  lineArray[1] = ""

  local maxLines
  --[[
   * Split a text into an array of strings.  Reduce the texts to a string of
   * hashes where each Unicode character represents one line.
   * Modifies linearray and linehash through being a closure.
   * @param {string} text String to encode.
   * @return {string} Encoded string.
   * @private
  --]]
  local function diff_linesToCharsMunge(text)
    local chars = ""
    -- Walk the text, pulling out a substring for each line.
    -- text.split('\n') would would temporarily double our memory footprint.
    -- Modifying text would create many large strings to garbage collect.
    local lineStart = 0
    local lineEnd = -1
    -- Keeping our own length variable is faster than looking it up.
    local lineArrayLength = #lineArray

    local index = 0

    while lineEnd < #text do
      if index > 1000 then
        vim.notify('broken')
      end

      index = index + 1

      -- lineEnd = text:find("%s", lineStart)
      lineEnd = text:find("[;. ',{}\n]", lineStart)
      -- lineEnd = text:find("%A", lineStart)
      if lineEnd == nil then
        lineEnd = #text
        -- else
        --   lineEnd = lineEnd - 1
      end
      local line = text:sub(lineStart, lineEnd)

      if lineHash[line] ~= nil then
        chars = chars .. utf8.char(lineHash[line])
      else
        if lineArrayLength == maxLines then
          -- Bail out at 1114111 because utf8.char(1114112) throws.
          line = text.sub(lineStart)
          lineEnd = #text
        end
        table.insert(lineArray, line)
        lineHash[line] = #lineArray - 1
        print(utf8.char(#lineArray - 1), #lineArray - 1, line)
        chars = chars .. utf8.char(#lineArray - 1)
      end
      lineStart = lineEnd + 1 + 0
    end

    return chars
  end

  maxLines = 666666
  local chars1 = diff_linesToCharsMunge(text1)
  maxLines = 1114111
  local chars2 = diff_linesToCharsMunge(text2)
  return { chars1 = chars1, chars2 = chars2, lineArray = lineArray }
end

local function diff_charsToLines(diffs, lineArray)
  for i = 1, #diffs, 1 do
    local chars = diffs[i][2]
    print(chars)
    local text = {}
    for j = 1, #chars, 1 do
      print(vim.inspect(chars:sub(j, j)))
      print(vim.inspect(utf8.codepoint(chars:sub(j, j))))
      -- print(vim.inspect(utf8.char(128)), vim.inspect(utf8.codepoint(utf8.char(128))))
      print(lineArray[utf8.codepoint(chars:sub(j, j)) + 1])
      text[j] = lineArray[utf8.codepoint(chars:sub(j, j)) + 1]
    end
    diffs[i][2] = table.concat(text, "")
  end
end

local function wordDiff(text1, text2)
  local chars = diff_linesToChars(text1, text2)

  local lineText1 = chars.chars1
  local lineText2 = chars.chars2
  local lineArray = chars.lineArray

  print(vim.inspect(lineArray))

  local diffs = diff.diff_main(lineText1, lineText2)
  print(vim.inspect(diffs))
  diff_charsToLines(diffs, lineArray)

  return diffs
end

local one = wordDiff(middle, left)
local two = wordDiff(middle, right)
local three = wordDiff(left, right)

print(vim.inspect(one))
print(vim.inspect(two))
print(vim.inspect(three))

local diffs = { one, two, three }

local function theyAreDifferent(a, a_aligned, b, b_aligned, c, c_aligned)
  if a == nil or b == nil or c == nil then
    return true
  end

  -- print(vim.inspect(a), vim.inspect(b), vim.inspect(c))

  if a[1] == 0 and b[1] ~= 0 and c[1] ~= 0 then
    table.insert(a_aligned, { 9, string.rep(" ", #b[2]) })
    table.insert(b_aligned, b)
    table.insert(c_aligned, c)

    return true
  end

  return false
end

for i = 1, 3, 1 do
  local changes = {}
  for _, change in ipairs(diffs[i]) do
    -- change: { 1 | 0 | -1, string}
    -- local words = vim.fn.split(change[2], "\\_[.('')]\\zs")
    -- local words = vim.fn.split(change[2], "[^[:alpha:]]\zs")
    -- local words = vim.fn.split(change[2], [[\_\W\zs]])
    local words = vim.fn.split(change[2], [[\_\W\zs]])
    for _, word in ipairs(words) do
      if word ~= "" then
        table.insert(changes, { change[1], word })
      end
    end
  end
  diffs[i] = changes
end

local indices = { 1, 1, 1 }
local index = 0

local aligned = { {}, {}, {} }

while true do
  index = index + 1
  if index == 1000 then
    vim.notify("broken one")
    break
  end

  local words = {}
  for i = 1, 3, 1 do
    table.insert(words, diffs[i][indices[i]])
  end

  if (words[1] == 0 and words[1] == 0 and words[1] == 0) or (words[2] == words[2] and words[2] == words[2]) then
    for i = 1, 3, 1 do
      table.insert(aligned[i], words[i])
      indices[i] = indices[i] + 1
    end
  end

  local updated = false
  for i = 1, 3, 1 do
    if not updated then
      local a = i
      local b = (i + 1) % 3 + 1
      local c = (i + 2) % 3 + 1

      if theyAreDifferent(words[a], aligned[a], words[b], aligned[b], words[c], aligned[c]) then
        indices[b] = indices[b] + 1
        indices[c] = indices[c] + 1
        updated = true
      end
    end
  end

  if indices[1] >= #diffs[1] and indices[2] >= #diffs[2] and indices[3] >= #diffs[3] then
    break
  end
end
-- print(vim.inspect(diffs[1]))
-- print("---")
-- print(vim.inspect(diffs[2]))
-- print("---")
-- print(vim.inspect(diffs[3]))

indices = { 1, 1, 1 }
local cum_lengths = { 1, 1, 1 }

while true do
  index = index + 1

  local words = {}
  local nils = 0
  for i = 1, 3, 1 do
    local change = diffs[i][indices[i]]
    if change ~= nil then
      table.insert(words, diffs[i][indices[i]])
    else
      table.insert(words, { 0, "" })
      nils = nils + 1
    end
  end

  if nils == 3 then
    -- reached the end
    break
  end

  local function increase(side)
    local current_length = #diffs[side][indices[side]][2]
    local cum_length = cum_lengths[side]

    cum_lengths[side] = cum_lengths[side] + current_length
    diffs[side][indices[side]] = { words[side][1], words[side][2], cum_length, cum_length + current_length }
    indices[side] = indices[side] + 1
  end

  local function isDifferent(a, b, c)
    if words[b][2] == "" then
      return false
    end
    if words[c][2] == "" then
      return false
    end

    return words[a][1] ~= words[b][1] and words[b][1] == words[c][1]
  end

  if
      (words[1][1] == 0 and words[2][1] == 0 and words[3][1] == 0)
      or (words[1][2] == words[2][2] and words[2][2] == words[3][2])
  then
    for side = 1, 3, 1 do
      local cum_length = cum_lengths[side]
      local side_index = indices[side]

      if diffs[side][side_index] ~= nil then
        diffs[side][side_index] =
        { words[side][1], words[side][2], cum_length, cum_length + #diffs[side][side_index][2] }
        cum_lengths[side] = cum_length + #diffs[side][indices[side]][2] + 1
        indices[side] = side_index + 1
      end
    end
  elseif isDifferent(1, 2, 3) then
    increase(2)
    increase(3)
  elseif isDifferent(2, 1, 3) then
    increase(1)
    increase(3)
  elseif isDifferent(3, 1, 2) then
    increase(1)
    increase(2)
  elseif words[1][1] ~= 0 then -- if 0 has reached the end
    increase(1)
  elseif words[2][1] ~= 0 then
    increase(2)
  elseif words[3][1] ~= 0 then
    increase(3)
  end

  if index > 5000 then
    vim.notify("broken two")
    break
  end
end

print(vim.inspect(diffs[1]))
print("---")
print(vim.inspect(diffs[2]))
print("---")
print(vim.inspect(diffs[3]))

local function merge(side, target)
  indices = { 1, 1, 1 }
  index = 0

  local last_inserted = false

  while true do
    index = index + 1

    -- there's been an error if we're past 1000
    if index > 1000 then
      vim.notify("broken three")
      break
    end

    local side_change = diffs[side][indices[side]]
    local target_change = diffs[target][indices[target]]

    -- reached the end
    if side_change == nil and target_change == nil then
      break
    end

    print(vim.inspect(side_change) ..
      ' --- ' .. vim.inspect(target_change) .. ' --- ' .. vim.inspect(indices) .. ' --- ' .. vim.inspect(last_inserted))

    if side_change ~= nil and target_change ~= nil then
      if side_change[2] == target_change[2] then
        if side_change[1] == target_change[1] then
          if side_change[1] == 0 then
            print('    text equal, moving forward, unsetting last_inserted')
            last_inserted = false
          else
            print('    text equal, moving forward, setting last_inserted')
            table.insert(diffs[target], indices[target], side_change)
            last_inserted = true
          end
          indices[side] = indices[side] + 1
          indices[target] = indices[target] + 1
        elseif side_change[1] == 0 and target_change[1] ~= 0 then
          indices[side] = indices[side] + 1
          indices[target] = indices[target] + 1
          last_inserted = false
          print('    text equal, target has change already, moving forward, unsetting last_inserted')
        elseif side_change[1] ~= 0 and target_change[1] == 0 then
          diffs[target][indices[target]][1] = side_change[1]
          indices[side] = indices[side] + 1
          indices[target] = indices[target] + 1
          last_inserted = true
          print('    text equal, set target to change, moving forward, setting last_inserted')
        elseif side_change[1] ~= 0 and target_change[1] ~= 0 then
          table.insert(diffs[target], indices[target], side_change)
          indices[side] = indices[side] + 1
          indices[target] = indices[target] + 1
          last_inserted = true
          print(
            '    text equal, different types of change, insert side to target, moving forward, setting last_inserted')
        end
      else
        if side_change[1] == 0 and target_change[1] ~= 0 then
          indices[target] = indices[target] + 1
          last_inserted = false
          print('    text not equal, target change, moving side forward find match, unsetting last_inserted')
        elseif side_change[1] ~= 0 and target_change[1] == 0 then
          table.insert(diffs[target], indices[target], side_change)
          indices[side] = indices[side] + 1
          indices[target] = indices[target] + 1
          last_inserted = true
          print('    text not equal, change on side, moving target forward find match, unsetting last_inserted')
        elseif side_change[1] ~= 0 and target_change[1] ~= 0 then
          if last_inserted then
            table.insert(diffs[target], indices[target], side_change)
            indices[side] = indices[side] + 1
            indices[target] = indices[target] + 1
            last_inserted = true
            print('    text not equal, different types of changes, continuing previous insert, inserting side')
          else
            indices[target] = indices[target] + 1
            last_inserted = false
            print('    text not equal, different types of changes, continuing previous insert, moving target forward')
          end
        end
      end
    elseif side_change == nil or target_change == nil then
      if side_change == nil and target_change ~= nil then
        indices[target] = indices[target] + 1
      elseif target_change == nil and side_change ~= nil then
        table.insert(diffs[target], indices[target], side_change)
        indices[target] = indices[target] + 1
        indices[side] = indices[side] + 1
      else
        print('both sides must be nill? break')
        break
      end
    else
      vim.notify('somehow reached here')
    end
    print('    ' .. vim.inspect(diffs[target]))
  end
end

if middle ~= "" then
  merge(2, 1) -- two is comparing middle and right, so just need to merge in left - middle diff
else
  merge(3, 1) -- two is comparing middle and right, so just need to merge in left - middle diff
end

print(vim.inspect(diffs[1]))
print("---")
print(vim.inspect(diffs[2]))
print("---")
print(vim.inspect(diffs[3]))

local final = ""
for _, change in ipairs(diffs[1]) do
  if change[1] ~= -1 then
    final = final .. change[2]
  end
end

local lines = vim.fn.split(final, [[\n]])
print(vim.inspect(lines))

vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
