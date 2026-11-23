// 1:1 port of vs/editor/common/viewModel/overviewZoneManager.ts

class Constants {
  static const int MINIMUM_HEIGHT = 4;
}

class ColorZone {
  // `_colorZoneBrand: void = undefined` has no Dart analogue (nominal brand only).
  final int from;
  final int to;
  final int colorId;

  ColorZone(num from, num to, num colorId)
      : from = from.toInt(), // TS `from | 0`
        to = to.toInt(),
        colorId = colorId.toInt();

  static int compare(ColorZone a, ColorZone b) {
    if (a.colorId == b.colorId) {
      if (a.from == b.from) {
        return a.to - b.to;
      }
      return a.from - b.from;
    }
    return a.colorId - b.colorId;
  }
}

/// A zone in the overview ruler
class OverviewRulerZone {
  // `_overviewRulerZoneBrand: void = undefined` — nominal brand only.
  final int startLineNumber;
  final int endLineNumber;

  /// If set to 0, the height in lines will be determined based on `endLineNumber`.
  final int heightInLines;
  final String color;

  ColorZone? _colorZone;

  OverviewRulerZone(this.startLineNumber, this.endLineNumber, this.heightInLines, this.color)
      : _colorZone = null;

  static int compare(OverviewRulerZone a, OverviewRulerZone b) {
    if (a.color == b.color) {
      if (a.startLineNumber == b.startLineNumber) {
        if (a.heightInLines == b.heightInLines) {
          return a.endLineNumber - b.endLineNumber;
        }
        return a.heightInLines - b.heightInLines;
      }
      return a.startLineNumber - b.startLineNumber;
    }
    return a.color.compareTo(b.color) < 0 ? -1 : 1;
  }

  void setColorZone(ColorZone colorZone) {
    _colorZone = colorZone;
  }

  ColorZone? getColorZones() => _colorZone;
}

class OverviewZoneManager {
  final int Function(int lineNumber) _getVerticalOffsetForLine;
  List<OverviewRulerZone> _zones;
  bool _colorZonesInvalid;
  num _lineHeight;
  num _domWidth;
  num _domHeight;
  num _outerHeight;
  num _pixelRatio;

  int _lastAssignedId;
  // TS `Object.create(null)` -> plain map with no prototype keys.
  final Map<String, int> _color2Id;
  // TS sparse `string[]` indexed by colorId (1-based).
  final List<String?> _id2Color;

  OverviewZoneManager(this._getVerticalOffsetForLine)
      : _zones = <OverviewRulerZone>[],
        _colorZonesInvalid = false,
        _lineHeight = 0,
        _domWidth = 0,
        _domHeight = 0,
        _outerHeight = 0,
        _pixelRatio = 1,
        _lastAssignedId = 0,
        _color2Id = <String, int>{},
        _id2Color = <String?>[];

  List<String> getId2Color() => _id2Color.whereType<String>().toList();

  void setZones(List<OverviewRulerZone> newZones) {
    _zones = newZones;
    _zones.sort(OverviewRulerZone.compare);
  }

  bool setLineHeight(num lineHeight) {
    if (_lineHeight == lineHeight) {
      return false;
    }
    _lineHeight = lineHeight;
    _colorZonesInvalid = true;
    return true;
  }

  void setPixelRatio(num pixelRatio) {
    _pixelRatio = pixelRatio;
    _colorZonesInvalid = true;
  }

  num getDOMWidth() => _domWidth;

  num getCanvasWidth() => _domWidth * _pixelRatio;

  bool setDOMWidth(num width) {
    if (_domWidth == width) {
      return false;
    }
    _domWidth = width;
    _colorZonesInvalid = true;
    return true;
  }

  num getDOMHeight() => _domHeight;

  num getCanvasHeight() => _domHeight * _pixelRatio;

  bool setDOMHeight(num height) {
    if (_domHeight == height) {
      return false;
    }
    _domHeight = height;
    _colorZonesInvalid = true;
    return true;
  }

  num getOuterHeight() => _outerHeight;

  bool setOuterHeight(num outerHeight) {
    if (_outerHeight == outerHeight) {
      return false;
    }
    _outerHeight = outerHeight;
    _colorZonesInvalid = true;
    return true;
  }

  List<ColorZone> resolveColorZones() {
    final bool colorZonesInvalid = _colorZonesInvalid;
    final int lineHeight = _lineHeight.floor();
    final int totalHeight = getCanvasHeight().floor();
    final int outerHeight = _outerHeight.floor();
    final num heightRatio = totalHeight / outerHeight;
    final int halfMinimumHeight = (Constants.MINIMUM_HEIGHT * _pixelRatio / 2).floor();

    final List<ColorZone> allColorZones = <ColorZone>[];
    for (int i = 0, len = _zones.length; i < len; i++) {
      final OverviewRulerZone zone = _zones[i];

      if (!colorZonesInvalid) {
        final ColorZone? colorZone = zone.getColorZones();
        if (colorZone != null) {
          allColorZones.add(colorZone);
          continue;
        }
      }

      final int offset1 = _getVerticalOffsetForLine(zone.startLineNumber);
      final int offset2 = zone.heightInLines == 0
          ? _getVerticalOffsetForLine(zone.endLineNumber) + lineHeight
          : offset1 + zone.heightInLines * lineHeight;

      final int y1 = (heightRatio * offset1).floor();
      final int y2 = (heightRatio * offset2).floor();

      int ycenter = ((y1 + y2) / 2).floor();
      int halfHeight = y2 - ycenter;

      if (halfHeight < halfMinimumHeight) {
        halfHeight = halfMinimumHeight;
      }

      if (ycenter - halfHeight < 0) {
        ycenter = halfHeight;
      }
      if (ycenter + halfHeight > totalHeight) {
        ycenter = totalHeight - halfHeight;
      }

      final String color = zone.color;
      int? colorId = _color2Id[color];
      if (colorId == null) {
        colorId = ++_lastAssignedId;
        _color2Id[color] = colorId;
        while (_id2Color.length <= colorId) {
          _id2Color.add(null);
        }
        _id2Color[colorId] = color;
      }
      final ColorZone colorZone = ColorZone(ycenter - halfHeight, ycenter + halfHeight, colorId);

      zone.setColorZone(colorZone);
      allColorZones.add(colorZone);
    }

    _colorZonesInvalid = false;

    allColorZones.sort(ColorZone.compare);
    return allColorZones;
  }
}
