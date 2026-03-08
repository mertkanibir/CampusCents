import SwiftUI
import UIKit
import PhotosUI

struct ProfilePhotoView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var draftProfile: StudentProfile = .sample
    @State private var selectedPhoto: PhotosPickerItem?

    private var labelColor: Color {
        colorScheme == .dark ? .white : .primary
    }

    var body: some View {
        VStack(spacing: 24) {
            AvatarView(profile: draftProfile, size: 120)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Choose Profile Photo", systemImage: "photo.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(labelColor)
            }
            .tint(labelColor)

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
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let jpegData = image.jpegData(compressionQuality: 0.75) {
                    draftProfile.avatarData = jpegData
                    state.profile = draftProfile
                }
            }
        }
    }
}
