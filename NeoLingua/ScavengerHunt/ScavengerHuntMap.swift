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
                
                TaskLocationList(
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
            }
        }
        .onAppear {
            print("onAppear ScavengerHuntMap")
            Task {
                await viewModel.fetchScavengerHuntState()
            }
        }
        .navigationDestination(for: Route.self) { route in
            router.destination(for: route)
        }
    }
}

struct TaskLocationList: View {
    @EnvironmentObject private var router: Router
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
                    ForEach(taskLocation) { location in
                        Button(action: {
                            buttonAction(location)
                            for marker in markers {
                                if marker.title == location.name {
                                    setMarker(marker)
                                }
                            }
                        }) {
                            HStack {
                                Text(location.name)
                                if let didFoundObject = location.performance?.performance.didFoundObject {
                                    if didFoundObject {
                                        Text("✅")
                                    } else {
                                        Text("❌")
                                    }
                                }
                            }
                            
                        }.if(location.performance?.performance.didFoundObject != nil, transform: { view in
                            view.disabled(true)
                        })
                    }
                    if areAllTaskDone() {
                        Button("back to scavenger hunt over view") {
                            router.navigateBack()
                        }
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: 200)
            }
        }
    }
    
    func areAllTaskDone() -> Bool {
        var isDone = true
        for location in taskLocation {
            if location.performance?.performance.didFoundObject == nil {
                return false
            }
        }
        return isDone
    }
}
