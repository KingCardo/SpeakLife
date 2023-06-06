//
//  PromisesWidget.swift
//  PromisesWidget
//
//  Created by Riccardo Washington on 11/2/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let content = "I am blessed!"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), promise: content)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), promise: content)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
                let endDate = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
                let thirtyMinutes: TimeInterval = 60 * 30
                var entries: [SimpleEntry] = []

                var currentDate = Date()
                while currentDate < endDate {
                    let declaration = Data.declarations.randomElement() ?? content
                    let entry = SimpleEntry(date: currentDate, promise: declaration)
                    currentDate += thirtyMinutes
                    entries.append(entry)
                }

                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
    }
}
extension Provider {
    struct Data {
        static let declarations: [String] = ["I tell you, you can pray for anything, and if you believe that you’ve received it, it will be yours.",
        "Love is patient and kind. Love is not jealous or boastful or proud or rude. It does not demand its own way. It is not irritable, and it keeps no record of being wronged.",
         "Always be joyful. Never stop praying. Be thankful in all circumstances, for this is God’s will for you who belong to Christ Jesus.",
         "The Lord is for me, so I will have no fear. What can mere people do to me?",
          "The Lord keeps watch over you as you come and go, both now and forever.",
            "You must serve only the Lord your God. If you do, I will bless you with food and water, and I will protect you from illness.",
           "I am leaving you with a gift—peace of mind and heart. And the peace I give is a gift the world cannot give. So don’t be troubled or afraid.",
            "How much better to get wisdom than gold, and good judgment than silver!",
           "A fool is quick-tempered, but a wise person stays calm when insulted.",
            "The light shines in the darkness, and the darkness can never extinguish it.",
            "For you know that when your faith is tested, your endurance has a chance to grow.",
           "Three things will last forever—faith, hope, and love—and the greatest of these is love.",
            "Don’t worry about anything; instead, pray about everything. Tell God what you need, and thank him for all he has done.",
            "For God has not given us a spirit of fear and timidity, but of power, love, and self-discipline.",
            "\"For I know the plans I have for you,\" says the Lord. \"They are plans for good and not for disaster, to give you a future and a hope.\"",
            "Kind words are like honey— sweet to the soul and healthy for the body.",
            "I have told you all this so that you may have peace in me. Here on earth you will have many trials and sorrows. But take heart, because I have overcome the world.",
            "Wealth from get-rich-quick schemes quickly disappears; wealth from hard work grows over time.",
            "Better to be patient than powerful; better to have self-control than to conquer a city.",
            "So I say, let the Holy Spirit guide your lives. Then you won’t be doing what your sinful nature craves.",
            "Faith shows the reality of what we hope for; it is the evidence of things we cannot see.",
            "And do everything with love.",
            "But thank God! He gives us victory over sin and death through our Lord Jesus Christ.",
            "I pray that God, the source of hope, will fill you completely with joy and peace because you trust in him. Then you will overflow with confident hope through the power of the Holy Spirit.",
            "So now wrap your heart tightly around the hope that lives within us, knowing that God always keeps his promises!",
            "So whether you eat or drink or whatever you do, do it all for the glory of God.",
            "Now may the Lord of peace himself give you his peace at all times and in every situation. The Lord be with you all.",
            "Honor the Lord with your wealth and with the best part of everything you produce.",
            "A person without self-control is like a city with broken-down walls.",
            "Let your unfailing love surround us, Lord, for our hope is in you alone.",
            "For it is by believing in your heart that you are made right with God, and it is by openly declaring your faith that you are saved.",
            "Most important of all, continue to show deep love for each other, for love covers a multitude of sins.",
            "Devote yourselves to prayer with an alert mind and a thankful heart.",
            "Fearing people is a dangerous trap, but trusting the Lord means safety.",
            "I am counting on the Lord; yes, I am counting on him. I have put my hope in his word.",
            "I will reward them with a long life and give them my salavtion",
            "So letting your sinful nature control your mind leads to death. But letting the Spirit control your mind leads to life and peace.",
            "Work hard and become a leader; be lazy and become a slave.",
            "The Lord is more pleased when we do what is right and just than when we offer him sacrifices.",
            "Let us hold tightly without wavering to the hope we affirm, for God can be trusted to keep his promise.",
            "So faith comes from hearing, that is, hearing the Good News about Christ.",
            "Love does no wrong to others, so love fulfills the requirements of God's law.",
            "This is the day the Lord has made. We will rejoice and be glad in it.",
            "Don't be afraid, for I am with you. Don't be discouraged, for I am your God. I will strengthen you and help you. I will hold you up with my victorious right hand.",
            "But if we look forward to something we don't yet have, we must wait patiently and confidently.",
            "Don’t you realize that your body is the temple of the Holy Spirit, who lives in you and was given to you by God? You do not belong to yourself, for God bought you with a high price. So you must honor God with your body.",
            "The Lord gives his people strength. The Lord blesses them with peace.",
            "Choose a good reputation over great riches; being held in high esteem is better than silver or gold.",
            "The temptations in your life are no different from what others experience. And God is faithful. He will not allow the temptation to be more than you can stand. When you are tempted, he will show you a way out so that you can endure.",
            "Trust in the Lord with all your heart; do not depend on your own understanding.",
            "And it is impossible to please God without faith. Anyone who wants to come to him must believe that God exists and that he rewards those who sincerely seek him.",
            "\"I tell you, you can pray for anything, and if you believe that you’ve received it, it will be yours.\"",
            "\"I tell you the truth, you can say to this mountain, ‘May you be lifted up and thrown into the sea,’ and it will happen. But you must really believe it will happen and have no doubt in your heart.\"",
            "Our life is lived by faith. We do not live by what we see in front of us.",
            "For the word of God will never fail.",
            "But when you ask him, be sure that your faith is in God alone. Do not waver, for a person with divided loyalty is as unsettled as a wave of the sea that is blown and tossed by the wind.",
            "If you openly declare that Jesus is Lord and believe in your heart that God raised him from the dead, you will be saved."]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let promise: String
    
}

struct Gradients {

    let colors: [Color] = [.cyan, .purple, .white, .red]

    func randomColors() -> [Color] {
        let shuffledColors = colors.shuffled()
        let array = Array(shuffledColors.prefix(2))
        return array
    }

    var purple: some View {
        LinearGradient(gradient: Gradient(colors: randomColors()), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PromisesGlanceView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let affirmation: String
    
    var fontSize: CGFloat {
        switch family {
        case .systemMedium: return 16
        default: return 24
        }
    }
    
    private let opacity = 0.85
    
    var body: some View {
        ZStack {
            Gradients().purple.opacity(opacity)
            Text(affirmation)
                .foregroundColor(.white)
                .font(.custom("BodoniSvtyTwoOSITCTT-Book", size: fontSize))
                .fontWeight(.medium)
                .padding()
        }
    }
}

struct PromisesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        PromisesGlanceView(affirmation: entry.promise)
    }
}

@main
struct PromisesWidget: Widget {
    let kind: String = "PromisesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PromisesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Promises")
        .description("Shows today's Bible promises.")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct PromisesWidget_Previews: PreviewProvider {
    static var previews: some View {
        PromisesWidgetEntryView(entry: SimpleEntry(date: Date(), promise:  "God loves you!"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
