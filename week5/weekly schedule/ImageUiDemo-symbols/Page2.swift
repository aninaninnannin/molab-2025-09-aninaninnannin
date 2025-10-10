import SwiftUI

struct Page2: View {
    var body: some View {
        _RecipeView(
            title: "Tomato & Egg Stir-fry",
            servings: "2 servings",
            timeCost: "15 min",
            ingredients: ["3 eggs", "2 tomatoes", "Salt", "Sugar (optional)", "Scallions", "Oil"],
            steps: [
                "Beat eggs with a pinch of salt; cut tomatoes.",
                "Scramble eggs until just set; remove.",
                "Sauté tomatoes to release juices (add a little sugar if desired).",
                "Return eggs, toss 10–20s, season with salt, finish with scallions."
            ]
        )
    }
}

// private to this file
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
