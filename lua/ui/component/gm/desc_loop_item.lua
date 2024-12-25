local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local DescItem = class("DescItem", super)
local gmData = Z.DataMgr.Get("gm_data")

function DescItem:ctor()
end

function DescItem:OnInit()
end

function DescItem:OnRefresh(data)
  local tIndex = gmData.DIndex
  local cmdInfo = ""
  if not gmData.GMexplore then
    local str1 = ""
    do
      local value = data.ParameterOrContent
      for i = 1, #value do
        str1 = 2 <= i and str1 .. "," .. value[i] or str1 .. value[i]
      end
    end
    local str2 = ""
    do
      local value = data.CommandOrParameterRemark
      for i = 1, #value do
        str2 = str2 .. value[i]
      end
    end
    local str3 = ""
    do
      local value = data.OptionalParameter
      for k, v in pairs(value) do
        str3 = str3 .. ",[" .. string.split(v, " ")[1] .. "]"
      end
    end
    cmdInfo = str1 .. str3 .. "\n" .. str2
  else
    local str = ""
    do
      local value = data.CommandOrParameterRemark
      if value[1] then
        str = value[1]
      end
    end
    cmdInfo = index == tIndex and data.Command .. "\n" .. str or data.Command
  end
  local tex_color = index == tIndex and Color.New(1.0577777777777777, 0.5955555555555555, 0.4177777777777778, 1) or Color.New(1, 1, 1, 1)
  self.uiBinder.desc.color = tex_color
  local str = data.Command
  if data.Type == gmData.CmdType.group then
    str = data.Command
  end
  self.str = str
  self.uiBinder.desc.text = cmdInfo
end

function DescItem:OnSelected(isSelectd, isClick)
  if isSelectd then
    self.uiBinder.desc.color = Color.New(1.0577777777777777, 0.5955555555555555, 0.4177777777777778, 1)
    Z.VMMgr.GetVM("gm").RefreshInputField(self.str .. " ")
    gmData.DIndex = 1
  else
    self.uiBinder.desc.color = Color.New(1, 1, 1, 1)
  end
end

function DescItem:OnUnInit()
end

return DescItem
