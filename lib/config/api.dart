class Api {
  static String baseUrl = "http://ls.samehgroup.com/api/v1/";
static String urlAppPrint = "http://ls.samehgroup.com/storage/apps/KHH_BarcodePrint.apk";

  static String app = "${baseUrl}apps";
  static String notifications = "${baseUrl}notifications";
  static String notificationUpdate = "${baseUrl}notifications/update";

  static String login = "${baseUrl}login";
  static String tokenUpdate = "${baseUrl}token_update";
  static String logout = "${baseUrl}logout";

  // Destroy
  static String destroy = "${baseUrl}destroy";
  static String quantityDestroy = "${baseUrl}quantity_destroy";
  static String quantityReserved = "${baseUrl}quantity_reserved";
  static String destroySave = "${baseUrl}destroy/save";
  static String destroyClear = "${baseUrl}destroy/clear";

  // Return
  static String supplier = "${baseUrl}supplier";
  static String returnData = "${baseUrl}return";
  static String returnCheck = "${baseUrl}return_check";
  static String returnQuantityDestroy = "${baseUrl}quantity_destroy_return";
  static String returnQuantityReserved = "${baseUrl}quantity_reserved_return";
  static String returnSave = "${baseUrl}return/save";
  static String returnClear = "${baseUrl}return/clear";

  // Stores From
  static String stores = "${baseUrl}stores";
  static String item = "${baseUrl}item";
  static String quantityCurrent = "${baseUrl}quantity_current";
  static String quantityReservedStore = "${baseUrl}quantity_reserved_store";
  static String storesSave = "${baseUrl}stores/save";
  static String storesClear = "${baseUrl}stores/clear";

  // Branches From
  static String branches = "${baseUrl}branches";
  static String itemBranch = "${baseUrl}item_branch";
  static String quantityCurrentBranch = "${baseUrl}quantity_current_branches";
  static String quantityReservedBranch = "${baseUrl}quantity_reserved_branches";
  static String branchSave = "${baseUrl}branches/save";
  static String branchClear = "${baseUrl}branches/clear";

  // Inventory
  static String inventory = "${baseUrl}inventory";
  static String inventorySave = "${baseUrl}inventory/save";
  static String inventoryClear = "${baseUrl}inventory/clear";

  static String pricing = "${baseUrl}pricing";
  static String offer = "${baseUrl}pricing/offer";

  static String ricivingSupplier = "${baseUrl}riciving";
  static String ricivingBarcode = "${baseUrl}riciving/barcode";
  static String ricivingSave = "${baseUrl}riciving/save";

  static String uploadImages = "${baseUrl}upload/images";
}
