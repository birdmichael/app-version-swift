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

    enum CondingKeys: String, CodingKey {
        case code
        case msg
        case data
    }
}
public struct VersionData: Decodable {
    /// 最低运行版本
    let allowLowestVersion: String
    /// 更新描述
    let description: String
    /// 更新类型
    let forceUpdate: UpdateType
    /// 最新版本
    let version: String

    enum CondingKeys: String, CodingKey {
        case allowLowestVersion
        case description
        case version
        case forceUpdate
    }
}

enum UpdateType: Int, Decodable {
    /// 强制更新 （没有关闭按钮，每次启动弹出提示）
    case must
    /// 一般更新 （有关闭按钮，每次启动弹出提示）
    case nomal
    /// 静默更新 （有关闭按钮，不弹出提示）
    case silent
    /// 忽略更新 （有关闭按钮，并且当前版本只弹出一次）
    case ignore
    /// 静默忽略更新 （和忽略更新一样，有关闭按钮，并且不弹出提示）
    case silentIgnore
}

