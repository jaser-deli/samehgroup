class Api {
  static String baseUrl =
      "http://188.247.88.114:8084/samehgroup/public/api/v1/";

  static String baseUrlMain =
      "http://ls.samehgroup.com:8081/LiveSales_old_new/public/api/v1/";

  static String app = "${baseUrlMain}apps";
  static String notifications = "${baseUrlMain}notifications";
  static String notificationUpdate = "${baseUrlMain}notifications/update";

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
}
