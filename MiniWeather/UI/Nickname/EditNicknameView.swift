//
//  EditNicknameView.swift
//  MiniWeather
//
//  Created by Ezenwa Okoro on 18/04/2024.
//

import SwiftUI

struct EditNicknameView: View {
    @Binding var editInfo: SearchTextField.EditInfo
    @Binding var showConfirmation: Bool
    @FocusState private var isFocused: Bool
    
    let location: Location
    let index: Int
    let onNicknameChange: (String, Int) -> Void
    let dismiss: () -> Void
    
    let spacing: CGFloat = 24
    var validNickname: String { editInfo.text.value(if: !editInfo.text.isEmpty) ?? location.city }
    
    init(location: Location, index: Int, editInfo: Binding<SearchTextField.EditInfo>, showConfirmation: Binding<Bool>, onNicknameChange: @escaping (String, Int) -> Void, dismiss: @escaping () -> Void) {
        self.location = location
        self.index = index
        self.onNicknameChange = onNicknameChange
        self.dismiss = dismiss
        self._editInfo = editInfo
        self._showConfirmation = showConfirmation
    }
    
    var body: some View {
        NavigationStack {
            ImageBackgroundView {
                VStack(spacing: 0) {
                    MaterialView(spacing: 32, insets: .init(value: spacing)) {
                        textField("Nickname", isNicknameField: true)
                        
                        textField("Location", isNicknameField: false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    Text("Tapping \"Save\" with no nickname entered will set the location's nickname to its city name.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .navigationTitle("Edit Nickname")
                .navigationBarTitleDisplayMode(.inline)
            }
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: dismiss) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { 
                        onNicknameChange(validNickname, index)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
            #endif
            .interactiveDismissDisabled(!editInfo.text.isEmpty)
            .confirmationDialog("", isPresented: $showConfirmation) {
                Button("Discard Changes?", role: .destructive, action: dismiss)
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    func headerText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 8)
    }
    
    @ViewBuilder func textField(_ text: String, isNicknameField: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            headerText(text)
            
            if isNicknameField {
                SearchTextField(placeholder: editInfo.placeholder, text: $editInfo.text)
                    .focused($isFocused)
                    .background(
                        Color.primary
                            .opacity(0.05)
                            .clipShape(
                                .rect(cornerRadius: 10)
                            )
                    )
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit {
                        onNicknameChange(validNickname, index)
                        dismiss()
                    }
            } else {
                SearchTextField(placeholder: "", text: .constant(location.fullName), canShowClearButton: false)
                    .disabled(true)
                    .foregroundStyle(.quaternary)
                    .background(
                        Color.primary
                            .opacity(0.01)
                            .clipShape(
                                .rect(cornerRadius: 10)
                            )
                    )
            }
        }
    }
}

#Preview {
    EditNicknameView(location: UniversalConstants.location, index: 0, editInfo: .constant(.init(purpose: "", placeholder: "", text: "")), showConfirmation: .constant(false)) { _, _ in
        
    } dismiss: {
        
    }
}
