//
//  PEMToSSHPublicKeyFormat.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

// adapter from: https://github.com/noncenz/SwiftyRSA which is distributed under the MIT license

import Foundation

extension Data {

    func ecPublicKeyToSSHFormat(curveName: String = "nistp256") throws -> String {
        // SSH key type for P-256 curve. Adjust this according to your curve.
        let keyType = "ecdsa-sha2-\(curveName)"

        var sshKey = Data()

        // Add the key type
        appendLengthPrefixedString(keyType, to: &sshKey)

        // Add the curve name
        appendLengthPrefixedString(curveName, to: &sshKey)

        // Public key format in SSH for EC keys is just the raw X || Y coordinates,
        // prefixed with the key format identifier (0x04 for uncompressed keys, which you already have).
        // Since your data is already in this format, you can append it directly.
        appendLengthPrefixedData(self, to: &sshKey)

        // Base64 encode the entire payload
        let base64EncodedKey = sshKey.base64EncodedString()

        return "\(keyType) \(base64EncodedKey)"
    }

    // Helper to append length-prefixed string data to the SSH key data
    func appendLengthPrefixedString(_ string: String, to data: inout Data) {
        guard let stringData = string.data(using: .utf8) else { return }
        appendLengthPrefixedData(stringData, to: &data)
    }

    // Helper to append length-prefixed data to the SSH key data
    func appendLengthPrefixedData(_ dataToAdd: Data, to data: inout Data) {
        var length = UInt32(dataToAdd.count).bigEndian
        data.append(Data(bytes: &length, count: 4))
        data.append(dataToAdd)
    }


    func publicPEMKeyToSSHFormat() throws -> String {
        let node = try! Asn1Parser.parse(data: self)
        
        // Ensure the raw data is an ASN1 sequence
        guard case .sequence(let nodes) = node else {
            throw NSError()
        }
        
        let RSA_HEADER = "ssh-rsa"
        
        var ssh:String = RSA_HEADER + " "
        var rsaBytes:Data = Data()
        
        // Get size of the header
        var byteCount: UInt32 = UInt32(RSA_HEADER.count).bigEndian
        var sizeData = Data(bytes: &byteCount, count: MemoryLayout.size(ofValue: byteCount))
        
        // Append size of header and content of header
        rsaBytes.append(sizeData)
        rsaBytes += RSA_HEADER.data(using: .utf8)!
        
        // Get the exponent
        if let exp = nodes.last, case .integer(let exponent) = exp {
            // Get size of exponent
            byteCount = UInt32(exponent.count).bigEndian
            sizeData = Data(bytes: &byteCount, count: MemoryLayout.size(ofValue: byteCount))
            
            // Append size of exponent and content of exponent
            rsaBytes.append(sizeData)
            rsaBytes += exponent
        }
        else{
            throw NSError()
        }
        
        // Get the modulus
        if let mod = nodes.first, case .integer(let modulus) = mod {
            // Get size of modulus
            byteCount = UInt32(modulus.count).bigEndian
            sizeData = Data(bytes: &byteCount, count: MemoryLayout.size(ofValue: byteCount))
            
            // Append size of modulus and content of modulus
            rsaBytes.append(sizeData)
            rsaBytes += modulus
        }
        else{
            throw NSError()
        }
        
        ssh += rsaBytes.base64EncodedString() + "\n"
        return ssh
    }
}
