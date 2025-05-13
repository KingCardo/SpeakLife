//
//  Untitled.swift
//  SpeakLife
//
//  Created by Riccardo Washington on 5/13/25.
//

import Foundation

struct Quiz: Identifiable {
    let id: UUID = UUID()
    let title: String
    let questions: [(String, [String], Int, String)]
}

let questions = [
    (
        "What should you do when the devil whispers, 'You're not good enough'?",
        ["Agree and try harder", "Ignore it", "Speak God's truth aloud", "Complain to a friend"],
        2,
        "Speak the truth: ‘I am the righteousness of God in Christ’ (2 Cor. 5:21)."
    ),
    (
        "You feel anxiety rising—what's the best first response?",
        ["Accept it as normal", "Declare 'God has not given me a spirit of fear'", "Distract yourself", "Call someone"],
        1,
        "Use 2 Tim. 1:7. Speaking Scripture out loud silences fear and activates peace."
    ),
    (
        "What do you do when symptoms hit your body suddenly?",
        ["Panic", "Pray silently", "Declare healing Scriptures", "Search online for answers"],
        2,
        "Isaiah 53:5 says by His wounds, we are healed. Speak healing boldly."
    ),
    (
        "The enemy says you’ll never change—what do you say?",
        ["Maybe that’s true", "Say nothing", "Declare 'I am a new creation in Christ'", "Try to prove him wrong"],
        2,
        "2 Cor. 5:17 — remind yourself and the enemy of your reborn identity."
    ),
    (
        "What’s the best response when your finances look hopeless?",
        ["Cry", "Declare God is your provider", "Blame yourself", "Work more hours"],
        1,
        "Declare: 'My God supplies all my needs' (Phil. 4:19). Speak faith, not fear."
    ),
    (
        "In the middle of a trial, what honors God most?",
        ["Complaining", "Silence", "Worship and gratitude", "Waiting to see what happens"],
        2,
        "Psalm 34:1 — 'I will bless the Lord at all times.' Praise shifts the atmosphere."
    ),
    (
        "The enemy whispers, 'You're alone' — what do you speak?",
        ["It's true", "Call a friend", "Declare 'God will never leave me'", "Cry it out"],
        2,
        "Hebrews 13:5 — God promised never to leave or forsake you. Speak it with boldness."
    ),
    (
        "You feel shame from your past — what now?",
        ["Own it", "Bury it", "Speak 'I’m forgiven and free'", "Try harder to be better"],
        2,
        "Romans 8:1 — No condemnation in Christ. Declare freedom!"
    ),
    (
        "How do you renew your mind daily?",
        ["Ignore bad thoughts", "Think positive", "Read and speak Scripture", "Pray only in church"],
        2,
        "Romans 12:2 — Be transformed by renewing your mind with God's Word."
    ),
    (
        "The devil says your future is doomed—how do you answer?",
        ["Believe it", "Speak Jeremiah 29:11", "Worry", "Wait and see"],
        1,
        "Speak: 'God has plans to prosper me, not to harm me.' Faith speaks."
    ),
    (
        "What do you do when you feel unworthy to pray?",
        ["Stay silent", "Try to fix yourself", "Declare your righteousness in Jesus", "Ask someone else to pray"],
        2,
        "Hebrews 4:16 — Come boldly to the throne because of Jesus, not your performance."
    ),
    (
        "When healing is slow, what should your response be?",
        ["Doubt it", "Keep declaring the Word", "Complain", "Give up"],
        1,
        "Faith holds on to the Word. Keep speaking it (Hebrews 10:23)."
    ),
    (
        "If symptoms return after prayer, what do you do?",
        ["Accept them", "Keep standing on God's promise", "Search for new remedies", "Blame yourself"],
        1,
        "Symptoms don’t cancel God’s Word. Keep standing — healing is yours (Isaiah 53:5)."
    ),
    (
        "The enemy says 'You’ll always be stuck' — what’s the truth?",
        ["Maybe he’s right", "Hope it changes", "Declare freedom in Jesus", "Stay quiet"],
        2,
        "John 8:36 — Whom the Son sets free is free indeed. Speak your freedom."
    ),
    (
        "When things don’t change fast, what do you believe?",
        ["It’s not working", "God’s Word is still true", "I must be doing something wrong", "Quit"],
        1,
        "God’s Word never fails (Isaiah 55:11). Speak it, believe it, wait in faith."
    )
]

