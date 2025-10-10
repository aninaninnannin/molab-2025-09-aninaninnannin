// NavigationView for pages

import SwiftUI

struct Page9: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    Page1()
                } label: {
                    Text("Running")
                }
                
                NavigationLink {
                    Page2()
                } label: {
                    Text("Tomato & Egg Stir-fry")
                }

                NavigationLink {
                    Page3()
                } label: {
                    Text("Strength")
                }
                NavigationLink {
                    Page4()
                } label: {
                    Text("Aglio e Olio")
                }

                NavigationLink {
                    Page5()
                } label: {
                    Text("Yoga")
                }
                NavigationLink {
                    Page6()
                } label: {
                    Text("Lean Chicken Salad")
                }

                NavigationLink {
                    Page7()
                } label: {
                    Text("Swimming")
                }
                NavigationLink {
                    Page8()
                } label: {
                    Text("Oat Banana Cup")
                }
            }
            .navigationTitle("weekly schedule")
        }
    }
}

#Preview {
    Page9()
}
