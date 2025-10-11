local UI = Z.UI
local super = require("ui.ui_view_base")
local Collection_windowView = class("Collection_windowView", super)

function Collection_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "collection_window")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Collection_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_ShopWindowEnter")
  self.memberView_ = require("ui.view.collection_member_sub_view").new(self)
  self.scoreView_ = require("ui.view.collection_score_sub_view").new(self)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.CheckAndShowView(30041)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("collection_window")
  end)
  self.uiBinder.tog_integral.group = self.uiBinder.togs_tab
  self.uiBinder.tog_select.group = self.uiBinder.togs_tab
  self.uiBinder.tog_integral:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_select:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_integral:AddListener(function()
    self:switchView(self.memberView_)
    self:refreshLabName(E.FunctionID.CollectionVipLevel, self.uiBinder.lab_title, "CollectionWindowTitleFirst")
  end)
  self.uiBinder.tog_select:AddListener(function()
    self:switchView(self.scoreView_)
    self:refreshLabName(E.FunctionID.CollectionVipLevel, self.uiBinder.lab_title, "CollectionWindowTitleScore")
  end)
  self:AddClick(self.uiBinder.btn_shop, function()
    local shopVm = Z.VMMgr.GetVM("shop")
    shopVm.OpenTokenShopView()
  end)
  self.uiBinder.tog_integral.isOn = true
  self.uiBinder.lab_shop_name.text = Lang("VipShopShortName")
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FashionCollectionWindowPrivilegeRed, self, self.uiBinder.tog_integral.transform)
end

function Collection_windowView:switchView(newView)
  if self.curView_ then
    self.curView_:DeActive()
  end
  self.curView_ = newView
  self.curView_:Active({}, self.uiBinder.node_parent)
end

function Collection_windowView:OnDeActive()
  if self.curView_ then
    self.curView_:DeActive()
  end
  self.uiBinder.tog_integral.group = nil
  self.uiBinder.tog_select.group = nil
  self.uiBinder.tog_integral:RemoveAllListeners()
  self.uiBinder.tog_select:RemoveAllListeners()
  self.uiBinder.tog_integral.isOn = false
  self.uiBinder.tog_select.isOn = false
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FashionCollectionWindowPrivilegeRed, self)
end

function Collection_windowView:refreshLabName(functionId, lab, param)
  local row = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(functionId, true)
  if not row then
    return
  end
  if param then
    lab.text = Lang(param, {
      name = row.Name
    })
  else
    lab.text = row.Name
  end
end

function Collection_windowView:onPlayAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Collection_windowView
