import SwiftUI

/// Sheet gom các nội dung tham khảo thêm ngoài bảng chữ cái: quy tắc phát âm
/// (phụ âm cuối, nối âm) và số đếm tiếng Hàn.
struct ReferenceMenuView: View {
    let language: AppLanguage

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    PronunciationRulesView(language: language)
                } label: {
                    row(icon: "waveform", title: L.pronunciationRulesTitle(language), subtitle: L.pronunciationRulesSubtitle(language))
                }

                NavigationLink {
                    NumbersView(language: language)
                } label: {
                    row(icon: "textformat.123", title: L.numbersTitle(language), subtitle: L.numbersSubtitle(language))
                }
            }
            .navigationTitle(L.referenceTitle(language))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ReferenceMenuView(language: .vi)
}