let healingQuizQuestions = [
    (
        "What’s the first step to receiving healing?",
        ["Beg God to heal you", "Keep reading healing testimonies", "Hear and believe God’s Word", "Try natural remedies"],
        2,
        "Faith comes by hearing the Word (Romans 10:17). Healing begins with revelation."
    ),
    (
        "What should you do when symptoms return?",
        ["Accept them", "Speak God's Word louder", "Change your prayer", "Try harder"],
        1,
        "Don’t draw back—declare the truth: 'By His stripes I am healed' (Isaiah 53:5)."
    ),
    (
        "What does it mean to prioritize God's Word?",
        ["Make time when convenient", "Read it once a week", "Feed on it daily like food", "Quote it only in emergencies"],
        2,
        "God’s Word is life and health (Proverbs 4:20–22). Feed on it daily like vital nourishment."
    ),
    (
        "How do you respond to lying symptoms?",
        ["Trust what you feel", "Google them", "Speak the truth in faith", "Call your doctor immediately"],
        2,
        "Symptoms are temporary facts. Truth is eternal. Speak the Word until facts bow to it."
    ),
    (
        "What’s the danger of focusing on how you feel?",
        ["You might feel worse", "It helps nothing", "It empowers doubt", "It’s natural"],
        2,
        "What you focus on grows. Focusing on symptoms empowers fear, not faith."
    ),
    (
        "How do you keep your healing?",
        ["Rest and eat well", "Keep hearing and speaking the Word", "Tell no one", "Keep testing yourself"],
        1,
        "Faith is a lifestyle. Keep feeding on the Word to stay strong and whole (Joshua 1:8)."
    ),
    (
        "What did Jesus say brings healing?",
        ["Hope", "Touching His garment", "Faith in Him", "Being good enough"],
        2,
        "Jesus told many: 'Your faith has made you whole.' Faith in His finished work heals."
    ),
    (
        "When do you stop speaking the Word?",
        ["When you feel better", "After 3 days", "When symptoms leave", "Never"],
        3,
        "The Word is your sword—don’t put it down. Keep speaking to guard your health (Eph. 6:17)."
    ),
    (
        "How often should you hear God’s healing Word?",
        ["Every Sunday", "Occasionally", "Daily", "When you're sick"],
        2,
        "Faith comes by *hearing* — not once, but continually (Romans 10:17)."
    ),
    (
        "Why is repetition of Scripture important?",
        ["It helps memory", "It impresses others", "It builds unshakable faith", "It’s tradition"],
        2,
        "Repetition renews your mind and transforms you from the inside out (Romans 12:2)."
    ),
    (
        "God’s Word is medicine. How should you take it?",
        ["With food", "Once in crisis", "Consistently, with faith", "At night only"],
        2,
        "Proverbs 4:22 calls the Word health to all your flesh—take it daily like medicine."
    ),
    (
        "You feel discouraged about progress—what now?",
        ["Stop trying", "Look for a new teaching", "Speak God’s promises again", "Rest more"],
        2,
        "Encourage yourself in the Lord (1 Samuel 30:6). Speak what’s true, not what you feel."
    ),
    (
        "What do you do when results are slow?",
        ["Doubt", "Press in more to the Word", "Give it a break", "Try something new"],
        1,
        "Keep planting and watering with the Word—God gives the increase (1 Cor. 3:6)."
    ),
    (
        "How do you know you're healed if symptoms remain?",
        ["You don't", "You speak what God said", "You ask others", "You wait for proof"],
        1,
        "We walk by faith, not by sight (2 Cor. 5:7). Believe and speak God’s Word over your body."
    ),
    (
        "What should your mouth always align with?",
        ["Feelings", "Doctor’s report", "God’s report", "What seems likely"],
        2,
        "'Let the redeemed of the Lord say so' (Psalm 107:2). Speak what Heaven says, not the world."
    )
    ]

