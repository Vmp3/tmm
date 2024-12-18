local Strings = {}

--- Uppercase: transforms any string into uppercase letters.
-- Custom function for lua 5.1 that includes converting any string to uppercase, including special character letters. Lua 5.1 does not have the UTF-8 module (available in higher versions of Lua 5.1).
-- @param string: string for uppercase letters that includes special characters. If the given parameter is not a string, it returns an empty string.
-- @return string: returns string typed in uppercase letters or empty string
function Strings:uppercase(str)
  if type(str) ~= "string" then return "" end

  local special_chars = {
    ["á"] = "Á",
    ["à"] = "À",
    ["â"] = "Â",
    ["ã"] = "Ã",
    ["é"] = "É",
    ["è"] = "È",
    ["ê"] = "Ê",
    ["í"] = "Í",
    ["ì"] = "Ì",
    ["î"] = "Î",
    ["ó"] = "Ó",
    ["ò"] = "Ò",
    ["ô"] = "Ô",
    ["õ"] = "Õ",
    ["ú"] = "Ú",
    ["ù"] = "Ù",
    ["û"] = "Û",
    ["ç"] = "Ç"
  }
  return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(char)
    return special_chars[char] or char:upper()
  end))
end

--- Lowercase: transforms any string into lowercase letters.
-- Custom function for lua 5.1 that includes converting any string to lowercase, including special character letters. Lua 5.1 does not have the UTF-8 module (available in higher versions of Lua 5.1).
-- @param string: string for lowercase letters that includes special characters. If the given parameter is not a string, it returns an empty string.
-- @return string: returns string typed in lowercase letters or empty string
function Strings:lowercase(str)
  if type(str) ~= "string" then return "" end

  local special_chars = {
    ["Á"] = "á",
    ["À"] = "à",
    ["Â"] = "â",
    ["Ã"] = "ã",
    ["É"] = "é",
    ["È"] = "è",
    ["Ê"] = "ê",
    ["Í"] = "í",
    ["Ì"] = "ì",
    ["Î"] = "î",
    ["Ó"] = "ó",
    ["Ò"] = "ò",
    ["Ô"] = "ô",
    ["Õ"] = "õ",
    ["Ú"] = "ú",
    ["Ù"] = "ù",
    ["Û"] = "û",
    ["Ç"] = "ç"
  }
  return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(char)
    return special_chars[char] or char:lower()
  end))
end

return Strings