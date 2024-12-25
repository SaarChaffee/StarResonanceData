local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_starlevel_popupView = class("Season_starlevel_popupView", super)

function Season_starlevel_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_starlevel_popup")
  self.seasonTitleData_ = Z.DataMgr.Get("season_title_data")
end

function Season_starlevel_popupView:OnActive()
  self.uiBinder.cont_bg_scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("season_starlevel_popup")
  end)
  self:initBinder()
  self.uiBinder.effect_uprank:SetEffectGoVisible(false)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_uprank)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_1)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_2)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_3)
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  if self.viewData and self.viewData.lastSeasonRankStar and self.viewData.curSeasonRankStar then
    local lastRankConfig = seasonRankTableMgr.GetRow(self.viewData.lastSeasonRankStar)
    local curRankConfig = seasonRankTableMgr.GetRow(self.viewData.curSeasonRankStar)
    self.uiBinder.lab_name.text = lastRankConfig.Name
    self.uiBinder.rimg_icon:SetImage(lastRankConfig.IconBig)
    local allConfigs = self.seasonTitleData_:GetAllConfigs()
    if allConfigs[lastRankConfig.RankId] then
      if #allConfigs[lastRankConfig.RankId] <= #self.node_stars_ then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_star_high, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.layout_star, true)
        for key, value in ipairs(self.node_stars_) do
          if key <= lastRankConfig.StarLevel then
            value.Ref:SetVisible(value.img_star_on, true)
            value.Ref:SetVisible(value.img_star_light, true)
          else
            value.Ref:SetVisible(value.img_star_on, false)
            value.Ref:SetVisible(value.img_star_light, false)
          end
          value.Ref:SetVisible(value.effect, false)
        end
        for key, value in ipairs(self.node_stars_) do
          if key <= #allConfigs[lastRankConfig.RankId] then
            value.Ref.UIComp:SetVisible(true)
          else
            value.Ref.UIComp:SetVisible(false)
          end
        end
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_star_high, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.layout_star, false)
        self.uiBinder.lab_star_num.text = "x" .. lastRankConfig.StarLevel
      end
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
      asyncCall(self.uiBinder.anim, "anim_season_starlevel_popup", self.cancelSource:CreateToken())
      if lastRankConfig and curRankConfig then
        if curRankConfig.RankId ~= lastRankConfig.RankId then
          if #allConfigs[curRankConfig.RankId] <= #self.node_stars_ then
            self:diffRankStarUpAnimPlay()
          else
            self:diffRankToMaxRankStarUpAnimPlay()
          end
        elseif #allConfigs[curRankConfig.RankId] <= #self.node_stars_ then
          self:sameRankStarUpAnimPlay(lastRankConfig.StarLevel, curRankConfig.StarLevel)
        else
          self:sameRankMaxRankStarUpAnimPlay(curRankConfig.StarLevel)
        end
      end
    end)()
  end
end

function Season_starlevel_popupView:OnDeActive()
  for _, value in ipairs(self.node_stars_) do
    value.Ref:SetVisible(value.img_star_on, false)
    value.Ref:SetVisible(value.img_star_light, false)
    value.Ref:SetVisible(value.effect, false)
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(value.effect)
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_uprank)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_1)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_2)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_3)
  local configs = self.seasonTitleData_:GetAllRankConfigList()
  local itemCount = 0
  local isStartCal = false
  for _, config in ipairs(configs) do
    if isStartCal then
      itemCount = itemCount + config.EchoPoints[1][2]
    end
    if config.Id == self.viewData.lastSeasonRankStar then
      isStartCal = true
    end
    if config.Id == self.viewData.curSeasonRankStar then
      isStartCal = false
    end
  end
  Z.UIMgr:OpenView("season_energy_window", {num = itemCount})
end

function Season_starlevel_popupView:OnRefresh()
end

function Season_starlevel_popupView:initBinder()
  self.node_stars_ = {
    [1] = self.uiBinder.node_star_1,
    [2] = self.uiBinder.node_star_2,
    [3] = self.uiBinder.node_star_3,
    [4] = self.uiBinder.node_star_4,
    [5] = self.uiBinder.node_star_5
  }
  for _, value in ipairs(self.node_stars_) do
    value.Ref:SetVisible(value.img_star_on, false)
    value.Ref:SetVisible(value.img_star_light, false)
    value.Ref:SetVisible(value.effect, false)
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(value.effect)
  end
