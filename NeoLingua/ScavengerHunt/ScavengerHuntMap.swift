import Foundation
import SwiftUI
import GoogleMaps

struct ScavengerHuntMap<ViewModel>: View where ViewModel: ScavengerHuntMapViewModel {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: ViewModel
    @State private var zoomInCenter: Bool = false
    @State private var expandList: Bool = false
    @State private var yDragTranslation: CGFloat = 0
    @State private var showHelpSheet = false

    private let scrollViewHeight: CGFloat = 80

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
            .navigationTitle("Scavenger hunt map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Need help?") {
                        showHelpSheet = true
                    }.sheet(isPresented: $showHelpSheet) {
                        ScavengerHuntHelpView()
                            .presentationDetents([.fraction(0.8)])
                            .presentationCornerRadius(40)
                    }
                }
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
