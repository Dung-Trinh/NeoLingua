import Foundation
import SwiftUI
import GoogleMaps

struct ScavengerHuntMap: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ScavengerHuntMapViewModelImpl
    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false
    @State var yDragTranslation: CGFloat = 0
    let scrollViewHeight: CGFloat = 80
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
              MapViewControllerBridge(
                markers: $viewModel.markers,
                selectedMarker: $viewModel.selectedMarker,
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
                CitiesList(
                    markers: $viewModel.markers,
                    taskLocation: $viewModel.scavengerHunt.taskLocations) { (location) in
                        viewModel.tappedTaskLocation(location: location)
                    }
            setMarker: { (marker) in
                guard self.viewModel.selectedMarker != marker else { return }
                self.viewModel.selectedMarker = marker
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
        .navigationDestination(for: Route.self) { route in
                router.destination(for: route)
        }
    }
}

struct CitiesList: View {
    @Binding var markers: [GMSMarker]
    @Binding var taskLocation: [TaskLocation]

    var buttonAction: (TaskLocation) -> Void
    var setMarker: (GMSMarker) -> Void
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
                    ForEach(taskLocation) { location in
                        Button(action: {
                            buttonAction(location)
                            for marker in markers {
                                if marker.title == location.name {
                                    setMarker(marker)
                                }
                            }
                        }) {
                            Text(location.name)
                        }
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: 200)
            }
        }
    }
}
