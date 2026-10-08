import Foundation
import SwiftData

protocol FacetEntity: PersistentModel {
    var name: String { get set }
    var stationCount: Int { get set }
}

protocol StorageModel: PersistentModel {
    associatedtype DTO: Sendable
    var storageKey: String { get }
    static func persist(_ dto: DTO) -> Self
    func apply(from dto: DTO)
    func applyUpdate(from other: Self)
    func toDTO() -> DTO
    static func predicate(forKeys keys: [String]) -> Predicate<Self>
}
