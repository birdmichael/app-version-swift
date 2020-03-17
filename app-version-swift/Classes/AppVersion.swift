//
//  AppVersion.swift
//  app-version-swift
//
//  Created by BirdMichael on 2020/3/16.
//

import Foundation
import Alamofire
import SnapKit


public class AppVersion: UIView {

    var date : ResponseData


    public static func registerApp(appId:String, serverUrl: String) {
        requestServer(appId: appId, serverUrl: serverUrl)
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

    private var listTxt:UITextView!

    init(parameters:ResponseData) {
        date = parameters
        super.init(frame: CGRect.zero)

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func showAlert(parameters:ResponseData) {
        guard !compareVersion(localVersion: currentVersion(), newVersion: parameters.version) else { return }
        let alert = AppVersion(parameters: parameters)
        alert.makeUI()
        appWindow?.addSubview(alert)
    }

    fileprivate static func requestServer(appId:String, serverUrl: String) {
        let parameters = ["channelCode" : "App Store",
                          "platform": "iOS",
                          "tenantAppId": appId,
                          "version": currentVersion()]

        AF.request(serverUrl, method: .get, parameters: parameters, encoding: URLEncoding.default).responseDecodable(of: Response.self) { (response) in
            switch response.result {
            case let .success(value):
                showAlert(parameters: value.data)
                case .failure(_):
                debugPrint("没有最新版本，请配置最新版本")
            }
        }
    }

    fileprivate func makeUI() {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)

        let config = AppVersionConfig.shared
        let ui = config.userInterface

        let contentView = UIView()
        contentView.center = self.center
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 12
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(260)
            make.center.equalToSuperview()
        }

        let topImage = UIImageView(frame: .zero)
        topImage.image = UIImage(named: "AppVersion.bundle/upgrade_bg_img", in: Bundle(for: AppVersion.self), compatibleWith: nil)
        contentView.addSubview(topImage)
        topImage.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }

        let rightImage = UIImageView(frame: .zero)
        rightImage.image = UIImage(named: "AppVersion.bundle/upgrade_rocket_img", in: Bundle(for: AppVersion.self), compatibleWith: nil)
        self.addSubview(rightImage)
        rightImage.snp.makeConstraints { (make) in
            make.right.equalTo(topImage)
            make.top.equalTo(topImage).offset(-24)
        }

        let lblVersion = UILabel()
        lblVersion.font = UIFont.boldSystemFont(ofSize: 13)
        lblVersion.textAlignment = .center
        lblVersion.textColor = .white
        lblVersion.text = "V\(date.version)"
        topImage.addSubview(lblVersion)
        lblVersion.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(-50)
        }

        listTxt = UITextView()
        listTxt.text = date.description
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
            make.top.equalTo(topImage.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        listTxt.layoutIfNeeded()


        if listTxt.frame.height > ui.alertMaxHeight {
            listTxt.isScrollEnabled = true
            listTxt.showsVerticalScrollIndicator = true
            listTxt.snp.remakeConstraints { (make) in
                make.top.equalTo(topImage.snp.bottom).offset(20)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(ui.alertMaxHeight)
            }
        }


        let btnUpdate = UIButton(type: .system)
        btnUpdate.clipsToBounds = true
        btnUpdate.layer.cornerRadius = 4
        btnUpdate.backgroundColor = UIColor(red: 34 / 255, green: 153 / 255, blue: 238 / 255, alpha: 1)
        btnUpdate.setTitleColor(UIColor.white, for: .normal)
        btnUpdate.setTitle("立即更新", for: .normal)
        btnUpdate.addTarget(self, action: #selector(gotoUpdate), for: UIControl.Event.touchUpInside)
        contentView.addSubview(btnUpdate)
        btnUpdate.snp.makeConstraints { (make) in
            make.top.equalTo(listTxt.snp.bottom).offset(10)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-16).priority(.medium)
            make.height.equalTo(34)
        }


        let btnCancel = UIButton(type: .system)
        btnCancel.bounds = CGRect.init(x: 0, y: 0, width: ui.cancelButtonWidth, height: ui.cancelButtonWidth)
        btnCancel.center = CGPoint.init(x: contentView.frame.maxX, y: contentView.frame.minY)
        btnCancel.setImage(UIImage(named: "AppVersion.bundle/upgrade_close_icon", in: Bundle(for: AppVersion.self), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnCancel.addTarget(self, action: #selector(cancelAlertAction), for: UIControl.Event.touchUpInside)
        contentView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(13)
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
        var appUrl = AppVersionConfig.shared.updateUrl
        if !AppVersionConfig.shared.updateUrl.contains("http://") && !AppVersionConfig.shared.updateUrl.contains("https://") {
            appUrl = "https://" + AppVersionConfig.shared.updateUrl
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



struct AppVersionConfig {
    static let shared = AppVersionConfig()

    /// 用户界面
    var userInterface = AppVersionUI()
    /// 更新appUrl
    var updateUrl = "http://www.apple.com"
}

struct AppVersionUI {
    /// 描述文字大小
    var txtFont: CGFloat = 13
    /// 最大高度
    var alertMaxHeight: CGFloat = 200
    /// 升级按钮高度
    var UpdateButtonHeight:CGFloat = 40
    /// 取消按钮宽度
    var cancelButtonWidth:CGFloat = 36


    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
}
