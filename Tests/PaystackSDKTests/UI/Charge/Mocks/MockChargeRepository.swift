import Foundation
import PaystackCore
@testable import PaystackUI

class MockChargeRepository: ChargeRepository {

    var expectedVerifyAccessCode: VerifyAccessCode?
    var expectedErrorResponse: Error?

    func verifyAccessCode(_ code: String) async throws -> VerifyAccessCode {
        guard let response = expectedVerifyAccessCode else {
            throw expectedErrorResponse ?? MockError.stubNotProvided
        }
        return response
    }

}
