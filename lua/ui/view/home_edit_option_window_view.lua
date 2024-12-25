local UI = Z.UI
local super = require("ui.ui_view_base")
local Home_edit_option_windowView = class("Home_edit_option_windowView", super)
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local path = "ui/prefabs/interaction/interaction_item_tpl"

function Home_edit_option_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "home_edit_option_window")
  self.vm_ = Z.VMMgr.GetVM("home")
end

function Home_edit_option_windowView:initBinders()
  self.optionsParent = self.uiBinder.layout_options_right
  self.closeBtn_ = self.uiBinder.btn_close
end

function Home_edit_option_windowView:OnActive()
  self:initBinders()
  if self.viewData == nil or #self.viewData == 0 then
    self.vm_.CloseOptionView()
  end
  self:AddClick(self.closeBtn_, function()
    self.vm_.CloseOptionView()
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(self.viewData) do
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.configId)
      if itemRow then
        local unit = self:AsyncLoadUiUnit(path, value.entityId, self.optionsParent.transform)
        if unit then
          local itemsVM = Z.VMMgr.GetVM("items")
          itemHelper.InitInteractionItem(unit, itemRow.Name, itemsVM.GetItemIcon(value.configId))
          itemHelper.AddCommonListener(unit)
          self:AddClick(unit.btn_interaction, function()
            local enitityId = value.entityId
            Z.DIServiceMgr.HomeService:SelectEntity(enitityId, false)
            Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelectingSingle, enitityId, value.configId)
            self.vm_.CloseOptionView()
          end)
        end
      end
    end
  end)()
end

function Home_edit_option_windowView:OnDeActive()
end

function Home_edit_option_windowView:OnRefresh()
end

return Home_edit_option_windowView
