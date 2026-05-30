import Foundation
import SwiftUI

enum L10n {
    static func t(_ key: String) -> String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return dict[key]?[lang] ?? dict[key]?["en"] ?? key
    }

    static let dict: [String: [String: String]] = [
        "sourceFiles": ["en": "Source Files", "zh": "源文件"],
        "clearAll": ["en": "Clear All", "zh": "全部清除"],
        "dropFilesHere": ["en": "Drop files or folders here", "zh": "拖放文件或文件夹到此处"],
        "items": ["en": "Items", "zh": "个项目"],
        "remove": ["en": "Remove", "zh": "移除"],
        "added": ["en": "Added", "zh": "已添加"],
        "files": ["en": "Files", "zh": "文件"],
        "folders": ["en": "Folder", "zh": "文件夹"],
        "targetFolder": ["en": "Target Folder", "zh": "目标文件夹"],
        "dropTargetHere": ["en": "Drop target folder here", "zh": "拖放目标文件夹到此处"],
        "favorites": ["en": "Favorites", "zh": "收藏"],
        "noFavorites": ["en": "No favorites yet", "zh": "暂无收藏"],
        "unfavorite": ["en": "Remove from favorites", "zh": "取消收藏"],
        "recent": ["en": "Recent", "zh": "最近使用"],
        "noRecent": ["en": "No recent folders", "zh": "暂无最近使用"],
        "startMoving": ["en": "Start Moving", "zh": "开始移动"],
        "moving": ["en": "Moving files...", "zh": "正在移动文件..."],
        "moveCompleted": ["en": "Move Completed", "zh": "移动完成"],
        "moveFailed": ["en": "Move Failed", "zh": "移动失败"],
        "filesFailed": ["en": "Files Failed", "zh": "个文件失败"],
        "partialSuccess": ["en": "Partial Success", "zh": "部分成功"],
        "movedMessage": [
            "en": "{success} files moved, {failed} failed",
            "zh": "{success} 个文件已移动, {failed} 个失败"
        ],
        "openDestination": ["en": "Open Destination", "zh": "打开目标位置"],
        "revealInFinder": ["en": "Reveal in Finder", "zh": "在 Finder 中显示"],
        "retryFailed": ["en": "Retry Failed", "zh": "重试失败文件"],
        "changeTarget": ["en": "Change folder", "zh": "切换文件夹"],
        "clickToBrowse": ["en": "or click to browse", "zh": "或点击浏览"],
        "selectTargetFolder": ["en": "Select target folder", "zh": "选择目标文件夹"],
        "undo": ["en": "Undo", "zh": "撤销"],
        "undone": ["en": "Undone", "zh": "已撤销"],
        "undoCompleted": ["en": "Move undone", "zh": "已撤销移动"],
        "undoFailed": ["en": "Undo failed", "zh": "撤销失败"],
        "failed": ["en": "failed", "zh": "失败"],
    ]
}
