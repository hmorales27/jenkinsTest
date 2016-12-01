/*
 * Configuration
*/

let ANALYTICS_ENABLED               : Bool = true
let FABRIC_ENABLED                  : Bool = true
let IP_Auth_Enabled                 : Bool = true
let NETWORKING_ENABLED              : Bool = true

var NETWORK_AVAILABLE               : Bool   { get { return InternetHelper.sharedInstance.available } }
var OVERRIDE_LOGIN                  : Bool = true
let PUSH_NOTIFICATIONS_ENABLED      : Bool = true
let USE_TEST_ADVERTISEMENTS         : Bool = false

let CONTENT_INNOVATION_CALL_ENABLED : Bool = true
let USE_NEW_UI                      : Bool = false

var COMPILE_TIMESTAMP               : String = ""
var BUILD_VERSION                   : String = ""
