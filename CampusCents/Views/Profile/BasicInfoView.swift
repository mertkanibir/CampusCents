import SwiftUI

struct BasicInfoView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var name: String = ""
    @State private var school: String = ""
    @State private var termSeason: String = "Spring"
    @State private var termYear: Int = Calendar.current.component(.year, from: Date())

    private var yearRange: [Int] {
        let y = Calendar.current.component(.year, from: Date())
        return Array((y - 2)...(y + 6))
    }

    var body: some View {
        List {
            Section {
                TextField("Name", text: $name)
                TextField("School", text: $school)
            } header: {
                Text("Basic info")
            }

            Section {
                Picker("Term", selection: $termSeason) {
                    Text("Spring").tag("Spring")
                    Text("Summer").tag("Summer")
                    Text("Fall").tag("Fall")
                    Text("Winter").tag("Winter")
                }
                Picker("Year", selection: $termYear) {
                    ForEach(yearRange, id: \.self) { Text(String($0)).tag($0) }
                }
            } header: {
                Text("Expected graduation")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Basic info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = state.profile.name
            school = state.profile.school
            let parts = state.profile.term.split(separator: " ")
            if let first = parts.first { termSeason = String(first) }
            if let last = parts.last, let y = Int(last) { termYear = y }
        }
        .onDisappear {
            var p = state.profile
            p.name = name
            p.school = school
            p.term = "\(termSeason) \(termYear)"
            state.profile = p
        }
    }
}
