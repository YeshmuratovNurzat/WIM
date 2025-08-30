import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

     let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.example.app/device",
                                                 binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { (call, result) in
          if call.method == "getDeviceId" {
            if let id = UIDevice.current.identifierForVendor?.uuidString {
              result(id)
            } else {
              result(FlutterError(code: "UNAVAILABLE",
                                  message: "Device ID not available",
                                  details: nil))
            }
          } else {
            result(FlutterMethodNotImplemented)
          }
        }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
