local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_unlock_windowView = class("Life_profession_unlock_windowView", super)

function Life_profession_unlock_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_unlock_window")
  self.lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
end

function Life_profession_unlock_windowView:OnActive()
  self.professionID = self.viewData.professionID
  self:bindBtnClick()
  self:refreshView()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
end

function Life_profession_unlock_windowView:bindBtnClick()
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self.lifeProfessionVM.AsyncRequestUnlockLifeProfession(self.professionID, self.cancelSource:CreateToken())
    self.lifeProfessionVM.CloseUnlockProfessionWindow()
  end)
  self:AddClick(self.uiBinder.btn_no, function()
    self.lifeProfessionVM.CloseUnlockProfessionWindow()
  end)
end

function Life_profession_unlock_windowView:refreshView()
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.professionID)
  if lifeProfessionTableRow == nil then
    return
  end
  self.uiBinder.rimg_pic:SetImage(lifeProfessionTableRow.BgPic)
  self.uiBinder.lab_sys_name.text = lifeProfessionTableRow.Name
  self.uiBinder.img_icon:SetImage(lifeProfessionTableRow.Icon)
  self.uiBinder.lab_content.text = Lang("LifeProfessionUnlockContent" .. self.professionID)
end

function Life_profession_unlock_windowView:OnDeActive()
end

function Life_profession_unlock_windowView:OnRefresh()
end

return Life_profession_unlock_windowView
