//
//  KeyBoardNotificationManager.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import Foundation
import Combine
import UIKit

final class KeyboardNotificationManager: ObservableObject {
    enum Status {
        case show, hide
        var description: String {
            switch self {
            case .show: return "Keyboard Show"
            case .hide: return "Keyboard Hide"
            }
        }
    }
    
    var subscriptions = Set<AnyCancellable>()
    @Published var keyboardHeight: CGFloat = 0.0
    lazy var updateKeyboardStatus: AnyPublisher<Status, Never> = $keyboardHeight.map { (height: CGFloat) -> KeyboardNotificationManager.Status in
        return height > 0 ? .show : .hide
    }.eraseToAnyPublisher()
    
    init() {
        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap {
                $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map {
                $0.height
            }
            .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))
        
        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillHideNotification)
            .compactMap { (noti: Notification) -> CGFloat in
                return .zero
            }
            .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))
    }
    
}
