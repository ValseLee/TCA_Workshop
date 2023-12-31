//
//  DateFormatter+Init.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/22.
//

import Foundation

extension DateFormatter {
    /**
     dateFormat, Calendar를 기본 값으로 설정하여 DateFormatter를 초기화하는 생성자
    - Parameters:
        - dateFormat: "D", "EEE" 형태의 문자열 포맷
        - calendar: 주어진 달력을 기준으로 Formatter 생성
     */
    convenience init(
        dateFormat: String,
        calendar: Calendar = .current
    ) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

/// App 내에서 사용할 Formatter들을 보관하는 Container
struct DateFormatters {
    let minuteHourFormatter = DateFormatter(dateFormat: "HH:mm a", calendar: .autoupdatingCurrent)
    let dayFormatter = DateFormatter(dateFormat: "YY년 MM월 dd일", calendar: .autoupdatingCurrent)
}
