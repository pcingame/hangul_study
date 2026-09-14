import Foundation

enum HangulData {
    static let all: [HangulLetter] = basicConsonants + basicVowels + doubleConsonants + compoundVowels

    static func letters(in category: HangulCategory) -> [HangulLetter] {
        all.filter { $0.category == category }
    }

    static let basicConsonants: [HangulLetter] = [
        HangulLetter(character: "ㄱ", romanization: "g / k", name: "기역 (giyeok)", category: .basicConsonant,
                     exampleWord: "가방", exampleRomanization: "gabang",
                     exampleMeaning: Bilingual(vi: "cái cặp", en: "bag"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"c/k\" tiếng Việt nhưng nhẹ và ít bật hơi hơn. Phân biệt với ㅋ (bật hơi mạnh) và ㄲ (căng, gắt).",
                        en: "Like Vietnamese \"c/k\" but softer and less aspirated. Compare ㅋ (strongly aspirated) and ㄲ (tense).")),
        HangulLetter(character: "ㄴ", romanization: "n", name: "니은 (nieun)", category: .basicConsonant,
                     exampleWord: "나무", exampleRomanization: "namu",
                     exampleMeaning: Bilingual(vi: "cái cây", en: "tree"),
                     pronunciationTip: Bilingual(
                        vi: "Giống hệt \"n\" tiếng Việt, đầu lưỡi chạm nướu răng trên.",
                        en: "Just like Vietnamese \"n\" — tongue tip touches the upper gum ridge.")),
        HangulLetter(character: "ㄷ", romanization: "d / t", name: "디귿 (digeut)", category: .basicConsonant,
                     exampleWord: "다리", exampleRomanization: "dari",
                     exampleMeaning: Bilingual(vi: "cái chân / cây cầu", en: "leg / bridge"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"đ\" tiếng Việt nhưng nhẹ hơi hơn. Phân biệt với ㅌ (bật hơi mạnh) và ㄸ (căng, gắt).",
                        en: "Like Vietnamese \"đ\" but softer. Compare ㅌ (strongly aspirated) and ㄸ (tense).")),
        HangulLetter(character: "ㄹ", romanization: "r / l", name: "리을 (rieul)", category: .basicConsonant,
                     exampleWord: "라디오", exampleRomanization: "radio",
                     exampleMeaning: Bilingual(vi: "đài radio", en: "radio"),
                     pronunciationTip: Bilingual(
                        vi: "Âm trung gian giữa \"l\" và \"r\": đầu lưỡi chạm nhẹ một lần lên vòm miệng, không rung lưỡi như \"r\" tiếng Việt.",
                        en: "A blend of \"l\" and \"r\": the tongue tip taps the roof of the mouth once — no rolling like a Vietnamese \"r\".")),
        HangulLetter(character: "ㅁ", romanization: "m", name: "미음 (mieum)", category: .basicConsonant,
                     exampleWord: "머리", exampleRomanization: "meori",
                     exampleMeaning: Bilingual(vi: "cái đầu", en: "head"),
                     pronunciationTip: Bilingual(
                        vi: "Giống hệt \"m\" tiếng Việt, mím hai môi lại.",
                        en: "Just like Vietnamese \"m\" — lips pressed together.")),
        HangulLetter(character: "ㅂ", romanization: "b / p", name: "비읍 (bieup)", category: .basicConsonant,
                     exampleWord: "바다", exampleRomanization: "bada",
                     exampleMeaning: Bilingual(vi: "biển", en: "sea"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"b\" tiếng Việt nhưng nhẹ hơi hơn. Phân biệt với ㅍ (bật hơi mạnh) và ㅃ (căng, gắt).",
                        en: "Like Vietnamese \"b\" but softer. Compare ㅍ (strongly aspirated) and ㅃ (tense).")),
        HangulLetter(character: "ㅅ", romanization: "s", name: "시옷 (siot)", category: .basicConsonant,
                     exampleWord: "사람", exampleRomanization: "saram",
                     exampleMeaning: Bilingual(vi: "người", en: "person"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"x\" tiếng Việt (không phải \"s\" cong lưỡi). Trước \"ㅣ\" hoặc \"y\" đọc ngả sang \"sh\".",
                        en: "Like Vietnamese \"x\" (a light \"s\", not retroflex). Before \"ㅣ\" or a \"y\" glide it shifts toward \"sh\".")),
        HangulLetter(character: "ㅇ", romanization: "ng / câm", name: "이응 (ieung)", category: .basicConsonant,
                     exampleWord: "아이", exampleRomanization: "ai",
                     exampleMeaning: Bilingual(vi: "đứa trẻ", en: "child"),
                     pronunciationTip: Bilingual(
                        vi: "Ở đầu âm tiết thì câm, chỉ là chỗ giữ vị trí cho nguyên âm. Ở cuối âm tiết mới đọc thành \"ng\" như trong \"cong\".",
                        en: "Silent at the start of a syllable — it's just a placeholder before the vowel. At the end of a syllable it's pronounced \"ng\" as in \"song\".")),
        HangulLetter(character: "ㅈ", romanization: "j", name: "지읒 (jieut)", category: .basicConsonant,
                     exampleWord: "자동차", exampleRomanization: "jadongcha",
                     exampleMeaning: Bilingual(vi: "xe hơi", en: "car"),
                     pronunciationTip: Bilingual(
                        vi: "Gần giống \"ch/tr\" tiếng Việt phát nhẹ. Phân biệt với ㅊ (bật hơi mạnh) và ㅉ (căng, gắt).",
                        en: "Close to a soft Vietnamese \"ch/tr\". Compare ㅊ (strongly aspirated) and ㅉ (tense).")),
        HangulLetter(character: "ㅊ", romanization: "ch", name: "치읓 (chieut)", category: .basicConsonant,
                     exampleWord: "책", exampleRomanization: "chaek",
                     exampleMeaning: Bilingual(vi: "quyển sách", en: "book"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"ch\" tiếng Việt nhưng bật một luồng hơi rõ ra khi phát âm — khác hẳn ㅈ nhẹ hơi.",
                        en: "Like Vietnamese \"ch\" but with a clear puff of breath — distinctly stronger than the soft ㅈ.")),
        HangulLetter(character: "ㅋ", romanization: "k", name: "키읔 (kieuk)", category: .basicConsonant,
                     exampleWord: "코", exampleRomanization: "ko",
                     exampleMeaning: Bilingual(vi: "cái mũi", en: "nose"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"kh\" tiếng Việt, bật hơi mạnh — đặt tay trước miệng sẽ thấy luồng hơi rõ. Khác ㄱ nhẹ hơi.",
                        en: "Like Vietnamese \"kh\", strongly aspirated — hold a hand in front of your mouth and you'll feel a puff of air. Compare the soft ㄱ.")),
        HangulLetter(character: "ㅌ", romanization: "t", name: "티읕 (tieut)", category: .basicConsonant,
                     exampleWord: "토마토", exampleRomanization: "tomato",
                     exampleMeaning: Bilingual(vi: "cà chua", en: "tomato"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"th\" tiếng Việt, bật hơi mạnh. Khác ㄷ nhẹ hơi.",
                        en: "Like Vietnamese \"th\", strongly aspirated. Compare the soft ㄷ.")),
        HangulLetter(character: "ㅍ", romanization: "p", name: "피읖 (pieup)", category: .basicConsonant,
                     exampleWord: "포도", exampleRomanization: "podo",
                     exampleMeaning: Bilingual(vi: "quả nho", en: "grape"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"ph\" tiếng Việt, bật hơi mạnh ở môi. Khác ㅂ nhẹ hơi.",
                        en: "Like Vietnamese \"ph\", a strong puff of air at the lips. Compare the soft ㅂ.")),
        HangulLetter(character: "ㅎ", romanization: "h", name: "히읗 (hieut)", category: .basicConsonant,
                     exampleWord: "하늘", exampleRomanization: "haneul",
                     exampleMeaning: Bilingual(vi: "bầu trời", en: "sky"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"h\" tiếng Việt, thở hơi nhẹ ra từ cổ họng.",
                        en: "Like Vietnamese \"h\" — a light breath from the throat.")),
    ]

