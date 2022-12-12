// View+CustomOverlay.swift

import SwiftUI

struct CustomOverlay<V: View>: ViewModifier {
    @Binding var isShown: Bool
    @State var alignment: Alignment
    let view: () -> V
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                Group {
                    if isShown {
                        view()
                    } else {
                        view()
                            .opacity(0)
                    }
                }
                .onContinuousHover { phase in
                    withAnimation {
                        switch phase {
                            case .active(_):
                                isShown = true
                            case .ended:
                                isShown = false
                        }
                    }
                }
            }
    }
}

extension View {
    func customOverlay<V: View>(isShown: Binding<Bool>, alignment: Alignment, @ViewBuilder view: @escaping () -> V) -> some View {
        modifier(CustomOverlay(isShown: isShown, alignment: alignment, view: view))
    }
}
