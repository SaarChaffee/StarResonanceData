local UI = Z.UI
local super = require("ui.ui_view_base")
local Pub_talk_option_windowView = class("Pub_talk_option_windowView", super)
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local eColor = {
  green = "#D6F460",
  red = "#FD7666",
  normal = "#CDD1C7"
}
local colorRgb = {
  green = Color.New(0.8392156862745098, 0.9568627450980393, 0.3764705882352941, 1),
  red = Color.New(0.9921568627450981, 0.4627450980392157, 0.4, 1),
  whilte = Color.New(1, 1, 1, 1)
}
local npcAtlasPath = "ui/atlas/npc/"
local pupUiPath = "ui/atlas/pub/"
local LEFTITEMCOUNT = 2
local CONTSLIDERHEIGHT = 348

function Pub_talk_option_windowView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.pub_talk_option_window.PrefabPath = "pub/pub_talk_option_window_pc"
  else
    Z.UIConfig.pub_talk_option_window.PrefabPath = "pub/pub_talk_option_window"
  end
  super.ctor(self, "pub_talk_option_window")
  self.optionVM_ = Z.VMMgr.GetVM("talk_option")
  self.talkData_ = Z.DataMgr.Get("talk_data")
end

function Pub_talk_option_windowView:initWidget()
  self.layout_options_left_ = self.uiBinder.layout_options_left
  self.layout_options_right_ = self.uiBinder.layout_options_right
  self.timeBinder_ = self.uiBinder.cont_time
  self.sliderBinder_ = self.uiBinder.cont_slider
  self.prafabCache_ = self.uiBinder.prafab_cache
end

function Pub_talk_option_windowView:OnActive()
  self.units_ = {}
  self:initWidget()
  self.layout_options_left_.blocksRaycasts = true
  self.layout_options_right_.blocksRaycasts = true
  if self.viewData.Type == E.TalkOptionsType.Confrontation then
    self:initBattleContainer()
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local count = #self.viewData.optionData
    local path = self.prafabCache_:GetString("interaction_item_right")
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    if count <= LEFTITEMCOUNT then
      for i, optionData in ipairs(self.viewData.optionData) do
        local unit = self:AsyncLoadUiUnit(path, "option" .. i, self.layout_options_right_.transform)
        table.insert(self.units_, unit)
        if unit then
          unit.btn_canvas.blocksRaycasts = true
          self:initOption(unit, optionData)
        end
      end
    else
      for i, optionData in ipairs(self.viewData.optionData) do
        local unit
        if i <= LEFTITEMCOUNT then
          path = self.prafabCache_:GetString("interaction_item_left")
          if Z.IsPCUI then
            path = path .. "_pc"
          end
          unit = self:AsyncLoadUiUnit(path, "option" .. i, self.layout_options_left_.transform)
        else
          path = self.prafabCache_:GetString("interaction_item_right")
          if Z.IsPCUI then
            path = path .. "_pc"
          end
          unit = self:AsyncLoadUiUnit(path, "option" .. i, self.layout_options_right_.transform)
        end
        table.insert(self.units_, unit)
        if unit then
          unit.btn_canvas.blocksRaycasts = true
          self:initOption(unit, optionData)
        end
      end
    end
    Z.EventMgr:Dispatch("HideTalkArrowUI")
  end)()
end

function Pub_talk_option_windowView:OnDeActive()
  self.units_ = nil
  Z.EventMgr:Dispatch("HideTalkArrowUI")
end