    static let basicVowels: [HangulLetter] = [
        HangulLetter(character: "ㅏ", romanization: "a", name: "아 (a)", category: .basicVowel,
                     exampleWord: "아빠", exampleRomanization: "appa",
                     exampleMeaning: Bilingual(vi: "bố", en: "dad"),
                     pronunciationTip: Bilingual(
                        vi: "Giống hệt \"a\" tiếng Việt, miệng mở rộng tự nhiên.",
                        en: "Just like Vietnamese \"a\" — mouth opens naturally wide.")),
        HangulLetter(character: "ㅑ", romanization: "ya", name: "야 (ya)", category: .basicVowel,
                     exampleWord: "야구", exampleRomanization: "yagu",
                     exampleMeaning: Bilingual(vi: "bóng chày", en: "baseball"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ \"i\" sang \"a\", giống \"ia\" đọc liền thành một âm.",
                        en: "A quick glide from \"i\" into \"a\", like Vietnamese \"ia\" said as one syllable.")),
        HangulLetter(character: "ㅓ", romanization: "eo", name: "어 (eo)", category: .basicVowel,
                     exampleWord: "어머니", exampleRomanization: "eomeoni",
                     exampleMeaning: Bilingual(vi: "mẹ", en: "mother"),
                     pronunciationTip: Bilingual(
                        vi: "Không có trong tiếng Việt: nằm giữa \"ơ\" và \"â\", miệng mở vừa, môi giang ngang (KHÔNG tròn môi — khác ㅗ).",
                        en: "No Vietnamese equivalent: between \"ơ\" and \"â\", mouth half-open, lips relaxed and NOT rounded (unlike ㅗ).")),
        HangulLetter(character: "ㅕ", romanization: "yeo", name: "여 (yeo)", category: .basicVowel,
                     exampleWord: "여자", exampleRomanization: "yeoja",
                     exampleMeaning: Bilingual(vi: "phụ nữ", en: "woman"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ \"i\" sang ㅓ — không tròn môi.",
                        en: "A quick glide from \"i\" into ㅓ — lips stay unrounded.")),
        HangulLetter(character: "ㅗ", romanization: "o", name: "오 (o)", category: .basicVowel,
                     exampleWord: "오리", exampleRomanization: "ori",
                     exampleMeaning: Bilingual(vi: "con vịt", en: "duck"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"ô\" tiếng Việt, môi tròn và hơi nhô ra phía trước.",
                        en: "Like Vietnamese \"ô\" — lips rounded and pushed slightly forward.")),
        HangulLetter(character: "ㅛ", romanization: "yo", name: "요 (yo)", category: .basicVowel,
                     exampleWord: "요리", exampleRomanization: "yori",
                     exampleMeaning: Bilingual(vi: "nấu ăn", en: "cooking"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ \"i\" sang ㅗ, giống \"yô\".",
                        en: "A quick glide from \"i\" into ㅗ, like \"yô\".")),
        HangulLetter(character: "ㅜ", romanization: "u", name: "우 (u)", category: .basicVowel,
                     exampleWord: "우유", exampleRomanization: "uyu",
                     exampleMeaning: Bilingual(vi: "sữa", en: "milk"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"u\" tiếng Việt, môi tròn và nhô ra nhiều hơn cả ㅗ.",
                        en: "Like Vietnamese \"u\" — lips rounded and pushed forward even more than ㅗ.")),
        HangulLetter(character: "ㅠ", romanization: "yu", name: "유 (yu)", category: .basicVowel,
                     exampleWord: "유리", exampleRomanization: "yuri",
                     exampleMeaning: Bilingual(vi: "thủy tinh", en: "glass"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ \"i\" sang ㅜ, giống \"yu\" tiếng Việt.",
                        en: "A quick glide from \"i\" into ㅜ, like Vietnamese \"yu\".")),
        HangulLetter(character: "ㅡ", romanization: "eu", name: "으 (eu)", category: .basicVowel,
                     exampleWord: "은행", exampleRomanization: "eunhaeng",
                     exampleMeaning: Bilingual(vi: "ngân hàng", en: "bank"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"ư\" tiếng Việt: môi giang ngang, KHÔNG tròn — dễ nhầm với ㅜ nếu tròn môi.",
                        en: "Like Vietnamese \"ư\": lips spread flat, NOT rounded — easy to mix up with ㅜ if you round your lips.")),
        HangulLetter(character: "ㅣ", romanization: "i", name: "이 (i)", category: .basicVowel,
                     exampleWord: "이름", exampleRomanization: "ireum",
                     exampleMeaning: Bilingual(vi: "cái tên", en: "name"),
                     pronunciationTip: Bilingual(
                        vi: "Giống hệt \"i\" tiếng Việt.",
                        en: "Just like Vietnamese \"i\".")),
    ]

