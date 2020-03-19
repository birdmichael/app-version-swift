//
//  Response.swift
//  Alamofire
//
//  Created by BirdMichael on 2020/3/16.
//

import Foundation

struct Response: Decodable {
    let code: Int
    let msg: String
    let data :VersionData
}
public struct VersionData: Codable {
    /// 最低运行版本
    var allowLowestVersion: String
    /// 更新地址（商店地址）
    var appStoreUrl: String
    /// 更新描述
    var description: String
    /// 更新类型
    var forceUpdate: VersionUpdateType
    /// 最新版本
    var version: String

    public init(allowLowestVersion: String, version: String, forceUpdate: VersionUpdateType, description: String, appStoreUrl: String) {
        self.allowLowestVersion = allowLowestVersion
        self.version = version
        self.forceUpdate = forceUpdate
        self.description = description
        self.appStoreUrl = appStoreUrl
    }
}

public enum VersionUpdateType: Int, Codable {
    /// 强制更新 （没有关闭按钮，每次启动弹出提示）
    case must = 0
    /// 一般更新 （有关闭按钮，每次启动弹出提示）
    case nomal = 1
    /// 静默更新 （有关闭按钮，不弹出提示）
    case silent = 2
    /// 忽略更新 （有关闭按钮，并且当前版本只弹出一次）
    case ignore = 3
    /// 静默忽略更新 （和忽略更新一样，有关闭按钮，并且不弹出提示）
    case silentIgnore = 4
}

