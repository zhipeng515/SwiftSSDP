//
//  SSDPMSearchResponse.swift
//  SwiftSSDP
//
//  Created by Paul Bates on 2/8/17.
//  Copyright © 2017 Paul Bates. All rights reserved.
//

import Foundation

/// An M-SEARCH response for a device or service found during device/service discovery
public struct SSDPMSearchResponse {
    /// CACHE-CONTROL
    public let cacheControl: Date?
    /// DATE
    public let date: Date?
    /// EXT
    public let ext: Bool
    /// LOCATION
    public let location: URL
    /// SERVER
    public let server: String?
    /// ST
    public let searchTarget: SSDPSearchTarget
    /// USN
    public let usn: String
    
    /// All other headers in the discovery response
    public let otherHeaders: [String: String]
}

//
// MARK: -
//

extension SSDPMSearchResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.usn.hashValue)
        hasher.combine(self.location.hashValue)
    }
}

public func ==(lhs: SSDPMSearchResponse, rhs: SSDPMSearchResponse) -> Bool {
    return lhs.usn == rhs.usn && lhs.location == rhs.location
}

extension SSDPMSearchResponse : CustomDebugStringConvertible {
    public var debugDescription: String {
        let headers = self.otherHeaders.reduce("", { acc, next in "\(acc)\(next.key)=\(next.value), " })
        return "location=\(self.location) usn=\(self.usn) server=\(self.server ?? "nil") headers=\(headers)"
    }
}

extension SSDPMSearchResponse {
    func retrieveLocation(with session: URLSession, _ completionBlock: @escaping (Data?, Error?)->Void) {
        let task = session.dataTask(with: self.location) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionBlock(nil, error) }
                return
            }
            guard let data = data else {
                NSLog("SSDPMSearchResponse xml - WARNING, no data from \(self.location)")
                DispatchQueue.main.async { completionBlock(nil, nil) }
                return
            }
            DispatchQueue.main.async { completionBlock(data, nil) }
        }
        task.resume()
    }
}
