//
//  CommonAlertType.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/31/24.
//

import Foundation

enum CommonAlertType: String, CaseIterable {
    case success = "성공하였습니다."
    case isCheckCurrentLocationFail = "현재 위치를 찾을 수 없습니다.\n앱 설정으로 가서 위치서비스를 허용하시겠어요?"
    case feedWriteSuccess = "등록되었습니다."
    case feedExists = "이 장소에 이미 등록한 피드가 있습니다."
    case feedNotExists = "이 장소에 등록된 피드가 없습니다.\n피드를 등록해주세요"
    case feedTitleNotExists = "제목을 입력해주세요."
    case feedCommentNotExists = "내용을 입력해주세요."
    case feedImgNotExists = "대표 이미지를 등록해주세요."
    case feedDeleteSuccess = "삭제되었습니다."
    case feedDeleteConfirm = "삭제 하시겠습니까?"
}
