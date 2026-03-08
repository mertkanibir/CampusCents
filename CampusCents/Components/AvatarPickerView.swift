import SwiftUI
import UIKit
import PhotosUI

struct AvatarPickerView: View {
    @Binding var profile: StudentProfile
    @State private var selectedPhoto: PhotosPickerItem?
    @Environment(\.colorScheme) private var colorScheme
    var labelColor: Color? = nil

    private var effectiveLabelColor: Color {
        labelColor ?? (colorScheme == .dark ? .white : .primary)
    }

    var body: some View {
        VStack(spacing: 10) {
            AvatarView(profile: profile, size: 82)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Choose Profile Photo", systemImage: "photo.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(effectiveLabelColor)
            }
            .tint(effectiveLabelColor)
            .onChange(of: selectedPhoto) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let jpegData = image.jpegData(compressionQuality: 0.75) {
                        profile.avatarData = jpegData
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
