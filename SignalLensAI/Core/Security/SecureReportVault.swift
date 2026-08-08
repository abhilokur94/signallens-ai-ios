import Foundation
import CryptoKit
import Security

actor SecureReportVault {
    private let service = "com.abhisheklokur.SignalLensAI.report-key"; private let account = "primary"
    func encrypt(_ data: Data) throws -> Data { let key = try loadOrCreateKey(); return try AES.GCM.seal(data, using: key).combined! }
    func decrypt(_ data: Data) throws -> Data { try AES.GCM.open(AES.GCM.SealedBox(combined: data), using: loadOrCreateKey()) }
    private func loadOrCreateKey() throws -> SymmetricKey {
        let query:[String:Any] = [kSecClass as String:kSecClassGenericPassword,kSecAttrService as String:service,kSecAttrAccount as String:account,kSecReturnData as String:true]
        var item: CFTypeRef?; let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data { return SymmetricKey(data:data) }
        let key=SymmetricKey(size:.bits256); let data=key.withUnsafeBytes{Data($0)}
        let add:[String:Any] = [kSecClass as String:kSecClassGenericPassword,kSecAttrService as String:service,kSecAttrAccount as String:account,kSecAttrAccessible as String:kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,kSecValueData as String:data]
        guard SecItemAdd(add as CFDictionary,nil)==errSecSuccess else { throw VaultError.keychain }
        return key
    }
    enum VaultError: Error { case keychain }
}
