import SwiftUI

struct Page4: View {
    var body: some View {
        _RecipeView(
            title: "Aglio e Olio",
            servings: "1–2 servings",
            timeCost: "20 min",
            ingredients: [
                "120g spaghetti", "4 garlic cloves (sliced)", "2 tbsp olive oil",
                "Chili flakes", "Salt", "Parsley/black pepper"
            ],
            steps: [
                "Cook pasta in salted water to al dente; reserve some pasta water.",
                "Gently fry garlic in oil on low heat to light golden; add chili flakes.",
                "Toss with pasta, add a splash of pasta water to emulsify; season and garnish."
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
