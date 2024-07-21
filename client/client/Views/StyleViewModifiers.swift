import Foundation
import SwiftUI

struct HeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(Color(UIColor.systemGray))
            .textCase(/*@START_MENU_TOKEN@*/ .uppercase/*@END_MENU_TOKEN@*/)
    }
}

struct SubHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .regular, design: .monospaced))
            .foregroundColor(Color(UIColor.systemGray2))
    }
}

struct TagStyle: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        VStack {
            content
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color(UIColor.systemBackground))
                .textCase(.uppercase)
                .padding(.horizontal, 2)
        }.background(color)
            .cornerRadius(2)
    }
}

struct LabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .foregroundColor(Color(UIColor.gray))
            .textCase(.uppercase)
    }
}

struct BigNumberStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .regular, design: .monospaced))
            .foregroundColor(Color(UIColor.white))
            .frame(width: 90, alignment: .leading)
    }
}

extension View {
    func headerStyle() -> some View {
        modifier(HeaderStyle())
    }

    func subHeaderStyle() -> some View {
        modifier(SubHeaderStyle())
    }

    func tagStyle(color: Color = Color(UIColor.systemGreen)) -> some View {
        modifier(TagStyle(color: color))
    }

    func labelStyle() -> some View {
        modifier(LabelStyle())
    }

    func bigNumberStyle() -> some View {
        modifier(BigNumberStyle())
    }
}
