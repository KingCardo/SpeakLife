//
//  APIClient.swift
//  Dios Es Aqui
//
//  Created by Riccardo Washington on 1/1/22.
//

import Foundation
import Combine
import SwiftUI

final class APIClient: APIService {
    
    @AppStorage("declarationCountFile") var declarationCountFile = 0
    @AppStorage("declarationCountBE") var declarationCountBE = 0
    
    func declarations(completion: @escaping([Declaration], APIError?, Bool) -> Void) {
        
        self.loadFromBackEnd() { [weak self] declarations, error, needsSync in
            var favorites: [Declaration] = []
            var myOwn: [Declaration] = []
            
            self?.loadFromDisk() { declarations, error in
                favorites = declarations.filter { $0.isFavorite == true }
                myOwn = declarations.filter {
                    $0.category == .myOwn
                }
            }
            
            
            var updatedDeclarations: [Declaration] = declarations
            
            for fav in favorites  {
                updatedDeclarations.removeAll { $0.id == fav.id }
            }
            updatedDeclarations.append(contentsOf: favorites)
            updatedDeclarations.append(contentsOf: myOwn)
            self?.declarationCountFile = updatedDeclarations.count
            completion(updatedDeclarations,  nil, needsSync)
            return
            
        }
    }
    
    private func loadFromDisk(completion: @escaping([Declaration], APIError?) -> Void) {
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirURL.appendingPathComponent("declarations").appendingPathExtension("txt")
        
        
        guard let data = try? Data(contentsOf: fileURL),
              let declarations = try? JSONDecoder().decode([Declaration].self, from: data) else {
            completion([], APIError.failedRequest)
            return
        }
        declarationCountFile = declarations.count
        completion(declarations, nil)
        return
    }
    
    
    func save(declarations: [Declaration], completion: @escaping(Bool) -> Void) {
        
        guard
            let DocumentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true),
            let data = try? JSONEncoder().encode(declarations)
        else {
            completion(false)
            fatalError("Unable to Load Declaration")
        }
        
        do  {
            let fileURL = DocumentDirURL.appendingPathComponent("declarations").appendingPathExtension("txt")
            try data.write(to: fileURL, options: .atomic)
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
    
    private func loadFromBackEnd(completion: @escaping([Declaration], APIError?, Bool) ->  Void) {
        guard
            let url = Bundle.main.url(forResource: "declarations", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
            completion([],APIError.resourceNotFound, false)
            return
        }
        
        do {
            let welcome = try JSONDecoder().decode(Welcome.self, from: data)
            let declarations = Set(welcome.declarations)
            // remove this when finish filtering every category
            let general = declarations.filter { $0.category == .alignment }
            let generalArray = Array(general)
            
            let faith = declarations.filter { $0.category == .faith }
            let faithArray = Set(faith).map({$0})
            
            let confidence = declarations.filter { $0.category == .confidence }
            let confidenceArray = Set(confidence).map({$0})
            
            let gratitude = declarations.filter { $0.category == .gratitude }
            let gratitudeArray = Set(gratitude).map({$0})
            
            let removedAllAffirmationsWithoutBookExceptGeneral = declarations.filter { $0.book != nil }
            let removedFaith = removedAllAffirmationsWithoutBookExceptGeneral.filter { $0.category != .faith }
            let removedConfidence = removedFaith.filter { $0.category != .confidence }
            let removedGratitude = removedConfidence.filter { $0.category != .gratitude }
            var array = Array(removedGratitude)
            array.append(contentsOf: generalArray)
            array.append(contentsOf: faithArray)
            array.append(contentsOf: confidenceArray)
            array.append(contentsOf: gratitudeArray)
            let needsSync = array.count != declarationCountBE
            print(array.count, declarationCountBE, "RWRW count")
            print(needsSync, "RWRW  needs sync")
            declarationCountBE = array.count
            completion(array, nil, needsSync)
            return
        } catch {
            print(error, "RWRW")
            completion([],APIError.failedDecode, false)
        }
    }
    
    // MARK: - Notifications
    
    func declarationCategories(completion: @escaping(Set<DeclarationCategory>, APIError?) -> Void) {
        loadSelectedCategoriesFromDisk { categories, error in
            if let error = error {
                completion([], error)
                return
            }
            
            completion(categories, nil)
            return
        }
    }
    
    func save(selectedCategories: Set<DeclarationCategory>, completion: @escaping(Bool) -> Void) {
        guard
            let DocumentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true),
            let data = try? JSONEncoder().encode(selectedCategories)
        else {
            completion(false)
            fatalError("Unable to Load Notification categories")
        }
        
        do  {
            let fileURL = DocumentDirURL.appendingPathComponent("notificationcategories").appendingPathExtension("txt")
            try data.write(to: fileURL, options: .atomic)
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
    
    private func loadSelectedCategoriesFromDisk(completion: @escaping(Set<DeclarationCategory>, APIError?) -> Void) {
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirURL.appendingPathComponent("notificationcategories").appendingPathExtension("txt")
        
        
        guard let data = try? Data(contentsOf: fileURL),
              let declarationsCategories = try? JSONDecoder().decode(Set<DeclarationCategory>.self, from: data) else {
            completion([], APIError.failedRequest)
            return
        }
        completion(declarationsCategories, nil)
        return
    }
}
