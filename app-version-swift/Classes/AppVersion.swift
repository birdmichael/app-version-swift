//
//  AppVersion.swift
//  app-version-swift
//
//  Created by BirdMichael on 2020/3/16.
//

import Foundation
import Alamofire
import SnapKit

struct UserDefaultKeys {
    /// 最后一次弹出版本
    let lastAlertVersion = "lastAlertVersion"
}

public class AppVersion: UIView {
    /// 描述列表
    public var listTxt: UITextView!
    /// 容器
    public var contentView: UIView!
    /// 顶部图片
    public var topImageView: UIImageView!
    /// 图标（默认是个小火箭）
    public var iconImageView: UIImageView!
    /// 版本信息
    public var versionLabel: UILabel!
    /// 更新按钮
    public var updateButton: UIButton!
    /// 取消按钮
    public var cancelButton: UIButton!

    
    var responseData : VersionData
    var config: AppVersionConfig

    /// 搭配后端框架，或一件请求
    public static func registerApp(appId:String, serverUrl: String, config: AppVersionConfig?) {
        requestServer(appId: appId, serverUrl: serverUrl, config: config)
    }

    /// 自定义请求，弹窗
    public static func showAlert(parameters:VersionData, config: AppVersionConfig?) {
        guard !compareVersion(localVersion: currentVersion(), newVersion: parameters.version) else { return } // 版本比较
        guard parameters.forceUpdate != .silent && parameters.forceUpdate != .silentIgnore else { return } // 如果是静默(静默和静默忽略)，则不弹出
        // 如果是可忽略，并且已经储存了最后一次弹出的版本,和需要弹出的版本是最新的。就不需要再次弹出
        if parameters.forceUpdate == .ignore,
            let lastAlertVersion = UserDefaults.standard.string(forKey: UserDefaultKeys().lastAlertVersion),
            compareVersion(localVersion: lastAlertVersion, newVersion: parameters.version) { return }
        let alert = AppVersion(parameters: parameters, config ?? AppVersionConfig())
        alert.setupSubView()
        appWindow?.addSubview(alert)
        UserDefaults.standard.set(parameters.version, forKey: UserDefaultKeys().lastAlertVersion)
    }

    static let appWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .map { $0?.windows.first } ?? UIApplication.shared.delegate?.window ?? nil
        }

        return UIApplication.shared.delegate?.window ?? nil
    }()

    init(parameters: VersionData, _ conf: AppVersionConfig) {
        config = conf
        responseData = parameters
        super.init(frame: CGRect.zero)

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func requestServer(appId:String, serverUrl: String, config: AppVersionConfig?) {
        let parameters = ["channelCode" : "App Store",
                          "platform": "iOS",
                          "tenantAppId": appId,
                          "version": currentVersion()]

        AF.request(serverUrl, method: .get, parameters: parameters, encoding: URLEncoding.default).responseDecodable(of: Response.self) { (response) in
            switch response.result {
            case let .success(value):
                showAlert(parameters: value.data, config: config)
                case .failure(_):
                debugPrint("没有最新版本，请配置最新版本")
            }
        }
    }

    fileprivate func setupSubView() {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)

        let ui = config.userInterface

        contentView = UIView()
        contentView.center = self.center
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 12
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(260)
            make.center.equalToSuperview()
        }

        topImageView = UIImageView(frame: .zero)
        topImageView.image = UIImage(named: "AppVersion.bundle/upgrade_bg_img", in: Bundle(for: AppVersion.self), compatibleWith: nil)
        contentView.addSubview(topImageView)
        topImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }

        iconImageView = UIImageView(frame: .zero)
        iconImageView.image = UIImage(named: "AppVersion.bundle/upgrade_rocket_img", in: Bundle(for: AppVersion.self), compatibleWith: nil)
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.right.equalTo(topImageView)
            make.top.equalTo(topImageView).offset(-24)
        }

        versionLabel = UILabel()
        versionLabel.font = UIFont.boldSystemFont(ofSize: 13)
        versionLabel.textAlignment = .center
        versionLabel.textColor = .white
        versionLabel.text = "V\(responseData.version)"
        topImageView.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(-50)
        }

        listTxt = UITextView()
        listTxt.text = responseData.description
        listTxt.isEditable = false
        listTxt.isSelectable = false
        listTxt.isScrollEnabled = false
        listTxt.showsVerticalScrollIndicator = false
        listTxt.showsHorizontalScrollIndicator = false

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: ui.txtFont),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1),
                          NSAttributedString.Key.paragraphStyle:style]
        listTxt.attributedText = NSAttributedString(string: listTxt.text, attributes: attributes)
        contentView.addSubview(listTxt)
        listTxt.sizeToFit()

        listTxt.snp.makeConstraints { (make) in
            make.top.equalTo(topImageView.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        listTxt.layoutIfNeeded()


        if listTxt.frame.height > ui.alertMaxHeight {
            listTxt.isScrollEnabled = true
            listTxt.showsVerticalScrollIndicator = true
            listTxt.snp.remakeConstraints { (make) in
                make.top.equalTo(topImageView.snp.bottom).offset(20)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(ui.alertMaxHeight)
            }
        }


        updateButton = UIButton(type: .system)
        updateButton.clipsToBounds = true
        updateButton.layer.cornerRadius = 4
        updateButton.backgroundColor = UIColor(red: 0.95, green: 0.14, blue: 0, alpha: 1)
        updateButton.setTitleColor(UIColor.white, for: .normal)
        updateButton.setTitle("立即更新", for: .normal)
        updateButton.addTarget(self, action: #selector(gotoUpdate), for: UIControl.Event.touchUpInside)
        contentView.addSubview(updateButton)
        updateButton.snp.makeConstraints { (make) in
            make.top.equalTo(listTxt.snp.bottom).offset(10)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-16).priority(.medium)
            make.height.equalTo(ui.updateButtonHeight)
        }


        cancelButton = UIButton(type: .system)
        cancelButton.center = CGPoint.init(x: contentView.frame.maxX, y: contentView.frame.minY)
        cancelButton.setImage(UIImage(named: "AppVersion.bundle/upgrade_close_icon", in: Bundle(for: AppVersion.self), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAlertAction), for: UIControl.Event.touchUpInside)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: ui.cancelButtonWidth, height: ui.cancelButtonWidth))
            make.top.equalTo(13)
        }
        // 如果是强制更新，或者当前版本小于最低版本
        cancelButton.isHidden = ((responseData.forceUpdate == .must) || !AppVersion.compareVersion(localVersion: AppVersion.currentVersion(), newVersion: responseData.allowLowestVersion))

        if let block = config.layoutCompletionBlock {
            block(self)
        }
    }

}

