import Foundation

extension Int {

    func formatSecondsAsMinutesAndSeconds() -> String {
        guard self >= 0 else { return "00:00" }
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

}
