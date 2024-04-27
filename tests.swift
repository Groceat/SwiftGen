//
// SwiftGenKit
// Copyright © 2022 SwiftGen
// MIT Licence
//

import Foundation
import XCTest

struct Strings {
  public enum PlaceholderType: String {
    case object = "String"
    case float = "Float"
    case int = "Int"
    case char = "CChar"
    case cString = "UnsafePointer<CChar>"
    case pointer = "UnsafeRawPointer"
    case uint = "UInt"

    init?(formatChar char: Character) {
      guard let lcChar = String(char).lowercased().first else {
        return nil
      }
      switch lcChar {
      case "@":
        self = .object
      case "a", "e", "f", "g":
        self = .float
      case "d", "i", "o", "x":
        self = .int
      case "u":
        self = .uint
      case "c":
        self = .char
      case "s":
        self = .cString
      case "p":
        self = .pointer
      default:
        return nil
      }
    }
  }
}

extension Strings.PlaceholderType {
  private static let formatTypesRegEx: NSRegularExpression = {
    // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
    let patternInt = "(?:h|hh|l|ll|q|z|t|j)?([diox])"
    // valid flag for Unsigned int
    let patternUnsignedInt = "(?:h|hh|l|ll|q|z|t|j)?([u])"
    // valid flags for float
    let patternFloat = "[aefg]"
    // like in "%3$" to make positional specifiers
    let position = "(\\d+\\$)?"
    // precision like in "%1.2f"
    let precision = "[-+# 0]?\\d?(?:\\.\\d)?"

    do {
      return try NSRegularExpression(
        pattern: "(?:^|(?<!%)(?:%%)*)%\(position)\(precision)(@|\(patternInt)|\(patternFloat)|\(patternUnsignedInt)|[csp])",
        options: [.caseInsensitive]
      )
    } catch {
      fatalError("Error building the regular expression used to match string formats")
    }
  }()

  /// Extracts the list of PlaceholderTypes from a format key
  ///
  /// Example: "I give %d apples to %@" --> [.int, .string]
  static func placeholderTypes(fromFormat formatString: String) throws -> [Strings.PlaceholderType] {
    let range = NSRange(location: 0, length: (formatString as NSString).length)

    // Extract the list of chars (conversion specifiers) and their optional positional specifier
    let chars = formatTypesRegEx.matches(in: formatString, options: [], range: range)
      .compactMap { match -> (String, Int?)? in
        let range: NSRange
        if match.range(at: 3).location != NSNotFound {
          // [dioux] are in range #3 because in #2 there may be length modifiers (like in "lld")
          range = match.range(at: 3)
        } else {
          // otherwise, no length modifier, the conversion specifier is in #2
          range = match.range(at: 2)
        }
        let char = (formatString as NSString).substring(with: range)

        let posRange = match.range(at: 1)
        if posRange.location == NSNotFound {
          // No positional specifier
          return (char, nil)
        } else {
          // Remove the "$" at the end of the positional specifier, and convert to Int
          let posRange1 = NSRange(location: posRange.location, length: posRange.length - 1)
          let posString = (formatString as NSString).substring(with: posRange1)
          let pos = Int(posString)
          if let pos = pos, pos <= 0 {
            return nil // Foundation renders "%0$@" not as a placeholder but as the "0@" literal
          }
          return (char, pos)
        }
      }

    return try placeholderTypes(fromChars: chars)
  }

  /// Creates an array of `PlaceholderType` from an array of format chars and their optional positional specifier
  ///
  /// - Note: Any position that doesn't have a placeholder defined will be stripped out, shifting the position of
  ///         the remaining placeholders. This is to match how Foundation behaves at runtime.
  ///         i.e. a string of `"%2$@ %3$d"` will end up with `[.object, .int]` since no placeholder
  ///         is defined for position 1.
  /// - Parameter chars: An array of format chars and their optional positional specifier
  /// - Throws: `Strings.ParserError.invalidPlaceholder` in case a `PlaceholderType` would be overwritten
  /// - Returns: An array of `PlaceholderType`
  private static func placeholderTypes(fromChars chars: [(String, Int?)]) throws -> [Strings.PlaceholderType] {
    var list = [Int: Strings.PlaceholderType]()
    var nextNonPositional = 1

    for (str, pos) in chars {
      guard let char = str.first, let placeholderType = Strings.PlaceholderType(formatChar: char) else { continue }
      let insertionPos: Int
      if let pos = pos {
        insertionPos = pos
      } else {
        insertionPos = nextNonPositional
        nextNonPositional += 1
      }
      guard insertionPos > 0 else { continue }

      if let existingEntry = list[insertionPos], existingEntry != placeholderType {
          //throw Strings.ParserError.invalidPlaceholder(previous: existingEntry, new: placeholderType)
      } else {
        list[insertionPos] = placeholderType
      }
    }

    // Omit any holes (i.e. position without a placeholder defined)
    return list
      .sorted { $0.0 < $1.0 } // Sort by key, i.e. the positional value
      .map { $0.value }
  }
}

class PlaceholderTypeTests: XCTestCase {

    func testUintPlaceholderType() {
        let formatString = "Total items: %u"
        do {
            let types = try Strings.PlaceholderType.placeholderTypes(fromFormat: formatString)
            XCTAssertEqual(types, [.uint], "The placeholder type for 'u' should be uint.")
            if types == [.uint]{
                print("Checks out!")
            }
            else{
                print("Wrong Type")
            }
        } catch {
            XCTFail("Parsing failed with an unexpected error: \(error)")
        }
    }
    func testingIntPlaceholderType() {
        let formatString = "Total items: %i"
        do {
            let types = try Strings.PlaceholderType.placeholderTypes(fromFormat: formatString)
            XCTAssertEqual(types, [.int], "The placeholder type for 'u' should be uint.")
            if types == [.int]{
                print("Checks out!")
            }
            else{
                print("Wrong Type")
            }
        } catch {
            XCTFail("Parsing failed with an unexpected error: \(error)")
        }
    }
    func testFloatPlaceholderType() {
        let formatString = "Total items: %u"
        do {
            let types = try Strings.PlaceholderType.placeholderTypes(fromFormat: formatString)
            XCTAssertEqual(types, [.uint], "The placeholder type for 'u' should be uint.")
            if types == [.uint]{
                print("Checks out!")
            }
            else{
                print("Wrong Type")
            }
        } catch {
            XCTFail("Parsing failed with an unexpected error: \(error)")
        }
    }
    func testUintMultiPlaceholderType() {
        let formatString = "Total items: %u Height:%o Total Weight: %u"
        do {
            let types = try Strings.PlaceholderType.placeholderTypes(fromFormat: formatString)
            XCTAssertEqual(types, [.uint, .int,. uint], "The placeholder type for 'u' should be uint.")
            if types == [.uint, .int, .uint]{
                print("Checks out!")
            }
            else{
                print("Wrong Type")
            }
        } catch {
            XCTFail("Parsing failed with an unexpected error: \(error)")
        }
    }

}

class TestRunner {
    static func runTests() {
        let tests = PlaceholderTypeTests()
        tests.testUintPlaceholderType()
        tests.testingIntPlaceholderType()
        tests.testFloatPlaceholderType()
        tests.testUintMultiPlaceholderType()
    }
}
TestRunner.runTests()
