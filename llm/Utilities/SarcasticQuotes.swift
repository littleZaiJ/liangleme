import Foundation

struct SarcasticQuotes {
    static let quotes = [
        "他在回了，在回别人了",
        "洗澡能洗三个小时？",
        "可能手机掉马桶了吧",
        "别等了，再等就馊了",
        "你的消息已进入黑洞",
        "对方正在忙着无视你",
        "建议先挂个号看看自己",
        "时间不会说谎，人会",
        "你的卑微已刷新记录",
        "在那边多烧点纸吧",
        "敷衍的最高境界是不回",
        "你猜他是不是已经睡着了",
        "可能在陪别人聊天呢",
        "你的期待已过期",
        "社交死亡现场直播中"
    ]

    static func random() -> String {
        quotes.randomElement() ?? "..."
    }
}
