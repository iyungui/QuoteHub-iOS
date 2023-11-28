//
//  KeyChain.swift
//  QuoteHub
//
//  Created by 이융의 on 10/23/23.
//

import Foundation
import Security

class KeyChain {
    // Create
    @discardableResult
    class func create(key: String, token: String) -> Bool {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]

        // Keychain은 Key값에 중복이 생기면, 저장할 수 없기 때문에 먼저 Delete해줌
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        if status != noErr {
            print("Failed to save token, status code = \(status)")
            return false
        }
        
        return true
    }
    
    // Read
    class func read(key: String) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,  // CFData 타입으로 불러오라는 의미
            kSecMatchLimit: kSecMatchLimitOne       // 중복되는 경우, 하나의 값만 불러오라는 의미
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                
                return value
            } else { return nil }
        } else {
//            print("Key chain failed to loading, status code = \(status)")
            return nil
        }
    }
    
    // Delete
    @discardableResult
    class func delete(key: String) -> Bool {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query)
        
        if status != noErr {
            print("Failed to delete the value, status code = \(status)")
            return false
        }
        
        return true
    }
}
