import Foundation
import Combine
import SwiftUI

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .chinese

    enum Language: String, CaseIterable, Identifiable {
        case chinese = "zh"
        case english = "en"

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .chinese: return "中文"
            case .english: return "English"
            }
        }
    }

    private let languageKey = "selected_language"

    init() {
        loadLanguage()
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
    }

    private func loadLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            // Detect system language (iOS 15 compatible)
            let systemLanguage = Locale.current.languageCode ?? Locale.current.identifier
            if systemLanguage.hasPrefix("zh") {
                currentLanguage = .chinese
            } else {
                currentLanguage = .english
            }
        }
    }
}

// MARK: - Localization Strings
struct Localization {
    static let strings: [LanguageManager.Language: [String: String]] = [
        .chinese: [
            "app_title": "🌎ORBIT",
            "search_placeholder": "🔎搜索卫星...",
            "days_label": "天数:",
            "elevation_label": "最高仰角≥",
            "time_filter_label": "仅19:00~23:59",
            "utc_filter_label": "UTC时间",
            "show_selected": "显示选中",
            "show_favorites": "显示收藏",
            "location": "📍位置",
            "no_location": "❌位置信息: 未获取",
            "calculating": "🔎预测中...",
            "no_passes": "⚠当前条件下未来3天内没有过境信息",
            "no_favorites": "⚠还没有收藏的卫星",
            "no_tle": "⚠无TLE信息",
            "unable_to_calc": "⚠请选择卫星并确认已定位",
            "notes": "ℹ️点击仰角: 实时对星\n⏰点击开始时间: 加入日历提醒",
            "satellite": "卫星",
            "date": "日期",
            "start": "开始",
            "max_elevation": "最高仰角",
            "end": "结束",
            "azimuth": "方位",
            "elevation": "仰角",
            "time": "时间",
            "tracking": "实时跟踪",
            "compass": "罗盘",
            "doppler": "多普勒",
            "frequency": "频率",
            "distance": "距离",
            "settings": "设置",
            "language": "语言",
            "theme": "主题",
            "about": "关于",
            "popular_satellites": "热门卫星",
            "favorites": "收藏",
            "remove_favorite": "移除收藏",
            "add_favorite": "添加收藏",
            "real_time": "实时",
            "history": "历史",
            "refresh": "刷新",
            "error": "错误",
            "loading": "加载中...",
            "retry": "重试",
            "cancel": "取消",
            "ok": "确定",
            "save": "保存",
            "delete": "删除",
            "edit": "编辑",
            "share": "分享",
            "copied": "已复制",
            "calendar": "日历",
            "add_to_calendar": "添加到日历",
            "calendar_added": "已添加到日历",
            "calendar_failed": "添加到日历失败",
            "permission_denied": "权限被拒绝",
            "permission_required": "需要权限",
            "location_permission": "需要位置权限来计算卫星过境",
            "motion_permission": "需要运动传感器权限来使用罗盘",
            "enable_permissions": "请在设置中启用权限",
            "open_settings": "打开设置",
            "latitude": "纬度",
            "longitude": "经度",
            "altitude": "高度",
            "manual_location": "手动输入位置",
            "use_current_location": "使用当前位置",
            "enter_latitude": "输入纬度",
            "enter_longitude": "输入经度",
            "enter_altitude": "输入高度 (米)",
            "save_location": "保存位置",
            "location_saved": "位置已保存",
            "location_failed": "保存位置失败",
        ],
        .english: [
            "app_title": "🌎ORBIT",
            "search_placeholder": "🔎Search satellites...",
            "days_label": "Days:",
            "elevation_label": "MAX. El ≥",
            "time_filter_label": "19:00~23:59",
            "utc_filter_label": "UTC Time",
            "show_selected": "Show selected",
            "show_favorites": "Show favorites",
            "location": "📍Location",
            "no_location": "❌Location: Not Retrieved",
            "calculating": "🔎Calculating...",
            "no_passes": "⚠No passes found for the next 3 days",
            "no_favorites": "⚠There is no favorite SAT",
            "no_tle": "⚠TLE not found",
            "unable_to_calc": "⚠Please select a satellite and confirm that the location has been determined",
            "notes": "ℹ️Click El: Real-time tracking\n⏰Click Date: Add to calendar",
            "satellite": "SAT",
            "date": "Date",
            "start": "Start",
            "max_elevation": "Max. El",
            "end": "End",
            "azimuth": "Az",
            "elevation": "El",
            "time": "Time",
            "tracking": "Tracking",
            "compass": "Compass",
            "doppler": "Doppler",
            "frequency": "Frequency",
            "distance": "Distance",
            "settings": "Settings",
            "language": "Language",
            "theme": "Theme",
            "about": "About",
            "popular_satellites": "Popular",
            "favorites": "Favorites",
            "remove_favorite": "Remove",
            "add_favorite": "Add",
            "real_time": "Real-time",
            "history": "History",
            "refresh": "Refresh",
            "error": "Error",
            "loading": "Loading...",
            "retry": "Retry",
            "cancel": "Cancel",
            "ok": "OK",
            "save": "Save",
            "delete": "Delete",
            "edit": "Edit",
            "share": "Share",
            "copied": "Copied",
            "calendar": "Calendar",
            "add_to_calendar": "Add to Calendar",
            "calendar_added": "Added to Calendar",
            "calendar_failed": "Failed to add to Calendar",
            "permission_denied": "Permission Denied",
            "permission_required": "Permission Required",
            "location_permission": "Location permission required for satellite pass calculation",
            "motion_permission": "Motion sensor permission required for compass",
            "enable_permissions": "Please enable permissions in Settings",
            "open_settings": "Open Settings",
            "latitude": "Latitude",
            "longitude": "Longitude",
            "altitude": "Altitude",
            "manual_location": "Manual Location",
            "use_current_location": "Use Current Location",
            "enter_latitude": "Enter Latitude",
            "enter_longitude": "Enter Longitude",
            "enter_altitude": "Enter Altitude (m)",
            "save_location": "Save Location",
            "location_saved": "Location Saved",
            "location_failed": "Failed to Save Location",
        ]
    ]

    static func localizedString(for key: String, language: LanguageManager.Language) -> String {
        return strings[language]?[key] ?? key
    }
}

// MARK: - View Extension for Localization
extension View {
    func localized(_ key: String, language: LanguageManager.Language) -> some View {
        Text(Localization.localizedString(for: key, language: language))
    }
}