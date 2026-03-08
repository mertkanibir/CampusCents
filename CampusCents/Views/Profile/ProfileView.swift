import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                AvatarView(profile: state.profile, size: 96)
                Text(state.profile.name.isEmpty ? "Your name" : state.profile.name)
                    .font(.title2.weight(.bold))
            }
            .padding(.top, 20)
            .padding(.bottom, 24)

            List {
                Section {
                    NavigationLink("Basic info") {
                        BasicInfoView()
                    }
                    NavigationLink("Profile photo") {
                        ProfilePhotoView()
                    }
                }

                Section(header: Text("Features")) {
                    NavigationLink("Budget & planning") {
                        BudgetPlanningView()
                    }
                }

                Section(header: Text("Account")) {
                    Button("Delete account", role: .destructive) {
                        state.deleteAccount()
                        dismiss()
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}
