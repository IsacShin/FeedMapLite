//
//  GrayBox.swift
//  FeedMapLite
//
//  Created by 신이삭 on 9/5/24.
//

import SwiftUI

struct GrayBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(hexString: "f7f7f7"))
            .cornerRadius(16)
    }
}

struct GrayBox_Previews: PreviewProvider {
    static var previews: some View {
        Text("ddfdsafsdafsdfsad")
            .modifier(GrayBox())
    }
}
