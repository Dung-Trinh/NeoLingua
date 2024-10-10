import Foundation
import SwiftUI
import GoogleMaps

struct ScavengerHuntMap: View {
    static let pointOfInterestSpots = [
        PointOfInterest(name: "Spielbank Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.083091, longitude: 8.243167)),
        PointOfInterest(name: "Kurpark Wiesbaden", coordinate: CLLocationCoordinate2D(latitude: 50.085472, longitude: 8.254062)),
        PointOfInterest(name: "Warmer Damm", coordinate: CLLocationCoordinate2D(latitude: 50.081240, longitude: 8.246010))
        ]
    
    @State var markers: [GMSMarker] = pointOfInterestSpots.map {
        let marker = GMSMarker(position: $0.coordinate)
        marker.title = $0.name
        return marker
    }
    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false
    @State var selectedMarker: GMSMarker?
    @State var yDragTranslation: CGFloat = 0
    let scrollViewHeight: CGFloat = 80
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
              MapViewControllerBridge(
                markers: $markers,
                selectedMarker: $selectedMarker,
                onAnimationEnded: {
                    self.zoomInCenter = true
                },
                mapViewWillMove: { (isGesture) in
                    guard isGesture else { return }
                    self.zoomInCenter = false
                })
              .animation(.easeIn)
              .background(Color(red: 254.0/255.0, green: 1, blue: 220.0/255.0))

              // Cities List
              CitiesList(markers: $markers) { (marker) in
                guard self.selectedMarker != marker else { return }
                self.selectedMarker = marker
                self.zoomInCenter = false
                self.expandList = false
              }  handleAction: {
                self.expandList.toggle()
              }
              .background(Color.white)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .offset(
                x: 0,
                y: geometry.size.height - (expandList ? scrollViewHeight + 150 : scrollViewHeight)
              )
              .offset(x: 0, y: self.yDragTranslation)
              .animation(.spring())
              .gesture(
                DragGesture().onChanged { value in
                  self.yDragTranslation = value.translation.height
                }.onEnded { value in
                  self.expandList = (value.translation.height < -120)
                  self.yDragTranslation = 0
                }
              )
              .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

struct CitiesList: View {
    
    @Binding var markers: [GMSMarker]
    var buttonAction: (GMSMarker) -> Void
    var handleAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // List Handle
                HStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 25, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                        .opacity(0.25)
                        .padding(.vertical, 8)
                }
                .frame(width: geometry.size.width, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    handleAction()
                }
                
                List {
                    Button("Spielfeld anzeigen") {
                        
                    }
                    ForEach(0..<self.markers.count) { id in
                        let marker = self.markers[id]
                        Button(action: {
                            buttonAction(marker)
                        }) {
                            Text(marker.title ?? "")
                        }
                    }
                }
//                .frame(maxWidth: .infinity,maxHeight: 200)
            }
        }
    }
}
