
![logo](/logo.png)

## APP版本管理系统

APP版本管理是一套多应用更新发版的管理平台。

通过部署本管理系统，以实现对多APP的多平台多渠道上的版本管理。

后端项目：[Github](https://github.com/xtTech/app-version)
## 使用方法

#### 安装

```ruby
pod 'app-version-swift'
```

#### 注册
下面是配合后台，直接使用配套后台，或者协商字段一样。否则可以使用下面自定义接方法

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 自定义配置
        var config = AppVersionConfig()
        config.updateUrl = "https://www.apple.com"
        config.layoutCompletionBlock = { alert in
            alert.updateButton.setTitle("升级", for: .normal)
        }
        /// api 自行替换接口地址
        AppVersion.registerApp(appId: "interbullion", serverUrl: "....api....", config: nil)
        return true
    }
```

##### 自定义接口
请求接口后，自己创建数据，直接进行弹窗。内部会做版本比对，或者更新类型判断
```swift
        // 自定义接口请求
        let data = VersionData(allowLowestVersion: "0", version: "1.0", forceUpdate: .must, description: "测试")
        AppVersion.showAlert(parameters: data, config: nil)
```


类型说明：

```
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
```



## 功能概览

本系统的主要功能有 IOS版本管理，自定义接口以及管理员管理。 

* `版本管理` 是本系统的基础功能，可以帮您实现自己的应用在安卓各应用商店或IOS的App Store上各个版本的管理。 +
* `RN 管理` 可以来便携管理您应用的RN包和RN路由。 +
* `自定义接口` 可以自定义您期望获得的数据信息。 +
* `管理员` 模块可以让您方便的实现多管理、多应用的操作。此外，`操作日志` 可以方便您监管其他应用管理员对各个应用的操作情况。 +
* `操作手册` 可以帮你查找操作方法。

### 相关文档

[[后端：开发/部署手册]](https://github.com/xtTech/app-version/blob/master/src/main/asciidoc/_chapter/get-started.adoc)

[[后端：使用手册]](https://github.com/xtTech/app-version/blob/master/src/main/asciidoc/_chapter/user-manual.adoc)

[[后端：版本查询 API 接口]](https://github.com/xtTech/app-version/blob/master/src/main/asciidoc/_chapter/rest-manual.adoc)

[[后端：Docker 使用手册]](https://github.com/xtTech/app-version/blob/master/src/main/asciidoc/_chapter/docker-manual.adoc)

### 项目预览

iOS端预览

![show](/show.png)

后端预览

![show1](/show1.png)

![show2](/show2.png)

NOTE: 有时候邮件回复的不是那么及时，推荐微信。

微信: birdmichael （备注：APP 管理系统）

### License

Apache Licensed. 具体查看 `License`

