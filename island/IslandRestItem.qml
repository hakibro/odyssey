import QtQuick
import QtQuick.Layouts
import "../components"
import "../core"
import "../services"

Item {
    id: root
    required property string itemId
    property var monitor
    property bool powerHovered: false
    signal powerRequested()
    signal captureRequested()
    implicitWidth: contentLoader.item?.implicitWidth ?? 0
    implicitHeight: 20

    Loader {
        id: contentLoader
        anchors.centerIn: parent
        sourceComponent: root.itemId === "Weather" ? weatherComponent
            : root.itemId === "Dnd" ? dndComponent
            : root.itemId === "Clock" ? clockComponent
            : root.itemId === "Workspaces" ? workspacesComponent
            : root.itemId === "KeepAwake" ? keepAwakeComponent
            : root.itemId === "Battery" ? batteryGlyphComponent
            : root.itemId === "PowerProfile" ? powerComponent : null
    }

    Component {
        id: weatherComponent
        Item {
            visible: Config.weather.enabled && WeatherService.available
            implicitWidth: Math.round(14 * Config.island.restIconScale)
            implicitHeight: 20
            Text {
                anchors.centerIn: parent
                text: WeatherService.icon
                color: Theme.tertiary
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(12 * Config.island.restIconScale)
            }
        }
    }

    Component {
        id: dndComponent
        Item {
            implicitWidth: Math.round(14 * Config.island.restIconScale)
            implicitHeight: 20
            Text {
                visible: NotificationService.count === 0
                anchors.centerIn: parent
                text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                color: NotificationService.doNotDisturb
                    ? Theme.tertiary : Theme.surfaceText
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(11 * Config.island.restIconScale)
            }
            Rectangle {
                visible: NotificationService.count > 0
                anchors.centerIn: parent
                width: 13; height: 13; radius: width / 2
                color: Theme.error
                Text { anchors.fill: parent; anchors.leftMargin: 1; text: NotificationService.count > 99 ? "99+" : NotificationService.count; color: Theme.foregroundFor(parent.color); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.family: Config.appearance.monoFontFamily; font.pixelSize: Math.round(7 * Config.island.restTextScale); font.weight: Font.Bold }
            }
            TapHandler { onTapped: NotificationService.toggleDoNotDisturb() }
        }
    }

    Component {
        id: clockComponent
        Text {
            text: ShellState.time
            color: Theme.surfaceText
            font.family: Config.appearance.monoFontFamily
            font.pixelSize: Math.round(11 * Config.island.restTextScale)
            font.weight: Font.Bold
        }
    }

    Component {
        id: workspacesComponent
        Item {
            readonly property int workspaceCount: Config.island.restWorkspaceCount
            implicitWidth: dots.implicitWidth
            implicitHeight: 20
            RowLayout {
                id: dots
                anchors.centerIn: parent
                spacing: Math.round(Theme.space1 * Config.island.restIconScale)
                Repeater {
                    model: workspaceCount
                    StatusDot {
                        active: root.monitor?.activeWorkspace?.id === index + 1
                        occupied: HyprlandService.occupiedWorkspaces.some(
                            workspace => workspace.id === index + 1)
                        urgent: HyprlandService.urgentWorkspaces.some(
                            workspace => workspace.id === index + 1)
                        Layout.preferredWidth: implicitWidth
                        Layout.preferredHeight: implicitHeight
                    }
                }
            }
        }
    }

    Component {
        id: keepAwakeComponent
        Item {
            implicitWidth: Math.round(14 * Config.island.restIconScale)
            implicitHeight: 20
            Text {
                anchors.centerIn: parent
                text: "󰅶"
                color: IdleService.inhibited ? Theme.error : Theme.surfaceText
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(11 * Config.island.restIconScale)
            }
            TapHandler { onTapped: IdleService.toggleInhibition() }
        }
    }

    // ------------------------------------------------------------------
    // Battery icon — pick one by switching `batteryComponent` below between:
    //   batteryOutlineComponent        horizontal body + nub + fill
    //   batteryGlyphComponent          vertical MDI glyph, level-tinted
    //   batteryGlyphHorizontalComponent horizontal FA glyph, level-tinted
    //   batteryBarComponent            minimalist horizontal fill bar
    // ------------------------------------------------------------------

    // (A) Default: horizontal battery outline with a proportional fill and a
    // positive terminal nub. The level reads directly from the fill.
    Component {
        id: batteryOutlineComponent
        Item {
            id: batteryIcon

            readonly property int percentage: BatteryService.percentageInt
            readonly property color levelColor: !BatteryService.available
                ? Theme.surfaceVariantText
                : BatteryService.charging ? Theme.primary
                : percentage <= 15 ? Theme.error
                : percentage <= 30 ? Theme.warning
                : Theme.success

            // Local size factor applied on top of the configured rest icon
            // scale, so the battery can sit a touch smaller than the other
            // resting items without changing the global setting.
            readonly property real scale: Config.island.restIconScale * 0.9
            readonly property real border: Math.max(1, Math.round(1 * scale))
            readonly property real gap: Math.max(1, Math.round(1.5 * scale))
            readonly property real nubWidth: Math.max(1, Math.round(1.75 * scale))
            readonly property real nubHeight: Math.round(4.5 * scale)
            readonly property real bodyWidth: Math.round(16 * scale)
            readonly property real bodyHeight: Math.round(9 * scale)

            implicitWidth: bodyWidth + nubWidth
            implicitHeight: 20

            Rectangle {
                id: body
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: batteryIcon.bodyWidth
                height: batteryIcon.bodyHeight
                radius: Math.max(1, Math.round(2 * batteryIcon.scale))
                color: "transparent"
                border.width: batteryIcon.border
                border.color: batteryIcon.levelColor

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: batteryIcon.border + batteryIcon.gap
                    readonly property real innerWidth: Math.max(0,
                        parent.width - 2 * (batteryIcon.border + batteryIcon.gap))
                    width: Math.round(innerWidth
                        * Math.max(0, Math.min(100, batteryIcon.percentage)) / 100)
                    height: Math.max(0, parent.height
                        - 2 * (batteryIcon.border + batteryIcon.gap))
                    radius: 1
                    color: batteryIcon.levelColor
                }
            }

            // Positive terminal nub on the right edge of the body.
            Rectangle {
                anchors.left: body.right
                anchors.verticalCenter: parent.verticalCenter
                width: batteryIcon.nubWidth
                height: batteryIcon.nubHeight
                radius: 1
                color: batteryIcon.levelColor
            }
        }
    }

    // (B) Plain Nerd Font glyph, tinted by charge level. No overlaid digits.
    // Uses the MDI battery series (U+F0079…), which is drawn vertically.
    Component {
        id: batteryGlyphComponent
        Item {
            readonly property int percentage: BatteryService.percentageInt
            readonly property color levelColor: !BatteryService.available
                ? Theme.surfaceVariantText
                : BatteryService.charging ? Theme.primary
                : percentage <= 15 ? Theme.error
                : percentage <= 30 ? Theme.warning
                : Theme.success

            implicitWidth: Math.round(20 * Config.island.restIconScale)
            implicitHeight: 20

            Text {
                anchors.centerIn: parent
                text: BatteryService.icon
                color: levelColor
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(12 * Config.island.restIconScale)
            }
        }
    }

    // (B2) Horizontal Nerd Font glyph. Uses the Font Awesome battery series
    // (U+F240…U+F244 / nf-fa-battery-*), which is drawn horizontally, unlike
    // the vertical MDI series above. Level maps to the nearest FA step.
    Component {
        id: batteryGlyphHorizontalComponent
        Item {
            readonly property int percentage: BatteryService.percentageInt
            readonly property color levelColor: !BatteryService.available
                ? Theme.surfaceVariantText
                : BatteryService.charging ? Theme.primary
                : percentage <= 15 ? Theme.error
                : percentage <= 30 ? Theme.warning
                : Theme.success

            // Horizontal Font Awesome battery glyphs, full → empty.
            readonly property string glyph: !BatteryService.available ? "\uf244"
                : BatteryService.charging ? "\uf0e7" // nf-fa-bolt
                : percentage > 87 ? "\uf240" // nf-fa-battery-full
                : percentage > 62 ? "\uf241" // nf-fa-battery-three-quarters
                : percentage > 37 ? "\uf242" // nf-fa-battery-half
                : percentage > 12 ? "\uf243" // nf-fa-battery-quarter
                : "\uf244" // nf-fa-battery-empty

            implicitWidth: Math.round(20 * Config.island.restIconScale)
            implicitHeight: 20

            Text {
                anchors.centerIn: parent
                text: parent.glyph
                color: parent.levelColor
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(12 * Config.island.restIconScale)
            }
        }
    }

    // (C) Minimalist horizontal fill bar — no outline, no nub. Just a track
    // and the level-tinted fill, which keeps the resting row very clean.
    Component {
        id: batteryBarComponent
        Item {
            id: batteryBar

            readonly property int percentage: BatteryService.percentageInt
            readonly property color levelColor: !BatteryService.available
                ? Theme.surfaceVariantText
                : BatteryService.charging ? Theme.primary
                : percentage <= 15 ? Theme.error
                : percentage <= 30 ? Theme.warning
                : Theme.success

            readonly property real scale: Config.island.restIconScale
            readonly property real barWidth: Math.round(18 * scale)
            readonly property real barHeight: Math.max(2, Math.round(5 * scale))

            implicitWidth: barWidth
            implicitHeight: 20

            Rectangle {
                id: track
                anchors.centerIn: parent
                width: batteryBar.barWidth
                height: batteryBar.barHeight
                radius: height / 2
                color: Theme.outlineVariant
            }

            Rectangle {
                anchors.left: track.left
                anchors.verticalCenter: track.verticalCenter
                width: Math.round(track.width
                    * Math.max(0, Math.min(100, batteryBar.percentage)) / 100)
                height: track.height
                radius: height / 2
                color: batteryBar.levelColor
            }
        }
    }

    Component {
        id: powerComponent
        Item {
            implicitWidth: 18
            implicitHeight: 20
            Text {
                visible: !CaptureService.recording
                anchors.centerIn: parent
                text: PowerProfileService.icon
                color: PowerProfileService.profileName === "Performance" ? Theme.warning
                    : PowerProfileService.profileName === "Power saver" ? Theme.success
                    : Theme.surfaceVariantText
                font.family: Config.appearance.monoFontFamily
                font.pixelSize: Math.round(11 * Config.island.restIconScale)
            }
            RecordingDot {
                anchors.centerIn: parent
                visible: CaptureService.recording
                active: visible
                dotSize: Math.round(8 * Config.island.restIconScale)
            }
            HoverHandler { onHoveredChanged: root.powerHovered = hovered }
            TapHandler {
                onTapped: CaptureService.recording
                    ? root.captureRequested() : root.powerRequested()
            }
        }
    }
}
