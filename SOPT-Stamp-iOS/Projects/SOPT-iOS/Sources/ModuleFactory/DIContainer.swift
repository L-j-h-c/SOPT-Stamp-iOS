//
//  DIContainer.swift
//  SOPT-iOS
//
//  Created by 김영인 on 2023/03/16.
//  Copyright © 2023 SOPT-iOS. All rights reserved.
//

import Core
import Network
import Domain
import Data

import SplashFeatureInterface
import SplashFeature
import OnboardingFeatureInterface
import OnboardingFeature
import AuthFeatureInterface
import AuthFeature
import SettingFeatureInterface
import SettingFeature
import StampFeatureInterface
import StampFeature

typealias Features = SplashFeatureViewBuildable & OnboardingFeatureViewBuildable & AuthFeatureViewBuildable & StampFeatureViewBuildable & SettingFeatureViewBuildable

final class DIContainer {
    lazy var authService = DefaultAuthService()
    lazy var userService = DefaultUserService()
    lazy var rankService = DefaultRankService()
    lazy var missionService = DefaultMissionService()
    lazy var stampService = DefaultStampService()
    lazy var firebaseService = DefaultFirebaseService()
}

extension DIContainer: Features {
    
    // MARK: - SplashFeature
    
    func makeSplashVC() -> SplashViewControllable {
        let repository = AppNoticeRepository(service: firebaseService)
        let useCase = DefaultAppNoticeUseCase(repository: repository)
        let viewModel = SplashViewModel(useCase: useCase)
        let splashVC = SplashVC()
        splashVC.factory = self
        splashVC.viewModel = viewModel
        return splashVC
    }
    
    func makeNoticePopUpVC(noticeType: NoticePopUpType, content: String) -> NoticePopUpViewControllable {
        let noticePopUpVC = NoticePopUpVC()
        noticePopUpVC.setData(type: noticeType, content: content)
        noticePopUpVC.modalPresentationStyle = .overFullScreen
        return noticePopUpVC
    }
    
    // MARK: - OnboardingFeature
    
    func makeOnboardingVC() -> OnboardingViewControllable {
        let onboardingVC = OnboardingVC()
        onboardingVC.factory = self
        return onboardingVC
    }
    
    // MARK: - AuthFeature
    
    func makeSignInVC() -> SignInViewControllable {
        let repository = SignInRepository(service: userService)
        let useCase = DefaultSignInUseCase(repository: repository)
        let viewModel = SignInViewModel(useCase: useCase)
        let signinVC = SignInVC()
        signinVC.factory = self
        signinVC.viewModel = viewModel
        return signinVC
    }
    
    func makeFindAccountVC() -> FindAccountViewControllable {
        let findAccountVC = FindAccountVC()
        return findAccountVC
    }
    
    func makeSignUpVC() -> SignUpViewControllable {
        let repository = SignUpRepository(service: authService, userService: userService)
        let useCase = DefaultSignUpUseCase(repository: repository)
        let viewModel = SignUpViewModel(useCase: useCase)
        let signUpVC = SignUpVC()
        signUpVC.factory = self
        signUpVC.viewModel = viewModel
        return signUpVC
    }
    
    public func makeSignUpCompleteVC() -> SignUpCompleteViewControllable {
        let signUpCompleteVC = SignUpCompleteVC()
        signUpCompleteVC.factory = self
        return signUpCompleteVC
    }
    
    // MARK: - StampFeature
    
    func makeMissionListVC(sceneType: MissionListSceneType) -> MissionListViewControllable {
        let repository = MissionListRepository(service: missionService)
        let useCase = DefaultMissionListUseCase(repository: repository)
        let viewModel = MissionListViewModel(useCase: useCase, sceneType: sceneType)
        let missionListVC = MissionListVC()
        missionListVC.viewModel = viewModel
        missionListVC.factory = self
        return missionListVC
    }
    
    func makeListDetailVC(sceneType: ListDetailSceneType,
                          starLevel: StarViewLevel,
                          missionId: Int,
                          missionTitle: String,
                          otherUserId: Int?) -> ListDetailViewControllable {
        let repository = ListDetailRepository(service: stampService)
        let useCase = DefaultListDetailUseCase(repository: repository)
        let viewModel = ListDetailViewModel(useCase: useCase,
                                            sceneType: sceneType,
                                            starLevel: starLevel,
                                            missionId: missionId,
                                            missionTitle: missionTitle,
                                            otherUserId: otherUserId)
        let listDetailVC = ListDetailVC()
        listDetailVC.viewModel = viewModel
        listDetailVC.factory = self
        return listDetailVC
    }
    
