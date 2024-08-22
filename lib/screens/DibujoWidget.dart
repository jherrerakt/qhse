import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qhse/screens/widgets/GlobalData.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPainter extends CustomPainter {
  List<List<Offset>> strokes;
  List<Color> colors; // Lista de colores asociados con cada trazo

  DrawingPainter(this.strokes, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length; i++) {
      Paint paint = Paint()
        ..color = colors[i] // Asignar color específico para cada trazo
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int j = 0; j < strokes[i].length - 1; j++) {
        canvas.drawLine(strokes[i][j], strokes[i][j + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DibujoWidget extends StatelessWidget {
  DibujoWidget({
    Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text(
          'Zona Afectada', // Agrega tu texto dentro de las comillas
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'LEMONMILK',
            color: Color.fromARGB(255, 0, 25, 48),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 204, 236),
      ),
      body: DibujoWidgetCuerpo(
        title: '',
      ),
    );
  }
}

class DibujoWidgetCuerpo extends StatefulWidget {
  final String title;
  DibujoWidgetCuerpo({Key? key, required this.title}) : super(key: key);

  @override
  _DibujoWidgetCuerpoState createState() => _DibujoWidgetCuerpoState();
}

class _DibujoWidgetCuerpoState extends State<DibujoWidgetCuerpo> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  List<List<Offset>> strokes = [];
  List<Color> strokeColors = []; // Lista de colores asociados con cada trazo
  List<Offset> currentStroke = [];
  Color selectedColor = Colors.black;
  int i = 0;

  @override
  void initState() {
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                    decoration: const BoxDecoration(),
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Container(
                                width: 500,
                                height: 300,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/parte_lesiones.jpg',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 500,
                                height: 300,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      // Obtener las dimensiones de la imagen directamente
                                      double imageWidth = 500;
                                      double imageHeight = 300;

                                      Offset localPosition =
                                          details.localPosition;
                                      // Limitar el dibujo al ancho y alto máximos de la imagen
                                      if (localPosition.dx >= 0 &&
                                          localPosition.dx <= imageWidth &&
                                          localPosition.dy >= 0 &&
                                          localPosition.dy <= imageHeight) {
                                        currentStroke.add(localPosition);
                                      }
                                    });
                                  },
                                  onPanEnd: (details) {
                                    setState(() {
                                      strokes.add(List.from(currentStroke));
                                      strokeColors.add(selectedColor);
                                      currentStroke.clear();
                                    });
                                  },
                                  child: CustomPaint(
                                    painter:
                                        DrawingPainter(strokes, strokeColors),
                                    child: Container(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 158, 204, 236))),
                  onPressed: () {
                    screenshotController
                        .capture(delay: const Duration(milliseconds: 10))
                        .then((capturedImage) async {
                      ShowCapturedWidget(context, capturedImage!);
                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                  child: const Text('Guardar Imagen',
                      style: TextStyle(
                          fontSize: 14, color: Color.fromARGB(255, 0, 25, 48))),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 158, 204, 236))),
                    onPressed: () {
                      OverlaySupportEntry entry = OverlaySupportEntry
                          .empty(); // Inicializar la variable entry con un valor predeterminado
                      entry = showSimpleNotification(
                        background: const Color.fromARGB(255, 245, 245, 245),
                        AlertDialog(
                          title: const Text('Seleccionar color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: [
                            Container(
                              width: 180,
                              height: 40,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromARGB(
                                            255, 158, 204, 236))),
                                onPressed: () {
                                  entry.dismiss(); // Cerrar la notificación
                                },
                                child: const Text('Aceptar',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 0, 25, 48))),
                              ),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      );
                    },
                    child: const Text('Cambiar color',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 0, 25, 48))),
                  ),
                ),
                Container(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 158, 204, 236))),
                    onPressed: () {
                      setState(() {
                        strokes.clear();
                        strokeColors.clear();
                      });
                    },
                    child: const Text('Limpiar',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 0, 25, 48))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _saveImage(Uint8List capturedImage) async {
    try {
      final String filename =
          "cl${DateTime.now().toUtc().year}${DateTime.now().toUtc().month}${DateTime.now().toUtc().day}${DateTime.now().toUtc().hour}${DateTime.now().toUtc().minute}${DateTime.now().toUtc().second}.png";
      String filePath;

      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        filePath = '${directory!.path}/$filename';
        print('Directorio: ${directory.path}');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$filename';
      }

      final file = File(filePath);
      await file.writeAsBytes(capturedImage);

      GlobalData.imagenCuerpo = filePath;

      print('Imagen guardada en: $filePath');
      return filePath;
    } catch (e) {
      print('Error al guardar la imagen: $e');
      return '';
    }
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) async {
    _saveImage(capturedImage);
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
      ),
    );
  }

  // _saved(File image) async {
  //   // final result = await ImageGallerySaver.save(image.readAsBytesSync());
  //   print("File Saved to Gallery");
  // }
}
