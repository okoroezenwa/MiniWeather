//
//  SettingsPicker.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 24/04/2024.
//

import SwiftUI

typealias SelectionEnum = Hashable & CaseIterable & Identifiable & RawRepresentable<String>

struct SettingsPicker<Selection: SelectionEnum>: View where Selection.AllCases == Array<Selection> {
    let title: String
    @Binding var selection: Selection
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Selection.allCases, id: \.self) { selection in
                Text(selection.rawValue)
            }
        }
        .tint(.secondary)
    }
}

#Preview {
    Form {
        SettingsPicker(title: "Test", selection: .constant(Theme.system))
    }
}
