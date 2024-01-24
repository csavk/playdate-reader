-- A function that splits a line into words
function splitWords (line)
    local words = {}
    for word in string.gmatch (line, "%S+") do
      table.insert (words, word)
    end
    return words
end

-- A function that converts a paragraph into a list of strings that fit the screen
function fitScreen (lines, paragraph, font, screenWidth)
    local s = "" -- the current string
    local words = splitWords (paragraph) -- the words in the paragraph
    for _, word in ipairs (words) do
      if s == "" then
        s = word
      else 
        s = s .. " " .. word
      end
      if font:getTextWidth (s) > screenWidth then -- check if s exceeds the screen width
        s = s:sub (1, -#word - 2) -- remove the last word and space from s
        table.insert (lines, s) -- insert s into t
        s = word -- assign the last word and space to s
      end
    end
    if s ~= "" then -- if s is not empty
      table.insert (lines, s) -- insert s into t
    end
  end