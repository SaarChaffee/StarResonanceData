local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_life_profession_left_subView = class("Map_life_profession_left_subView", super)
local loopListView = require("ui.component.loop_list_view")
local profession_item = require("ui.component.map.map_profession_item")
local collection_item = require("ui.component.map.map_collection_item")

function Map_life_profession_left_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_life_profession_left_sub", "map/map_life_profession_left_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function Map_life_profession_left_subView:OnActive()
  self:InitData()
  self:InitComp()
end

function Map_life_profession_left_subView:OnDeActive()
  self:UnInitLoopListView()
end

function Map_life_profession_left_subView:OnRefresh()
end

function Map_life_profession_left_subView:InitData()
  self.curExpandDict_ = {}
  self.curSelectCollectionId_ = self.mapData_:GetTargetCollectionId()
  self:initLoopData()
end

function Map_life_profession_left_subView:InitComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:InitLoopListView()
end

function Map_life_profession_left_subView:InitLoopListView()
  self.loopProfessionListView_ = loopListView.new(self, self.uiBinder.loop_profession, profession_item, "profession_item")
  self.loopProfessionListView_:Init(self.professionList_)
  self.loopCollectionListView_ = loopListView.new(self, self.uiBinder.loop_collection, collection_item, "collection_item")
  self.loopCollectionListView_:Init({})
  local count = #self.professionList_
  if 0 < count then
    local defaultIndex = 1
    self.loopProfessionListView_:SetSelected(defaultIndex)
    self:OnProfessionItemClick(self.professionList_[defaultIndex])
  end
  self:SetUIVisible(self.uiBinder.node_normal, 0 < count)
  self:SetUIVisible(self.uiBinder.node_empty, count == 0)
end

function Map_life_profession_left_subView:UnInitLoopListView()
  self.loopProfessionListView_:UnInit()
  self.loopProfessionListView_ = nil
  self.loopCollectionListView_:UnInit()
  self.loopCollectionListView_ = nil
end

function Map_life_profession_left_subView:initLoopData()
  local curSceneId = self.parent_:GetCurSceneId()
  self.professionList_ = {}
  self.collectionDict_ = {}
  local dataList = Z.TableMgr.GetTable("LifeCollectListTableMgr").GetDatas()
  for i, v in pairs(dataList) do
    local collectionPosInfo = self.mapData_:GetCollectionPosInfo(v.Id, curSceneId)
    if collectionPosInfo and 0 < #collectionPosInfo then
      if self.collectionDict_[v.LifeProId] == nil then
        self.collectionDict_[v.LifeProId] = {}
      end
      table.insert(self.collectionDict_[v.LifeProId], v)
    end
  end
  for k, v in pairs(self.collectionDict_) do
    table.insert(self.professionList_, k)
    table.sort(self.collectionDict_[k], function(a, b)
      if a.Sort == b.Sort then
        return a.Id < b.Id
      else
        return a.Sort < b.Sort
      end
    end)
  end
end

function Map_life_profession_left_subView:OnProfessionItemClick(professionId)
  local config = Z.TableMgr.GetRow("LifeProfessionTableMgr", professionId)
  if config == nil then
    return
  end
  local dataList = self.collectionDict_[professionId] or {}
  self.loopCollectionListView_:RefreshListView(dataList, false)
  self.loopCollectionListView_:ClearAllSelect()
  if self.curSelectCollectionId_ then
    for i, v in ipairs(dataList) do
      if v.Id == self.curSelectCollectionId_ then
        self.loopCollectionListView_:SetSelected(i)
        break
      end
    end
  end
  self.uiBinder.lab_profession.text = config.Name
end

function Map_life_profession_left_subView:OnCollectionItemClick(collectionId)
  if self.curSelectCollectionId_ == collectionId then
    self.curSelectCollectionId_ = nil
  else
    self.curSelectCollectionId_ = collectionId
  end
  self.mapData_:SetTargetCollectionId(self.curSelectCollectionId_)
  self.loopProfessionListView_:RefreshAllShownItem()
end

return Map_life_profession_left_subView
