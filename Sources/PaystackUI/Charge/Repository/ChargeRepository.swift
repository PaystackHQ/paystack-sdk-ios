import Foundation

protocol ChargeRepository {
    func verifyAccessCode(_ code: String) async throws -> VerifyAccessCode
}
