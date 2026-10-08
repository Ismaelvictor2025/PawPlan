//
//  DogUseCases.swift
//  PawPlan
//
//  Created for PawPlan Clean Architecture.
//

import Foundation

public struct GetDogsUseCase: Sendable {
    private let dogRepository: DogRepositoryProtocol

    public init(dogRepository: DogRepositoryProtocol) {
        self.dogRepository = dogRepository
    }

    public func execute() throws -> [Dog] {
        return try dogRepository.fetchAllDogs()
    }

    public func execute(id: UUID) throws -> Dog? {
        return try dogRepository.fetchDog(id: id)
    }
}

public struct SaveDogUseCase: Sendable {
    private let dogRepository: DogRepositoryProtocol

    public init(dogRepository: DogRepositoryProtocol) {
        self.dogRepository = dogRepository
    }

    public func execute(_ dog: Dog) throws {
        let trimmedName = dog.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw DogProfileError.emptyName
        }
        guard dog.weight >= 0 else {
            throw DogProfileError.invalidWeight
        }
        var updatedDog = dog
        updatedDog.name = trimmedName
        try dogRepository.saveDog(updatedDog)
    }
}

public struct DeleteDogUseCase: Sendable {
    private let dogRepository: DogRepositoryProtocol

    public init(dogRepository: DogRepositoryProtocol) {
        self.dogRepository = dogRepository
    }

    public func execute(id: UUID) throws {
        try dogRepository.deleteDog(id: id)
    }
}
