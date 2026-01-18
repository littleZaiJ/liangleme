import SwiftUI

struct AnalysisView: View {
    @State private var chatText = ""
    @State private var showingReport = false
    @State private var analysisResult: AIAnalysisResult?
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var isAnalyzing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("聊天记录分析")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            Text("粘贴文字或上传聊天截图，让我们看看死因是什么")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal)

                            // 图片选择区域
                            VStack(spacing: 12) {
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 20))
                                        Text("上传聊天截图（最多5张）")
                                            .font(.system(size: 16, design: .serif))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.deadGrey.opacity(0.5))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)

                                // 已选择的图片预览
                                if !selectedImages.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                                    Button(action: {
                                                        selectedImages.remove(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.black.opacity(0.6))
                                                            .clipShape(Circle())
                                                    }
                                                    .offset(x: 5, y: -5)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.horizontal)

                            // 文本输入区域
                            TextEditor(text: $chatText)
                                .font(.system(size: 16, design: .serif))
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .frame(minHeight: 150)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.deadGrey.opacity(0.3))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.horizontal)

                            if chatText.isEmpty {
                                Text("或者在此输入聊天记录...")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.horizontal, 32)
                                    .padding(.top, -130)
                            }
                        }

                        Button(action: {
                            Task {
                                await analyzeChatHistory()
                            }
                        }) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("分析中...")
                                        .font(.system(size: 18, weight: .semibold, design: .serif))
                                        .foregroundColor(.white)
                                } else {
                                    Text("分析死因")
                                        .font(.system(size: 18, weight: .semibold, design: .serif))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.kleinBlue)
                            )
                        }
                        .padding(.horizontal)
                        .disabled(chatText.isEmpty && selectedImages.isEmpty || isAnalyzing)
                        .opacity(chatText.isEmpty && selectedImages.isEmpty || isAnalyzing ? 0.5 : 1.0)

                        if let result = analysisResult {
                            DeathReportCard(result: result)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("尸检科")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
        }
    }

    private func analyzeChatHistory() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let result: AIAnalysisResult

            if !selectedImages.isEmpty && !chatText.isEmpty {
                // 图片+文本组合分析
                result = try await AIService.shared.analyzeCombined(text: chatText, images: selectedImages)
            } else if !selectedImages.isEmpty {
                // 仅图片分析
                result = try await AIService.shared.analyzeImage(selectedImages[0])
            } else {
                // 仅文本分析
                result = try await AIService.shared.analyzeText(chatText)
            }

            withAnimation {
                analysisResult = result
                showingReport = true
            }
        } catch {
            // 错误处理
            print("Analysis failed: \(error)")
        }
    }
}

struct DeathReportCard: View {
    let result: AIAnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("死亡报告")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                Text("死因:")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.white.opacity(0.7))

                Text(result.cause)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.red)
            }

            if !result.keywords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("检测到的关键词:")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.white.opacity(0.7))

                    FlowLayout(spacing: 8) {
                        ForEach(result.keywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.3))
                                )
                        }
                    }
                }
            }

            if let details = result.details {
                VStack(alignment: .leading, spacing: 8) {
                    Text("详细分析:")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.white.opacity(0.7))

                    Text(details)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                Text("建议:")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.white.opacity(0.7))

                Text(result.suggestion)
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.white)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.deadGrey.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red.opacity(0.5), lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

// 流式布局用于关键词
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    AnalysisView()
}
