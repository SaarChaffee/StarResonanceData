local UI = Z.UI
local super = require("ui.ui_subview_base")
local Team_head_tips_windowView = class("Team_head_tips_windowView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local MAX_SHOW_NAME_LENGTH = 9

function Team_head_tips_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "team_head_tips_window", "team/team_head_tips_window", UI.ECacheLv.None)
  self.idCardShowList_ = {}
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.vm = Z.VMMgr.GetVM("team")
  self.entityVM_ = Z.VMMgr.GetVM("entity")
end

function Team_head_tips_windowView:OnActive()
  self:intiComp()
  self:bindEvents()
end

function Team_head_tips_windowView:intiComp()
  self.node_head = self.uiBinder.node_head
  self.prefab_cache_ = self.uiBinder.prefab_cache
end

function Team_head_tips_windowView:OnDeActive()
  self:removeIdCard()
end

function Team_head_tips_windowView:OnRefresh()
end

function Team_head_tips_windowView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.RefreshIdCard, self.refreshIdCard, self)
end

function Team_head_tips_windowView:refreshIdCard(recvCharIdList)
  local charIdList = recvCharIdList
  if not charIdList or charIdList.count == 0 then
    self:removeIdCard()
    return
  end
  local itemPath = self.prefab_cache_:GetString(Z.IsPCUI and "idcard_item_pc" or "idcard_item_mobile")
  if itemPath == nil then
    return
  end
  Z.UIMgr:AddShowMouseView("team_head_tips_window_view")
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, math.max(charIdList.count, #self.idCardShowList_) do
      local uuid
      if i <= charIdList.count then
        uuid = charIdList[i - 1]
      end
      if uuid then
        local charId = self.entityVM_.UuidToEntId(uuid)
        local isAi = self.entityVM_.CheckIsAIByEntId(charId)
        if not isAi then
          local unitName = "idCard_" .. i
          if self.idCardShowList_[i] == nil then
            self.idCardShowList_[i] = {unitName = unitName, unitGo = nil}
            self.idCardShowList_[i].unitGo = self:AsyncLoadUiUnit(itemPath, unitName, self.node_head.transform)
          end
          if self.idCardShowList_[i] and self.idCardShowList_[i].unitGo then
            local item = self.idCardShowList_[i].unitGo
            if uuid == nil then
              item.Ref.UIComp:SetVisible(false)
            else
              local ent = Z.EntityMgr.Instance:GetEntity(uuid)
              if ent then
                local name = ent:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
                if name then
                  if string.zlenNormalize(name) > MAX_SHOW_NAME_LENGTH then
                    name = self.vm.GetStringByCharCount(name, MAX_SHOW_NAME_LENGTH) .. "..."
                  end
                  local charId = self.entityVM_.UuidToEntId(uuid)
                  local rideId = ent:GetLuaRidingId()
                  item.lab_name.text = name
                  local socialData = self.socialVm_.AsyncGetSocialData(0, charId, self.cancelSource:CreateToken())
                  if socialData then
                    self:AddAsyncClick(item.btn, function()
                      if Z.UIMgr:IsActive("expression") then
                        local multActionVM = Z.VMMgr.GetVM("multaction")
                        multActionVM.SetInviteId(charId)
                      else
                        local idCardVM = Z.VMMgr.GetVM("idcard")
                        idCardVM.AsyncGetCardData(charId, self.cancelSource:CreateToken(), nil, true, rideId)
                      end
                    end)
                    playerPortraitHgr.InsertNewPortraitBySocialData(item.head, socialData, nil, self.cancelSource:CreateToken())
                  end
                  item.Ref.UIComp:SetVisible(true)
                else
                  item.Ref.UIComp:SetVisible(false)
                end
              else
                item.Ref.UIComp:SetVisible(false)
              end
            end
          end
        end
      end
    end
  end)()
end

function Team_head_tips_windowView:removeIdCard()
  for i, v in ipairs(self.idCardShowList_) do
    self:RemoveUiUnit(v.unitName)
  end
  self.idCardShowList_ = {}
  local multActionVM = Z.VMMgr.GetVM("multaction")
  multActionVM.ResetInviteId()
  Z.UIMgr:RemoveShowMouseView("team_head_tips_window_view")
end

return Team_head_tips_windowView
