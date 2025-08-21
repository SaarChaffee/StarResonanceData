local RedCacheContainer = {}

function RedCacheContainer:GetFaceRed()
  if self.faceRed_ == nil then
    self.faceRed_ = require("rednode/face_red")
  end
  return self.faceRed_
end

function RedCacheContainer:GetFashingRed()
  if self.fashingRed_ == nil then
    self.fashingRed_ = require("rednode/fishing_red")
  end
  return self.fashingRed_
end

function RedCacheContainer:GetFashionRed()
  if self.fashionRed_ == nil then
    self.fashionRed_ = require("rednode/fashion_red")
  end
  return self.fashionRed_
end

function RedCacheContainer:GetBagRed()
  if self.bagRed_ == nil then
    self.bagRed_ = require("rednode/bag_red")
  end
  return self.bagRed_
end

function RedCacheContainer:GetEquipRed()
  if self.equipRed_ == nil then
    self.equipRed_ = require("rednode/equip_red")
  end
  return self.equipRed_
end

function RedCacheContainer:GetExploreMonsterRed()
  if self.exploreMonsterRed_ == nil then
    self.exploreMonsterRed_ = require("rednode/explore_monster_red")
  end
  return self.exploreMonsterRed_
end

function RedCacheContainer:GetExpressionRed()
  if self.expressionRed_ == nil then
    self.expressionRed_ = require("rednode/expression_red")
  end
  return self.expressionRed_
end

function RedCacheContainer:GetQuestRed()
  if self.questRed_ == nil then
    self.questRed_ = require("rednode/quest_red")
  end
  return self.questRed_
end

return RedCacheContainer
