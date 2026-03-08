import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var state: AppState
    @State private var draftProfile = StudentProfile.sample

    var body: some View {
        NavigationStack {
            Form {
                Section("Student") {
                    HStack(spacing: 14) {
                        AvatarView(profile: draftProfile, size: 60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(draftProfile.name).font(.headline)
                            Text(draftProfile.school).foregroundStyle(.secondary)
                        }
                    }
                    AvatarPickerView(profile: $draftProfile)
                }

                Section("Basic Info") {
                    LabeledField("Name", value: $draftProfile.name)
                    LabeledField("School", value: $draftProfile.school)
                    LabeledField("Term", value: $draftProfile.term)
                }

                Section("Planning") {
                    Picker("Budget Style", selection: $draftProfile.budgetStyle) {
                        ForEach(BudgetInput.BudgetStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    Picker("Housing Type", selection: $draftProfile.housingType) {
                        ForEach(BudgetInput.HousingType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("App") {
                    Button("Save Changes") {
                        state.profile = draftProfile
                    }
                    Button("Reset Demo Data", role: .destructive) {
                        state.resetForDemo()
                        draftProfile = .sample
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                draftProfile = state.profile
            }
        }
    }
}
