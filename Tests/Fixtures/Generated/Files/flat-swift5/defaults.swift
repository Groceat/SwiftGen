// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Files

// swiftlint:disable identifier_name line_length number_separator type_body_length
internal enum Files {
  /// File
  internal static let file = File(name: "File", ext: nil, relativePath: "", mimeType: "application/octet-stream")
  /// test.txt
  internal static let testTxt = File(name: "test", ext: "txt", relativePath: "", mimeType: "text/plain")
  /// empty intermediate/subfolder/another video.mp4
  internal static let anotherVideoMp4 = File(name: "another video", ext: "mp4", relativePath: "empty intermediate/subfolder", mimeType: "video/mp4")
  /// subdir/A Video With Spaces.mp4
  internal static let aVideoWithSpacesMp4 = File(name: "A Video With Spaces", ext: "mp4", relativePath: "subdir", mimeType: "video/mp4")
  /// subdir/subdir/graphic.svg
  internal static let graphicSvg = File(name: "graphic", ext: "svg", relativePath: "subdir/subdir", mimeType: "image/svg+xml")
}

// MARK: - Implementation Details

internal struct File {
  internal fileprivate(set) var name: String
  internal fileprivate(set) var ext: String?
  internal fileprivate(set) var relativePath: String
  internal fileprivate(set) var mimeType: String

  internal var url: URL {
    return url(locale: nil)
  }

  internal func url(locale: Locale?) -> URL {
    let bundle = BundleToken.bundle
    let url = bundle.url(forResource: name, withExtension: ext, subdirectory: relativePath, localization: locale?.identifier)
    guard let result = url else {
      let file = name + (ext != nil ? "." + ext : "")
      fatalError("Could not locate file named \(file)")
    }
    return result
  }

  internal var path: String {
    return path(locale: nil)
  }

  internal func path(locale: Locale?) -> String {
    return url(locale: locale).path
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
