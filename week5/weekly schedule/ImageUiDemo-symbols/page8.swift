import SwiftUI

struct Page8: View {
    var body: some View {
        _RecipeView(
            title: "Quick Oat Banana Cup",
            servings: "1 serving",
            timeCost: "10 min",
            ingredients: ["40g quick oats", "1 banana", "150ml milk/alt milk", "Honey (optional)", "Nuts/raisins"],
            steps: [
                "Heat oats with milk (microwave 1–2 min or stovetop) until thick.",
                "Stir in banana slices; add honey and nuts if you like."
            ]
        )
    }
}

private struct _RecipeView: View {
    let title: String
    let servings: String
    let timeCost: String
    let ingredients: [String]
    let steps: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title).font(.largeTitle).bold()
                HStack {
                    Label(servings, systemImage: "person.2")
                    Label(timeCost, systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()
                Text("Ingredients").font(.title3).bold()
                ForEach(ingredients, id: \.self) { Text("• " + $0) }

                Divider().padding(.top, 4)
                Text("Steps").font(.title3).bold()
                ForEach(Array(steps.enumerated()), id: \.offset) { i, s in
                    Text("\(i+1). \(s)")
                }
            }
            .padding()
        }
    }
}