function Pub_talk_option_windowView:initOption(unit, optionData)
  local holderParam = {}
  holderParam = Z.Placeholder.SetMePlaceholder(holderParam)
  holderParam = Z.Placeholder.SetPlayerSelfPronoun(holderParam)
  local content = Z.Placeholder.Placeholder(optionData.Content, holderParam)
  itemHelper.InitInteractionItem(unit, content)
  itemHelper.AddCommonListener(unit)
  unit.cont_key_icon.Ref.UIComp:SetVisible(false)
  if self.viewData.Type == E.TalkOptionsType.Confrontation and optionData.Type == Z.EPFlowConfrontationType.Neutral and self.talkData_:GetNeutral(optionData.Id, optionData.Index) then
    unit.img_bg_off:SetImage(npcAtlasPath .. "talk_btn_bg_gray")
    unit.btn_canvas.blocksRaycasts = false
  end
  self:AddAsyncClick(unit.btn_interaction, function()
    self.isCutdown_ = false
    if self.viewData.Type == E.TalkOptionsType.Confrontation then
      self.layout_options_left_.blocksRaycasts = false
      self.layout_options_right_.blocksRaycasts = false
      if optionData.Type == Z.EPFlowConfrontationType.Neutral then
        self.talkData_:SelectedNeutral(optionData.Id, optionData.Index)
        self:addConsiderTime(unit, optionData)
      elseif optionData.Type == Z.EPFlowConfrontationType.Correct then
        self:changeTrust(unit, optionData.TrustValue, optionData)
      elseif optionData.Type == Z.EPFlowConfrontationType.Wrong then
        self:changeTrust(unit, -optionData.TrustValue, optionData)
      end
    else
      optionData.Func()
    end
  end)
end

function Pub_talk_option_windowView:initBattleContainer()
  self.isCutdown_ = true
  self.timeBinder_.Ref.UIComp:SetVisible(true)
  self.sliderBinder_.Ref.UIComp:SetVisible(true)
  self.timeBinder_.Ref:SetVisible(self.timeBinder_.lab_add_time, false)
  self.sliderImg_ = self.sliderBinder_.img_slider
  self.sliderImg_.fillAmount = self.talkData_.TrustValue / 100
  self.sliderBinder_.rect_slider:SetHeight(CONTSLIDERHEIGHT * self.sliderImg_.fillAmount)
  self:setContSliderColor(colorRgb.whilte)
  self:initContTime()
  self:lightMoveSlider()
  self.timerMgr:StartTimer(function()
    if self.isCutdown_ == false then
      return
    end
    if self.talkData_.TimeValue > 0 then
      self.timeBinder_.img_slider.fillAmount = self.timeBinder_.img_slider.fillAmount - self.ratio
      self.talkData_:ChangeTimeValue(-1)
      local str = self.talkData_.TimeValue
      if self.talkData_.TimeValue == 3 then
        self.timeBinder_.img_slider:SetColor(colorRgb.red)
        str = string.format("<color=%s>%s</color>", eColor.red, self.talkData_.TimeValue)
        self.timeBinder_.img_num_bg:SetImage(pupUiPath .. "pub_icon_time_red")
      end
      if self.talkData_.TimeValue < 3 then
        str = string.format("<color=%s>%s</color>", eColor.red, self.talkData_.TimeValue)
      end
      if self.talkData_.TimeValue == 0 then
        self:timeOutRandomSelected()
      end
      self.timeBinder_.lab_num.text = str
    end
  end, 1, -1)
end

function Pub_talk_option_windowView:cut()
end

function Pub_talk_option_windowView:timeOutRandomSelected()
  self.layout_options_left_.blocksRaycasts = false
  self.layout_options_right_.blocksRaycasts = false
  for _, item in pairs(self.units_) do
    item.img_bg_off:SetImage(npcAtlasPath .. "talk_btn_bg_red")
  end
  local opetionData = self.viewData.optionData[1]
  local index = 1
  for i = 2, table.zcount(self.viewData.optionData) do
    if self.viewData.optionData[i].Type == Z.EPFlowConfrontationType.Wrong then
      if opetionData.Type == Z.EPFlowConfrontationType.Neutral or opetionData.Type == Z.EPFlowConfrontationType.Correct then
        opetionData = self.viewData.optionData[i]
        index = i
      elseif opetionData.TrustValue < self.viewData.optionData[i].TrustValue then
        opetionData = self.viewData.optionData[i]
        index = i
      end
    end
  end
  self:changeTrust(self.units_[index], -opetionData.TrustValue, opetionData)
end

function Pub_talk_option_windowView:setContSliderColor(color)
  self.sliderImg_:SetColor(color)
  self.sliderBinder_.img_icon:SetColor(color)
  if color == colorRgb.whilte then
    self.sliderBinder_.img_icon_bg:SetImage(pupUiPath .. "pub_bg_white")
    self.sliderBinder_.img_slider_top_light:SetImage(pupUiPath .. "pub_icon_white")
  elseif color == colorRgb.green then
    self.sliderBinder_.img_icon_bg:SetImage(pupUiPath .. "pub_bg_green")
    self.sliderBinder_.img_slider_top_light:SetImage(pupUiPath .. "pub_icon_green")
  elseif color == colorRgb.red then
    self.sliderBinder_.img_icon_bg:SetImage(pupUiPath .. "pub_bg_red")
    self.sliderBinder_.img_slider_top_light:SetImage(pupUiPath .. "pub_icon_red")
  end