    func makeMissionCompletedVC(starLevel: StarViewLevel, completionHandler: (() -> Void)?) -> MissionCompletedViewControllable {
        let missionCompletedVC = MissionCompletedVC()
            .setLevel(starLevel)
        missionCompletedVC.completionHandler = completionHandler
        missionCompletedVC.modalPresentationStyle = .overFullScreen
        missionCompletedVC.modalTransitionStyle = .crossDissolve
        return missionCompletedVC
    }
    
    func makeRankingVC() -> RankingViewControllable {
        let repository = RankingRepository(service: rankService)
        let useCase = DefaultRankingUseCase(repository: repository)
        let viewModel = RankingViewModel(useCase: useCase)
        let rankingVC = RankingVC()
        rankingVC.factory = self
        rankingVC.viewModel = viewModel
        return rankingVC
    }
    
    func makeAlertVC(type: AlertType,
                     title: String,
                     description: String = "",
                     customButtonTitle: String,
                     customAction: (() -> Void)? = nil) -> AlertViewControllable {
        let alertVC = AlertVC(alertType: type)
            .setTitle(title, description)
            .setCustomButtonTitle(customButtonTitle)
        alertVC.customAction = customAction
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        return alertVC
    }
    
    func makeNetworkAlertVC() -> AlertViewControllable {
        let alertVC = AlertVC(alertType: .networkErr)
            .setTitle(I18N.Default.networkError, I18N.Default.networkErrorDescription)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        return alertVC
    }
    
    // MARK: - SettingFeature
    
    func makeSettingVC() -> SettingViewControllable {
        let repository = SettingRepository(authService: authService, stampService: stampService, rankService: rankService)
        let useCase = DefaultSettingUseCase(repository: repository)
        let viewModel = SettingViewModel(useCase: useCase)
        let settingVC = SettingVC()
        settingVC.factory = self
        settingVC.viewModel = viewModel
        return settingVC
    }
    
    func makeNicknameEditVC() -> NicknameEditViewControllable {
        let settingRepository = SettingRepository(authService: authService, stampService: stampService, rankService: rankService)
        let settingUseCase = DefaultSettingUseCase(repository: settingRepository)

        let signUpRepository = SignUpRepository(service: self.authService, userService: self.userService)
        let signUpUseCase = DefaultSignUpUseCase(repository: signUpRepository)

        let viewModel = NicknameEditViewModel(nicknameUseCase: signUpUseCase, editPostUseCase: settingUseCase)
        let nicknameEdit = NicknameEditVC()
        nicknameEdit.factory = self
        nicknameEdit.viewModel = viewModel
        return nicknameEdit
    }
    
    func makeSentenceEditVC() -> SentenceEditViewControllable {
        let repository = SettingRepository(authService: authService, stampService: stampService, rankService: rankService)
        let useCase = DefaultSentenceEditUseCase(repository: repository)
        let viewModel = SentenceEditViewModel(useCase: useCase)
        let sentenceEditVC = SentenceEditVC()
        sentenceEditVC.viewModel = viewModel
        sentenceEditVC.factory = self
        return sentenceEditVC
    }
    
    func makePasswordChangeVC() -> PasswordChangeViewControllable {
        let repository = SettingRepository(authService: authService, stampService: stampService, rankService: rankService)
        let useCase = DefaultPasswordChangeUseCase(repository: repository)
        let viewModel = PasswordChangeViewModel(useCase: useCase)
        let passwordChangeVC = PasswordChangeVC()
        passwordChangeVC.factory = self
        passwordChangeVC.viewModel = viewModel
        return passwordChangeVC
    }
    
    func makePrivacyPolicyVC() -> PrivacyPolicyViewControllable {
        let privacyPolicyVC = PrivacyPolicyVC()
        return privacyPolicyVC
    }
    
    func makeTermsOfServiceVC() -> TermsOfServiceViewControllable {
        let termsOfServiceVC = TermsOfServiceVC()
        return termsOfServiceVC
    }
    
    func makeWithdrawalVC() -> WithdrawalViewControllable {
        let withdrawalVC = WithdrawalVC()
        let repository = SettingRepository(authService: authService, stampService: stampService, rankService: rankService)
        let useCase = DefaultSettingUseCase(repository: repository)
        let viewModel = WithdrawalViewModel(useCase: useCase)
        withdrawalVC.viewModel = viewModel
        withdrawalVC.factory = self
        return withdrawalVC
    }
}
