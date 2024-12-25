local ContainerMgr = {
  AccountSerialize = require("zcontainer.account_serialize").New(),
  CharNameInfo = require("zcontainer.char_name_info").New(),
  CharSerialize = require("zcontainer.char_serialize").New(),
  CharShowIdInfo = require("zcontainer.char_show_id_info").New(),
  DungeonSyncData = require("zcontainer.dungeon_sync_data").New(),
  ExchangeDeskItemInfo = require("zcontainer.exchange_desk_item_info").New(),
  ExchangeNoticeDeskItemInfo = require("zcontainer.exchange_notice_desk_item_info").New(),
  ExchangeNoticeStorageItemInfo = require("zcontainer.exchange_notice_storage_item_info").New(),
  ExchangeNoticeTotalInfo = require("zcontainer.exchange_notice_total_info").New(),
  ExchangeSaleRankInfo = require("zcontainer.exchange_sale_rank_info").New(),
  ExchangeSaleStoreInfo = require("zcontainer.exchange_sale_store_info").New(),
  ExchangeStorageItemInfo = require("zcontainer.exchange_storage_item_info").New(),
  ExchangeTotalInfo = require("zcontainer.exchange_total_info").New(),
  GlobalMailTable = require("zcontainer.global_mail_table").New(),
  IncrInfo = require("zcontainer.incr_info").New(),
  MoneyIncrInfo = require("zcontainer.money_incr_info").New(),
  OpenIdPrivilegeSerialize = require("zcontainer.open_id_privilege_serialize").New(),
  OpenInfo = require("zcontainer.open_info").New(),
  PrivateMailTable = require("zcontainer.private_mail_table").New()
}

function ContainerMgr:Reset()
  self.AccountSerialize = require("zcontainer.account_serialize").New()
  self.CharNameInfo = require("zcontainer.char_name_info").New()
  self.CharSerialize = require("zcontainer.char_serialize").New()
  self.CharShowIdInfo = require("zcontainer.char_show_id_info").New()
  self.DungeonSyncData = require("zcontainer.dungeon_sync_data").New()
  self.ExchangeDeskItemInfo = require("zcontainer.exchange_desk_item_info").New()
  self.ExchangeNoticeDeskItemInfo = require("zcontainer.exchange_notice_desk_item_info").New()
  self.ExchangeNoticeStorageItemInfo = require("zcontainer.exchange_notice_storage_item_info").New()
  self.ExchangeNoticeTotalInfo = require("zcontainer.exchange_notice_total_info").New()
  self.ExchangeSaleRankInfo = require("zcontainer.exchange_sale_rank_info").New()
  self.ExchangeSaleStoreInfo = require("zcontainer.exchange_sale_store_info").New()
  self.ExchangeStorageItemInfo = require("zcontainer.exchange_storage_item_info").New()
  self.ExchangeTotalInfo = require("zcontainer.exchange_total_info").New()
  self.GlobalMailTable = require("zcontainer.global_mail_table").New()
  self.IncrInfo = require("zcontainer.incr_info").New()
  self.MoneyIncrInfo = require("zcontainer.money_incr_info").New()
  self.OpenIdPrivilegeSerialize = require("zcontainer.open_id_privilege_serialize").New()
  self.OpenInfo = require("zcontainer.open_info").New()
  self.PrivateMailTable = require("zcontainer.private_mail_table").New()
end

return ContainerMgr
