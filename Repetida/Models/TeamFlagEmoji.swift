import Foundation

enum TeamFlagEmoji {
    /// FIFA 3-letter codes mapped to ISO 3166-1 alpha-2 for regional-indicator flags.
    private static let fifaToISO: [String: String] = [
        "ALG": "DZ",
        "ARG": "AR",
        "AUS": "AU",
        "AUT": "AT",
        "BEL": "BE",
        "BIH": "BA",
        "BRA": "BR",
        "CAN": "CA",
        "CIV": "CI",
        "COL": "CO",
        "COD": "CD",
        "CPV": "CV",
        "CRO": "HR",
        "CUW": "CW",
        "CZE": "CZ",
        "ECU": "EC",
        "EGY": "EG",
        "ESP": "ES",
        "FRA": "FR",
        "GER": "DE",
        "GHA": "GH",
        "HAI": "HT",
        "IRN": "IR",
        "IRQ": "IQ",
        "JOR": "JO",
        "JPN": "JP",
        "KOR": "KR",
        "KSA": "SA",
        "MAR": "MA",
        "MEX": "MX",
        "NED": "NL",
        "NOR": "NO",
        "NZL": "NZ",
        "PAN": "PA",
        "PAR": "PY",
        "POR": "PT",
        "QAT": "QA",
        "RSA": "ZA",
        "SEN": "SN",
        "SUI": "CH",
        "SWE": "SE",
        "TUN": "TN",
        "TUR": "TR",
        "USA": "US",
        "URU": "UY",
        "UZB": "UZ",
    ]

    /// Teams without a distinct ISO country code use explicit flag emoji.
    private static let directEmoji: [String: String] = [
        "ENG": "\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}",
        "SCO": "\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}",
    ]

    static func emoji(forFIFACode code: String) -> String? {
        let upper = code.uppercased()
        if let direct = directEmoji[upper] {
            return direct
        }
        guard let iso = fifaToISO[upper] else { return nil }
        return flag(fromISOAlpha2: iso)
    }

    static func flag(fromISOAlpha2 iso: String) -> String? {
        let upper = iso.uppercased()
        guard upper.count == 2,
              upper.allSatisfy({ $0.isASCII && $0.isLetter })
        else { return nil }

        let base: UInt32 = 127_397
        var scalars = String.UnicodeScalarView()
        for scalar in upper.unicodeScalars {
            guard let flagScalar = UnicodeScalar(base + scalar.value) else { return nil }
            scalars.append(flagScalar)
        }
        return String(scalars)
    }
}

extension Team {
    var flagEmoji: String? {
        guard section == .national else { return nil }
        return TeamFlagEmoji.emoji(forFIFACode: code)
    }

    var flaggedName: String {
        guard let flagEmoji else { return name }
        return "\(flagEmoji) \(name)"
    }

    var flaggedCode: String {
        guard let flagEmoji else { return code }
        return "\(flagEmoji) \(code)"
    }
}
