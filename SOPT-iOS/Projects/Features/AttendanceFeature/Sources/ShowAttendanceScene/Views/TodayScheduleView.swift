//
//  TodayScheduleView.swift
//  AttendanceFeature
//
//  Created by devxsby on 2023/04/12.
//  Copyright © 2023 SOPT-iOS. All rights reserved.
//

import UIKit

import Core
import Domain
import DSKit

/*
 출석 조회하기 뷰의 상단 오늘의 일정을 보여주는 뷰 입니다.
 */

final class TodayScheduleView: UIView {
    
    private enum Metric {
        static let todayAttendanceHeight = 51.f
    }
    
    // MARK: - UI Components

    private let dateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .Main.body2
        label.textColor = DSKitAsset.Colors.gray60.color
        return label
    }()
    
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSKitAsset.Colors.gray60.color
        label.font = .Main.body2
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = DSKitFontFamily.Suit.regular.font(size: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DSKitAsset.Colors.gray30.color
        label.font = .Main.body2
        return label
    }()
    
    private lazy var dateStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [dateImageView, dateLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var placeStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [placeImageView, placeLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var dateAndPlaceStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [dateStackView, placeStackView])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var todayInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeStackView, dateAndPlaceStackView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.setCustomSpacing(15, after: dateAndPlaceStackView)
        return stackView
    }()
    
    private let todayAttendanceView: TodayAttendanceView = {
        let view = TodayAttendanceView()
        view.isHidden = true
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            todayInfoStackView,
            subtitleLabel,
            todayAttendanceView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Initialization

    init(type: AttendanceScheduleType) {
        super.init(frame: .zero)
        
        confiureContentView()
        setLayout(type)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension TodayScheduleView {
    
    private func confiureContentView() {
        self.backgroundColor = DSKitAsset.Colors.black60.color
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
    }
    
    private func setLayout(_ type: AttendanceScheduleType) {
        addSubview(containerStackView)
        
        todayAttendanceView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(32)
        }
        
        if case .unscheduledDay = type {
            todayInfoStackView.isHidden = true
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(32)
                $0.leading.equalToSuperview().offset(32)
            }
        }
    }
    
    func updateLayout(_ type: AttendanceScheduleType) {
        if case .unscheduledDay = type {
            todayInfoStackView.isHidden = true
            
            titleLabel.text = I18N.Attendance.today + I18N.Attendance.unscheduledDay + I18N.Attendance.dayIs
            titleLabel.setTypoStyle(DSKitFontFamily.Suit.medium.font(size: 16))
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(32)
                $0.leading.equalToSuperview().offset(32)
            }
        }
    }
    
    private func setDefaultLayout() {
        dateImageView.image = DSKitAsset.Assets.opDate.image
        placeImageView.image = DSKitAsset.Assets.opPlace.image
    }
}

// MARK: - Methods

extension TodayScheduleView {
    
    func setData(date: String, place: String, todaySchedule: String, description: String?) {
        setDefaultLayout()
        dateLabel.text = date
        placeLabel.text = place
        titleLabel.text = I18N.Attendance.today + todaySchedule + I18N.Attendance.dayIs
        titleLabel.partFontChange(targetString: todaySchedule,
                                  font: DSKitFontFamily.Suit.bold.font(size: 18))
        subtitleLabel.text = description
        subtitleLabel.isHidden = ((description?.isEmpty) == nil || description == "")
    }
    
    func setAttendanceInfo(_ attendances: [AttendanceStepModel], _ hasAttendance: Bool) {
        todayAttendanceView.setTodayAttendances(attendances)
        todayAttendanceView.isHidden = !hasAttendance
    }
}
