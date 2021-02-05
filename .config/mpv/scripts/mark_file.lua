local utils = require "mp.utils"
local msg = require "mp.msg"

-- Globale variables
del_list = {}
save_list = {}

function contains_item(l, i, prefix)
   for k, v in pairs(l) do
      if v == i then
         mp.osd_message("un" .. prefix .. " current file")
         l[k] = nil
         return true
      end
   end
   mp.osd_message(prefix .. " current file")
   return false
end

function mark_save()
   local work_dir = mp.get_property_native("working-directory")
   local file_path = mp.get_property_native("path")
   local s = file_path:find(work_dir, 0, true)
   local final_path
   if s and s == 0 then
      final_path = file_path
   else
      final_path = utils.join_path(work_dir, file_path)
   end
   if not contains_item(save_list, final_path, "saving") then
      table.insert(save_list, final_path)
   end   
end

function mark_delete()
   local work_dir = mp.get_property_native("working-directory")
   local file_path = mp.get_property_native("path")
   local s = file_path:find(work_dir, 0, true)
   local final_path
   if s and s == 0 then
      final_path = file_path
   else
      final_path = utils.join_path(work_dir, file_path)
   end
   if not contains_item(del_list, final_path, "deleting") then
      table.insert(del_list, final_path)
   end
end

function save_or_delete()
   for i, v in pairs(del_list) do
      print("deleting: "..v)
      dir, fn = utils.split_path(v)
      mkdir_cmd = 'mkdir "'..dir..'trash"'
      rename_str = dir..'trash\\/'..fn
      os.execute(mkdir_cmd) 
      os.rename(v, rename_str)
   end
   for i, v in pairs(save_list) do
      print("saving: "..v)
      dir, fn = utils.split_path(v)
      mkdir_cmd = 'mkdir "'..dir..'saved"'
      rename_str = dir..'saved\\/'..fn
      os.execute(mkdir_cmd) 
      os.rename(v, rename_str)
   end
end

-- Key bindings
mp.add_key_binding(nil, "delete_file", mark_delete)
mp.add_key_binding(nil, "save_file", mark_save)
mp.register_event("shutdown", save_or_delete)
