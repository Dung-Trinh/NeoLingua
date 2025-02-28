import SwiftUI
import GoogleMaps

struct TaskLocationList: View {
    @EnvironmentObject private var router: Router
    @Binding var markers: [GMSMarker]
    @Binding var taskLocation: [TaskLocation]
    @StateObject var locationManager = LocationManager()
    
    var buttonAction: (TaskLocation) -> Void
    var setMarker: (GMSMarker) -> Void
    var handleAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
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
                    Section {
                        ForEach(taskLocation) { location in
                            Button(action: {
                                if locationManager.checkIfLocationIsNearby(location) {
                                    buttonAction(location)
                                    for marker in markers {
                                        if marker.title == location.name {
                                            setMarker(marker)
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Text(location.name)
                                        .if(locationManager.checkIfLocationIsNearby(location) == false , transform: { view in
                                            view.foregroundColor(.gray)
                                    })
                                    
                                    if let didFoundObject = location.performance?.performance.didFoundObject {
                                        if didFoundObject {
                                            Text("✅")
                                        } else {
                                            Text("❌")
                                        }
                                    }
                                    Spacer()
                                    if locationManager.checkIfLocationIsNearby(location) {
                                        Text("📋")
                                    } else {
                                        Text("ℹ️")
                                    }
                                }
                                
                            }.if(location.performance?.performance.didFoundObject != nil , transform: { view in
                                view.disabled(true)
                            })
                        }
                        if areAllTaskDone() {
                            Button("back to scavenger hunt over view") {
                                router.navigateBack()
                            }
                        }
                    }header: {
                        Text("Task location")
                    } footer: {
                        VStack(alignment: .leading, spacing: Styleguide.Margin.small) {
                            Text("ℹ️ = Annäherung an das Objekt erforderlich")
                            Text("📋 = Aufgaben stehen bereit")
                        }
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: 300)
            }
            .background(Color(.systemGray6))
            .onAppear{
                locationManager.taskLocations = taskLocation
            }
        }
    }
    
    private func areAllTaskDone() -> Bool {
        let isDone = true
        for location in taskLocation {
            if location.performance?.performance.didFoundObject == nil {
                return false
            }
        }
        return isDone
    }
}
