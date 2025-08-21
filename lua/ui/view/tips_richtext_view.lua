local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_richTextView = class("Tips_richTextView", super)
E.EUnderLineTipsType = {WithTitle = 1, NoTitle = 2}
local TextDescriptionType = {
  Normal = 1,
  SkillReplace = 2,
  AttrDescription = 3
}

function Tips_richTextView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_richtext")
end

function Tips_richTextView:OnActive()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitTips()
  end)()
end

function Tips_richTextView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Tips_richTextView:OnRefresh()
end

function Tips_richTextView:asyncInitTips()
  self.data_ = self.viewData.showTable
  self:AddClick(self.uiBinder.presscheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end)
  self.uiBinder.presscheck:StartCheck()
  local path = self.uiBinder.prefabcache_root:GetString("underLineTips")
  if path == nil or path == "" then
    return
  end
  for i = 1, #self.data_ do
    local item = self:AsyncLoadUiUnit(path, string.zconcat("underLineTipsItem", i), self.uiBinder.layout_info, self.cancelSource:CreateToken())
    if item == nil then
      return
    end
    local TableRow = self.data_[i]
    if #self.data_ == 1 then
      if TableRow.ShowRule == E.EUnderLineTipsType.NoTitle then
        self.uiBinder.Ref:SetVisible(self.uiBinder.cont_title_btn, false)
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
      elseif TableRow.ShowRule == E.EUnderLineTipsType.WithTitle then
        self.uiBinder.Ref:SetVisible(self.uiBinder.cont_title_btn, true)
        self.uiBinder.lab_name.text = TableRow.Text
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
      end
      item.Ref:SetVisible(item.img_bottom, false)
      item.lab_info.text = self:ParseTextDescriptionConfig(TableRow)
    else
      item.Ref:SetVisible(item.img_bottom, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
      self.uiBinder.lab_name.text = Lang("underTipsTitle")
      item.lab_off_title.text = TableRow.Text
      item.Ref:SetVisible(item.lab_off_title, true)
      item.lab_info.text = self:ParseTextDescriptionConfig(TableRow)
    end
  end
  self.uiBinder.img_bg:ForceRebuildLayoutImmediate()
  self.uiBinder.adaptPos:UpdatePosition(self.parentTrans, true, true, true)
end

function Tips_richTextView:ParseTextDescriptionConfig(config)
  local res = ""
  if config then
    if config.Type then
      if config.Type == TextDescriptionType.Normal then
        res = config.Description
      elseif config.Type == TextDescriptionType.SkillReplace then
        local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(config.Par)
        if skillConfig then
          res = skillConfig.Desc
        end
      elseif config.Type == TextDescriptionType.AttrDescription then
        local attrDescription = Z.TableMgr.GetTable("AttrDescriptionMgr").GetRow(config.Par)
        if attrDescription and attrDescription.Description then
          res = attrDescription.Description
        end
      end
    else
      res = config.Description
    end
  end
  return Z.RichTextHelper.DeleteTextLink(res)
end

return Tips_richTextView
