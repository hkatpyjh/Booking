import UIKit
import ProgressHUD

struct SettingService {
    static var shared = SettingService()
    var setting: Setting!
    
    private init(){}
    
    mutating func initialization() {
        if let settingAsData = UserDefaults.standard.data(forKey: Const.SETTING_KEY) {
            setting = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [Setting.self], from: settingAsData) as! Setting
        }
        
        if setting == nil {
            setting = Setting()
            save()
        }
        
        let animationType = IndicatorType.init(rawValue: find(settingType: .Indicator).datas[0])!.type
        ProgressHUD.animationType = animationType
    }
    
    func save() {
        let settingAsData = try! NSKeyedArchiver.archivedData(withRootObject: setting!, requiringSecureCoding: true)

        UserDefaults.standard.set(settingAsData, forKey: Const.SETTING_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func find(settingType: SettingType) -> SettingOption {
        if let settingSection = setting.settingOptions.first(where: { $0.settingType == settingType }) {
            return settingSection
        }
        fatalError("Unexpected settingType(\(settingType))")
    }
    
    func update(settingOption: SettingOption) {
        if let index = setting.settingOptions.firstIndex(where: { $0.settingType == settingOption.settingType }) {
            setting.settingOptions[index] = settingOption
        }
    }
    
    func saveImage(img: UIImage, tmpFile: URL, name: String, completionBlock:@escaping ()->Void) {
        if let data = img.jpegData(compressionQuality: 0) {
            let imgURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: tmpFile)
            try? data.write(to: imgURL)
            completionBlock()
        }
    }
    
    func getImage(name: String) -> UIImage? {
        let imgURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        guard let imageData = try? Data(contentsOf: imgURL) else {
            return UIImage(systemName: "person.fill")!.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        
        return UIImage(data: imageData)
    }
}
