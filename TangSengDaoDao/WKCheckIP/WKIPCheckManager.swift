//
//  WKIPCheckManager.swift
//  TangSengDaoDaoiOS
//
//  Created by YY1688 on 2025/4/22.
//  Copyright © 2025 WK. All rights reserved.
//

import UIKit
import MMDB_Swift

@objcMembers
class WKIPCheckManager: NSObject {
    
    static let shared = WKIPCheckManager()
    
    private let ipServices = [
            "https://api.ip.sb/ip",
            "https://icanhazip.com/",
            "https://ifconfig.me/ip"
        ]
    
    // 定义模型
    struct ConfigResponse: Decodable {
        let config: String?
        let configJw: String?
    }
    
    // 获取 API 地址
    func getAPIAddressWith(completion: @escaping (_ apiAddress: String?, _ error: NSError?) -> Void) {
        fetchConfig { [weak self] configModel in
            guard let `self` = self, let config = configModel?.config, let configlw = configModel?.configJw else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "IPManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取 IP"]))
                }
                return
            }
            getAPIAddressWithConfig(config, configJw: configlw) { apiAddress, error in
                DispatchQueue.main.async {
                    completion(apiAddress, error)
                }
            }
        }
    }
    
    // 请求函数
    private func fetchConfig(retryCount: Int = 3, completion: @escaping (ConfigResponse?) -> Void) {
        guard let url = URL(string: "https://liuxing-shangwu.oss-accelerate.aliyuncs.com/config.json") else {
            print("无效的 URL")
            completion(nil)
            return
        }

        func attemptRequest(remainingTries: Int) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("请求失败: \(error.localizedDescription)")
                    if remainingTries > 1 {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                            attemptRequest(remainingTries: remainingTries - 1)
                        }
                    } else {
                        completion(nil)
                    }
                    return
                }

                guard let data = data else {
                    print("无数据返回")
                    completion(nil)
                    return
                }

                do {
                    let config = try JSONDecoder().decode(ConfigResponse.self, from: data)
                    completion(config)
                } catch {
                    print("解析失败: \(error)")
                    if remainingTries > 1 {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                            attemptRequest(remainingTries: remainingTries - 1)
                        }
                    } else {
                        completion(nil)
                    }
                }
            }.resume()
        }

        attemptRequest(remainingTries: retryCount)
    }
        
    /// 获取 API 地址
    private func getAPIAddressWithConfig(_ config: String,
                                     configJw: String,
                                     completion: @escaping (_ apiAddress: String?, _ error: NSError?) -> Void) {
        fetchPublicIP(at: 0, timeout: 5) { result in
            switch result {
            case .success(let ip):
                let countryCode = self.lookupCountryCode(for: ip)
                let api = (countryCode.uppercased() == "CN") ? config : configJw
                completion(api, nil)
            case .failure(let error):
                completion(nil, error as NSError)
            }
        }
    }

    // MARK: - 获取公网 IP（尝试多个服务）
    private func fetchPublicIP(at index: Int, timeout: TimeInterval, completion: @escaping (Result<String, Error>) -> Void) {
        guard index < ipServices.count, let url = URL(string: ipServices[index]) else {
            completion(.failure(NSError(domain: "IPManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取 IP"])))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !ip.isEmpty {
                completion(.success(ip))
            } else {
                self.fetchPublicIP(at: index + 1, timeout: timeout, completion: completion)
            }
        }
        task.resume()
    }
    
    @objc func lookupCountryCode(for ip: String) -> String {
        let url = Bundle.main.path(forResource: "GeoLite2-Country", ofType: "mmdb")
        print("url ----- \(url)");
        guard let url = url, let db = MMDB(url) else {
            print("db is nil")
            return ""
        }
        
        if let country = db.lookup(ip) {
            print("country: %@", country)
            let isoCode = country.isoCode
            return isoCode
        }
        
        return ""
    }

}

extension WKIPCheckManager {
    static func wk_baseUrl(url: String) -> String {
        return String(format: "%@/v1/", removeTrailingSlash(from: url))
    }
    
    static func wk_webUrl(url: String) -> String {
        return String(format: "%@/web/", removeTrailingSlash(from: url))
    }
    
    static func removeTrailingSlash(from url: String) -> String {
        if url.hasSuffix("/") {
            return String(url.dropLast())
        }
        return url
    }
}
