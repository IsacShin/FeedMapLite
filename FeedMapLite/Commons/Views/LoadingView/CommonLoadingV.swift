//
//  CommonLoadingV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 9/5/24.
//

import SwiftUI

struct CommonLoadingV: View {
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            CommonLoadingIndicator()
        }
    }
}

struct CommonLoadingWrapV_Previews: PreviewProvider {
    static var previews: some View {
        CommonLoadingV()
    }
}
