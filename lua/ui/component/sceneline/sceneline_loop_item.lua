local super = require("ui.component.loop_list_view_item")
local SceneLineLoopItem = class("SceneLineLoopItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function SceneLineLoopItem:ctor()
  self.sceneLineData_ = Z.DataMgr.Get("sceneline_data")
end

function SceneLineLoopItem:OnInit()
  self.parentUIView_ = self.parent.UIView
  self.nodeHeadList = {
    self.uiBinder.node_head_1,
    self.uiBinder.node_head_2,
    self.uiBinder.node_head_3,
    self.uiBinder.node_head_4
  }
end

function SceneLineLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.icon_state:ChangeStateByKey(self:getIconStateKey(data.status))
  local param = {
    val = data.lineId
  }
  if data.status == E.SceneLineState.SceneLineStatusRecycle then
    self.uiBinder.lab_line_num.text = Lang("LineRecycleNote", param)
  else
    self.uiBinder.lab_line_num.text = Lang("Line", param)
  end
  self:refreshTeamPlayerPortrait()
  self:refreshSelectedUI()
end

function SceneLineLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  if isSelected then
    self.parentUIView_:OnSceneLineSelect(curData)
  end
  self:refreshSelectedUI()
end

function SceneLineLoopItem:OnUnInit()
end

function SceneLineLoopItem:getIconStateKey(status)
  if status == E.SceneLineState.SceneLineStatusLow or status == E.SceneLineState.SceneLineStatusMedium then
    return "Green"
  elseif status == E.SceneLineState.SceneLineStatusHigh then
    return "Orange"
  elseif status == E.SceneLineState.SceneLineStatusFull then
    return "Red"
  elseif status == E.SceneLineState.SceneLineStatusRecycle then
    return "Gray"
  end
end

function SceneLineLoopItem:refreshTeamPlayerPortrait()
  if self.sceneLineData_.SocialDataBySceneGuidDict == nil then
    return
  end
  local socialDataList = self.sceneLineData_.SocialDataBySceneGuidDict[self.data_.sceneGuid]
  for index, node_head in ipairs(self.nodeHeadList) do
    if socialDataList == nil then
      node_head.Ref.UIComp:SetVisible(false)
    else
      local socialData = socialDataList[index]
      if socialData then
        playerPortraitHgr.InsertNewPortraitBySocialData(self.nodeHeadList[index], socialData, function()
          local idCardVM = Z.VMMgr.GetVM("idcard")
          idCardVM.AsyncGetCardData(socialData.basicData.charID, self.parentUIView_.cancelSource:CreateToken())
        end, self.parentUIView_.cancelSource:CreateToken())
        node_head.Ref.UIComp:SetVisible(true)
      else
        node_head.Ref.UIComp:SetVisible(false)
      end
    end
  end
end

function SceneLineLoopItem:refreshSelectedUI(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

return SceneLineLoopItem
