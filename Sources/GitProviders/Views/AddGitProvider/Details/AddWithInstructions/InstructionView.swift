//
//  InstructionView.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

protocol InstructionView: View {
    associatedtype T
    var preset: GitProviderPresets { get }
    var customDetails: CustomProviderDetails? { get }
    var gitProviderStore: GitProviderStore { get }
    func forceAdd(authItem: T)
}

extension InstructionView {
    
    var gitProvider: GitProvider? {
        gitProviderStore.gitProviders.first { provider in
            switch preset {
            case .Custom:
                return provider.customDetails?.customName == customDetails?.customName
            default:
                return provider.baseKeyName == preset.rawValue
            }
        }
    }
    
    var hostName: String {
        if preset == .Custom {
            return customDetails?.customName ?? "Custom"
        } else {
            return preset.rawValue
        }
    }
    
    func instructionBase(i: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(i).circle")
            Text(text)
        }
    }
    
    @ViewBuilder
    func instruction(
        i: Int,
        text: String,
        link url: URL? = nil,
        copyableText: String? = nil,
        onClick: (() -> Void)? = nil,
        shouldPasteButton: Bool = false,
        input: (title: String, binding: Binding<String>)? = nil,
        secureInput: (title: String, binding: Binding<String>)? = nil,
        toggle: Binding<Bool>? = nil
    ) -> some View {
        if let url = url {
            Link(destination: url) {
                HStack {
                    instructionBase(i: i, text: text)
                    Spacer()
                    Text(url.absoluteString).font(.footnote).foregroundColor(.gray)
                }
            }
        } else if let onClick = onClick {
            Button(action: onClick) {
                instructionBase(i: i, text: text)
            }
        } else if let toggle = toggle {
            Toggle(isOn: toggle, label: {
                instructionBase(i: i, text: text)
            })
        } else {
            instructionBase(i: i, text: text)
        }
        if let input = input {
            HStack {
                TextField(input.title, text: input.binding).keyboardType(.asciiCapable).disableAutocorrection(true)
                PasteButton(into: input.binding)
            }
        }
        if let secureInput = secureInput {
            HStack {
                SecureField(secureInput.title, text: secureInput.binding)
                PasteButton(into: secureInput.binding)
            }
        }
        if let copyableText = copyableText {
            HStack {
                CopiableCellView(copiableText: copyableText).font(.footnote)
            }
        }
    }
    
    func instructionSection<Content: View>(footer: String, @ViewBuilder content: () -> Content) -> some View {
        Section(header: HStack {
            Image(systemName: "list.number")
            Text("Setup Instructions")
            Spacer()
        }, footer: Text(footer), content: content)
    }
}
