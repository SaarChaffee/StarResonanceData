local UI = Z.UI
local super = require("ui.ui_subview_base")
local Collection_member_subView = class("Collection_member_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local privilege_item = require("ui.component.fashion.fashion_privilege_item")

function Collection_member_subView:ctor(parent)
  self.uiBinder = nil
  self.parentNode_ = parent
  super.ctor(self, "collection_member_sub", "collection/collection_member_sub", UI.ECacheLv.None)
end

function Collection_member_subView:OnActive()
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_score.node_eff)
  self:onStartAnimShow()
  self.privilegeList_ = loopGridView.new(self, self.uiBinder.loop_item, privilege_item, "collection_item_tpl")
  self.privilegeList_:Init({})
  self:AddClick(self.uiBinder.btn_left, function()
    if self.curLevel_ <= 1 then
      return
    end
    self.curLevel_ = self.curLevel_ - 1
    self:refreshCurLevelInfo()
  end)
  self:AddClick(self.uiBinder.btn_right, function()
    if self.curLevel_ >= self.maxLevel_ then
      return
    end
    self.curLevel_ = self.curLevel_ + 1
    self:refreshCurLevelInfo()
  end)
  self:refreshViewData()
  self:bindEvent()
end

function Collection_member_subView:OnDeActive()
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_score.node_eff)
  self.uiBinder.node_score.node_eff:SetEffectGoVisible(false)
  self.privilegeList_:UnInit()
  self:unBindEvent()
end

function Collection_member_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
end

function Collection_member_subView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
end

function Collection_member_subView:refreshViewData()
  self.maxLevel_, self.levelList_ = Z.CollectionScoreHelper.RefreshCollectionScoreSlider(self.uiBinder.node_score)
  self.curLevel_ = Z.CollectionScoreHelper.GetCollectionCurLevel()
  self.activeLevel_ = Z.CollectionScoreHelper.GetCollectionCurLevel()
  self:refreshCurLevelInfo()
end

function Collection_member_subView:refreshCurLevelInfo()
  Z.CollectionScoreHelper.RefreshCollectionScoreLevel(self.uiBinder.node_score, self.curLevel_)
  self:refreshBtnState()
  self:refreshPrivilegeList()
end

function Collection_member_subView:refreshPrivilegeList()
  local privilegeList = {}
  for i = 1, #self.levelList_ do
    local row = self.levelList_[i]
    for j = 1, #row.Privilege do
      privilegeList[#privilegeList + 1] = {
        privilegeId = row.Privilege[j],
        unlock = self.curLevel_ >= row.Id
      }
    end
  end
  self.privilegeShowList_ = {}
  local tempDict = {}
  for i = 1, #privilegeList do
    local privilegeRow = Z.TableMgr.GetTable("FashionPrivilegeTableMgr").GetRow(privilegeList[i].privilegeId, true)
    if privilegeRow then
      local info = {
        row = privilegeRow,
        unlock = privilegeList[i].unlock
      }
      local count = #self.privilegeShowList_
      if tempDict[privilegeRow.Type] == nil then
        local index = count + 1
        tempDict[privilegeRow.Type] = index
        self.privilegeShowList_[index] = info
      elseif privilegeList[i].unlock then
        local tempIndex = tempDict[privilegeRow.Type]
        self.privilegeShowList_[tempIndex] = info
      end
    end
  end
  self.privilegeList_:RefreshListView(self.privilegeShowList_, false)
end

function Collection_member_subView:refreshBtnState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_left, self.curLevel_ > 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_right, self.curLevel_ < self.maxLevel_)
end

function Collection_member_subView:OnSelectPrivilege(row)
  Z.UIMgr:OpenView("collection_membership_popup", {
    row = row,
    list = self.privilegeShowList_
  })
end

function Collection_member_subView:onStartAnimShow()
  self.uiBinder.node_score.node_eff:SetEffectGoVisible(true)
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Collection_member_subView