end

function Season_starlevel_popupView:starToMax()
  local lastRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(self.viewData.lastSeasonRankStar)
  local allConfigs = self.seasonTitleData_:GetAllConfigs()
  local lastMaxRankStar = #allConfigs[lastRankConfig.RankId]
  for key, value in ipairs(self.node_stars_) do
    if key > lastRankConfig.StarLevel and key <= lastMaxRankStar then
      local asyncCall = Z.CoroUtil.async_to_sync(value.anim.CoroPlayOnce)
      asyncCall(value.anim, "anim_season_star_tpl_open_02", self.cancelSource:CreateToken())
      value.Ref:SetVisible(value.img_star_on, true)
      value.Ref:SetVisible(value.img_star_light, true)
      value.Ref:SetVisible(value.effect, true)
    end
  end
end

function Season_starlevel_popupView:diffRankStarUpAnimPlay()
  Z.AudioMgr:Play("UI_Event_NameSuccess")
  self:starToMax()
  self.uiBinder.effect_uprank:SetEffectGoVisible(true)
  local curRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(self.viewData.curSeasonRankStar)
  self.uiBinder.lab_name.text = curRankConfig.Name
  self.uiBinder.rimg_icon:SetImage(curRankConfig.IconBig)
  local allConfigs = self.seasonTitleData_:GetAllConfigs()
  if allConfigs[curRankConfig.RankId] then
    for key, value in ipairs(self.node_stars_) do
      value.Ref:SetVisible(value.img_star_on, false)
      value.Ref:SetVisible(value.img_star_light, false)
      value.Ref:SetVisible(value.effect, false)
      if key <= #allConfigs[curRankConfig.RankId] then
        value.Ref.UIComp:SetVisible(true)
      else
        value.Ref.UIComp:SetVisible(false)
      end
    end
    for key, value in ipairs(self.node_stars_) do
      if key <= curRankConfig.StarLevel then
        local asyncCall = Z.CoroUtil.async_to_sync(value.anim.CoroPlayOnce)
        asyncCall(value.anim, "anim_season_star_tpl_open_02", self.cancelSource:CreateToken())
        value.Ref:SetVisible(value.img_star_on, true)
        value.Ref:SetVisible(value.img_star_light, true)
        value.Ref:SetVisible(value.effect, true)
      end
    end
  end
end

function Season_starlevel_popupView:diffRankToMaxRankStarUpAnimPlay()
  Z.AudioMgr:Play("UI_Event_NameSuccess")
  self:starToMax()
  self.uiBinder.effect_uprank:SetEffectGoVisible(true)
  local curRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(self.viewData.curSeasonRankStar)
  self.uiBinder.lab_name.text = curRankConfig.Name
  self.uiBinder.rimg_icon:SetImage(curRankConfig.IconBig)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_star_high, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_star, false)
  self.uiBinder.lab_star_num.text = "x" .. curRankConfig.StarLevel
  local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
  asyncCall(self.uiBinder.anim, "anim_season_starlevel_popup_star", self.cancelSource:CreateToken())
end

function Season_starlevel_popupView:sameRankStarUpAnimPlay(startStar, endStar)
  Z.AudioMgr:Play("UI_Event_NameSuccess")
  for key, value in ipairs(self.node_stars_) do
    if startStar < key and key <= endStar then
      local asyncCall = Z.CoroUtil.async_to_sync(value.anim.CoroPlayOnce)
      asyncCall(value.anim, "anim_season_star_tpl_open_02", self.cancelSource:CreateToken())
    end
  end
end

function Season_starlevel_popupView:sameRankMaxRankStarUpAnimPlay(starLevel)
  Z.AudioMgr:Play("UI_Event_NameSuccess")
  self.uiBinder.lab_star_num.text = "x" .. starLevel
  local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
  asyncCall(self.uiBinder.anim, "anim_season_starlevel_popup_star", self.cancelSource:CreateToken())
end

return Season_starlevel_popupView
