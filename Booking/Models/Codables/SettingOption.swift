import UIKit

struct SettingOption: Codable {
    let section: SettingSection
    let settingType: SettingType
    let cellType: SettingCellType
    var args: [String]
    var datas: [String]
    var preset: [String]
    var isOn: Bool
    
    init(_ section: SettingSection, _ settingType: SettingType, _ cellType: SettingCellType, preset: [String] = [], args: [String] = [], isOn: Bool = false) {
        self.section = section
        self.settingType = settingType
        self.cellType = cellType
        self.args = args
        self.isOn = isOn
        self.preset = preset
        
        switch settingType {
        case .Profile:
            self.datas = args.suffix(args.count - 1)
        default:
            self.datas = args.suffix(args.count - 2)
        }
    }
}
