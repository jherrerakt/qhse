import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:qhse/Utilidades/Domains/CentroTrabajo.dart';
import 'package:qhse/Utilidades/Domains/ComunicacionRiesgo.dart';
import 'package:qhse/Utilidades/Domains/ResponsableArea.dart';
import 'package:qhse/Utilidades/Domains/Seccion.dart';
import 'package:path/path.dart' as path;

class FormularioRiesgosScreen extends StatefulWidget {
  const FormularioRiesgosScreen({super.key});

  @override
  State<FormularioRiesgosScreen> createState() =>
      _FormularioRiesgosScreenState();
}

class _FormularioRiesgosScreenState extends State<FormularioRiesgosScreen>
    with TickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'COMUNICACIÓN DE RIESGOS (1/2)'),
    const Tab(text: 'VALIDACIÓN SIT. RIESGO (2/2)'),
    const Tab(text: 'LISTADO ACCIONES'),
  ];

  late TabController _tabController;

  List<DropdownMenuItem<String>> unidadnegocio = [];
  List<DropdownMenuItem<String>> subunidadnegocio = [];
  List<DropdownMenuItem<String>> responsablesSeccion = [];
  List<MultiSelectItem<String>> responsables = [];
  List<String> ambitos = [
    "Medio ambiente",
    "Riesgos industriales",
    "Seguridad y salud",
    "Calidad"
  ];

  String? tipoCentro;
  String? tipoSeccion;
  String? tipoResponsable;

  bool loaded = false;
  bool modoEdit = false;
  bool riesgoLoaded = false;

  late ComunicacionRiesgo miRiesgo;

  int selOptTipoComRiesgo = 0;
  int selOptAmbito = 0;
  int selOptValidado = 0;
  int selOptReqPlan = 0;

  String valueUni = "";

  TextEditingController textoProyecto = TextEditingController();
  TextEditingController textoDialogo = TextEditingController();
  TextEditingController textoDescripcion = TextEditingController();
  TextEditingController textoAccion = TextEditingController();
  TextEditingController textoMotivo = TextEditingController();

  File? photo;
  final _picker = ImagePicker();
  List<File> selectedFiles = [];
  List<String> existingImageUrls = [];

  bool validCentro = true;
  bool validSeccion = true;
  bool validDescripcion = true;
  bool validDialogo = true;
  bool validMotivo = true;

  final dbRef = FirebaseDatabase.instance.ref().child('centros_trabajo');
  final seccionRef = FirebaseDatabase.instance.ref().child('secciones');
  final responsablesRef =
      FirebaseDatabase.instance.ref().child('responsables_area_seccion');
  List<CentroTrabajo> listaCentros = [];
  List<Seccion> listaSecciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Cargando datos iniciales...');
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await _getCentroTrabajo();
    print('Cargando datos iniciales');
    print('Evento cargado: $riesgoLoaded');
    if (riesgoLoaded) {
      _cargarFormulario(miRiesgo);
    }
    setState(() {
      loaded = true;
    });
  }

  void _cargarFormulario(ComunicacionRiesgo riesgo) {
    setState(() {
      tipoCentro =
          riesgo.idCentroTrabajo.isNotEmpty ? riesgo.idCentroTrabajo : null;

      tipoSeccion = riesgo.idSeccion.isNotEmpty ? riesgo.idSeccion : null;
      tipoResponsable = riesgo.idUsuarioResponsableAreaSeccion.isNotEmpty
          ? riesgo.idUsuarioResponsableAreaSeccion
          : null;
      selOptTipoComRiesgo = riesgo.idTipoComunicacion == "OC" ? 1 : 2;
      selOptAmbito =
          1 + ambitos.indexWhere((ambito) => ambito == riesgo.idAmbito);
      textoProyecto.text = riesgo.idUsuarioProyectoAsignado;
      textoDialogo.text = riesgo.dialogo;
      textoDescripcion.text = riesgo.descripcion;
      textoAccion.text = riesgo.accionInmediata;
      textoMotivo.text = riesgo.motivoRechazoValidacion;
      selOptValidado = riesgo.validadoResponsableArea == "Si"
          ? 1
          : riesgo.validadoResponsableArea == "No"
              ? 2
              : 0;
      selOptReqPlan = riesgo.requierePlanAccion ? 2 : 1;
      existingImageUrls = riesgo.imageUrls.isNotEmpty ? riesgo.imageUrls : [];
      selectedFiles = riesgo.documentUrls.map((url) => File(url)).toList();
      _getCentroTrabajo();
      _getSeccionTrabajo(tipoCentro!);
      _getResponsables(tipoSeccion!);
    });
  }

  Future<void> _getCentroTrabajo() async {
    print('Obteniendo datos...');
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref().child('centros_trabajo').once();
      print("Datos obtenidos: ${snapshot.toString()}");
    } catch (e) {
      print("Error obteniendo datos: $e");
    }

    final event = await dbRef.once();

    var temp = <CentroTrabajo>[];
    event.snapshot.children.forEach((DataSnapshot snapshot) {
      var centro = CentroTrabajo.fromSnapshot(snapshot);
      temp.add(centro);
    });
    setState(() {
      listaCentros = temp;
      listaCentros.sort((a, b) => a.textoCentroTrabajo
          .toLowerCase()
          .compareTo(b.textoCentroTrabajo.toLowerCase()));
      if (tipoCentro != null &&
          !listaCentros.any((centro) => centro.idCentroTrabajo == tipoCentro)) {
        tipoCentro =
            listaCentros.isNotEmpty ? listaCentros.first.idCentroTrabajo : null;
        tipoSeccion = null;
      }
      if (tipoCentro != null) {
        _getSeccionTrabajo(tipoCentro!);
      }
    });
  }

  void _getSeccionTrabajo(String centroId) {
    seccionRef.onValue.listen((event) {
      var temp = <Seccion>[];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var seccion = Seccion.fromSnapshot(snapshot);
        if (seccion.idCentroTrabajo == centroId) {
          temp.add(seccion);
        }
      });
      setState(() {
        listaSecciones = temp.toSet().toList();
        listaSecciones.sort((a, b) => a.textoSeccion
            .toLowerCase()
            .compareTo(b.textoSeccion.toLowerCase()));
        if (tipoSeccion != null &&
            !listaSecciones
                .any((seccion) => seccion.idSeccion == tipoSeccion)) {
          tipoSeccion = null;
        }
      });
    });
  }

  void _getResponsables(String seccionId) {
    responsablesRef.onValue.listen((event) {
      var temp = <DropdownMenuItem<String>>[];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var responsable = ResponsableArea.fromSnapshot(snapshot);
        if (responsable.idSeccion == seccionId) {
          temp.add(DropdownMenuItem<String>(
            value: responsable.idResponsableAreaSeccion,
            child: Text(responsable.nombreResponsableAreaSeccion),
          ));
        }
      });
      setState(() {
        responsablesSeccion = temp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;

      modoEdit = arguments['esNuevo'] ?? true;
      riesgoLoaded = arguments['miRiesgo'] != null;
      if (riesgoLoaded) {
        miRiesgo = arguments['miRiesgo'];
      }
      loaded = true;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'AP02-Comunicación de Riesgos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              fontFamily: 'LEMONMILK',
              color: Color.fromARGB(255, 0, 25, 48),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 204, 236),
        actions: <Widget>[
          if (riesgoLoaded && !modoEdit)
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Color.fromARGB(255, 0, 25, 48), size: 25),
              onPressed: () {
                setState(() {
                  modoEdit = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.send,
                color: Color.fromARGB(255, 0, 25, 48), size: 25),
            onPressed: () {
              if (_validacionesForm()) {
                if (riesgoLoaded) {
                  _updateDatosForm();
                } else {
                  _sendDatosForm();
                }
                _clearForm();
              } else {
                _showPopup("Hay campos obligatorios sin completar", false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: myTabs,
              isScrollable: true,
              indicatorColor: const Color.fromARGB(255, 158, 204, 236),
              labelColor: const Color.fromARGB(255, 0, 25, 48),
            ),
            Expanded(
              child: loaded
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTab1Content(),
                        _buildTab2Content(),
                        _buildTab3Content(),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab1Content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 9,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Centro *",
                      errorText: validCentro ? null : "Campo obligatorio",
                    ),
                    isExpanded: true,
                    value: listaCentros.any(
                            (centro) => centro.idCentroTrabajo == tipoCentro)
                        ? tipoCentro
                        : null,
                    items: listaCentros.map((centro) {
                      return DropdownMenuItem<String>(
                        value: centro.idCentroTrabajo,
                        child: Text(centro.textoCentroTrabajo),
                      );
                    }).toList(),
                    onChanged: modoEdit
                        ? (opt) {
                            setState(() {
                              tipoCentro = opt!;
                              validCentro = true;
                              tipoSeccion = null;
                              _getSeccionTrabajo(tipoCentro!);
                            });
                          }
                        : null,
                    disabledHint: tipoCentro != null && listaCentros.isNotEmpty
                        ? Text(listaCentros
                            .firstWhere(
                                (centro) =>
                                    centro.idCentroTrabajo == tipoCentro,
                                orElse: () => listaCentros.first)
                            .textoCentroTrabajo)
                        : null,
                  ),
                ),
                Expanded(
                  child: Visibility(
                    visible: tipoCentro != null,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Color.fromARGB(255, 0, 64, 124)),
                      onPressed: modoEdit
                          ? () {
                              setState(() {
                                tipoCentro = null;
                              });
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  children: [
                    const Text('Tipo comunicación riesgo *'),
                    Expanded(
                      child: Visibility(
                        visible: selOptTipoComRiesgo > 0,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Color.fromARGB(255, 0, 64, 124)),
                          onPressed: modoEdit
                              ? () {
                                  setState(() {
                                    selOptTipoComRiesgo = 0;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: const Text('Observación de comportamiento'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: selOptTipoComRiesgo,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptTipoComRiesgo = value!;
                            });
                          }
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Situación de riesgo'),
                  leading: Radio<int>(
                    value: 2,
                    groupValue: selOptTipoComRiesgo,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptTipoComRiesgo = value!;
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: tipoSeccion != null || listaSecciones.isNotEmpty,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Sección *",
                            errorText:
                                validSeccion ? null : "Campo obligatorio",
                          ),
                          isExpanded: true,
                          value: listaSecciones.any(
                                  (seccion) => seccion.idSeccion == tipoSeccion)
                              ? tipoSeccion
                              : null,
                          items: listaSecciones.map((seccion) {
                            return DropdownMenuItem<String>(
                              value: seccion.idSeccion,
                              child: Text(seccion.textoSeccion),
                            );
                          }).toList(),
                          onChanged: modoEdit
                              ? (opt) {
                                  setState(() {
                                    tipoSeccion = opt!;
                                    validSeccion = true;
                                    tipoResponsable = null;
                                    _getResponsables(
                                        tipoSeccion!); // Llamar a _getResponsables aquí
                                  });
                                }
                              : null,
                          disabledHint: tipoSeccion != null
                              ? Text(listaSecciones
                                  .firstWhere((seccion) =>
                                      seccion.idSeccion == tipoSeccion)
                                  .textoSeccion)
                              : null,
                        ),
                      ),
                      Expanded(
                        child: Visibility(
                          visible: tipoSeccion != null,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      tipoSeccion = null;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: responsablesSeccion.isNotEmpty,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 9,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Responsable de Area/Sección",
                            ),
                            isExpanded: true,
                            value: responsablesSeccion.any((responsable) =>
                                    responsable.value == tipoResponsable)
                                ? tipoResponsable
                                : null,
                            items: responsablesSeccion,
                            onChanged: modoEdit
                                ? (opt) {
                                    setState(() {
                                      tipoResponsable = opt!;
                                    });
                                  }
                                : null,
                            disabledHint: tipoResponsable != null
                                ? Text(responsablesSeccion
                                    .firstWhere((responsable) =>
                                        responsable.value == tipoResponsable)
                                    .child
                                    .key
                                    .toString())
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Visibility(
                            visible: tipoResponsable != null,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Color.fromARGB(255, 0, 64, 124)),
                              onPressed: modoEdit
                                  ? () {
                                      setState(() {
                                        tipoResponsable = null;
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  children: [
                    const Text('Ámbito'),
                    Expanded(
                      child: Visibility(
                        visible: selOptAmbito > 0,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Color.fromARGB(255, 0, 64, 124)),
                          onPressed: modoEdit
                              ? () {
                                  setState(() {
                                    selOptAmbito = 0;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: const Text('Medio ambiente'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: selOptAmbito,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptAmbito = value!;
                            });
                          }
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Riesgos industriales'),
                  leading: Radio<int>(
                    value: 2,
                    groupValue: selOptAmbito,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptAmbito = value!;
                            });
                          }
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Seguridad y salud'),
                  leading: Radio<int>(
                    value: 3,
                    groupValue: selOptAmbito,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptAmbito = value!;
                            });
                          }
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Calidad'),
                  leading: Radio<int>(
                    value: 4,
                    groupValue: selOptAmbito,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptAmbito = value!;
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Añadir Imagen"),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: existingImageUrls.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      photo = null;
                                      existingImageUrls = [];
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Color.fromARGB(255, 0, 64, 124)),
                        onPressed: modoEdit
                            ? () {
                                getImage(ImageSource.camera);
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.image,
                            color: Color.fromARGB(255, 0, 64, 124)),
                        onPressed: modoEdit
                            ? () {
                                getImage(ImageSource.gallery);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 0, 64, 124), width: 2.0),
              ),
              width: double.infinity,
              height: 300,
              child: existingImageUrls.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: existingImageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: existingImageUrls[index],
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    )
                  : photo != null
                      ? Image.file(photo!)
                      : const Icon(Icons.image,
                          color: Color.fromARGB(255, 0, 64, 124)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100 + selectedFiles.length * 50,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Añadir documentación"),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.note_add_rounded,
                              color: Color.fromARGB(255, 0, 64, 124)),
                          onPressed: modoEdit
                              ? () {
                                  _pickDocuments();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: selectedFiles.map((file) {
                        // Obtener solo el nombre del archivo y limpiar la cadena
                        String fileName = path
                            .basename(file.path)
                            .replaceFirst(RegExp(r'^documents%2F'), '')
                            .replaceFirst(RegExp(r'\?.*$'), '');
                        return Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.file_copy,
                                    color: Color.fromARGB(255, 0, 64, 124)),
                                const SizedBox(width: 10),
                                Text(
                                    fileName), // Mostrar solo el nombre limpio del archivo
                              ],
                            ),
                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Color.fromARGB(255, 0, 64, 124)),
                                onPressed: modoEdit
                                    ? () {
                                        setState(() {
                                          selectedFiles.remove(file);
                                        });
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: selOptTipoComRiesgo == 1,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Diálogo *'),
                      Expanded(
                        child: Visibility(
                          visible: textoDialogo.text.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      textoDialogo.clear();
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: textoDialogo,
                    maxLines: 6,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: validDialogo ? null : "Campo obligatorio",
                    ),
                    readOnly: !modoEdit,
                    onChanged: modoEdit
                        ? (text) {
                            setState(() {
                              textoDialogo.text = text;
                              validDialogo = true;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: selOptTipoComRiesgo == 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Descripción *'),
                      Expanded(
                        child: Visibility(
                          visible: textoDescripcion.text.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      textoDescripcion.clear();
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: textoDescripcion,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !modoEdit,
                    onChanged: modoEdit
                        ? (text) {
                            setState(() {
                              textoDescripcion.text = text;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Acción Inmediata'),
                      Expanded(
                        child: Visibility(
                          visible: textoAccion.text.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      textoAccion.clear();
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: textoAccion,
                    maxLines: 6,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    readOnly: !modoEdit,
                    onChanged: modoEdit
                        ? (text) {
                            setState(() {
                              textoAccion.text = text;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab2Content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const Text('Requiere validación por responsable de área'),
                    Expanded(
                      child: Visibility(
                        visible: selOptValidado > 0,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Color.fromARGB(255, 0, 64, 124)),
                          onPressed: modoEdit
                              ? () {
                                  setState(() {
                                    selOptValidado = 0;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: const Text('Sí'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: selOptValidado,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptValidado = value!;
                            });
                          }
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('No'),
                  leading: Radio<int>(
                    value: 2,
                    groupValue: selOptValidado,
                    onChanged: modoEdit
                        ? (value) {
                            setState(() {
                              selOptValidado = value!;
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            Visibility(
              visible: selOptValidado == 1,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Requiere Plan de acción'),
                      Expanded(
                        child: Visibility(
                          visible: selOptReqPlan > 0,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      selOptReqPlan = 0;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: const Text('No'),
                    leading: Radio<int>(
                      value: 1,
                      groupValue: selOptReqPlan,
                      onChanged: modoEdit
                          ? (value) {
                              setState(() {
                                selOptReqPlan = value!;
                              });
                            }
                          : null,
                    ),
                  ),
                  ListTile(
                    title: const Text('Sí'),
                    leading: Radio<int>(
                      value: 2,
                      groupValue: selOptReqPlan,
                      onChanged: modoEdit
                          ? (value) {
                              setState(() {
                                selOptReqPlan = value!;
                              });
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: selOptReqPlan == 2,
                    child: const Text(
                      'AL GUARDAR EL REGISTRO, SE LANZARÁ AUTOMÁTICAMENTE EL PLAN DE ACCIÓN\nDONDE PODRÁS CUMPLIMENTAR LAS DIFERENTES ACCIONES',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: selOptValidado == 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Motivo *'),
                      Expanded(
                        child: Visibility(
                          visible: textoMotivo.text.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Color.fromARGB(255, 0, 64, 124)),
                            onPressed: modoEdit
                                ? () {
                                    setState(() {
                                      textoMotivo.clear();
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: textoMotivo,
                    maxLines: 6,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: validMotivo ? null : "Campo obligatorio",
                    ),
                    readOnly: !modoEdit,
                    onChanged: modoEdit
                        ? (text) {
                            setState(() {
                              textoMotivo.text = text;
                              validMotivo = true;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab3Content() {
    return const Center(child: Text("No hay acciones disponibles"));
  }

  bool _validacionesForm() {
    print('Validando campos...');
    setState(() {
      validCentro = tipoCentro != null;
      if (listaSecciones.isNotEmpty) {
        validSeccion = tipoSeccion != null;
      } else {
        validSeccion = true;
      }
      validDialogo =
          selOptTipoComRiesgo != 1 ? true : textoDialogo.text.isNotEmpty;
      validMotivo = selOptValidado < 2 ? true : textoMotivo.text.isNotEmpty;
    });

    return validCentro && validSeccion && validDialogo && validMotivo;
  }

  void _sendDatosForm() async {
    print('Enviando datos...');
    print('Centro: $tipoCentro');
    print('Sección: $tipoSeccion');
    print('Responsable: $tipoResponsable');

    final String fecha = DateTime.now().toUtc().toString();
    final String directorio =
        "cl${DateTime.now().toUtc().year}${DateTime.now().toUtc().month}${DateTime.now().toUtc().day}${DateTime.now().toUtc().hour}${DateTime.now().toUtc().minute}${DateTime.now().toUtc().second}";

    List<String> imageUrls = [];
    if (photo != null) {
      String? imageUrl = await uploadImage(photo!);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }

    print('Documentos seleccionados: ${selectedFiles.length}');

    List<String> documentUrls = [];
    for (File document in selectedFiles) {
      String? documentUrl = await uploadDocument(document);
      if (documentUrl != null) {
        documentUrls.add(documentUrl);
      }
    }

    final int numero = _generateUniqueNumber();

    final ComunicacionRiesgo riesgo = ComunicacionRiesgo(
      num: _generateUniqueNumber(),
      accionInmediata: textoAccion.text,
      descripcion: textoDescripcion.text,
      dialogo: textoDialogo.text,
      directorioArchivos: directorio,
      fechaEntrada: fecha,
      idAmbito: ambitos.isNotEmpty && selOptAmbito > 0
          ? ambitos[selOptAmbito - 1]
          : "",
      idCentroTrabajo:
          tipoCentro != null && tipoCentro!.isNotEmpty ? tipoCentro! : " ",
      idEstatus: "ESR001",
      idRegistro: 0,
      idSeccion: tipoSeccion ?? "",
      idTipoComunicacion: selOptTipoComRiesgo == 1 ? "OC" : "SR",
      idUsuarioDeclarante: "16",
      idUsuarioProyectoAsignado: "",
      idUsuarioResponsableAreaSeccion: tipoResponsable ?? "",
      motivoRechazoValidacion: textoMotivo.text,
      nombreUsuarioDeclarante: "TestApp",
      nombreUsuarioProyectoAsignado: textoProyecto.text,
      nombreUsuarioResponsableAreaSeccion: tipoResponsable ?? "",
      requierePlanAccion: selOptReqPlan == 2,
      validadoResponsableArea: selOptValidado == 1
          ? "Si"
          : selOptValidado == 2
              ? "No"
              : "",
      imageUrls: imageUrls,
      documentUrls: documentUrls,
    );

    print(riesgo.toJson());

    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('comunicacion_riesgos');

    ref.child(numero.toString()).set(riesgo.toJson());

    _showPopup("Registro guardado con éxito", true);
  }

  int _generateUniqueNumber() {
    final now = DateTime.now().toUtc();
    final uniqueNumber = int.parse(
        '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}');
    return uniqueNumber;
  }

  void _updateDatosForm() async {
    print('Actualizando datos...');
    final String directorio =
        "cl${DateTime.now().toUtc().year}${DateTime.now().toUtc().month}${DateTime.now().toUtc().day}${DateTime.now().toUtc().hour}${DateTime.now().toUtc().minute}${DateTime.now().toUtc().second}";

    List<String> imageUrls = [];
    if (photo != null) {
      String? imageUrl = await uploadImage(photo!);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    print('Documentos seleccionados: ${selectedFiles.length}');

    // Crear una copia de selectedFiles para evitar modificación concurrente
    List<File> documentsToUpload = List.from(selectedFiles);
    List<String> documentUrls = [];
    for (File document in documentsToUpload) {
      String? documentUrl = await uploadDocument(document);
      if (documentUrl != null) {
        documentUrls.add(documentUrl);
      }
    }

    final ComunicacionRiesgo riesgo = ComunicacionRiesgo(
      num: miRiesgo.num,
      accionInmediata: textoAccion.text.isNotEmpty
          ? textoAccion.text
          : miRiesgo.accionInmediata,
      descripcion: textoDescripcion.text.isNotEmpty
          ? textoDescripcion.text
          : miRiesgo.descripcion,
      dialogo:
          textoDialogo.text.isNotEmpty ? textoDialogo.text : miRiesgo.dialogo,
      directorioArchivos:
          directorio.isNotEmpty ? directorio : miRiesgo.directorioArchivos,
      fechaEntrada: miRiesgo.fechaEntrada,
      idAmbito: ambitos.isNotEmpty && selOptAmbito > 0
          ? ambitos[selOptAmbito - 1]
          : miRiesgo.idAmbito,
      idCentroTrabajo: tipoCentro != null && tipoCentro!.isNotEmpty
          ? tipoCentro!
          : miRiesgo.idCentroTrabajo,
      idEstatus: "ESR001",
      idRegistro: miRiesgo.idRegistro,
      idSeccion: tipoSeccion != null && tipoSeccion!.isNotEmpty
          ? tipoSeccion!
          : miRiesgo.idSeccion,
      idTipoComunicacion: selOptTipoComRiesgo == 1 ? "OC" : "SR",
      idUsuarioDeclarante: miRiesgo.idUsuarioDeclarante,
      idUsuarioProyectoAsignado: textoProyecto.text.isNotEmpty
          ? textoProyecto.text
          : miRiesgo.idUsuarioProyectoAsignado,
      idUsuarioResponsableAreaSeccion:
          tipoResponsable != null && tipoResponsable!.isNotEmpty
              ? tipoResponsable!
              : miRiesgo.idUsuarioResponsableAreaSeccion,
      motivoRechazoValidacion: textoMotivo.text.isNotEmpty
          ? textoMotivo.text
          : miRiesgo.motivoRechazoValidacion,
      nombreUsuarioDeclarante: miRiesgo.nombreUsuarioDeclarante,
      nombreUsuarioProyectoAsignado: textoProyecto.text.isNotEmpty
          ? textoProyecto.text
          : miRiesgo.nombreUsuarioProyectoAsignado,
      nombreUsuarioResponsableAreaSeccion:
          tipoResponsable != null && tipoResponsable!.isNotEmpty
              ? tipoResponsable!
              : miRiesgo.nombreUsuarioResponsableAreaSeccion,
      requierePlanAccion:
          selOptReqPlan == 2 ? true : miRiesgo.requierePlanAccion,
      validadoResponsableArea: selOptValidado == 1
          ? "Si"
          : selOptValidado == 2
              ? "No"
              : miRiesgo.validadoResponsableArea,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : miRiesgo.imageUrls,
      documentUrls:
          documentUrls.isNotEmpty ? documentUrls : miRiesgo.documentUrls,
    );

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('comunicacion_riesgos/${miRiesgo.num}');
    await ref.update(riesgo.toJson());

    _showPopup("Registro actualizado con éxito", true);
  }

  void _showPopup(String message, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? "Éxito" : "Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  _clearForm();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    setState(() {
      tipoCentro = null;
      tipoSeccion = null;
      tipoResponsable = null;
      selOptTipoComRiesgo = 0;
      selOptAmbito = 0;
      selOptValidado = 0;
      selOptReqPlan = 0;
      valueUni = "";
      textoProyecto.clear();
      textoDialogo.clear();
      textoDescripcion.clear();
      textoAccion.clear();
      textoMotivo.clear();
      photo = null;
      selectedFiles.clear();
      modoEdit = false;
      riesgoLoaded = false;
    });
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedImage = await _picker.pickImage(source: imageSource);
    if (pickedImage != null) {
      setState(() {
        photo = File(pickedImage.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch.toString()}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<String?> uploadDocument(File documentFile) async {
    try {
      String fileName =
          'documents/${DateTime.now().millisecondsSinceEpoch.toString()}';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading document: $e");
      return null;
    }
  }
}
