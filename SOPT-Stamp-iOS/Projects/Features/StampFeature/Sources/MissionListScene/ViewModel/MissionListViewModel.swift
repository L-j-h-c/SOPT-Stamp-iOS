//
//  MissionListViewModel.swift
//  PresentationTests
//
//  Created by Junho Lee on 2022/12/03.
//  Copyright © 2022 SOPT-Stamp-iOS. All rights reserved.
//

import Combine
import Foundation

import Core
import Domain

public class MissionListViewModel: ViewModelType {
    
    private let useCase: MissionListUseCase
    private var cancelBag = CancelBag()
    public var missionListsceneType: MissionListSceneType!
    public var otherUserId: Int?
    
    // MARK: - Inputs
    
    public struct Input {
        let viewWillAppear: Driver<Void>
        let missionTypeSelected: CurrentValueSubject<MissionListFetchType, Never>
    }
    
    // MARK: - Outputs
    
    public class Output: NSObject {
        @Published var missionListModel: [MissionListModel]?
    }
    
    // MARK: - init
    
    public init(useCase: MissionListUseCase, sceneType: MissionListSceneType) {
        self.useCase = useCase
        self.missionListsceneType = sceneType
    }
}

extension MissionListViewModel {
    public func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        self.bindOutput(output: output, cancelBag: cancelBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .sink { owner, _ in
                owner.fetchMissionList(type: input.missionTypeSelected.value)
            }.store(in: cancelBag)
        
        input.missionTypeSelected
            .dropFirst()
            .withUnretained(self)
            .sink { owner, fetchType in
                owner.useCase.fetchMissionList(type: fetchType)
            }.store(in: cancelBag)
        
        return output
    }
    
    private func fetchMissionList(type: MissionListFetchType) {
        switch self.missionListsceneType {
        case .ranking(_, _, let userId):
            self.otherUserId = userId
            self.useCase.fetchOtherUserMissionList(type: .complete, userId: userId)
        default:
            self.useCase.fetchMissionList(type: type)
        }
    }
    
    private func bindOutput(output: Output, cancelBag: CancelBag) {
        let fetchedMissionList = self.useCase.missionListModelsFetched
        
        fetchedMissionList.asDriver()
            .sink(receiveValue: { model in
                output.missionListModel = model
            })
            .store(in: self.cancelBag)
    }
}
