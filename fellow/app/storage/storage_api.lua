local http = require('app/shared/utils/ncluahttp')
local logging = require('app/shared/utils/logging')

local StorageAPI = {
  initial_path = 'app/storage/_private/',
  assets_path = 'local/assets/',
  system_path = 'local/system/',
}

function StorageAPI:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local function exec(cmd, _res)
  local handle, err = io.popen(cmd);
  if not _res then _res = true; end;

  if _res then
      local result = handle:read("*a");
      handle:close();
      return result;
  end
  handle:close();
end

function StorageAPI:file_check(path, filename, extension, debug)
  if path == nil then path = self.initial_path end
  if filename == nil then return end
  if extension == nil then extension = '.png' end
  if debug ==  nil then debug = false end
  local worked, result = pcall(
    function()
      local file, err, code = io.open(self.initial_path .. path .. filename .. extension, 'rb')
      if not file then
        -- if debug then logging.error('err: ' .. err .. ' | code: ' ..code) end
        return false
      end
      return true
    end
  )
  return result
end

function StorageAPI:get_file(path, filename, extension)
  if path == nil then
    path = self.initial_path
  end
  if filename == nil then
    return
  end
  if extension == nil then
    extension = '.png'
  end

  local worked, result = pcall(
    function()
      local file, err, code = io.open(self.initial_path .. path .. filename .. extension, 'rb')
      if not file then
        return nil
      end
      return self.initial_path .. path .. filename .. extension
    end
  )

  return result

end

function StorageAPI:set_file(path, filename, extension, file_data)
  local worked, result = pcall(
    function()
      local file, err, code = assert(io.open(path .. filename .. extension, 'w+b'))
      if not file then
         print("Error opening file", path, err)
      end
      return file
    end)
  result:write(file_data)
  result:close()
end

function StorageAPI:list_all_files(path)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..path..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end


---------------------------------
------- // Instance \\ -----------
local P = {}
P.StorageAPI = StorageAPI

return P;