
import SwiftUI
import Firebase
import MapKit

struct SnapVocabularyPage: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: SnapVocabularyPageViewModelImpl
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.allTasks) { task in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: task.coordinates.latitude, longitude: task.coordinates.longitude)) {
                        Button(action: {
                            viewModel.showMarkerDetails(marker: task)
                        }) {
                            Image(systemName: "photo.circle.fill")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.indigo)
                                
                        }
                    }
                }.ignoresSafeArea(edges: .all)
                VStack {
                    HStack {
                        Text("ⓘ Suchen das Icon in ihrer Umgebung auf der Karte und tippe darauf um ein Vokabelrätsel zu starten")
                            .font(.body)
                            .foregroundColor(.white)
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.indigo)
                    }.padding()
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.8)))
                    .padding(.horizontal, 10)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 10)
                }
                .frame(maxWidth: geometry.size.width * 0.9)
            }
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .sheet(isPresented: $viewModel.isPresented, content: {
            VStack {
                if let sharedImageTask = viewModel.sharedImageTask{
                    NearMeTaskPage(viewModel: NearMeTaskPageViewModelImpl(sharedImageTask: sharedImageTask), isPresented: $viewModel.isPresented)
                }
            }
        })
    }
}
