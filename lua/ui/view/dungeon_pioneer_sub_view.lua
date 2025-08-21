local UI = Z.UI
local super = require("ui.ui_subview_base")
local Dungeon_pioneer_subView = class("Dungeon_pioneer_subView", super)
local loopListView = require("ui/component/loopscrollrect")
local loopItem = require("ui.component.dungeon.dungeon_condition_item")

function Dungeon_pioneer_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "dungeon_pioneer_sub", "dungeon/dungeon_pioneer_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.dungeonData_ = Z.DataMgr.Get("dungeon_data")
end

function Dungeon_pioneer_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.parent_:CloseRightSubView()
  end)
  self:initData()
end

function Dungeon_pioneer_subView:OnDeActive()
  Z.CommonTipsVM.CloseTitleContentItems()
end

function Dungeon_pioneer_subView:OnRefresh()
  self.dungeonId_ = Z.StageMgr.GetCurrentDungeonId()
  if self.dungeonId_ and self.dungeonId_ ~= 0 then
    self.dungeonConfig_ = self.dungeonData_:GetDungeonIntroductionById(self.dungeonId_)
    self:refreshWidthTask()
    self:refreshBoxItems()
    self:refreshDungeonIntroduction()
  end
end

function Dungeon_pioneer_subView:initData()
  self.tipsId_ = nil
  self.dungeonId_ = nil
  self.exploreValue_ = 0
  self.dungeonConfig_ = nil
  self.loop_ = loopListView.new(self.uiBinder.loop_item, self, loopItem)
end

function Dungeon_pioneer_subView:showUI(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_pioneer, isShow)
end

function Dungeon_pioneer_subView:refreshDungeonIntroduction()
  self.uiBinder.lab_title.text = self.dungeonConfig_.name
  self.uiBinder.lab_progress.text = self.exploreValue_
  self.uiBinder.slider.value = self.exploreValue_ * 0.01
end

function Dungeon_pioneer_subView:refreshBoxItems()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
    local width = self.uiBinder.rect_slider:GetSizeDelta(nil, nil)
    local data = self.dungeonData_:GetChestIntroductionById(self.dungeonId_)
    local pioneerInfo = self.dungeonData_.PioneerInfos[self.dungeonId_]
    for index, item in ipairs(data) do
      local boxItem = self.uiBinder["box_" .. index]
      if boxItem then
        do
          local posX = width * item.preValue * 0.01
          boxItem.Trans:SetAnchorPosition(posX, 0)
          boxItem.lab_percentage.text = string.format("%d%%", item.preValue)
          local chestStateTpe = E.ChestStateTpe.NotOpen
          if self.exploreValue_ >= item.preValue then
            chestStateTpe = E.ChestStateTpe.CanOpen
          end
          if pioneerInfo.awards[item.rewardId] then
            chestStateTpe = E.ChestStateTpe.AlreadyOpen
          end
          if chestStateTpe == E.ChestStateTpe.NotOpen then
            boxItem.Ref:SetVisible(boxItem.img_progress_off, true)
            boxItem.Ref:SetVisible(boxItem.img_progress_on, false)
            boxItem.Ref:SetVisible(boxItem.img_on, true)
            boxItem.Ref:SetVisible(boxItem.img_light, false)
            boxItem.Ref:SetVisible(boxItem.img_off, false)
          elseif chestStateTpe == E.ChestStateTpe.CanOpen then
            boxItem.Ref:SetVisible(boxItem.img_progress_off, false)
            boxItem.Ref:SetVisible(boxItem.img_progress_on, true)
            boxItem.Ref:SetVisible(boxItem.img_on, true)
            boxItem.Ref:SetVisible(boxItem.img_light, true)
            boxItem.Ref:SetVisible(boxItem.img_off, false)
          elseif chestStateTpe == E.ChestStateTpe.AlreadyOpen then
            boxItem.Ref:SetVisible(boxItem.img_progress_off, false)
            boxItem.Ref:SetVisible(boxItem.img_progress_on, true)
            boxItem.Ref:SetVisible(boxItem.img_on, false)
            boxItem.Ref:SetVisible(boxItem.img_light, false)
            boxItem.Ref:SetVisible(boxItem.img_off, true)
          end
          boxItem.btn_treasure:AddListener(function()
            if chestStateTpe == E.ChestStateTpe.CanOpen then
              Z.CoroUtil.create_coro_xpcall(function()
                local dungeonInfo = {}
                dungeonInfo.dungeonID = self.dungeonId_
                local reply = Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncSendPioneerAward(dungeonInfo, item.rewardId, self.cancelSource)
                if reply then
                  boxItem.Ref:SetVisible(boxItem.img_progress_on, true)
                  boxItem.Ref:SetVisible(boxItem.img_on, false)
                  boxItem.Ref:SetVisible(boxItem.img_light, false)
                  boxItem.Ref:SetVisible(boxItem.img_off, true)
                end
              end)()
            elseif chestStateTpe == E.ChestStateTpe.NotOpen then
              local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(item.rewardId)
              self:chestItemShow(awardList, item.preValue, boxItem.Trans)
            end
          end)
        end
      end
    end
  end)()
end

function Dungeon_pioneer_subView:chestItemShow(awardDataList, preValue, trans)
  local titleLang = string.format("%s%d%%", Lang("ExploreBox"), preValue)
  Z.CommonTipsVM.OpenTitleContentItems(trans, titleLang, Lang("ExploreAwardTip"), awardDataList)
end

function Dungeon_pioneer_subView:refreshWidthTask()
  Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(self.dungeonId_)
  local pioneerInfo = self.dungeonData_.PioneerInfos[self.dungeonId_]
  local pioneerData = pioneerInfo.pioneerData
  local tempDatas = {}
  for _, v in ipairs(pioneerData) do
    table.insert(tempDatas, v)
  end
  Z.VMMgr.GetVM("ui_enterdungeonscene").ShowPioneerTaskSort(tempDatas, self.dungeonId_)
  self.exploreValue_ = pioneerInfo.progress
  self.loop_:SetData(pioneerData)
end

return Dungeon_pioneer_subView
