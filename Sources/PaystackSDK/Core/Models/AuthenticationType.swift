import Foundation

public enum AuthenticationType {
    case otp(SubmitOtpRequest)
    case pin(SubmitPinRequest)
    case phone(SubmitPhoneRequest)
    case birthday(SubmitBirthdayRequest)
    case address(SubmitAddressRequest)
}
