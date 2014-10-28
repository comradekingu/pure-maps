/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtPositioning 5.0

import "js/util.js" as Util

/*
 * XXX: The intended way to draw a route on a QtLocation map would be to use
 * QtLocation's MapPolyline. MapPolyline, however, renders awfully ugly.
 * To work around this, let's use a Canvas and Context2D drawing primitives
 * to draw our route. This looks nice, but might be horribly inefficient.
 *
 * http://bugreports.qt-project.org/browse/QTBUG-38459
 */

Canvas {
    id: canvas
    height: app.totalHeight
    width: app.totalWidth
    contextType: "2d"
    renderStrategy: Canvas.Cooperative
    z: 200

    property string attribution: ""
    property bool   changed: false
    property bool   hasPath: false
    property bool   initDone: false
    property string mode: "car"
    property var    paintX: 0
    property var    paintY: 0
    property var    path: {"x": [], "y": []}
    property var    simplePaths: {}

    Timer {
        // Use an timer to ensure updates if map panned.
        // Needed since Sailfish OS 1.1.0.38.
        interval: 500
        repeat: true
        running: canvas.hasPath
        onTriggered: canvas.changed && canvas.requestPaint();
    }

    onPaint: {
        console.log("onPaint: " + Date.now());
        // Clear the whole canvas and redraw entire route.
        // This gets called continuously as the map is panned!
        if (!canvas.hasPath) return;
        if (!canvas.changed) return;
        canvas.initDone || canvas.initContextProperties();
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        var zoom = Math.floor(map.zoomLevel);
        var key = zoom.toString();
        if (!canvas.simplePaths.hasOwnProperty(key)) {
            // Use a simplified path to avoid the slowness of
            // plotting too many polyline segments on screen.
            if (map.gesture.isPinchActive) return;
            canvas.simplePaths[key] = {"x": [], "y": []};
            return canvas.simplify(zoom);
        }
        var spath = canvas.simplePaths[key];
        canvas.context.beginPath();
        var bbox = map.getBoundingBox();
        var maxLength = Math.min(map.widthCoords, map.heightCoords);
        var xmin = bbox[0] - 1.5 * maxLength;
        var xmax = bbox[1] + 1.5 * maxLength;
        var ymin = bbox[2] - 1.5 * maxLength;
        var ymax = bbox[3] + 1.5 * maxLength;
        var prev = false;
        for (var i = 0; i < spath.x.length; i++) {
            var x = spath.x[i];
            var y = spath.y[i];
            if (x >= xmin && x <= xmax && y >= ymin && y <= ymax) {
                var xpos = Util.xcoord2xpos(x, bbox[0], bbox[1], map.width);
                var ypos = Util.ycoord2ypos(y, bbox[2], bbox[3], map.height);
                canvas.context.lineTo(xpos, ypos);
                prev = true;
            } else if (prev) {
                // Break path when going outside the area
                // in which segments are rendered.
                canvas.context.stroke();
                canvas.context.beginPath();
                prev = false;
            } else {
                prev = false;
            }
        }
        canvas.paintX = map.center.longitude;
        canvas.paintY = map.center.latitude;
        canvas.changed = false;
        canvas.context.stroke();
    }

    onPathChanged: {
        // Update canvas in conjunction with panning the map
        // only when we actually have a route to display.
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        canvas.simplePaths = {};
        canvas.hasPath = canvas.path.x.length > 0;
        if (canvas.hasPath) {
            canvas.x = Qt.binding(function() {
                return (this.paintX - map.center.longitude) * map.scaleX;
            });
            canvas.y = Qt.binding(function() {
                return (map.center.latitude - this.paintY) * map.scaleY;
            });
        } else {
            canvas.x = 0;
            canvas.y = 0;
        }
    }

    onXChanged: canvas.changed = true;
    onYChanged: canvas.changed = true;

    function clear() {
        // Clear path from the canvas.
        canvas.path = {"x": [], "y": []};
        canvas.redraw();
    }

    function initContextProperties() {
        // Initialize context paint properties.
        canvas.context.globalAlpha = 0.5;
        canvas.context.lineCap = "round";
        canvas.context.lineJoin = "round";
        canvas.context.lineWidth = 10;
        canvas.context.strokeStyle = "#0540ff";
        canvas.initDone = true;
    }

    function redraw() {
        // Clear canvas and redraw entire route.
        canvas.changed = true;
        canvas.requestPaint();
    }

    function setPath(x, y) {
        // Set route path from coordinates.
        canvas.path = {"x": x, "y": y};
        canvas.redraw();
    }

    function setSimplePath(zoom, path) {
        // Set simplified path at zoom level.
        Object.defineProperty(canvas.simplePaths, zoom.toString(), {
            value: path, writable: true});
        canvas.requestPaint();
    }

    function simplify(zoom) {
        // Simplify path for display at zoom level using Douglas-Peucker.
        if (zoom < 14) {
            var tol = Math.pow(2, 18-zoom) / 83250;
        } else {
            // Don't try simplification at high zoom levels as
            // we approach Douglas-Peucker's worst case O(n^2).
            var tol = null;
        }
        var maxLength = Math.min(map.widthCoords, map.heightCoords);
        var args = [canvas.path.x, canvas.path.y, tol, false, maxLength, 2000];
        py.call("poor.polysimp.simplify_qml", args, function(path) {
            canvas.setSimplePath(zoom, path);
        });
    }
}
