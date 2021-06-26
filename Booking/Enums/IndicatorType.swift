import Foundation
import ProgressHUD

enum IndicatorType: String, CaseIterable {
    case systemActivityIndicator
    case horizontalCirclesPulse
    case lineScaling
    case singleCirclePulse
    case multipleCirclePulse
    case singleCircleScaleRipple
    case multipleCircleScaleRipple
    case circleSpinFade
    case lineSpinFade
    case circleRotateChase
    case circleStrokeSpin
    
    var type: AnimationType {
        switch self {
        case .systemActivityIndicator:
            return .systemActivityIndicator
        case .horizontalCirclesPulse:
            return .horizontalCirclesPulse
        case .lineScaling:
            return .lineScaling
        case .singleCirclePulse:
            return .singleCirclePulse
        case .multipleCirclePulse:
            return .multipleCirclePulse
        case .singleCircleScaleRipple:
            return .singleCircleScaleRipple
        case .multipleCircleScaleRipple:
            return .multipleCircleScaleRipple
        case .circleSpinFade:
            return .circleSpinFade
        case .lineSpinFade:
            return .lineSpinFade
        case .circleRotateChase:
            return .circleRotateChase
        case .circleStrokeSpin:
            return .circleStrokeSpin
        }
    }
}
