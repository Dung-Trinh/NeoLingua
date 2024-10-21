import Foundation
import SwiftUI
import GoogleMaps

struct ScavengerHuntMap: View {
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
              CitiesList(markers: $viewModel.markers) { (marker) in
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
