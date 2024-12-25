local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_share_illustrate_windowView = class("Fishing_share_illustrate_windowView", super)

function Fishing_share_illustrate_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_share_illustrate_window")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function Fishing_share_illustrate_windowView:OnActive()
  self.uiBinder.presscheck:StopCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      Z.UIMgr:CloseView("fishing_share_illustrate_window")
    end
  end, nil, nil)
end

function Fishing_share_illustrate_windowView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Fishing_share_illustrate_windowView:OnRefresh()
  self.uiBinder.presscheck:StartCheck()
  local showData = self.viewData
  local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(showData.FishId)
  if fishCfg then
    self.uiBinder.rimg_icon:SetImage(fishCfg.FishingIcon)
    local star = self.fishingData_.GetStarBySize(showData.Size, fishCfg)
    self:updateStarUI(star)
    self.uiBinder.lab_fishname.text = fishCfg.Name
    local fishTypeCfg = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(fishCfg.Type)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_size, fishTypeCfg and fishTypeCfg.Infoshow == 1)
    self.uiBinder.lab_size.text = showData.Size
    self.uiBinder.lab_name.text = Lang("FishingOwner") .. showData.OwnerName
    if fishCfg.Quality == E.FishingQuality.Normal then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedNormal")
    elseif fishCfg.Quality == E.FishingQuality.Rare then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedRare")
    elseif fishCfg.Quality == E.FishingQuality.Myth then
      self.uiBinder.lab_rarity.text = Lang("FishingIllustratedMyth")
    end
    self.uiBinder.img_quality:SetImage(self.fishingData_.IllQualityPathDict_[fishCfg.Quality])
  end
  self.uiBinder.ring_panel:UpdatePosition(showData.parent, true, false, false)
end

function Fishing_share_illustrate_windowView:updateStarUI(star)
  self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_01, 1 <= star)
  self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_02, 2 <= star)
  self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_03, 3 <= star)
  self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_04, 4 <= star)
  self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_05, 5 <= star)
end

return Fishing_share_illustrate_windowView
