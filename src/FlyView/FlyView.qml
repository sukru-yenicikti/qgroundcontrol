import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap
import QGroundControl.Toolbar
import QGroundControl.Viewer3D

Item {
    id: _root

    readonly property bool _is3DMode: QGCViewer3DManager.displayMode === QGCViewer3DManager.View3D

    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _guidedController:      guidedActionsController
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property var    _mapControl:            mapControl
    property real   _fullItemZorder:         0

    function dropMainStatusIndicatorTool() {
        toolbar.dropMainStatusIndicatorTool()
    }

    QGCToolInsets {
        id:                     _toolInsets
        topEdgeLeftInset:       toolbar.height
        topEdgeCenterInset:     topEdgeLeftInset
        topEdgeRightInset:      topEdgeLeftInset
        leftEdgeBottomInset:    0
        bottomEdgeLeftInset:    0
    }

    Item {
        id:                 mapHolder
        anchors.fill:       parent

        property real topOffset: toolbar.height
        property real leftRatio: 0.45
        property real leftTopRatio: 0.55
        property real rightTopRatio: 0.58

            FlyViewMap {
        id:                     mapControl
        anchors.left:           parent.left
        anchors.top:            parent.top
        anchors.topMargin:      mapHolder.topOffset
        width:                  parent.width * mapHolder.leftRatio
        height:                 (parent.height - mapHolder.topOffset) * mapHolder.leftTopRatio

        planMasterController:   _planController
        rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        pipView:                _pipView
        pipMode:                false
        toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"

        enabled:                !_is3DMode
        visible:                !_is3DMode

        Component.onCompleted: {
            mapControl.zoomLevel = 0
        }
    }

        FlyViewVideo {
            id:             videoControl
            anchors.left:   mapControl.right
            anchors.top:    parent.top
            anchors.topMargin: mapHolder.topOffset
            width:          parent.width * (1 - mapHolder.leftRatio)
            height: (parent.height - mapHolder.topOffset) * mapHolder.rightTopRatio
            visible:        QGroundControl.videoManager.hasVideo
            pipView:        _pipView
        }

        Rectangle {
            id: hudPanel

            x: parent.width * mapHolder.leftRatio
            y: mapHolder.topOffset
            width: parent.width * (1 - mapHolder.leftRatio)
            height: (parent.height - mapHolder.topOffset) * mapHolder.rightTopRatio

            z: 10
            color: QGroundControl.videoManager.hasVideo ? "transparent" : "black"
            border.color: "white"

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
                text: (_activeVehicle && _activeVehicle.armed) ? "ARMED" : "DISARMED"
                color: (_activeVehicle && _activeVehicle.armed) ? "lime" : "red"
                font.pointSize: 18
            }

            QGCLabel {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 20
                anchors.topMargin: 20
                text: "SPD\n" + ((_activeVehicle && _activeVehicle.armed) ? _activeVehicle.groundSpeed.rawValue.toFixed(1) : "0.0")
                color: "white"
                font.pointSize: 14
            }

            QGCLabel {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 20
                anchors.topMargin: 20
                text: "ALT\n" + ((_activeVehicle && _activeVehicle.armed) ? _activeVehicle.altitudeRelative.rawValue.toFixed(1) : "0.0")
                color: "white"
                font.pointSize: 14
            }

            Item {
                anchors.centerIn: parent
                width: 80
                height: 80

                Rectangle {
                    anchors.centerIn: parent
                    width: 80
                    height: 3
                    color: "lime"
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 3
                    height: 80
                    color: "lime"
                }
            }

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: "GPS: " + (_activeVehicle ? "CONNECTED" : "NO GPS")
                color: "white"
                font.pointSize: 14
            }
        }

        Rectangle {
            id: telemetryPanel
            anchors.left:       parent.left
            anchors.bottom:     parent.bottom
            width:              parent.width * mapHolder.leftRatio
            height: (parent.height - mapHolder.topOffset) * (1 - mapHolder.leftTopRatio)
            color:              "#202020"
            border.color:       "white"

            GridLayout {
                anchors.fill:       parent
                anchors.margins:    20
                columns:            2
                rowSpacing:         12
                columnSpacing:      12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#111111"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        QGCLabel { text: "GND SPD"; color: "#00FF66"; font.pointSize: 11 }

                        QGCLabel {
                            text: (_activeVehicle ? _activeVehicle.groundSpeed.rawValue.toFixed(2) : "0.00") + " m/s"
                            color: "white"
                            font.pointSize: 16
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#111111"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        QGCLabel { text: "AIR SPD"; color: "#33AAFF"; font.pointSize: 11 }

                        QGCLabel {
                            text: (_activeVehicle ? _activeVehicle.airSpeed.rawValue.toFixed(2) : "0.00") + " m/s"
                            color: "white"
                            font.pointSize: 16
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#111111"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        QGCLabel { text: "ALTITUDE"; color: "#FF9933"; font.pointSize: 11 }

                        QGCLabel {
                            text: (_activeVehicle ? _activeVehicle.altitudeRelative.rawValue.toFixed(2) : "0.00") + " m"
                            color: "white"
                            font.pointSize: 16
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#111111"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        QGCLabel { text: "BATTERY"; color: "#FFD700"; font.pointSize: 11 }

                        QGCLabel {
                            text: (_activeVehicle && _activeVehicle.batteries.count > 0
                                   ? _activeVehicle.batteries.get(0).voltage.rawValue.toFixed(2)
                                   : "0.00") + " V"
                            color: "white"
                            font.pointSize: 16
                        }
                    }
                }
            }
        }

        Rectangle {
            id: messagePanel
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            width:              parent.width * (1 - mapHolder.leftRatio)
            height: (parent.height - mapHolder.topOffset) * (1 - mapHolder.rightTopRatio)
            color:              "#303030"
            border.color:       "white"

            Column {
                anchors.fill:       parent
                anchors.margins:    12
                spacing:            8

                QGCLabel {
                    text: "MESSAGES"
                    color: "white"
                    font.pointSize: 18
                }

                QGCLabel {
                    text: _activeVehicle ? "Vehicle connected" : "System disconnected"
                    color: "white"
                    font.pointSize: 13
                }

                QGCLabel {
                    text: _activeVehicle ? "Receiving telemetry..." : "Waiting for vehicle..."
                    color: "white"
                    font.pointSize: 13
                }
            }
        }

        PipView {
            id:                     _pipView
            visible:                false
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1:                  mapControl
            item2:                  null

            property real leftEdgeBottomInset: 0
            property real bottomEdgeLeftInset: 0
        }

        FlyViewWidgetLayer {
            id:                 widgetLayer
            anchors.fill:       parent
            z:                  _fullItemZorder + 2
            parentToolInsets:   _toolInsets
            mapControl:         _mapControl
            visible:            false
        }

        FlyViewCustomLayer {
            id:                 customOverlay
            anchors.fill:       widgetLayer
            z:                  _fullItemZorder + 2
            parentToolInsets:   widgetLayer.totalToolInsets
            mapControl:         _mapControl
            visible:            false
        }

        FlyViewInsetViewer {
            id:             widgetLayerInsetViewer
            anchors.fill:   parent
            z:              widgetLayer.z + 1
            insetsToView:   widgetLayer.totalToolInsets
            visible:        false
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            guidedValueSlider:  _guidedValueSlider
        }

        GuidedValueSlider {
            id:                 guidedValueSlider
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.topMargin:  toolbar.height
            z:                  QGroundControl.zOrderTopMost
            visible:            false
        }

        Loader {
            id:             viewer3DLoader
            z:              1
            anchors.fill:   parent
            active:         _is3DMode

            onActiveChanged: {
                if (active) {
                    setSource("qrc:/qml/QGroundControl/Viewer3D/Models3D/Viewer3DModel.qml")
                }
            }
        }
    }

    FlyViewToolBar {
        id:                 toolbar
        guidedValueSlider:  _guidedValueSlider
        visible:            !QGroundControl.videoManager.fullScreen
    }
}