let peaceQuizQuestions = [
    (
        "Someone cuts you off in traffic. What do you do?",
        ["Yell at them", "Bless them and speak peace", "Let it ruin your day", "Hold it in"],
        1,
        "Speak peace instead of offense — 'Bless those who curse you' (Luke 6:28)."
    ),
    (
        "Your day feels rushed and overwhelming. What's your first move?",
        ["Power through", "Take a deep breath and give it to Jesus", "Complain", "Multitask harder"],
        1,
        "Cast your cares on Him (1 Peter 5:7). Peace starts with surrender."
    ),
    (
        "You're feeling irritated for no clear reason. What should you speak?",
        ["This day is ruined", "I just need coffee", "I have the mind of Christ", "I’m so done"],
        2,
        "Speak identity over emotion. You have the mind of Christ (1 Cor. 2:16)."
    ),
    (
        "How do you stay grounded when your routine gets disrupted?",
        ["Panic", "Reset and speak God’s promises", "Blame others", "Skip your quiet time"],
        1,
        "God’s peace isn’t based on routine — it flows from His Word (Isaiah 26:3)."
    ),
    (
        "What’s the root of perfect peace?",
        ["Having control", "No interruptions", "Trusting in God", "Zero problems"],
        2,
        "Isaiah 26:3 — 'You will keep him in perfect peace whose mind is stayed on You.'"
    ),
    (
        "How do you protect your peace throughout the day?",
        ["Isolate", "Avoid people", "Speak Scripture throughout the day", "Ignore feelings"],
        2,
        "Speak life consistently — 'Great peace have they who love your law' (Psalm 119:165)."
    ),
    (
        "You wake up anxious. What do you do before anything else?",
        ["Scroll your phone", "Speak Psalm 23:1", "Rush to work", "Get distracted"],
        1,
        "Start by declaring peace — 'The Lord is my Shepherd, I shall not want.'"
    ),
    (
        "Someone says something rude. How do you respond?",
        ["Fire back", "Walk away", "Speak, 'I’m unoffendable in Christ'", "Ignore them"],
        2,
        "'A gentle answer turns away wrath' (Proverbs 15:1). Speaking truth keeps your peace."
    ),
    (
        "What happens when you keep speaking peace?",
        ["You fake it", "Nothing", "Peace multiplies in your life", "You become passive"],
        2,
        "'Grace and peace be multiplied to you through the knowledge of God' (2 Peter 1:2)."
    ),
    (
        "You’re tired and someone needs help. What now?",
        ["Ignore them", "Help and grumble", "Speak grace and serve with joy", "Say you're busy"],
        2,
        "Peace and strength come from grace — not your own energy (2 Cor. 12:9)."
    ),
    (
        "Your thoughts keep racing. How do you calm them?",
        ["Sleep", "Talk to a friend", "Speak God’s promises out loud", "Scroll Instagram"],
        2,
        "Let peace guard your heart and mind through Christ Jesus (Philippians 4:7)."
    ),
    (
        "What should you do with every small frustration?",
        ["Suppress it", "Rant about it", "Cast it on Jesus", "Hold it in until later"],
        2,
        "Jesus said, 'Come to me... I will give you rest' (Matt. 11:28)."
    ),
    (
        "When someone tries to steal your peace, what do you speak?",
        ["They’re so annoying", "Why me?", "I choose peace — nothing missing, nothing broken", "I’ll get even later"],
        2,
        "Peace is a decision. 'Let the peace of Christ rule in your hearts' (Col. 3:15)."
    ),
    (
        "You forgot to pray this morning. What now?",
        ["Feel guilty", "Start right now", "Blame your schedule", "Hope God understands"],
        1,
        "God is always ready — peace is restored the moment you return (Isaiah 30:15)."
    ),
    (
        "What’s a powerful peace confession you can speak daily?",
        ["I hope this day goes well", "I'm just trying to survive", "I live in perfect peace — my mind is on Jesus", "No one better mess with me today"],
        2,
        "Confession brings possession. Speak Isaiah 26:3 every morning."
    )
]

