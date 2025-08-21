local UI = Z.UI
local super = require("ui.ui_subview_base")
local Life_metarial_preview_subView = class("Life_metarial_preview_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local comRewardItem = require("ui.component.common_reward_grid_list_item")

function Life_metarial_preview_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "life_metarial_preview_sub", "life_profession/life_metarial_preview_sub", UI.ECacheLv.None)
end

function Life_metarial_preview_subView:OnActive()
  self.press = self.uiBinder.press
  self.gridViewRect_ = self.uiBinder.grid_view
  self:EventAddAsyncListener(self.press.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
  self.gridViewLoop_ = loopGridView.new(self, self.gridViewRect_, comRewardItem, "com_item_square_8")
  self.gridViewLoop_:Init(self.viewData.data)
end

function Life_metarial_preview_subView:OnDeActive()
  self.press:StopCheck()
  if self.gridViewLoop_ then
    self.gridViewLoop_:UnInit()
  end
end

function Life_metarial_preview_subView:OnRefresh()
  self.press:StartCheck()
end

return Life_metarial_preview_subView
