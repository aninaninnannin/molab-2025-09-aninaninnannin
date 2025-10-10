import SwiftUI

struct Page6: View {
    var body: some View {
        _RecipeView(
            title: "Lean Chicken Salad",
            servings: "1 serving",
            timeCost: "25 min",
            ingredients: [
                "150g chicken breast", "Mixed greens", "Cherry tomatoes", "Cucumber",
                "1 tbsp olive oil", "Salt & pepper", "Lemon juice or yogurt"
            ],
            steps: [
                "Season chicken with salt & pepper; pan-sear or air-fry 8–10 min; slice.",
                "Prep veggies in a bowl; add chicken on top.",
                "Dress with olive oil + lemon juice (or yogurt), season to taste."
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