let protectionQuizQuestions = [
    (
        "What should you declare when you feel unsafe?",
        ["I hope nothing bad happens", "God is my refuge and fortress", "It’s out of my control", "I’ll just avoid danger"],
        1,
        "'He is my refuge and my fortress' — Psalm 91:2. Speak it and rest in His covering."
    ),
    (
        "What protects you more than locks or alarms?",
        ["Being alert", "Common sense", "God’s angels", "Staying home"],
        2,
        "Psalm 91:11 — 'He will command His angels concerning you.' His protection is supernatural."
    ),
    (
        "When trouble comes near, what do you speak?",
        ["Hope for the best", "Let’s see what happens", "No weapon formed against me shall prosper", "It is what it is"],
        2,
        "Isaiah 54:17 — Declare victory before you see it. No weapon will succeed."
    ),
    (
        "You’re traveling alone. What truth do you stand on?",
        ["I’m vulnerable", "I trust my driver", "The Lord goes with me", "I stay quiet and watchful"],
        2,
        "Deuteronomy 31:6 — He goes with you, never leaving or forsaking."
    ),
    (
        "What surrounds you according to Psalm 91?",
        ["Uncertainty", "Dangers", "God’s faithfulness and angels", "Protection when you're good enough"],
        2,
        "You’re covered by His feathers and shielded by truth — Psalm 91:4."
    ),
    (
        "What should you believe about your home?",
        ["Hope it’s safe", "Install more cameras", "No evil will befall it", "Just pray sometimes"],
        2,
        "Psalm 91:10 — 'No evil shall befall you, nor shall any plague come near your dwelling.'"
    ),
    (
        "What’s your response to a scary news headline?",
        ["Panic", "Share it", "Declare Psalm 91", "Ignore it"],
        2,
        "News doesn’t override God’s promises. Speak Psalm 91 with authority."
    ),
    (
        "How do you activate God's protection daily?",
        ["Think positive", "Speak protection Scriptures", "Watch the news", "Stay hidden"],
        1,
        "God’s Word is your shield — speak it and activate it (Ephesians 6:17)."
    ),
    (
        "What does the blood of Jesus do for your safety?",
        ["Forgives you", "Makes you feel loved", "Marks you as protected", "Only helps when sick"],
        2,
        "Just like Israel marked their doors, you can plead the blood over your life (Exodus 12:13)."
    ),
    (
        "What should your heart posture be under attack?",
        ["Worry", "Boldness", "Hope it ends", "Fear"],
        1,
        "Be bold and confident — 'The Lord is my helper; I will not fear' (Hebrews 13:6)."
    ),
    (
        "You're walking through a dark place. What do you say?",
        ["This is scary", "I wish I was home", "Even though I walk through the valley, I will fear no evil", "It’ll be fine eventually"],
        2,
        "Psalm 23:4 — Declare it even in the dark: God is with you."
    ),
    (
        "What’s the most powerful shield you have?",
        ["Alarm system", "Street smarts", "Faith", "Family support"],
        2,
        "Ephesians 6:16 — 'Take up the shield of faith… to extinguish all the flaming darts.'"
    ),
    (
        "How should you speak over your children?",
        ["I hope they stay safe", "You never know these days", "I plead the blood over them", "I tell them to be careful"],
        2,
        "Declare Psalm 91 and plead the blood — it’s not fear, it’s faith in action."
    ),
    (
        "What surrounds the one who fears the Lord?",
        ["Worry", "Hardship", "The angel of the Lord", "Uncertainty"],
        2,
        "Psalm 34:7 — 'The angel of the Lord encamps around those who fear Him, and delivers them.'"
    ),
    (
        "What happens when you dwell in the secret place?",
        ["You become religious", "You gain spiritual strength", "You abide under God's shadow", "You avoid problems"],
        2,
        "Psalm 91:1 — Abiding in Him brings divine protection and rest."
    )
]


