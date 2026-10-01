import QtQuick
import "../core"

// Island background surface.
//
// Previously this used QtQuick.Shapes to draw a path with shoulder curves.
// Shapes are not rendered reliably on every Quickshell/Wayland setup (the
// path silently disappears while sibling text/rectangles still paint), so the
// surface is drawn with plain Rectangles instead. Floating style is a fully
// rounded rounded-rect; attached style squares the top edge so it melts into
// the screen edge, matching the old shoulder silhouette.
Item {
    id: root

    property real bodyWidth: 200
    property bool attached: false
    property real radius: Theme.radiusLarge
    property color fillColor: Qt.alpha(Theme.surfaceContainer,
        Config.appearance.surfaceOpacity)
    property color outlineColor: Qt.alpha(Theme.outlineVariant,
        Theme.dark ? 0.62 : 0.48)
    property real outlineWidth: 1
    // 0 uses the established panel material; 1 is tuned for the thin resting
    // Island. Intermediate values animate through hover/expansion morphs.
    property real compactGlass: 0
    property color materialFillColor: SurfaceMaterial.fill(fillColor,
        compactGlass)
    property color materialOutlineColor: SurfaceMaterial.outline(outlineColor)
    readonly property real shoulderWidth: attached
        ? Math.min(22, Math.max(12, height * 0.46)) : 0
    readonly property real edgeInset: Math.max(0.5, outlineWidth / 2)
    readonly property real cornerRadius: Math.max(0, Math.min(radius,
        (height - edgeInset * 2) / 2, bodyWidth / 2))
    readonly property real topY: attached ? -edgeInset : edgeInset
    readonly property real bottomY: height - edgeInset
    readonly property color gradientTopColor: SurfaceMaterial.glass
        ? Qt.tint(materialFillColor, Qt.alpha(
            SurfaceMaterial.compactHighlight, compactGlass * 0.16))
        : materialFillColor
    readonly property color gradientBottomColor: SurfaceMaterial.glass
        ? Qt.tint(materialFillColor, Qt.alpha(
            SurfaceMaterial.compactDepthEdge, 0.08 + compactGlass * 0.05))
        : materialFillColor

    // Attached keeps the full width flush to the edge; floating reserves the
    // side margins that carry the shoulder taper.
    width: attached ? bodyWidth : bodyWidth + shoulderWidth * 2
    clip: true

    // Body of the panel. Floating insets the sides so the shoulders read as a
    // taper; attached spans the full width and only rounds the bottom corners.
    Rectangle {
        id: surfaceRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.attached ? 0 : root.shoulderWidth + root.edgeInset
        anchors.rightMargin: root.attached ? 0 : root.shoulderWidth + root.edgeInset
        y: root.topY
        height: Math.max(0, root.bottomY - root.topY)
        topLeftRadius: root.attached ? 0 : root.cornerRadius
        topRightRadius: root.attached ? 0 : root.cornerRadius
        bottomLeftRadius: root.cornerRadius
        bottomRightRadius: root.cornerRadius
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.gradientTopColor }
            GradientStop { position: 0.42; color: root.materialFillColor }
            GradientStop { position: 0.86; color: root.materialFillColor }
            GradientStop { position: 1.0; color: root.gradientBottomColor }
        }
        border.width: root.outlineWidth
        border.color: root.outlineWidth > 0 ? root.materialOutlineColor
            : "transparent"
    }

    // Attached style squares the top corners on the body itself (see above), so
    // no separate shoulder patches are needed. Floating gets its taper from the
    // side margins; those margins use the body material as filler.
    Rectangle {
        visible: !root.attached && root.shoulderWidth > 0
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.shoulderWidth + root.edgeInset
        height: Math.max(0, root.shoulderWidth + root.edgeInset)
        color: root.materialFillColor
        z: -1
    }
    Rectangle {
        visible: !root.attached && root.shoulderWidth > 0
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.shoulderWidth + root.edgeInset
        height: Math.max(0, root.shoulderWidth + root.edgeInset)
        color: root.materialFillColor
        z: -1
    }

    Behavior on fillColor {
        ColorAnimation { duration: Animations.normal }
    }
    Behavior on outlineColor {
        ColorAnimation { duration: Animations.normal }
    }
    Behavior on materialFillColor {
        ColorAnimation { duration: Animations.normal }
    }
    Behavior on materialOutlineColor {
        ColorAnimation { duration: Animations.normal }
    }
    Behavior on compactGlass {
        NumberAnimation {
            duration: Config.animations.surfaceMorph
            easing.type: Animations.emphasizedEase
        }
    }
    Behavior on radius {
        NumberAnimation {
            duration: Animations.normal
            easing.type: Animations.standardEase
        }
    }
}
