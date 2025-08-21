local CommonFilterHelper = class("CommonFilterHelper")
local common_filter_subView = require("ui/view/common_filter_sub_view")
local filter_type_eliminate_tipsView = require("ui/view/filter_type_eliminate_tips_view")

function CommonFilterHelper:ctor(parent)
  self.filterSubView_ = common_filter_subView.new(self)
  self.eliminateTips_ = filter_type_eliminate_tipsView.new(self)
  self.filterSubParent_ = nil
  self.eliminateParent_ = nil
  self.title_ = ""
  self.filterTypes_ = {}
  self.certainFunc_ = nil
end

function CommonFilterHelper:Init(title, filterTypes, filterSubParent, eliminateParent, certainFunc)
  self.title_ = title
  self.filterTypes_ = filterTypes
  self.filterSubParent_ = filterSubParent
  self.eliminateParent_ = eliminateParent
  self.certainFunc_ = certainFunc
end

function CommonFilterHelper:ActiveFilterSub(viewData)
  local subViewData = {
    title = self.title_,
    filterTypes = viewData.filterTypes or self.filterTypes_,
    filterRes = viewData.filterRes,
    filterFunc = function(filterRes)
      self:certain(filterRes)
    end,
    closeFunc = function()
      if viewData.closeFunc then
        viewData.closeFunc()
      end
      self.filterSubView_:DeActive()
    end,
    clearFunc = function()
      self:clear()
    end
  }
  if self.filterSubView_.IsActive then
    self.filterSubView_:DeActive()
  end
  self.filterSubView_:Active(subViewData, self.filterSubParent_)
end

function CommonFilterHelper:ActiveEliminateSub(filterRes)
  if filterRes == nil then
    return
  end
  local count = 0
  for _, data in pairs(filterRes) do
    if data.value then
      for _, value in pairs(data.value) do
        if value then
          count = count + 1
        end
      end
    end
  end
  if 0 < count then
    local eliminateViewData = {
      filterRes = filterRes,
      clearFunc = function()
        self:clear()
      end
    }
    self.eliminateTips_:Active(eliminateViewData, self.eliminateParent_)
  else
    self.eliminateTips_:DeActive()
  end
end

function CommonFilterHelper:DeActive()
  self.filterSubView_:DeActive()
  self.eliminateTips_:DeActive()
end

function CommonFilterHelper:certain(filterRes)
  if self.certainFunc_ then
    self.certainFunc_(filterRes)
  end
  self:ActiveEliminateSub(filterRes)
end

function CommonFilterHelper:clear()
  if self.filterSubView_.IsActive then
    self.filterSubView_:ClearFilter(true)
  else
    self.filterSubView_:ClearFilter()
  end
  self.eliminateTips_:DeActive()
  if self.certainFunc_ then
    self.certainFunc_({})
  end
end

return CommonFilterHelper
