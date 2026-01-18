import Foundation
import UIKit

// MARK: - AI分析结果
struct AIAnalysisResult {
    let cause: String
    let suggestion: String
    let keywords: [String]
    let details: String?
}

// MARK: - AI服务协议
protocol AIServiceProtocol {
    func analyzeText(_ text: String) async throws -> AIAnalysisResult
    func analyzeImage(_ image: UIImage) async throws -> AIAnalysisResult
    func analyzeCombined(text: String, images: [UIImage]) async throws -> AIAnalysisResult
}

// MARK: - AI服务实现
class AIService: AIServiceProtocol {
    static let shared = AIService()

    private init() {}

    // TODO: 配置大模型API
    private var apiKey: String? {
        // 从配置文件或环境变量读取
        return nil
    }

    private var apiEndpoint: String {
        // 可以配置为Claude、OpenAI等
        return "https://api.anthropic.com/v1/messages"
    }

    // MARK: - 文本分析
    func analyzeText(_ text: String) async throws -> AIAnalysisResult {
        // TODO: 接入大模型进行分析
        // 目前使用本地分析作为fallback
        return localAnalyzeText(text)
    }

    // MARK: - 图片分析
    func analyzeImage(_ image: UIImage) async throws -> AIAnalysisResult {
        // TODO: 接入大模型进行图片OCR和分析
        // 1. 将图片转为base64
        // 2. 调用大模型API进行识别
        // 3. 解析返回结果

        // 目前返回提示信息
        return AIAnalysisResult(
            cause: "图片分析功能开发中",
            suggestion: "请接入大模型API以启用图片分析",
            keywords: [],
            details: "将实现OCR识别聊天记录截图并进行情感分析"
        )
    }

    // MARK: - 组合分析（文本+图片）
    func analyzeCombined(text: String, images: [UIImage]) async throws -> AIAnalysisResult {
        // TODO: 同时分析文本和图片
        // 优先使用图片中的内容，文本作为补充

        if images.isEmpty {
            return try await analyzeText(text)
        }

        // 目前返回本地文本分析
        return localAnalyzeText(text)
    }

    // MARK: - 本地分析（Fallback）
    private func localAnalyzeText(_ text: String) -> AIAnalysisResult {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let lowercasedText = text.lowercased()

        let keywordsToCheck = ["呵呵", "嗯", "哦", "洗澡", "忙", "哈哈", "好的", "可以"]
        var foundKeywords: [String] = []

        for keyword in keywordsToCheck {
            if lowercasedText.contains(keyword) {
                foundKeywords.append(keyword)
            }
        }

        let lineCount = lines.count
        var cause = ""
        var suggestion = ""
        var details = ""

        if !foundKeywords.isEmpty && foundKeywords.count >= 3 {
            cause = "敷衍性回复"
            suggestion = "对方已经懒得好好说话了，建议拉黑"
            details = "检测到多个敷衍关键词，对方明显兴趣不高"
        } else if lineCount < 5 {
            cause = "冷暴力"
            suggestion = "话都不愿意多说，在那边多烧点纸吧"
            details = "聊天记录过短，对方可能不想继续交流"
        } else if lowercasedText.contains("哈哈") && lowercasedText.components(separatedBy: "哈哈").count > 3 {
            cause = "已读乱回"
            suggestion = "笑着笑着就没了，和陪聊有什么区别"
            details = "过度使用'哈哈'通常是尴尬的表现"
        } else if foundKeywords.contains("嗯") || foundKeywords.contains("哦") {
            cause = "单字敷衍综合征"
            suggestion = "一个字能解决的事，绝不说两个字"
            details = "单字回复是典型的不想聊天信号"
        } else {
            cause = "对你没兴趣"
            suggestion = "醒醒吧，别再自我感动了"
            details = "综合分析显示对方兴趣度较低"
        }

        return AIAnalysisResult(
            cause: cause,
            suggestion: suggestion,
            keywords: foundKeywords,
            details: details
        )
    }
}

// MARK: - API调用示例（待实现）
extension AIService {
    /*
    // 示例：调用Claude API
    private func callClaudeAPI(text: String, images: [UIImage]? = nil) async throws -> AIAnalysisResult {
        guard let apiKey = apiKey else {
            throw AIServiceError.missingAPIKey
        }

        var messages: [[String: Any]] = [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": """
                        请分析这段聊天记录，判断对方的态度。
                        重点关注：
                        1. 回复的积极性
                        2. 是否敷衍（如：嗯、哦、哈哈）
                        3. 字数和情感投入

                        聊天内容：
                        \(text)

                        请返回JSON格式：
                        {
                            "cause": "死因",
                            "suggestion": "建议",
                            "keywords": ["关键词"],
                            "details": "详细分析"
                        }
                        """
                    ]
                ]
            ]
        ]

        // 如果有图片，添加到content中
        if let images = images {
            for image in images {
                if let base64 = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() {
                    // 添加图片到消息中
                }
            }
        }

        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1024,
            "messages": messages
        ]

        var request = URLRequest(url: URL(string: apiEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        // 解析响应
        // ...

        return AIAnalysisResult(cause: "", suggestion: "", keywords: [], details: nil)
    }
    */
}

enum AIServiceError: Error {
    case missingAPIKey
    case invalidResponse
    case networkError
}
