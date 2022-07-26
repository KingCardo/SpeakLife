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
    
    func declarations(completion: @escaping([Declaration], APIError?) -> Void) {
        
        syncDeclarations() { [weak  self]  needsSync in
            if needsSync {
                var favorites: [Declaration] = []
                self?.loadFromDisk() { declarations, error in
                    favorites = declarations.filter { $0.isFavorite == true }
                }
                self?.loadFromBackEnd() { declarations, error in
                    var updatedDeclarations: [Declaration] = declarations
                    
                    for fav in favorites  {
                        updatedDeclarations.removeAll { $0.id == fav.id }
                    }
                    updatedDeclarations.append(contentsOf: favorites)
                    completion(updatedDeclarations,  nil)
                }
            } else {
                self?.loadFromDisk() { declarations, error in
                    completion(declarations, error)
                }
            }
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
    
    private func syncDeclarations(completion: @escaping(Bool) -> Void)  {
        loadFromBackEnd { declarations, error in
            if self.declarationCountBE > self.declarationCountFile {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func loadFromBackEnd(completion: @escaping([Declaration], APIError?) ->  Void) {
        guard
            let url = Bundle.main.url(forResource: "declarations", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                completion([],APIError.resourceNotFound)
            return
        }
        
        do {
            let welcome = try JSONDecoder().decode(Welcome.self, from: data)
            let declarations = welcome.declarations
            declarationCountBE = welcome.count
            completion(declarations, nil)
            
        } catch {
            completion([],APIError.failedDecode)
            
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
