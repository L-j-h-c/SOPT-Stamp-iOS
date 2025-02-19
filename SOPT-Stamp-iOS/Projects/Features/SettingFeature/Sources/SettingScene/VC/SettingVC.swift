//
//  SettingVC.swift
//  Presentation
//
//  Created by 양수빈 on 2022/12/17.
//  Copyright © 2022 SOPT-Stamp-iOS. All rights reserved.
//

import UIKit

import Combine
import SnapKit
import Then

import Core
import DSKit

import AuthFeatureInterface
import SettingFeatureInterface
import StampFeatureInterface

public class SettingVC: UIViewController, SettingViewControllable {
    
    // MARK: - Properties
    
    public var viewModel: SettingViewModel!
    private var cancelBag = CancelBag()
    public var factory: (AuthFeatureViewBuildable & SettingFeatureViewBuildable & StampFeatureViewBuildable)!
    private let resetButtonTapped = PassthroughSubject<Bool, Never>()
    
    // MARK: - UI Components
    
    private lazy var naviBar = CustomNavigationBar(self, type: .titleWithLeftButton)
        .setTitle(I18N.Setting.setting)
    private let collectionViewFlowlayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowlayout)
    
    // MARK: - View Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModels()
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.setRegister()
    }
}

// MARK: - Methods

extension SettingVC {
    
    private func bindViewModels() {
        let input = SettingViewModel.Input(
            resetButtonTapped: resetButtonTapped.asDriver())
        let output = self.viewModel.transform(from: input, cancelBag: self.cancelBag)
        
        output.resetSuccessed
            .filter({ $0 })
            .sink { _ in
                self.showToast(message: I18N.Setting.resetSuccess)
            }.store(in: self.cancelBag)
    }
    
    private func setRegister() {
        SettingCVC.register(target: collectionView)
        SettingHeaderView.register(target: collectionView, isHeader: true)
        SettingFooterView.register(target: collectionView, isHeader: false)
    }
    
    private func setDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func presentResetAlertVC() {
        let alertVC = factory.makeAlertVC(
            type: .titleDescription,
            title: I18N.Setting.resetMissionTitle,
            description: I18N.Setting.resetMissionDescription,
            customButtonTitle: I18N.Setting.reset,
            customAction: { [weak self] in
                self?.resetButtonTapped.send(true)
            }).viewController
        
        self.present(alertVC, animated: true)
    }
    
    private func showEditSentenceView() {
        let editSentenceVC = factory.makeSentenceEditVC().viewController
        navigationController?.pushViewController(editSentenceVC, animated: true)
    }
    
    private func showEditNicknameView() {
        let editNicknameVC = factory.makeNicknameEditVC().viewController
        navigationController?.pushViewController(editNicknameVC, animated: true)
    }
    
    private func showPasswordChangeView() {
        let passwordChangeVC = factory.makePasswordChangeVC().viewController
        navigationController?.pushViewController(passwordChangeVC, animated: true)
    }
    
    private func showPrivacyPolicyView() {
        let privacyPolicyVC = factory.makePrivacyPolicyVC().viewController
        navigationController?.pushViewController(privacyPolicyVC, animated: true)
    }
    
    private func showTermsOfServieView() {
        let termsOfServiceVC = factory.makeTermsOfServiceVC().viewController
        navigationController?.pushViewController(termsOfServiceVC, animated: true)
    }
    
    private func logout() {
        UserDefaultKeyList.Auth.userId = nil
        self.changeRootViewController()
    }
    
    private func changeRootViewController() {
        guard let uWindow = self.view.window else { return }
        let navigation = UINavigationController(rootViewController: factory.makeSignInVC().viewController)
        navigation.isNavigationBarHidden = true
        uWindow.rootViewController = navigation
        uWindow.makeKey()
        UIView.transition(with: uWindow, duration: 0.5, options: [.transitionCrossDissolve], animations: {}, completion: nil)
    }
}

// MARK: - UI & Layout

extension SettingVC {
    private func setUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        collectionView.contentInset.top = 8
    }
    
    private func setLayout() {
        self.view.addSubviews(naviBar, collectionView)
        
        naviBar.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(naviBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SettingVC: WithdrawButtonDelegate {
    func withdrawButtonTapped() {
        let withdrawalVC = factory.makeWithdrawalVC().viewController
        navigationController?.pushViewController(withdrawalVC, animated: true)
    }
}

// MARK: - UICollectionView

extension SettingVC: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                showEditSentenceView()
            case 1:
                showPasswordChangeView()
            default:
                showEditNicknameView()
            }
        case 1:
            switch indexPath.row {
            case 0:
                showPrivacyPolicyView()
            case 1:
                showTermsOfServieView()
            default:
                openExternalLink(urlStr: ExternalURL.GoogleForms.serviceProposal)
            }
        case 2:
            self.presentResetAlertVC()
        default:
            logout()
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        var height = width*42/335
        
        if indexPath.row == 2 || indexPath.section == 2 || indexPath.section == 3 {
            height = width*49/335
        }
        return CGSize(width: width, height: height)
    }
}

extension SettingVC: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 3 { return .zero }
        let width = self.collectionView.frame.width
        let height = width*35/335
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section != 3 { return .zero }
        let width = self.collectionView.frame.width
        let height = width*23/335
        return CGSize(width: width, height: height)
    }
}

extension SettingVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionList = viewModel.settingList
        return sectionList[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCVC.className, for: indexPath) as? SettingCVC else { return UICollectionViewCell() }
        let titleList = viewModel.settingList[indexPath.section]
        if indexPath.row == 1 { cell.setLines() }
        if indexPath.row == 2 { cell.setRadius() }
        if indexPath.section == 2 {
            cell.removeArrow()
                .setRadius()
        }
        
        if indexPath.section == 3 {
            cell.changeTextColor(DSKitAsset.Colors.soptampAccess300.color)
                .setRadius(false)
                .removeArrow()
        }
        cell.setData(titleList[indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingHeaderView.className, for: indexPath) as? SettingHeaderView else { return UICollectionReusableView() }
            let headerList = viewModel.sectionList
            header.setData(headerList[indexPath.section])
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingFooterView.className, for: indexPath) as? SettingFooterView else { return UICollectionReusableView() }
            footer.buttonDelegate = self
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}
