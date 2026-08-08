import SwiftUI

@main struct SignalLensAIApp:App {
    @State private var model=AppModel()
    var body:some Scene { WindowGroup { RootView().environment(model).preferredColorScheme(.dark).task{model.start()} } }
}
struct RootView:View {
    @Environment(AppModel.self) private var model
    var body:some View { @Bindable var model=model; TabView(selection:$model.selectedTab){DashboardView().tabItem{Label("Pulse",systemImage:AppTab.pulse.symbol)}.tag(AppTab.pulse);TimelineView().tabItem{Label("Timeline",systemImage:AppTab.timeline.symbol)}.tag(AppTab.timeline);IncidentsView().tabItem{Label("Insights",systemImage:AppTab.incidents.symbol)}.tag(AppTab.incidents);DemoLabView().tabItem{Label("Demo",systemImage:AppTab.demo.symbol)}.tag(AppTab.demo);PrivacyView().tabItem{Label("Privacy",systemImage:AppTab.privacy.symbol)}.tag(AppTab.privacy)}.tint(SLColor.cyan) }
}
