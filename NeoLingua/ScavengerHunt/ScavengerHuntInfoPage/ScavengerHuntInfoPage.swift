import SwiftUI
import MapKit

struct ScavengerHuntInfoPage<ViewModel>: View where ViewModel: ScavengerHuntInfoPageViewModel {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Image("scavengerHuntHelpImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                Text("Schnitzeljagd")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                    Text(.init("**1. Standorte endecken:** Nähern Sie sich dem Standort um Aufgaben freizuschalten"))
                    Text(.init("**2. Aufgaben erledigen:** Absolvieren Sie die Aufgaben bei den Standorten"))
                    Text(.init("**3. Gesuchtes Objekt finden:** Nutzen Sie den gegebenen Tipp, um das gesuchte Objekt aufzuspüren und zufotografieren."))
                    Text(.init("**4. Finale Punktzahl:** Nach der letzten Aufgabe siehst du deine Punktzahl und eine Zusammenfassung deiner Leistung"))
                }
                .multilineTextAlignment(.leading)
                .padding(.bottom)
                VStack {
                    Toggle("Radius(\(String(format: "%.0f", viewModel.radius))m) anpassen ", isOn: $viewModel.isCustomRadiusActive)
                    
                    if let userLocation = viewModel.userLocation, viewModel.isCustomRadiusActive {
                        Map {
                            MapCircle(
                                center: userLocation,
                                radius: CLLocationDistance(viewModel.radius)
                            )
                            .foregroundStyle(.blue.opacity(0.2))
                            .mapOverlayLevel(level: .aboveRoads)
                            MapCircle(
                                center: userLocation,
                                radius: CLLocationDistance(10)
                            )
                            .foregroundStyle(.red.opacity(0.8))
                            .mapOverlayLevel(level: .aboveRoads)
                            
                        }.frame(height: 300)
                        Text("Radius(\(String(format: "%.0f", viewModel.radius))m)")
                        Slider(value: $viewModel.radius, in: 200...2000, step: 100)
                    }
                    HStack {
                        Text("Anzahl der Standorte")
                        Spacer(minLength: 8)
                        Picker("Anzahl der Locations", selection: $viewModel.locationAmount) {
                            ForEach(1...3, id: \.self) { amount in
                                Text("\(amount)").tag(amount)
                            }
                        }
                    }
                    
                }.padding(.bottom)
                
                PrimaryButton(
                    title: "Schnitzeljagd in der Umgebung generieren",
                    color: .blue,
                    action: {
                        viewModel.navigateTo(route: .scavengerHunt(.generatedNearMe(Int(viewModel.radius), viewModel.locationAmount)))
                    }
                )
                
                PrimaryButton(
                    title: "Schnitzeljagd in der Umgebung suchen",
                    color: .blue,
                    action: {
                        viewModel.navigateTo(route: .scavengerHunt(.competitiveMode))
                    }
                )
            }
            .padding()
            .navigationTitle("Schnitzeljagd")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                viewModel.fetchUserLocation()
            }
        }
    }
}
