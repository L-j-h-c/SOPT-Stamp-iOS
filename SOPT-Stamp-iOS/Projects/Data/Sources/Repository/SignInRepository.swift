//
//  SignInRepository.swift
//  Presentation
//
//  Created by devxsby on 2022/12/01.
//  Copyright © 2022 SOPT-Stamp-iOS. All rights reserved.
//

import Combine

import Domain
import Network

public class SignInRepository {
    
    private let networkService: SignInServiceType
    private let cancelBag = Set<AnyCancellable>()
    
    public init(service: SignInServiceType) {
        self.networkService = service
    }
}

extension SignInRepository: SignInRepositoryInterface {
    
}