    static let doubleConsonants: [HangulLetter] = [
        HangulLetter(character: "ㄲ", romanization: "kk", name: "쌍기역 (ssanggiyeok)", category: .doubleConsonant,
                     exampleWord: "까치", exampleRomanization: "kkachi",
                     exampleMeaning: Bilingual(vi: "chim ác là", en: "magpie"),
                     pronunciationTip: Bilingual(
                        vi: "Âm \"c/k\" căng và gắt hơn ㄱ, hoàn toàn không bật hơi — siết chặt cổ họng một chút trước khi bật ra.",
                        en: "A tenser, sharper \"c/k\" than ㄱ, with zero aspiration — tighten the throat slightly right before releasing it.")),
        HangulLetter(character: "ㄸ", romanization: "tt", name: "쌍디귿 (ssangdigeut)", category: .doubleConsonant,
                     exampleWord: "딸기", exampleRomanization: "ttalgi",
                     exampleMeaning: Bilingual(vi: "dâu tây", en: "strawberry"),
                     pronunciationTip: Bilingual(
                        vi: "Âm \"đ\" căng và gắt hơn ㄷ, không bật hơi.",
                        en: "A tenser, sharper \"đ\" than ㄷ, with no aspiration.")),
        HangulLetter(character: "ㅃ", romanization: "pp", name: "쌍비읍 (ssangbieup)", category: .doubleConsonant,
                     exampleWord: "빵", exampleRomanization: "ppang",
                     exampleMeaning: Bilingual(vi: "bánh mì", en: "bread"),
                     pronunciationTip: Bilingual(
                        vi: "Âm \"b\" căng và gắt hơn ㅂ, hai môi mím chặt rồi bật nhanh, không có hơi.",
                        en: "A tenser, sharper \"b\" than ㅂ — lips pressed firmly then released quickly, with no puff of air.")),
        HangulLetter(character: "ㅆ", romanization: "ss", name: "쌍시옷 (ssangsiot)", category: .doubleConsonant,
                     exampleWord: "쌀", exampleRomanization: "ssal",
                     exampleMeaning: Bilingual(vi: "gạo", en: "uncooked rice"),
                     pronunciationTip: Bilingual(
                        vi: "Âm \"x\" xuýt rõ và căng hơn ㅅ, giữ luồng hơi xát lâu hơn một chút.",
                        en: "A tenser, more hissing \"x/s\" than ㅅ — hold the hissing airflow a touch longer.")),
        HangulLetter(character: "ㅉ", romanization: "jj", name: "쌍지읒 (ssangjieut)", category: .doubleConsonant,
                     exampleWord: "짜다", exampleRomanization: "jjada",
                     exampleMeaning: Bilingual(vi: "mặn", en: "salty"),
                     pronunciationTip: Bilingual(
                        vi: "Âm \"ch/tr\" căng và gắt hơn ㅈ, phát nhanh và dứt khoát.",
                        en: "A tenser, sharper \"ch/tr\" than ㅈ — released quickly and crisply.")),
    ]

