import SwiftUI

enum SLColor { static let ink=Color(red:0.04,green:0.06,blue:0.12); static let panel=Color(red:0.09,green:0.12,blue:0.22); static let cyan=Color(red:0.25,green:0.91,blue:0.86); static let violet=Color(red:0.49,green:0.39,blue:0.98); static let warning=Color.orange }
struct GlassCard<Content:View>:View { @ViewBuilder let content:Content; var body:some View { content.padding(16).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:22)).overlay(RoundedRectangle(cornerRadius:22).stroke(.white.opacity(0.08))) } }
struct ProvenanceBadge:View { let value:DataProvenance; var body:some View { Text(value.rawValue.uppercased()).font(.caption2.bold()).padding(.horizontal,8).padding(.vertical,5).background(value == .simulated ? Color.orange.opacity(0.2):Color.white.opacity(0.1),in:Capsule()) } }