let destinyQuizQuestions = [
    (
        "What should you believe about your life?",
        ["It’s random", "It’s up to fate", "God has a plan and purpose", "It’s probably too late"],
        2,
        "Jeremiah 29:11 — 'I know the plans I have for you… to give you a future and a hope.'"
    ),
    (
        "You feel behind in life. What do you speak?",
        ["I missed my chance", "God’s timing is perfect", "Maybe it wasn’t meant to be", "Everyone is ahead of me"],
        1,
        "God makes everything beautiful in its time (Ecclesiastes 3:11)."
    ),
    (
        "How do you step into your calling?",
        ["Wait until everything is perfect", "Trust and obey step by step", "Figure it out yourself", "Compare your path to others"],
        1,
        "Proverbs 3:5-6 — 'Trust in the Lord… He will direct your paths.'"
    ),
    (
        "What does delay mean in God’s eyes?",
        ["It’s denial", "It’s a test", "It means you failed", "It’s preparation"],
        3,
        "Delay is not denial. God prepares you before He promotes you (James 1:4)."
    ),
    (
        "When you feel unqualified, what truth should you speak?",
        ["Maybe I’m not called", "God chooses the weak", "Others are more gifted", "I'll stay quiet"],
        1,
        "1 Corinthians 1:27 — 'God chose the foolish things… to shame the wise.'"
    ),
    (
        "What do you declare in a season of waiting?",
        ["Nothing’s happening", "God’s working behind the scenes", "I’m stuck", "This is unfair"],
        1,
        "Faith sees what God promised — even when you can’t yet see it (2 Cor. 5:7)."
    ),
    (
        "How does God prepare you for your purpose?",
        ["Through success only", "By isolating you", "By refining and equipping you", "By blessing your plans"],
        2,
        "Romans 8:28 — 'All things work together for good… to those called according to His purpose.'"
    ),
    (
        "What’s your role in discovering God’s will?",
        ["Make your own path", "Ask others for their plan", "Surrender and renew your mind", "Work until you're exhausted"],
        2,
        "Romans 12:2 — Be transformed… then you’ll know His good and perfect will."
    ),
    (
        "What should you say when doors close?",
        ["God must not want me to succeed", "I’ll never get another chance", "God is redirecting me", "I should’ve tried harder"],
        2,
        "Closed doors protect destiny. He opens the right ones no one can shut (Rev. 3:7)."
    ),
    (
        "What qualifies you for your calling?",
        ["Perfection", "Trying really hard", "Faith in Jesus", "Approval from people"],
        2,
        "God qualifies the called — it's His grace, not your performance (2 Tim. 1:9)."
    ),
    (
        "What if you’ve made mistakes in the past?",
        ["You're disqualified", "You missed your chance", "God can still use you", "You have to earn it back"],
        2,
        "Romans 11:29 — 'The gifts and calling of God are irrevocable.'"
    ),
    (
        "How do you stay in step with God’s plan?",
        ["Push doors open", "Pray then follow peace", "Compare with others", "Always say yes"],
        1,
        "Colossians 3:15 — Let peace rule in your heart and guide your decisions."
    ),
    (
        "You feel overlooked. What do you speak?",
        ["No one sees me", "God sees and knows me", "It’s not fair", "I’m wasting my time"],
        1,
        "God sees in secret and rewards openly (Matthew 6:6)."
    ),
    (
        "When you don't feel ready, what’s the truth?",
        ["I need more time", "God equips those He calls", "I might fail", "This is too big for me"],
        1,
        "Hebrews 13:21 — 'May He equip you with everything good for doing His will.'"
    ),
    (
        "What happens when you say yes to God?",
        ["He tests you", "You sacrifice everything", "He empowers you", "Life gets harder"],
        2,
        "Philippians 2:13 — 'It is God who works in you to will and to act.'"
    )
]

