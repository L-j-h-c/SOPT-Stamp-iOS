//
//  SettingFeatureViewControllable.swift
//  SettingFeatureTests
//
//  Created by 김영인 on 2023/03/18.
//  Copyright © 2023 SOPT-iOS. All rights reserved.
//

import Core

import BaseFeatureDependency

public protocol SettingViewControllable: ViewControllable { }

public protocol NicknameEditViewControllable: ViewControllable { }

public protocol SentenceEditViewControllable: ViewControllable { }

public protocol PrivacyPolicyViewControllable: ViewControllable { }

public protocol TermsOfServiceViewControllable: ViewControllable { }

public protocol WithdrawalViewControllable: ViewControllable {
    var userType: UserType { get set }
}

public protocol SettingFeatureViewBuildable {
    func makeSettingVC() -> SettingViewControllable
    func makeNicknameEditVC() -> NicknameEditViewControllable
    func makeSentenceEditVC() -> SentenceEditViewControllable
    func makePrivacyPolicyVC() -> PrivacyPolicyViewControllable
    func makeTermsOfServiceVC() -> TermsOfServiceViewControllable
    func makeWithdrawalVC(userType: UserType) -> WithdrawalViewControllable
}
