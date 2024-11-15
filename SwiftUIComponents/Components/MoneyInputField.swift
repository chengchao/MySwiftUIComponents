//
//  MoneyInputField.swift
//  Money input field component for SwiftUI
//
//

import SwiftUI

struct MoneyInputField: View {
  @Binding var amountInCents: Int
  @State private var formattedAmountString = "0"

  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    return formatter
  }()

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
          amountInCents = Int((Double(sanitizeInput(formattedAmountString)) ?? 0) * 100)
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

  private func sanitizeInput(_ input: String) -> String {
    // Remove any invalid characters (only digits, `.` are allowed)
    let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
    return String(input.unicodeScalars.filter { allowedCharacters.contains($0) })
  }

  private func truncateDecimalPlaces(_ value: String) -> String {
    if let dotIndex = value.firstIndex(of: ".") {
      let truncatedEndIndex =
        value.index(dotIndex, offsetBy: 3, limitedBy: value.endIndex) ?? value.endIndex
      return String(value[..<truncatedEndIndex])
    }
    return value
  }

  private func formatNumber(_ number: Double) -> String {
    let result =
      MoneyInputField.numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    return result
  }
}

#Preview {
  @Previewable @State var amountInCents: Int = 0
  return MoneyInputField(amountInCents: $amountInCents).onChange(of: amountInCents) { oldValue, newValue in
    print("Amount changed from \(oldValue) to \(newValue)")
  }
}
