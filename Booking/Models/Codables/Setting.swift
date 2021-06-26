import Foundation

class Setting: NSObject, NSSecureCoding, Codable {
    var categoryIndex: Int = 0
    var categoryName: String = Const.DEFAULT_CATEGORY[2]
    var canSetup: Bool = true
    var settingOptions: [SettingOption] = []
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        let jsonDecoder = JSONDecoder()
        let json = decoder.decodeObject(forKey: Const.SETTING_KEY) as? String
        if let jsonData = json?.data(using: .utf8) {
            let obj = try! jsonDecoder.decode(Setting.self, from: jsonData)
            self.categoryIndex = obj.categoryIndex
            self.categoryName = obj.categoryName
            self.canSetup = obj.canSetup
            self.settingOptions = obj.settingOptions
        }
    }
    
    func encode(with coder: NSCoder) {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        coder.encode(json, forKey: Const.SETTING_KEY)
    }
    
    private func setup() {
        if canSetup {
            settingOptions.append(SettingOption(.User, .Profile, .StaticCell, args: Const.DEFAULT_PROFILE))
            settingOptions.append(SettingOption(.Appearance, .Preview, .SwitchCell, args: Const.DEFAULT_PREVIEW, isOn: true))
            settingOptions.append(SettingOption(.Appearance, .Indicator, .StaticCell, args: Const.DEFAULT_INDICATOR))
            settingOptions.append(SettingOption(.Data, .Category, .StaticCell, preset: Const.PRESET_SEGMENT_CATEGORY, args: Const.DEFAULT_CATEGORY))
            
            for key in Const.RECOMMEND_KEYWORD {
                LocalService.shared.saveSearchHistory(key: key, type: .Recommend)
            }
            
            for dictionary in Const.PRESET_CATEGORY_MENU {
                let menu = MainMenu(value: dictionary)
                LocalService.shared.saveMenu(menu: menu)
            }
            
            canSetup = false
        }
    }
}