let wordsQuizQuestions = [
    (
        "What does Proverbs 18:21 say about your tongue?",
        ["It helps you communicate", "It reflects your heart", "It carries life and death", "It’s hard to control"],
        2,
        "'Life and death are in the power of the tongue…' — Your words are never neutral."
    ),
    (
        "What happens when you speak life over your situation?",
        ["Nothing changes", "You feel better", "Faith is activated", "It helps others only"],
        2,
        "Mark 11:23 — 'Whoever says to this mountain… it will be done for him.'"
    ),
    (
        "Why should you guard your words?",
        ["To sound wise", "To avoid trouble", "They shape your future", "It’s polite"],
        2,
        "James 3 — The tongue is like a rudder that steers your whole life."
    ),
    (
        "You feel sick. What do you say?",
        ["I'm always getting sick", "Hope I feel better", "By His stripes I’m healed", "This always happens"],
        2,
        "Speak healing, not symptoms — Isaiah 53:5 is your authority."
    ),
    (
        "When you’re frustrated, what’s the best habit?",
        ["Vent it", "Speak peace over yourself", "Stay silent", "Post about it"],
        1,
        "Proverbs 15:1 — 'A gentle answer turns away wrath.' Words release peace or pain."
    ),
    (
        "What makes your declarations powerful?",
        ["Emotion", "Volume", "Faith and truth", "Repetition only"],
        2,
        "Power doesn’t come from shouting — it comes from believing (2 Cor. 4:13)."
    ),
    (
        "What happens when you constantly speak fear?",
        ["It helps you prepare", "You stay realistic", "You attract what you say", "It doesn’t matter"],
        2,
        "Job 3:25 — 'What I feared has come upon me.' Your words build your reality."
    ),
    (
        "What did Jesus use to defeat the devil?",
        ["Prayer", "Silence", "Scripture spoken aloud", "His presence"],
        2,
        "In Matthew 4, Jesus said 'It is written' three times and shut the devil down."
    ),
    (
        "When should you speak God's Word?",
        ["At church", "In emergencies", "All day, every day", "Before bed"],
        2,
        "Deuteronomy 6:7 — Talk of the Word 'when you walk… lie down… rise up…'"
    ),
    (
        "You spoke negatively — what now?",
        ["Just move on", "Hope it’s okay", "Repent and speak life", "Do nothing"],
        2,
        "Cancel wrong words by speaking truth. James 3:10 — blessings and curses shouldn’t mix."
    ),
    (
        "Why are your words spiritual?",
        ["They affect your mood", "They sound powerful", "They come from your heart", "They carry faith or fear"],
        3,
        "Jesus said, 'Out of the abundance of the heart, the mouth speaks' (Luke 6:45)."
    ),
    (
        "How do you shift your atmosphere?",
        ["Take deep breaths", "Control others", "Speak Scripture boldly", "Play music"],
        2,
        "Words create worlds — Hebrews 11:3. Speak the Word and change the room."
    ),
    (
        "What should your mouth be full of?",
        ["News", "Opinion", "Praise and promises", "Complaints"],
        2,
        "Psalm 34:1 — 'I will bless the Lord at all times; His praise shall continually be in my mouth.'"
    ),
    (
        "What do your words reveal?",
        ["Your personality", "Your past", "Your heart condition", "Your thoughts"],
        2,
        "Luke 6:45 — What you truly believe will always find its way into your mouth."
    ),
    (
        "What does faith do with God’s Word?",
        ["Reads it", "Thinks about it", "Speaks it", "Sings it"],
        2,
        "2 Corinthians 4:13 — 'I believed, and therefore I spoke.' Faith speaks!"
    )
]
