local super = require("ui.model.data_base")
local AfficheData = class("AfficheData", super)

function AfficheData:ctor()
  super.ctor(self)
  self:ClearAfficheData()
end

function AfficheData:SetShowAfficheIndex(afficheIndex)
  self.showAfficheIndex_ = afficheIndex
end

function AfficheData:GetShowAfficheData(noticeType)
  if not self.typeDic_[noticeType] then
    return
  end
  if self.showAfficheIndex_ > 0 and self.showAfficheIndex_ <= #self.typeDic_[noticeType] then
    return self.typeDic_[noticeType][self.showAfficheIndex_]
  end
  return nil
end

function AfficheData:ClearAfficheData()
  self.typeDic_ = {
    [E.NoticeType.Event] = {},
    [E.NoticeType.System] = {}
  }
  self.showAfficheIndex_ = 1
end

function AfficheData:AddAfficheData(noticeType, title, subtitle, context, image)
  if self.typeDic_[noticeType] == nil then
    self.typeDic_[noticeType] = {}
  end
  table.insert(self.typeDic_[noticeType], {
    titleName_ = title,
    subTitleName_ = subtitle,
    afficheContent_ = context,
    afficheImage_ = image,
    index_ = #self.typeDic_[noticeType] + 1
  })
end

function AfficheData:GetAfficheData(noticeType)
  return self.typeDic_[noticeType] or {}
end

function AfficheData:GetShowAfficheDataIndex()
  return self.showAfficheIndex_
end

return AfficheData
