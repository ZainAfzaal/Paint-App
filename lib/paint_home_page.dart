import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'draw_line.dart';
import 'sketcher.dart';

class PaintHomePage extends StatefulWidget {
  @override
  _PaintHomePageState createState() => _PaintHomePageState();
}

class _PaintHomePageState extends State<PaintHomePage> {
  List<DrawLine> lines = [];
  List<DrawLine> undoneLines = []; // For redo
  DrawLine? currentLine;
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;

  final GlobalKey canvasKey = GlobalKey();

  void startDrawing(Offset pos) {
    currentLine = DrawLine([pos], selectedColor, strokeWidth);
    lines.add(currentLine!);
    undoneLines.clear(); // Clear redo stack on new draw
    setState(() {});
  }

  void keepDrawing(Offset pos) {
    currentLine?.points.add(pos);
    setState(() {});
  }

  void clearCanvas() {
    lines.clear();
    undoneLines.clear();
    setState(() {});
  }

  void undo() {
    if (lines.isNotEmpty) {
      undoneLines.add(lines.removeLast());
      setState(() {});
    }
  }

  void redo() {
    if (undoneLines.isNotEmpty) {
      lines.add(undoneLines.removeLast());
      setState(() {});
    }
  }

  // void pickColor() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text('Pick Color'),
  //       content: BlockPicker(
  //         pickerColor: selectedColor,
  //         onColorChanged: (color) {
  //           setState(() => selectedColor = color);
  //           Navigator.pop(context);
  //         },
  //       ),
  //     ),
  //   );
  // }

  void pickColor() {
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) => tempColor = color,
            enableAlpha: true, // no transparency slider
            displayThumbColor: true,
            paletteType: PaletteType.hueWheel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedColor = tempColor);
              Navigator.pop(context);
            },
            child: Text('Select'),
          ),
        ],
      ),
    );
  }

  void pickStrokeWidth() {
    double tempWidth = strokeWidth;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Brush Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Slider(
            min: 1,
            max: 20,
            value: tempWidth,
            onChanged: (val) => setState(() => tempWidth = val),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => strokeWidth = tempWidth);
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paint App'), backgroundColor: Colors.teal),
      body: Stack(
        children: [
          RepaintBoundary(
            key: canvasKey,
            child: GestureDetector(
              onPanStart: (details) {
                final renderBox =
                    canvasKey.currentContext!.findRenderObject() as RenderBox;
                final pos = renderBox.globalToLocal(details.globalPosition);
                startDrawing(pos);
              },
              onPanUpdate: (details) {
                final renderBox =
                    canvasKey.currentContext!.findRenderObject() as RenderBox;
                final pos = renderBox.globalToLocal(details.globalPosition);
                keepDrawing(pos);
              },

              child: CustomPaint(painter: Sketcher(lines), size: Size.infinite),
            ),
          ),
          Positioned(
            right: 10,
            top: 80,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens, color: selectedColor),
                    onPressed: pickColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.brush),
                    onPressed: pickStrokeWidth,
                  ),
                  IconButton(icon: Icon(Icons.undo), onPressed: undo),
                  IconButton(icon: Icon(Icons.redo), onPressed: redo),
                  IconButton(icon: Icon(Icons.delete), onPressed: clearCanvas),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
