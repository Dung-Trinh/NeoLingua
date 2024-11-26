import SwiftUI
import MapKit

struct ScavengerHuntInfoPage: View {
    @EnvironmentObject private var router: Router
    let locationManager = LocationManager()
    @State var userLocation: CLLocationCoordinate2D?
    @State var radius: Double = 200.0
    @State var isCustomRadiusActive: Bool = false
    
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
                    Toggle("Radius(\(String(format: "%.0f",radius))m) anpassen ", isOn: $isCustomRadiusActive)
                    
                    if let userLocation = userLocation, isCustomRadiusActive {
                        Map {
                            MapCircle(center: userLocation, radius: CLLocationDistance(radius))
                                .foregroundStyle(.blue.opacity(0.2))
                                .mapOverlayLevel(level: .aboveRoads)
                            MapCircle(center: userLocation, radius: CLLocationDistance(10))
                                .foregroundStyle(.red.opacity(0.8))
                                .mapOverlayLevel(level: .aboveRoads)
                            
                        }.frame(height: 300)
                        Text("Radius(\(String(format: "%.0f",radius))m)")
                        Slider(value: $radius, in: 200...2000, step: 100)
                    }
                }.padding(.bottom)
                
                PrimaryButton(
                    title: "Schnitzeljagd in der Umgebung generieren",
                    color: .blue,
                    action: {
                        router.push(.scavengerHunt(.scavengerHunt(.generatedNearMe(Int(radius)))))
                    }
                )
                
                PrimaryButton(
                    title: "Schnitzeljagd in der Umgebung suchen",
                    color: .blue,
                    action: {
                        router.push(.scavengerHunt(.scavengerHunt(.competitiveMode)))
                    }
                )
            }
            .padding()
            .navigationTitle("Schnitzeljagd")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                fetchUserLocation()
            }
        }
    }
    
    func fetchUserLocation() {
        locationManager.requestLocation()
        locationManager.checkLocationAuthorization()
        guard let lastKnownLocation = locationManager.lastKnownLocation else {
            print("lastKnownLocation is nil")
            return
        }
        print(lastKnownLocation)
        self.userLocation = CLLocationCoordinate2D(latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
    }
}
