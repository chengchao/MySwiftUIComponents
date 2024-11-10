//
//  MoneyInputField.swift
//  Money input field component for SwiftUI
//
//

import SwiftUI

struct MoneyInputField: View {
  @Binding var amountInCents: Int
  @State private var formattedAmountString = "0"

  var body: some View {
    VStack {
      TextField("Enter amount", text: $formattedAmountString)
        .keyboardType(.decimalPad)
        .padding()
        .onAppear {
          formattedAmountString = String(format: "%.2f", Double(amountInCents) / 100)
        }
        .onChange(of: formattedAmountString) { oldValue, newValue in
          formattedAmountString = formatNumberString(oldValue: oldValue, newValue: newValue)
          if let number = Double(formattedAmountString) {
            amountInCents = Int(number * 100)
          } else {
            amountInCents = 0
          }
        }
    }
  }

  func formatNumberString(oldValue: String, newValue: String) -> String {
    if newValue.isEmpty {
      return "0"
    }

    var value = sanitizeInput(newValue)
    value = truncateDecimalPlaces(value)

    let isEndWithDot = value.last == "."
    let hasSuffixDotZero = value.hasSuffix(".0")

    if let number = Double(value) {
      let result = formatNumber(number)

      if isEndWithDot {
        return result + "."
      }

      if hasSuffixDotZero {
        return result + ".0"
      }

      return result
    } else {
      return oldValue  // Fallback to oldValue if conversion fails
    }
  }

  private let nonNumericCharactersRegex = try! NSRegularExpression(pattern: "[^0-9.]", options: [])

  private func sanitizeInput(_ input: String) -> String {
    let range = NSRange(location: 0, length: input.utf16.count)
    return nonNumericCharactersRegex.stringByReplacingMatches(
      in: input, options: [], range: range, withTemplate: "")
  }

  private func truncateDecimalPlaces(_ value: String) -> String {
    if let dotIndex = value.firstIndex(of: ".") {
      let truncatedEndIndex =
        value.index(dotIndex, offsetBy: 3, limitedBy: value.endIndex) ?? value.endIndex
      return String(value[..<truncatedEndIndex])
    }
    return value
  }

  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    return formatter
  }()

  private func formatNumber(_ number: Double) -> String {
    let result =
      MoneyInputField.numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    return result
  }
}

#Preview {
  @Previewable @State var amountInCents: Int = 0
  return MoneyInputField(amountInCents: $amountInCents)
}
