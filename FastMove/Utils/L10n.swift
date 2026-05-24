import Foundation
import SwiftUI

/// Simple localization helper. Follows system language automatically.
enum L10n {
    static func t(_ key: String) -> String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return dict[key]?[lang] ?? dict[key]?["en"] ?? key
    }

    static let dict: [String: [String: String]] = [
        "sourceFiles":   ["en": "Source Files",    "zh": "源文件"],
        "clearAll":      ["en": "Clear All",       "zh": "全部清除"],
        "dropHere":      ["en": "Drop files or folders here", "zh": "拖放文件或文件夹到此处"],
        "dropSupported": ["en": "Supports images, videos, documents, folders", "zh": "支持图片、视频、文档、文件夹"],
        "items":         ["en": "item(s)",         "zh": "个项目"],
        "dropMore":      ["en": "Drop more files here to add", "zh": "继续拖放以添加更多文件"],
        "removeHint":    ["en": "Remove from list","zh": "从列表中移除"],
        "targetFolder":  ["en": "Target Folder",   "zh": "目标文件夹"],
        "clear":         ["en": "Clear",           "zh": "清除"],
        "dropDest":      ["en": "Drop destination folder here", "zh": "拖放目标文件夹到此处"],
        "dropToReplace": ["en": "Drop to replace", "zh": "拖放以替换"],
        "progress":      ["en": "Progress",        "zh": "进度"],
        "ready":         ["en": "Ready",           "zh": "就绪"],
        "moving":        ["en": "Moving...",       "zh": "移动中…"],
        "done":          ["en": "Done",            "zh": "完成"],
        "cancelled":     ["en": "Cancelled",       "zh": "已取消"],
        "completed":     ["en": "Completed",       "zh": "已完成"],
        "failed":        ["en": "Failed",          "zh": "失败"],
        "pending":       ["en": "Pending",         "zh": "待处理"],
        "current":       ["en": "Current:",        "zh": "当前："],
        "cancel":        ["en": "Cancel",          "zh": "取消"],
        "startMoving":   ["en": "Start Moving",    "zh": "开始移动"],
        "log":           ["en": "Log",             "zh": "日志"],
        "lines":         ["en": "lines",           "zh": "行"],
        "noOutput":      ["en": "No output yet. Click \"Start Moving\" to begin.", "zh": "暂无输出。点击「开始移动」以开始。"],
    ]
}