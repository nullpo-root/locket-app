import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct LocketEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let senderName: String
    let caption: String
    let timeAgo: String
}

// MARK: - Timeline Provider
struct LocketProvider: TimelineProvider {
    let appGroupId = "group.com.example.locketApp"

    func placeholder(in context: Context) -> LocketEntry {
        LocketEntry(
            date: Date(),
            image: nil,
            senderName: "Locket",
            caption: "Tap to take a photo",
            timeAgo: "Just now"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LocketEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LocketEntry>) -> Void) {
        let entry = loadCurrentEntry()
        // Refresh every 15 minutes or when triggered by silent push / app reload
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> LocketEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let senderName = userDefaults?.string(forKey: "sender_name") ?? "Friend"
        let caption = userDefaults?.string(forKey: "caption") ?? ""
        let timeAgo = userDefaults?.string(forKey: "time_ago") ?? "Recently"
        let imagePath = userDefaults?.string(forKey: "image_path")

        var loadedImage: UIImage? = nil
        if let path = imagePath, FileManager.default.fileExists(atPath: path) {
            loadedImage = UIImage(contentsOfFile: path)
        }

        return LocketEntry(
            date: Date(),
            image: loadedImage,
            senderName: senderName,
            caption: caption,
            timeAgo: timeAgo
        )
    }
}

// MARK: - Widget View
struct LocketWidgetEntryView : View {
    var entry: LocketProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // Main Photo
                if let uiImage = entry.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    // Fallback placeholder
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 1.0, green: 0.835, blue: 0.0)) // Locket Gold
                        Text("No photos yet")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                // Top/Bottom gradient overlay for readability
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Sender Info & Time Badge (Locket Iconic Style)
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(entry.senderName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(entry.timeAgo)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .widgetURL(URL(string: "locket://open"))
    }
}

// MARK: - Widget Configuration
struct LocketWidget: Widget {
    let kind: String = "LocketWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LocketProvider()) { entry in
            LocketWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Locket Live Photo")
        .description("View live photo updates from your closest friends directly on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
