import Foundation

struct CardIdentifier {
    private static let amexPrefixRanges = ["34", "37"]
    private static let vervePrefixRanges = ["5060", "5061", "5078", "5079", "6500"]
    private static let discoverPrefixRanges = ["6011", "622", "64", "65"]
    private static let jcbPrefixRanges = ["35"]
    private static let dinersPrefixRanges = ["300", "301", "302", "303", "304", "305", "309", "36", "38", "39"]
    private static let visaPrefixRanges = ["4"]
    private static let mastercardPrefixRanges = ["501", "502", "503", "504", "505",
                                                 "5062", "5063", "5064", "5065", "5066", "5067", "5068", "5069",
                                                 "5070", "5071", "5072", "5073", "5074", "5075", "5076", "5077",
                                                 "508", "509", "500", "51", "52", "53", "54", "55", "56", "57",
                                                 "58", "59"]

    let type: CardType
    let prefixes: [String]

    static var allTypes: [CardIdentifier] {
        [.init(type: .amex, prefixes: amexPrefixRanges),
         .init(type: .verve, prefixes: vervePrefixRanges),
         .init(type: .discover, prefixes: discoverPrefixRanges),
         .init(type: .jcb, prefixes: jcbPrefixRanges),
         .init(type: .diners, prefixes: dinersPrefixRanges),
         .init(type: .visa, prefixes: visaPrefixRanges),
         .init(type: .mastercard, prefixes: mastercardPrefixRanges)]
    }
}
