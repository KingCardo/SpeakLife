//
//  APIService.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import Foundation
import Combine

protocol APIService {
    func declarations(completion: @escaping([Declaration], APIError?) -> Void)// -> AnyPublisher<[Declaration], APIError>
    func save(declarations: [Declaration], completion: @escaping(Bool) -> Void)
    func declarationCategories(completion: @escaping(Set<DeclarationCategory>, APIError?) -> Void)
    func save(selectedCategories: Set<DeclarationCategory>, completion: @escaping(Bool) -> Void)
    
}
