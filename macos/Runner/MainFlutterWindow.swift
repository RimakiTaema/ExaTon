import Cocoa
import FlutterMacOS
import Security

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    LegacyTokens.register(with: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}

/// Reads the tokens ExaTon 1.5 (Tauri, keyring crate) saved: generic
/// passwords in the login keychain with service "net.rimaki.exatonext" and
/// the account email as the account name. Read only; nothing is deleted.
enum LegacyTokens {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "exaton/legacy", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "listTokens",
            let args = call.arguments as? [String: Any],
            let service = args["service"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        let entries = list(service: service)
        DispatchQueue.main.async { result(entries) }
      }
    }
  }

  private static func accounts(service: String) -> [String] {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecMatchLimit as String: kSecMatchLimitAll,
      kSecReturnAttributes as String: true,
    ]
    var out: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &out) == errSecSuccess,
          let items = out as? [[String: Any]]
    else { return [] }
    return items.compactMap { $0[kSecAttrAccount as String] as? String }
  }

  /// One read per account; macOS may ask the user to allow access because
  /// the items were created by the 1.5 app.
  private static func list(service: String) -> [[String: String]] {
    var entries: [[String: String]] = []
    for account in Set(accounts(service: service)) {
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true,
      ]
      var out: CFTypeRef?
      if SecItemCopyMatching(query as CFDictionary, &out) == errSecSuccess,
         let data = out as? Data,
         let token = String(data: data, encoding: .utf8),
         !token.isEmpty
      {
        entries.append(["email": account, "token": token])
      }
    }
    return entries
  }
}