end

function Pub_talk_option_windowView:initContTime()
  self.timeBinder_.img_num_bg:SetImage(pupUiPath .. "pub_icon_time_green")
  self.timeBinder_.lab_num.text = self.talkData_.TimeValue
  self.timeBinder_.img_slider.fillAmount = 1
  self.ratio = 1 / self.talkData_.TimeValue
  self.timeBinder_.img_slider:SetColor(colorRgb.green)
end

function Pub_talk_option_windowView:lightMoveSlider()
  local sliderHigt = self.sliderBinder_.rect_slider.rect.height
  local sliderPosY = self.sliderBinder_.rect_slider.anchoredPosition.y
  local lightHigt = self.sliderBinder_.rect_slider_top_light.rect.height
  local lightX = self.sliderBinder_.rect_slider_top_light.anchoredPosition.x
  local posY = sliderHigt + sliderPosY + lightHigt / 2 - 20
  self.sliderBinder_.rect_slider_top_light.localPosition = Vector3.New(lightX, posY, 0)
end

function Pub_talk_option_windowView:changeTrust(unit, trustValue, optionData)
  local isFail = false
  self.talkData_:InitTimeValue()
  if self.talkData_.TrustValue + trustValue > 100 then
    trustValue = 100 - self.talkData_.TrustValue
  end
  if self.talkData_.TrustValue + trustValue <= 0 then
    trustValue = -self.talkData_.TrustValue
    isFail = true
  end
  if trustValue == 0 and optionData.Func then
    optionData.Func()
    return
  end
  self.talkData_:ChangeTrustValue(trustValue)
  if trustValue < 0 then
    self:setContSliderColor(colorRgb.red)
    if unit then
      unit.img_bg_off:SetImage(npcAtlasPath .. "talk_btn_bg_red")
    end
  end
  if 0 < trustValue then
    if unit then
      unit.img_bg_off:SetImage(npcAtlasPath .. "talk_btn_bg_on")
    end
    self:setContSliderColor(colorRgb.green)
  end
  local loopCount = math.abs(trustValue)
  self.timerMgr:StartTimer(function()
    self.sliderImg_.fillAmount = self.sliderImg_.fillAmount + trustValue / math.abs(trustValue) / 100
    self.sliderBinder_.rect_slider:SetHeight(CONTSLIDERHEIGHT * self.sliderImg_.fillAmount)
    self:lightMoveSlider()
    loopCount = loopCount - 1
    if loopCount == 0 then
      Z.CoroUtil.create_coro_xpcall(function()
        self.layout_options_left_.blocksRaycasts = true
        self.layout_options_right_.blocksRaycasts = true
        if isFail then
          self.optionVM_.StartFailFlow(Z.EPFlowEventType.Confrontation, optionData.FailNodeName)
        elseif optionData.Func then
          optionData.Func()
        end
      end)()
    end
  end, 0.5 / math.abs(trustValue), math.abs(trustValue), nil, function()
  end)
end

function Pub_talk_option_windowView:addConsiderTime(unit, optionData)
  local time = optionData.TimeValue
  unit.img_bg_off:SetImage(npcAtlasPath .. "talk_btn_bg_gray")
  unit.btn_canvas.blocksRaycasts = false
  self.timeBinder_.lab_add_time.text = "+" .. time .. Lang("EquipSecondsText")
  self.timeBinder_.Ref:SetVisible(self.timeBinder_.lab_add_time, true)
  self.talkData_:ChangeTimeValue(time)
  self:initContTime()
  self.timerMgr:StartTimer(function()
    self.layout_options_left_.blocksRaycasts = true
    self.layout_options_right_.blocksRaycasts = true
    self.timeBinder_.Ref:SetVisible(self.timeBinder_.lab_add_time, false)
    optionData.Func()
  end, 0.5, 1)
end

function Pub_talk_option_windowView:OnRefresh()
end

return Pub_talk_option_windowView