    static let compoundVowels: [HangulLetter] = [
        HangulLetter(character: "ㅐ", romanization: "ae", name: "애 (ae)", category: .compoundVowel,
                     exampleWord: "개", exampleRomanization: "gae",
                     exampleMeaning: Bilingual(vi: "con chó", en: "dog"),
                     pronunciationTip: Bilingual(
                        vi: "Giữa \"e\" và \"a\" tiếng Việt, miệng mở khá rộng. Người Hàn hiện đại phát âm gần như không phân biệt với ㅔ.",
                        en: "Between Vietnamese \"e\" and \"a\", mouth fairly open. Modern Korean speakers barely distinguish it from ㅔ.")),
        HangulLetter(character: "ㅒ", romanization: "yae", name: "얘 (yae)", category: .compoundVowel,
                     exampleWord: "얘기", exampleRomanization: "yaegi",
                     exampleMeaning: Bilingual(vi: "câu chuyện", en: "talk"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt \"i\" sang ㅐ. Ít gặp — chủ yếu trong từ \"얘기\" (câu chuyện).",
                        en: "A glide from \"i\" into ㅐ. Rare — mostly seen in \"얘기\" (talk/story).")),
        HangulLetter(character: "ㅔ", romanization: "e", name: "에 (e)", category: .compoundVowel,
                     exampleWord: "게", exampleRomanization: "ge",
                     exampleMeaning: Bilingual(vi: "con cua", en: "crab"),
                     pronunciationTip: Bilingual(
                        vi: "Giống \"ê\" tiếng Việt. Trong tiếng Hàn hiện đại nghe gần giống hệt ㅐ nên đừng quá lo phân biệt khi nghe.",
                        en: "Like Vietnamese \"ê\". In modern Korean it sounds almost identical to ㅐ, so don't stress over telling them apart by ear.")),
        HangulLetter(character: "ㅖ", romanization: "ye", name: "예 (ye)", category: .compoundVowel,
                     exampleWord: "예의", exampleRomanization: "yeui",
                     exampleMeaning: Bilingual(vi: "lễ nghi", en: "manners"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt \"i\" sang ㅔ, giống \"iê\" tiếng Việt.",
                        en: "A glide from \"i\" into ㅔ, like Vietnamese \"iê\".")),
        HangulLetter(character: "ㅘ", romanization: "wa", name: "와 (wa)", category: .compoundVowel,
                     exampleWord: "과일", exampleRomanization: "gwail",
                     exampleMeaning: Bilingual(vi: "trái cây", en: "fruit"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ ㅗ (môi tròn) sang ㅏ, giống \"oa\" tiếng Việt.",
                        en: "A quick glide from rounded ㅗ into ㅏ, like Vietnamese \"oa\".")),
        HangulLetter(character: "ㅙ", romanization: "wae", name: "왜 (wae)", category: .compoundVowel,
                     exampleWord: "왜", exampleRomanization: "wae",
                     exampleMeaning: Bilingual(vi: "tại sao", en: "why"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt từ ㅗ sang ㅐ, giống \"oe\" mở. Nghe gần giống ㅚ và ㅞ trong khẩu ngữ.",
                        en: "A glide from ㅗ into ㅐ, like an open \"oe\". Sounds close to ㅚ and ㅞ in casual speech.")),
        HangulLetter(character: "ㅚ", romanization: "oe", name: "외 (oe)", category: .compoundVowel,
                     exampleWord: "외국", exampleRomanization: "oeguk",
                     exampleMeaning: Bilingual(vi: "nước ngoài", en: "foreign country"),
                     pronunciationTip: Bilingual(
                        vi: "Người Hàn hiện đại thường phát âm như ㅞ (\"we\"), môi tròn ngay từ đầu.",
                        en: "Modern speakers usually pronounce it like ㅞ (\"we\"), lips rounded from the start.")),
        HangulLetter(character: "ㅝ", romanization: "wo", name: "워 (wo)", category: .compoundVowel,
                     exampleWord: "원숭이", exampleRomanization: "wonsungi",
                     exampleMeaning: Bilingual(vi: "con khỉ", en: "monkey"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ ㅜ (môi tròn) sang ㅓ, giống \"uơ\".",
                        en: "A quick glide from rounded ㅜ into ㅓ, like \"uơ\".")),
        HangulLetter(character: "ㅞ", romanization: "we", name: "웨 (we)", category: .compoundVowel,
                     exampleWord: "웨이터", exampleRomanization: "weiteo",
                     exampleMeaning: Bilingual(vi: "bồi bàn", en: "waiter"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt từ ㅜ sang ㅔ, giống \"we\" tiếng Anh.",
                        en: "A glide from ㅜ into ㅔ, like English \"we\".")),
        HangulLetter(character: "ㅟ", romanization: "wi", name: "위 (wi)", category: .compoundVowel,
                     exampleWord: "가위", exampleRomanization: "gawi",
                     exampleMeaning: Bilingual(vi: "cái kéo", en: "scissors"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt từ ㅜ sang ㅣ, giống \"uy\" tiếng Việt.",
                        en: "A glide from ㅜ into ㅣ, like Vietnamese \"uy\".")),
        HangulLetter(character: "ㅢ", romanization: "ui", name: "의 (ui)", category: .compoundVowel,
                     exampleWord: "의사", exampleRomanization: "uisa",
                     exampleMeaning: Bilingual(vi: "bác sĩ", en: "doctor"),
                     pronunciationTip: Bilingual(
                        vi: "Lướt nhanh từ ㅡ sang ㅣ. Đứng đầu từ đọc đủ \"ưi\"; ở giữa/cuối từ thường đọc gọn thành \"ㅣ\" (ví dụ đuôi sở hữu \"의\" đọc là \"e\").",
                        en: "A quick glide from ㅡ into ㅣ. Pronounced fully as \"ưi\" at the start of a word; mid-word or word-finally it often simplifies to just \"ㅣ\" (e.g. the possessive particle \"의\" is read \"e\").")),
    ]
}
