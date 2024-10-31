//
//  CommonWebV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/27/24.
//

import SwiftUI
import ComposableArchitecture

struct CommonWebV: View {
    @Environment(\.dismiss) var dismiss

    var store: StoreOf<WebViewFeature>
    var urlStr: String
    
    init(store: StoreOf<WebViewFeature>, urlStr: String) {
        self.store = store
        self.urlStr = urlStr
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                CommonWebView(store: store,
                              urlStr: self.urlStr)
                
                if viewStore.isShowIndicator {
                    CommonLoadingV()
                }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            }
            .onChange(of: viewStore.isDismiss) { _, newValue in
                if newValue {
                    dismiss()
                }
            }
            .alert(isPresented: viewStore.binding(
                get: { $0.isShowAlert },
                send: .showAlert(isShowAlert: false, alertMsg: "")
            )) {
                Alert(
                    title: Text(viewStore.jsAlert ?? ""),
                    dismissButton: .default(Text("확인"), action: {
                        print("알림창 확인")
                    })
                )
            }
        }
    }
}

#Preview {
    CommonWebV(store: Store(initialState: WebViewFeature.State(), reducer: {
        WebViewFeature()
    }), urlStr: "https://m.naver.com")
}
