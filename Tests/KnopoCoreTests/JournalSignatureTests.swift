import Testing
import Foundation
@testable import KnopoCore

/// `journalDaySignature()` backs the journal home's memoized day list: it must
/// change when the *set* of non-empty journal days changes (add / delete /
/// empty), and stay put when only a day's content changes.
@Suite struct JournalSignatureTests {

    private func journal(_ name: String, _ blocks: [String]) -> PageDocument {
        PageDocument(name: name, blocks: blocks.map { Block(content: $0) },
                     isJournal: true, fileExists: true)
    }

    @Test func signatureTracksDaySet() throws {
        let cache = try CacheDB() // in-memory
        try cache.indexPage(journal("2026-06-10", ["a"]), stamp: nil)
        try cache.indexPage(journal("2026-06-11", ["b", "c"]), stamp: nil)
        let twoDays = try cache.journalDaySignature()

        // Editing within a day (same day set) — signature unchanged.
        try cache.indexPage(journal("2026-06-11", ["b", "c", "d"]), stamp: nil)
        expectEqual(try cache.journalDaySignature(), twoDays)

        // A new non-empty day — signature changes.
        try cache.indexPage(journal("2026-06-12", ["e"]), stamp: nil)
        let threeDays = try cache.journalDaySignature()
        expectTrue(threeDays != twoDays)

        // Deleting a day — signature changes (the removed day drops out).
        try cache.removePage(key: "2026-06-10")
        expectTrue(try cache.journalDaySignature() != threeDays)

        // Emptying a day (0 blocks) — signature changes; only 2026-06-12 remains.
        try cache.indexPage(journal("2026-06-11", []), stamp: nil)
        let oneDay = try cache.journalDaySignature()
        expectTrue(oneDay != twoDays)

        // The regression this fingerprint fixes: swap one day for another in the
        // same window. The *count* of days is unchanged (1), but the set differs,
        // so the signature must still change.
        try cache.indexPage(journal("2026-06-12", []), stamp: nil)    // drop the one day
        try cache.indexPage(journal("2026-07-01", ["x"]), stamp: nil) // add a different one
        expectTrue(try cache.journalDaySignature() != oneDay)
    }
}