// MARK: - Actions
extension AppVersion {
    @objc private func cancelAlertAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            self.backgroundColor = UIColor.clear
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    @objc private func gotoUpdate() {
        var appUrl = config.updateUrl
        if !config.updateUrl.contains("http://") && !config.updateUrl.contains("https://") {
            appUrl = "https://" + config.updateUrl
        }
        let url = URL(string: appUrl)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
}

// MARK: - 版本比较
extension AppVersion {
    /// 返回当前版本
    static func currentVersion() -> String {
        guard let localVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return localVersion
    }
    /// 版本比较
    fileprivate static func compareVersion(localVersion: String, newVersion: String) -> Bool {
        if checkSeparat(versionString: localVersion) == "" || checkSeparat(versionString: newVersion) == ""{
            debugPrint("\n\("Only support '.''-'/''*'_'delimiter")\n")
            return false
        }
        guard let localVersionArray = cutUpNumber(vString: localVersion) as? [String] else { return false}
        guard let storeVersionArray = cutUpNumber(vString: newVersion) as? [String] else {return false}
        return compareNumber(localArray: localVersionArray, storeArray: storeVersionArray)
    }

    /// 检查分割
    fileprivate static func checkSeparat(versionString:String) -> String {
        var separated:String = ""
        if versionString.contains(".") {separated = "."}
        if versionString.contains("-") {separated = "-"}
        if versionString.contains("/") {separated = "/"}
        if versionString.contains("*") {separated = "*" }
        if versionString.contains("_") {separated = "_" }

        return separated
    }

    /// 获取版本数组
    fileprivate static func cutUpNumber(vString:String) -> NSArray {
        let  separat = checkSeparat(versionString: vString)
        let versionChar = NSCharacterSet(charactersIn:separat) as CharacterSet
        let vStringArr = vString.components(separatedBy: versionChar)
        return vStringArr as NSArray
    }

    /// 比较
    ///
    ///     `true`为版本版本大于或等于更新版本。则是最新版本
    /// - Parameters:
    ///   - localArray: 本地版本
    ///   - storeArray: 比较版本
    fileprivate static func compareNumber(localArray:[String],storeArray:[String]) -> Bool {
        for version in 0..<localArray.count {
            if  Int(localArray[version])! != Int(storeArray[version])! {
                if Int(localArray[version])! > Int(storeArray[version])! {
                    return true
                } else {
                    return false
                }
            }
        }
        return true // 相同
    }
}



public struct AppVersionConfig {
    public init() {}
    /// 用户界面
    public var userInterface = AppVersionUI()
    /// 更新appUrl
    public var updateUrl = "http://www.apple.com"
    /// 视图创建完毕，给外部一次修改里面布局的机会
    public var layoutCompletionBlock : ((_ alert: AppVersion) -> Void)?
}

public struct AppVersionUI {
    /// 描述文字大小
    public var txtFont: CGFloat = 13
    /// 最大高度
    public var alertMaxHeight: CGFloat = 200
    /// 升级按钮高度
    public var updateButtonHeight:CGFloat = 34
    /// 取消按钮宽度
    public var cancelButtonWidth:CGFloat = 16


    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
}
