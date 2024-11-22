//
//  FeedWriteV.swift
//  FeedMapLite
//
//  Created by 신이삭 on 9/5/24.
//

import SwiftUI
import CoreLocation
import ComposableArchitecture
import UIKit

struct FeedWriteV: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var selectFeedData: FeedDataModel? = nil
    var isUpdateV: Bool = false
    var loca: CLLocation?
    var address: String?
    var store: StoreOf<FeedWriteFeature>
    
    @ObservedObject var keyboardManager = KeyboardNotificationManager()
    @State var keyboardStatus: KeyboardNotificationManager.Status = .hide
    @Binding var isActive: Bool
    
    init(store: StoreOf<FeedWriteFeature>, isUpdateV: Bool, loca: CLLocation? = nil, address: String? = nil, isActive: Binding<Bool>, selectFeedData: FeedDataModel? = nil) {
        self.selectFeedData = selectFeedData
        self.isUpdateV = isUpdateV
        self.loca = loca
        self.address = address
        self.store = store
        self._isActive = isActive
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { g in
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: 15)
                            Group {
                                Text("주소")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Spacer().frame(height: 15)
                                Text(viewStore.addr)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Spacer().frame(height: 15)
                                Text("제목")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Spacer().frame(height: 15)
                                TextField("", text: viewStore.$title)
                                .tint(.blue)
                                .foregroundStyle(.gray)
                                .frame(height: 35)
                                .textInputAutocapitalization(.none)
                                .autocorrectionDisabled(false)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Button(action: {
                                            UIApplication.shared.endEditing(true)
                                        }, label: {
                                            Text("닫기")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.blue)
                                        })
                                        Spacer()
                                    }
                                }
                                .background(
                                    HStack {
                                        if viewStore.title.isEmpty {
                                            Text("제목을 입력해주세요")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                            Spacer()
                                        }
                                    }
                                )
                                
                                Spacer().frame(height: 30)
                            }
                            
                            Text("내용")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Spacer().frame(height: 15)
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: viewStore.$comment)
                                    .tint(.blue)
                                    .colorMultiply(Color(hexString: "f7f7f7"))
                                    .scrollContentBackground(.hidden)
                                    .background(Color(hexString: "f7f7f7"))
                                    .foregroundColor(.gray)
                                    .frame(height: 132)
                                    .background(.gray)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(false)
                                    .modifier(GrayBox())
                                
                                if viewStore.comment.isEmpty {
                                    Text("내용을 입력해주세요")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .padding(.top, 20)
                                        .padding(.horizontal, 20)
                                }
                            }
                            
                            Group {
                                Spacer().frame(height: 12)
                                Text("※ 부적절하거나 불쾌감을 줄 수 있는 컨텐츠는 제재를 받을 수 있습니다")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                Spacer().frame(height: 30)
                                HStack(spacing: 0) {
                                    Text("이미지 선택")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("최대 3장")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                Spacer().frame(height: 12)
                                HStack(spacing: 10) {
                                    if viewStore.imgs.count > 0 {
                                        ForEach(viewStore.imgs.indices, id: \.self) { i in
                                            Button {
                                                if viewStore.imgs.count > i {
                                                    viewStore.send(.removeImgAction(idx: i))
                                                } else {
                                                    viewStore.send(.showPhotoPicker(isShow: true))
                                                }
                                            } label: {
                                                if viewStore.imgs.count > i {
                                                    Image(uiImage: viewStore.imgs[i])
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: g.size.width / 3 - 60, height: 65)
                                                        .modifier(GrayBox())
                                                        .overlay(alignment: .topTrailing) {
                                                            Image("btnClose01")
                                                                .offset(x: 5, y: -5)
                                                        }
                                                } else {
                                                    Image("icoPlus-1")
                                                        .frame(width: g.size.width / 3 - 60, height: 65)
                                                        .modifier(GrayBox())
                                                }
                                            }
                                        }
                                    } else {
                                        Button {
                                            if viewStore.imgs.count > 0 {
                                                viewStore.send(.removeImgAction(idx: 0))
                                            } else {
                                                viewStore.send(.showPhotoPicker(isShow: true))
                                            }
                                        } label: {
                                            if viewStore.imgs.count > 0 {
                                                Image(uiImage: viewStore.imgs[0])
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: g.size.width / 3 - 60, height: 65)
                                                    .modifier(GrayBox())
                                                    .overlay(alignment: .topTrailing) {
                                                        Image("btnClose01")
                                                            .offset(x: 5, y: -5)
                                                    }
                                            } else {
                                                Image("icoPlus-1")
                                                    .frame(width: g.size.width / 3 - 60, height: 65)
                                                    .modifier(GrayBox())
                                            }
                                        }
                                        
                                    }
                                }
                                Spacer().frame(height: 40)
                                if isUpdateV {
                                    VStack(alignment: .center) {
                                        Button {
                                            viewStore.send(.showAlert(isShow: true,
                                                                      alertType: .feedDeleteConfirm))
                                        } label: {
                                            Text("삭제하기")
                                                .underline()
                                                .foregroundColor(Color.red)
                                        }
                                        
                                        Spacer().frame(height: 40)
                                    }
                                    .frame(width: g.size.width - 40)
                                }
                                Spacer().frame(height: 20)
                                Button {
                                    viewStore.send(.uploadFeed(isUpdateV: self.isUpdateV,
                                                               loca: self.loca,
                                                               context: self.modelContext))
                                } label: {
                                    Text("완료")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .background(.black)
                                        .cornerRadius(16)
                                }
                            }
                            Spacer()
                        }
                        .padding(20)
                        .frame(width: g.size.width)
                        .frame(minHeight: g.size.height)
                    }
                    .scrollIndicators(.hidden)
                    
                    if viewStore.isLoading {
                        CommonLoadingV()
                    }
                }
                .navigationTitle("피드등록")
            }
            .navigationBarTitleDisplayMode(.inline)
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
            .background(DARK_COLOR)
            .onReceive(self.keyboardManager.updateKeyboardStatus) { updatedStatus in
                self.keyboardStatus = updatedStatus
            }
            .task {
                viewStore.send(.setData(feedData: selectFeedData,
                                        address: address))
            }
            .alert(isPresented: viewStore.$showAlert) {
                let msg = viewStore.alertType.rawValue
                switch viewStore.alertType {
                case .feedWriteSuccess:
                    return Alert(title: Text(msg), dismissButton: .default(Text("확인"), action: {
                        self.isActive = true
                        dismiss()
                    }))
                case .feedDeleteConfirm:
                    return Alert(
                        title: Text(msg),
                        primaryButton: .default(Text("확인"))  {
                            guard let selectFeedData = self.selectFeedData else { return }
                            viewStore.send(.removeFeed(feedData: selectFeedData, context: modelContext))
                        },
                        secondaryButton: .cancel(Text("취소")))
                case .feedDeleteSuccess:
                    return Alert(title: Text(msg), dismissButton: .default(Text("확인"), action: {
                        self.isActive = true
                        dismiss()
                    }))
                default:
                    return Alert(title: Text(msg), dismissButton: .default(Text("확인"), action: {
                    }))
                }
            }
            .sheet(isPresented: viewStore.$showPhotoPicker) {
                CommonImagePicker(completion: { images in
                    viewStore.send(.setImages(imgs: images))
                }, maxCount: 3)
            }
            .onChange(of: viewStore.isUpdate) { old, new in
                if new {
                    self.isActive = true
                    viewStore.send(.showAlert(isShow: true,
                                              alertType: .feedWriteSuccess))
                }
            }
            
        }
        
    }
}

//#Preview {
//    FeedWriteV()
//}
