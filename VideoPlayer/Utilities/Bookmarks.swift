// Bookmarks.swift

import Foundation

@objcMembers final class BookMarks: NSObject, NSSecureCoding {
    struct Keys {
        static let data = "data"
    }

    var data: [URL: Data] = [URL: Data]()

    static var supportsSecureCoding: Bool = true

    required init?(coder: NSCoder) {
        self.data = coder.decodeObject(
            of: [NSDictionary.self, NSData.self, NSURL.self],
            forKey: Keys.data
        ) as? [URL: Data] ?? [:]
    }

    required init(data: [URL: Data]) {
        self.data = data
    }

    func encode(with coder: NSCoder) {
        coder.encode(data, forKey: Keys.data)
    }

    func store(url: URL) {
        do {
            let bookmark = try url.bookmarkData(
                options: NSURL.BookmarkCreationOptions.withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            data[url] = bookmark

            self.dump()
        } catch {
            print("Error storing bookmarks: \(error.localizedDescription)")
        }
    }

    func dump() {
        let path = Self.path()
        do {
            try NSKeyedArchiver.archivedData(
                withRootObject: self,
                requiringSecureCoding: true
            ).write(to: path)
        } catch {
            print("Error dumping bookmarks: \(error.localizedDescription)")
        }
    }

    static func path() -> URL {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        url.append(path: "Bookmarks.dict")
        return url
    }

    static func restore() -> BookMarks? {
        let path = Self.path()
        let nsdata = NSData(contentsOf: path)

        guard nsdata != nil else { return nil }

        do {
            let bookmarks = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: nsdata! as Data)
            for bookmark in bookmarks?.data ?? [:] {
                Self.restore(bookmark)
            }
            return bookmarks
        } catch {
            print("Error loading bookmarks: \(error.localizedDescription)")
            return nil
        }
    }

    static func restore(_ bookmark: (key: URL, value: Data)) {
        let restoredUrl: URL?
        var isStale = false

        print("Restoring \(bookmark.key)")
        do {
            restoredUrl = try URL(
                resolvingBookmarkData: bookmark.value,
                options: NSURL.BookmarkResolutionOptions.withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        } catch {
            print("Error restoring bookmarks: \(error.localizedDescription)")
            restoredUrl = nil
        }

        if let url = restoredUrl {
            if isStale {
                print("URL is stale")
            } else {
                if !url.startAccessingSecurityScopedResource() {
                    print("Couldn't access: \(url.path)")
                }
            }
        }
    }
}
