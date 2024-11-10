//
//  ContentView.swift
//  SwiftUIComponents
//
//  Created by Chao Cheng on 11/9/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @State var amountInCents = 0

  var body: some View {
    MoneyInputField(amountInCents: $amountInCents)
  }
}

#Preview {
  ContentView()
}
