local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_templateView = class("Menu_templateView", super)
local MAX_TEMPLATE_ID = 1000

function Menu_templateView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_template_sub", "face/face_menu_template_sub", UI.ECacheLv.None)
end

function Menu_templateView:OnActive()
  super.OnActive(self)
  self.isSelected_ = false
  Z.CoroUtil.create_coro_xpcall(function()
    self:initTemplateItem()
  end)()
end

function Menu_templateView:initTemplateItem()
  local rowList = {}
  for modelId, row in pairs(Z.TableMgr.GetTable("ModelHumanTableMgr").GetDatas()) do
    if row.Sex == self.faceData_.Gender and row.Model == self.faceData_.BodySize and modelId < MAX_TEMPLATE_ID then
      table.insert(rowList, row)
    end
  end
  table.sort(rowList, function(a, b)
    return a.ModelPrefabID > b.ModelPrefabID
  end)
  for i, row in ipairs(rowList) do
    local modelId = row.ModelPrefabID
    local item = self:AsyncLoadUiUnit("ui/prefabs/face/face_template_item", i, self.uiBinder.togs_content_ref)
    if item then
      item.rimg_player:SetImage("ui/textures/face/" .. row.PreviewIcon)
      item.tog.isOn = false
      item.tog.group = self.uiBinder.togs_content
      item.tog:AddListener(function(isOn)
        if isOn then
          self.isSelected_ = true
          local templateVM = Z.VMMgr.GetVM("face_template")
          templateVM.UpdateOptionDictByModelId(modelId)
          templateVM.UpdateFashionByModelId(modelId)
        end
      end)
    end
  end
end

function Menu_templateView:OnDeActive()
  if self.isSelected_ then
    local fashionZList = ZUtil.Pool.Collections.ZList_Panda_ZGame_SingleWearData.Rent()
    local equipZList = self.faceVM_.GetDefaultEquipZList(self.faceData_.Gender)
    Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.LocalAttr.EWearFashion, fashionZList)
    Z.EventMgr:Dispatch(Z.ConstValue.FaceAttrChange, Z.LocalAttr.EWearEquip, equipZList)
    fashionZList:Recycle()
    equipZList:Recycle()
  end
  self.isSelected_ = nil
  super.OnDeActive(self)
end

function Menu_templateView:IsAllowDyeing()
  return false
end

return Menu_templateView
