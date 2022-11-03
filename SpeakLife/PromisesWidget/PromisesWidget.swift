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
        static let declarations: [String] = ["I am filled with love, peace, joy and hope!", "I believe my angels are with me keeping me safe.", "God will turn every bad circumstance to turn out for my good!", "I am exactly where I'm meant to be.", "My prayers are always being listened to by the Creator of the Universe!", "I'm not concerned with other people's opinion's of me.",  "I love the person I am becoming.",  "I love the person I see in the mirror." , "Taking care of myself is a top priority.", "I ask God to guide my steps when I feel lost.", "Never settle for a life you don't want out of fear to go after what you truly want.", "I am inspired to do great things with my life!", "I am ready to put in the work to succeed!", "I am proud for how far I've come!", "I won't listen to the lying thoughts that try to make me afraid!", "I am thankful for food and clean water I have access to every day!", "I am thankful for all my future blessings!", "Thankfulness creates more doors of blessings!", "I am thankful for my family!", "I am grateful I have everything inside me to be successful!",  "I am highly favored!", "My gratitude attracts abundance!", "I am much more powerful than I think!", "I am a strong, wise, warrior!", "I am the author of my life!", "It's ok to feel fear, but I will respond in peace!",  "I prioritize people who bring peace!", "I will overcome every fear and obstacle!", "On hard days I always believe better days are coming!", "I was born to find and fulfill my purpose!", "I am getting closer and closer to my dreams!", "I feed my spirit daily!", "My experiences was necessary for the success that's coming!", "I am a very happy person!", "I am the only one that has the keys to my happiness!", "I am loving the results of taking care of myself.", "I choose to prioritize my health.", "I will workout to stay fit!", "I will protect my peace at all cost!", "My mind is sharp and alert!", "God gives me peace in my storms!", "Taking time for myself is very necessary!", "I am mindful of my thoughts and reject all negativity!", "Abundance and prosperity is coming my way!", "I attract prosperity with my choices.", "I am making a lot of money doing what I love!", "My financial future is bright!", "I start my day with positive affirmations!",  "I take care of myself spiritually, mentally, and physically!",  "I pursue my passions!", "God is with me wherever I go!", "I was made for a special reason and will fulfill it.", "Even when a door closes, I know God will lead me to the right one!", "I choose to respond in love.", "I love myself.",  "I love what I do.", "Being grateful keeps me happy in the present.", "I am thankful for all the closed doors that wasn't meant for me.", "I am thankful for my friends who push me to be better!", "I have extreme persistence!", "I wake up grateful for a new day to live!", "I am thankful for everything I learned on the journey!", "I will make intentional choices that bring peace!", "I am in control of how I respond to every situation.", "I won't waste time worrying!", "I choose faith over fear!", "I can change my mindset with discipline and practice!", "Fear is like a paper tooth tiger!", "I declare my health gets better everyday!", "I drink water, get fresh air, exercise and get plenty of rest.", "I reap the benefits of my healthy choices.", "My body functions perfectly how God designed it to.", "I am always becoming a better version of myself.", "God gives me peace wherever I go!", "My angels follow me everywhere I go.", "I release my worries to God and absorb peace.",  "I am thankful for all I have now, and making room for more.",  "I level up in everything I do.", "My visions are becoming reality!", "I am attracting new opportunites everyday.", "I only have one life, and I won't waste it.", "One step at a time, I will achieve my goals.", "I forgive myself for my past mistakes.", "Good news is coming!", "I spend time with positive, loving people.", "Life is just getting better and better.", "Challenges are a part of the journey to greatness.", "I trust the plans God has for me.", "My standards are high because of how I value myself.", "I am bold and fearless.", "Thankfulness has helped me view the world differently.", "I am thankful for my passions."]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let promise: String
    
}

struct PromisesGlanceView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let affirmation: String
    
    var fontSize: CGFloat {
        switch family {
        case .systemSmall: return 20
        default: return 24
        }
    }
    
    private let opacity = 0.85
    
    var body: some View {
        ZStack {
            Color.cyan.opacity(opacity)
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
        .supportedFamilies([.systemSmall, .systemMedium,.systemLarge])
    }
}

struct PromisesWidget_Previews: PreviewProvider {
    static var previews: some View {
        PromisesWidgetEntryView(entry: SimpleEntry(date: Date(), promise:  "God loves you!"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
