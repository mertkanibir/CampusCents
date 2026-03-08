import SwiftUI

struct ProfilePhotoView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var draftProfile: StudentProfile = .sample

    private var labelColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    var body: some View {
        VStack(spacing: 24) {
            AvatarView(profile: draftProfile, size: 120)
            AvatarPickerView(profile: $draftProfile, labelColor: labelColor)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
        .navigationTitle("Profile photo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            draftProfile = state.profile
        }
        .onChange(of: draftProfile) { _, new in
            state.profile = new
        }
    }
}
