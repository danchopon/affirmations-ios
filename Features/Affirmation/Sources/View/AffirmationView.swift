import SwiftUI
import CorePersistence
import CoreAnalytics

public struct AffirmationView: View {
    public let affirmation: Affirmation
    public init(affirmation: Affirmation) { self.affirmation = affirmation }
    public var body: some View {
        Text(affirmation.text)
    }
}
