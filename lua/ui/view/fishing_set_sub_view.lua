local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_set_subView = class("Fishing_set_subView", super)

function Fishing_set_subView:ctor(parent)
  self.uiBinder = nil
  self.parentView_ = parent
  super.ctor(self, "fishing_set_sub", "fishing/fishing_set_sub", UI.ECacheLv.None)
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function Fishing_set_subView:OnActive()
  self.itemUI_ = {}
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_return, function()
    self.parentView_:CloseSettingView()
  end)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingSettingChange, self.refreshUI, self)
  Z.UIMgr:AddShowMouseView("fishing_set_sub")
end

function Fishing_set_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingSettingChange, self.refreshUI, self)
  Z.UIMgr:RemoveShowMouseView("fishing_set_sub")
end

function Fishing_set_subView:OnRefresh()
  self:refreshUI()
end

function Fishing_set_subView:refreshUI()
  for _, v in ipairs(self.itemUI_) do
    self:RemoveUiUnit(v)
  end
  self.itemUI_ = {}
  self.isCreating_ = true
  Z.CoroUtil.create_coro_xpcall(function()
    local fishingSettingData = Z.DataMgr.Get("fishing_setting_data")
    local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "set_item_tpl")
    for k, v in ipairs(fishingSettingData.ShowEntityAllCfg) do
      local name = "set_entity_" .. k
      local setItem = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_setting_entity)
      setItem.lab_title.text = v.txt
      setItem.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      setItem.tog_camera_setting:RemoveAllListeners()
      setItem.tog_camera_setting:AddListener(function(isOn)
        self.fishingVM_.SetShowEntitySetting(v.type, isOn)
        Z.DIServiceMgr.FishingService:SetEntityShow(v.type, isOn)
      end)
      table.insert(self.itemUI_, name)
    end
    for k, v in ipairs(fishingSettingData.ShowUIAllCfg) do
      local name = "set_ui_" .. k
      local setItem = self:AsyncLoadUiUnit(path, name, self.uiBinder.layout_setting_ui)
      setItem.lab_title.text = v.txt
      setItem.tog_camera_setting:SetIsOnWithoutCallBack(v.state)
      setItem.tog_camera_setting:RemoveAllListeners()
      setItem.tog_camera_setting:AddListener(function(isOn)
        self.fishingVM_.SetShowUISetting(v.type, isOn)
        Z.LuaBridge.SetHudSwitch(isOn)
      end)
      table.insert(self.itemUI_, name)
    end
    self.isCreating_ = false
  end)()
end

return Fishing_set_subView
