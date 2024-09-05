import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:qhse/Utilidades/Domains/CentroTrabajo.dart';
import 'package:qhse/Utilidades/Domains/Evento.dart';
import 'package:qhse/Utilidades/Domains/Fact_Eventos.dart';
import 'package:qhse/Utilidades/Domains/ParteCuerpo.dart';
import 'package:qhse/Utilidades/Domains/ResponsableArea.dart';
import 'package:qhse/Utilidades/Domains/TipoEvento.dart';
import 'package:qhse/screens/DibujoWidget.dart';
import 'package:qhse/screens/widgets/GlobalData.dart';
import 'package:qhse/screens/widgets/dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qhse/screens/widgets/searchusuario.dart';
import 'package:path_provider/path_provider.dart';

class FormularioEventosScreen extends StatefulWidget {
  const FormularioEventosScreen({super.key});

  @override
  _FormularioEventosScreenState createState() =>
      _FormularioEventosScreenState();
}

class _FormularioEventosScreenState extends State<FormularioEventosScreen>
    with TickerProviderStateMixin {
  bool loaded = false;
  bool modoEdit = false;
  bool eventoLoaded = false;
  String textoEstatus = "";
  int selectedOption = 0;
  int validacionhse = 0;
  String textoeec = "";
  TextEditingController textonombreempresa = TextEditingController();
  TextEditingController dateController =
      TextEditingController(text: '1900-01-01');
  TextEditingController timeController = TextEditingController(text: '00:00');
  TextEditingController textodescripcion = TextEditingController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController textocausas = TextEditingController();
  TextEditingController textocorrectivas = TextEditingController();
  TextEditingController textoconclusiones = TextEditingController();
  TextEditingController textorecomendaciones = TextEditingController();
  TextEditingController textolesiones = TextEditingController();
  TextEditingController textoseveridad = TextEditingController();
  TextEditingController textomotivo2 = TextEditingController();
  // DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String textposition = "";
  String latitud = "";
  String longitud = "";
  bool validDesc = true;
  bool _hasFever = false;
  bool _hasCough = false;
  bool _hasFatigue = false;
  bool _hasHeadache = false;
  bool _hasWeakness = false;
  final _heartRateController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _oxygenController = TextEditingController();

  late FactEventos miEvento;

  double _heartRate = 0;
  double _systolic = 0;
  double _diastolic = 0;
  double _oxygen = 0;
  List<File> selectedFiles = [];

  int opcionValida = 0;
  String selectedDay = 'Lunes';
  final List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  double horatrabajo = 1;
  String textoPlanEmergencias = "";
  int planemergencias = 0;

  String textonotificacion = "";
  TextEditingController textomotivono = TextEditingController();
  int opcionGravedad = 0;
  int validacionresponsable = 0;
  String textoValidadaResponsable = "";
  String textohse = "";

  //  TABLAS
  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Zona fija'),
    const Tab(text: '1. Notificación'),
  ];

  //  TABLAS
  late TabController _tabController;

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('EEC = Empresas Externas Contratadas'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Position> getCurrentLocation() async {
    Position position = await determinePosition();
    latitud = position.latitude.toString();
    longitud = position.longitude.toString();
    textposition = 'Latitud $latitud Longitud: $longitud';
    return position;
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

  void _toggleTab3Visibility() {
    final selectedEtapa = tipoEtapa;

    if (selectedEtapa == "1") {
      // Si la etapa seleccionada es "1", elimina la tercera pestaña
      if (myTabs.length > 2) {
        myTabs.removeLast();
      }
    } else if (selectedEtapa == "2" ||
        selectedEtapa == "3" ||
        selectedEtapa == "4" ||
        selectedEtapa == "5") {
      // Agregar las pestañas correspondientes para otras etapas
      if (myTabs.length > 2) {
        // Si hay más de 2 pestañas (incluyendo "Zona fija" y "1. Notificación"),
        // reemplaza la última pestaña
        myTabs.removeLast();
      }

      switch (selectedEtapa) {
        case "2":
          myTabs.add(const Tab(text: '2.-Validación notificación'));
          break;
        case "3":
          myTabs.add(const Tab(text: '3.-Categorización QHSE'));
          break;
        case "4":
          myTabs.add(const Tab(text: '4.-Investigación'));
          break;
        case "5":
          myTabs.add(const Tab(text: '5.-Validación investigación'));
          break;
        default:
          break;
      }
    }

    setState(() {
      _tabController = TabController(vsync: this, length: myTabs.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
    //inicializa miEvento con valores vacios
    miEvento = FactEventos(
      imagenCuerpo: null,
      idEvento: '',
      centroTrabajo: '',
      dateController: '',
      timeController: '',
      textposition: '',
      selectedOption: 0,
      textonombreempresa: '',
      textodescripcion: '',
      heartRate: 0,
      systolic: 0,
      diastolic: 0,
      oxygen: 0,
      hasFever: false,
      hasCough: false,
      hasFatigue: false,
      hasHeadache: false,
      hasWeakness: false,
      opcionValida: 0,
      selectedDay: '',
      horatrabajo: 0,
      planemergencias: 0,
      textomotivono: '',
      opcionGravedad: 0,
      textocausas: '',
      textocorrectivas: '',
      textoconclusiones: '',
      textorecomendaciones: '',
      textoseveridad: '',
      textolesiones: '',
      textomotivo2: '',
      valoresParteCuerpo: [],
      validacionResponsable: 0,
      validacionHSE: 0,
      tipoUsuario: '',
      tipoUsuario2: '',
      tipoEvento: '',
      evento: '',
      selectedFiles: [],
    );
    print('Inicializando formulario');
    _getTipoEvento();
    _getCentros();
    _getTiposEtapa();
    _getUsuarios();
    _getParteCuerpo();
    GlobalData.imagenCuerpo = '';

    // Attach listeners to TextEditingController to evaluate the state when values change
    _heartRateController.addListener(_updateChart);
    _systolicController.addListener(_updateChart);
    _diastolicController.addListener(_updateChart);
    _oxygenController.addListener(_updateChart);
    _controller2.addListener(_updateChart);
    _controller.addListener(_updateChart);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    print('Cargando datos iniciales');
    print('Evento cargado: $eventoLoaded');

    _getTipoEvento();
    _getCentros();
    _getTiposEtapa();
    _getUsuarios();
    _getParteCuerpo();
    GlobalData.imagenCuerpo = '';

    // Attach listeners to TextEditingController to evaluate the state when values change
    _heartRateController.addListener(_updateChart);
    _systolicController.addListener(_updateChart);
    _diastolicController.addListener(_updateChart);
    _oxygenController.addListener(_updateChart);
    _controller2.addListener(_updateChart);
    _controller.addListener(_updateChart);

    if (eventoLoaded) {
      _cargarFormulario(miEvento);
    }
    setState(() {
      loaded = true;
    });
  }

  void _cargarFormulario(FactEventos evento) {
    setState(() async {
      print('Cargando formulario');
      print(evento.toJson());

      if (evento.imagenCuerpo != null && evento.imagenCuerpo!.isNotEmpty) {
        print('Entro a cargar imagen');
        GlobalData.imagenCuerpo = evento.imagenCuerpo!;
      } else {
        print('No hay imagen');
        GlobalData.imagenCuerpo = "";
      }

      print('Imagen: ${GlobalData.imagenCuerpo}');

      tipoEvento = evento.tipoEvento.isNotEmpty ? evento.tipoEvento : null;
      _getEvento();
      tipoeventoSeleccionado = evento.evento.isNotEmpty ? evento.evento : null;
      tipoCentro =
          evento.centroTrabajo.isNotEmpty ? evento.centroTrabajo : null;
      dateController.text = evento.dateController.isNotEmpty
          ? evento.dateController
          : '1900-01-01';
      timeController.text =
          evento.timeController.isNotEmpty ? evento.timeController : '00:00';
      textposition = evento.textposition.isNotEmpty ? evento.textposition : '';
      selectedOption = evento.selectedOption;
      textonombreempresa.text =
          evento.textonombreempresa.isNotEmpty ? evento.textonombreempresa : '';
      textodescripcion.text =
          evento.textodescripcion.isNotEmpty ? evento.textodescripcion : '';

      _heartRateController.text = evento.heartRate.toString();
      _systolicController.text = evento.systolic.toString();
      _diastolicController.text = evento.diastolic.toString();
      _oxygenController.text = evento.oxygen.toString();

      _hasFever = evento.hasFever;
      _hasCough = evento.hasCough;
      _hasFatigue = evento.hasFatigue;
      _hasHeadache = evento.hasHeadache;
      _hasWeakness = evento.hasWeakness;
      opcionValida = evento.opcionValida;
      selectedDay =
          evento.selectedDay.isNotEmpty ? evento.selectedDay : 'Lunes';
      horatrabajo = evento.horatrabajo;
      planemergencias = evento.planemergencias;
      //selectedFiles = evento.selectedFiles.cast<File>();

      if (opcionValida == 2) {
        textomotivono.text =
            evento.textomotivono.isNotEmpty ? evento.textomotivono : '';
      }
      opcionGravedad = evento.opcionGravedad;

      textocausas.text =
          evento.textocausas.isNotEmpty ? evento.textocausas : '';
      textocorrectivas.text =
          evento.textocorrectivas.isNotEmpty ? evento.textocorrectivas : '';
      textoconclusiones.text =
          evento.textoconclusiones.isNotEmpty ? evento.textoconclusiones : '';
      textorecomendaciones.text = evento.textorecomendaciones.isNotEmpty
          ? evento.textorecomendaciones
          : '';
      textoseveridad.text =
          evento.textoseveridad.isNotEmpty ? evento.textoseveridad : '';
      textolesiones.text =
          evento.textolesiones.isNotEmpty ? evento.textolesiones : '';
      textomotivo2.text =
          evento.textomotivo2.isNotEmpty ? evento.textomotivo2 : '';
      valoresParteCuerpo = evento.valoresParteCuerpo.isNotEmpty
          ? evento.valoresParteCuerpo.toSet()
          : <String>{};

      validacionresponsable = evento.validacionResponsable;
      validacionhse = evento.validacionHSE;

      tipoUsuario2 = evento.tipoUsuario2;

      print('Tipo usuario 2: $tipoUsuario2');

      await _getUsuarios();

      String resultado = listaUsuario
          .firstWhere((ResponsableArea res) =>
              res.idResponsableAreaSeccion == evento.tipoUsuario2)
          .nombreResponsableAreaSeccion;

      _controller2.text = resultado;

      print('Tipo usuario: $tipoUsuario');

      String resultado2 = listaUsuario
          .firstWhere((ResponsableArea res) =>
              res.idResponsableAreaSeccion == evento.tipoUsuario)
          .nombreResponsableAreaSeccion;

      print('Resultado 2: $resultado2');

      _controller.text = resultado2;
    });
  }

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    _tabController.dispose();
    _heartRateController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _oxygenController.dispose();
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _updateChart() {
    setState(() {
      _heartRate = double.tryParse(_heartRateController.text) ?? 0;
      _systolic = double.tryParse(_systolicController.text) ?? 0;
      _diastolic = double.tryParse(_diastolicController.text) ?? 0;
      _oxygen = double.tryParse(_oxygenController.text) ?? 0;
    });
  }

  Position? position;

  String _evaluateHealthStatus() {
    if (_heartRate < 60 || _heartRate > 100) {
      return 'Latidos del corazón fuera de rango';
    }
    if (_systolic < 90 || _systolic > 120) {
      return 'Presión sistólica fuera de rango';
    }
    if (_diastolic < 60 || _diastolic > 80) {
      return 'Presión diastólica fuera de rango';
    }
    if (_oxygen < 95) {
      return 'Oxígeno en sangre bajo';
    }
    return 'Todas las constantes están dentro de rangos saludables';
  }

  Color _getHealthStatusColor() {
    if (_heartRate < 60 ||
        _heartRate > 100 ||
        _systolic < 90 ||
        _systolic > 120 ||
        _diastolic < 60 ||
        _diastolic > 80 ||
        _oxygen < 95) {
      return Colors.red;
    }
    return Colors.green;
  }

  //*************DATABASES*************
  //-----------------TIPO EVENTO-----------------
  final dbRef = FirebaseDatabase.instance.ref().child('tipoevento');
  List<TipoEvento> listaEventos = [];
  String? tipoEvento;
  bool datosCargadosTipoEvento = false;

  Future<void> _getTipoEvento() async {
    print('Cargando tipo de evento');
    if (datosCargadosTipoEvento) {
      print('Datos ya cargados');
      return;
    }
    final tipoevento = await dbRef.once();
    var temp = <TipoEvento>[];
    tipoevento.snapshot.children.forEach((DataSnapshot snapshot) {
      var centro = TipoEvento.fromSnapshot(snapshot);
      temp.add(centro);
    });
    setState(() {
      listaEventos = temp;
      listaEventos.sort((a, b) =>
          a.textoEvento.toLowerCase().compareTo(b.textoEvento.toLowerCase()));
      if (tipoEvento != null &&
          !listaEventos
              .any((tipoevento) => tipoevento.idEvento == tipoEvento)) {
        tipoEvento =
            listaEventos.isNotEmpty ? listaEventos.first.idEvento : null;
      }
    });
    datosCargadosTipoEvento = true;
  }
  //-------------------------------------------

  //-----------------EVENTO-----------------
  final dbRefEvento = FirebaseDatabase.instance.ref().child('evento');
  List<Evento> listaEvento = [];
  String? tipoeventoSeleccionado;

  Future<void> _getEvento() async {
    final evento = await dbRefEvento.once();
    var temp = <Evento>[];
    evento.snapshot.children.forEach((DataSnapshot snapshot) {
      var elem = Evento.fromSnapshot(snapshot);
      temp.add(elem);
    });
    setState(() {
      listaEvento = temp;
      listaEvento = listaEvento
          .where((evento) => evento.idTipoEvento == tipoEvento)
          .toList();

      listaEvento.sort((a, b) =>
          a.textoEvento.toLowerCase().compareTo(b.textoEvento.toLowerCase()));
      if (tipoeventoSeleccionado != null &&
          !listaEvento.any(
              (evento) => evento.idClaseEvento == tipoeventoSeleccionado)) {
        tipoeventoSeleccionado =
            listaEvento.isNotEmpty ? listaEvento.first.idClaseEvento : null;
      }
    });
  }

  //-------------------------------------------

  //-----------------CENTROS-----------------
  final dbRefCentros = FirebaseDatabase.instance.ref().child('centros_trabajo');
  List<CentroTrabajo> listaCentros = [];
  String? tipoCentro;
  bool datosCargadosCentro = false;

  Future<void> _getCentros() async {
    if (datosCargadosCentro) {
      return;
    }
    final centros = await dbRefCentros.once();
    var temp = <CentroTrabajo>[];
    for (var snapshot in centros.snapshot.children) {
      var elem = CentroTrabajo.fromSnapshot(snapshot);
      temp.add(elem);
    }
    setState(() {
      listaCentros = temp;
      listaCentros.sort((a, b) => a.textoCentroTrabajo
          .toLowerCase()
          .compareTo(b.textoCentroTrabajo.toLowerCase()));
      if (tipoCentro != null &&
          !listaCentros.any((centro) => centro.idCentroTrabajo == tipoCentro)) {
        tipoCentro =
            listaCentros.isNotEmpty ? listaCentros.first.idCentroTrabajo : null;
      }
    });
    datosCargadosCentro = true;
  }
  //-------------------------------------------

  //-----------------PERFILES-----------------

  final DatabaseReference gruposRef =
      FirebaseDatabase.instance.ref().child('grupos');

  Future<String?> getGroupNameByEmail(String email) async {
    DataSnapshot snapshot =
        (await gruposRef.orderByChild('email').equalTo(email).once()).snapshot;

    if (snapshot.exists) {
      Map<dynamic, dynamic> grupos = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in grupos.entries) {
        Map<dynamic, dynamic> grupoData = entry.value as Map<dynamic, dynamic>;
        return grupoData['nombre'] as String?;
      }
    }
    return null; // Retorna null si no se encontró el grupo
  }

//-------------------------------------------

  //-----------------ETAPAS-----------------
  String? tipoEtapa;
  List<DropdownMenuItem<String>> etapas = [];

  Future<void> _getTiposEtapa() async {
    String? grupo = await getGroupNameByEmail(GlobalData.user.email!);

    print('Grupo: $grupo');

    if (grupo?.trim() == 'Grupo1') {
      etapas.clear();
      etapas.add(
          const DropdownMenuItem(value: "1", child: Text("1.-Notificación")));
    } else if (grupo?.trim() == 'Grupo2') {
      etapas.clear();
      etapas.add(
          const DropdownMenuItem(value: "1", child: Text("1.-Notificación")));
      etapas.add(const DropdownMenuItem(
          value: "2", child: Text("2.-Validación notificación")));
      etapas.add(const DropdownMenuItem(
          value: "3", child: Text("3.-Categorización QHSE")));
      etapas.add(
          const DropdownMenuItem(value: "4", child: Text("4.-Investigación")));
    } else if (grupo?.trim() == 'Grupo3') {
      etapas.clear();
      etapas.add(
          const DropdownMenuItem(value: "1", child: Text("1.-Notificación")));
      etapas.add(const DropdownMenuItem(
          value: "3", child: Text("3.-Categorización QHSE")));
      etapas.add(
          const DropdownMenuItem(value: "4", child: Text("4.-Investigación")));
      etapas.add(const DropdownMenuItem(
          value: "5", child: Text("5.-Validación investigación")));
    } else if (grupo?.trim() == 'GrupoX') {
      etapas.clear();
      etapas.add(
          const DropdownMenuItem(value: "1", child: Text("1.-Notificación")));
      etapas.add(const DropdownMenuItem(
          value: "2", child: Text("2.-Validación notificación")));
      etapas.add(const DropdownMenuItem(
          value: "3", child: Text("3.-Categorización QHSE")));
      etapas.add(
          const DropdownMenuItem(value: "4", child: Text("4.-Investigación")));
      etapas.add(const DropdownMenuItem(
          value: "5", child: Text("5.-Validación investigación")));
    }

    tipoEtapa = etapas.isNotEmpty ? etapas.first.value : null;
  }
//-------------------------------------------

//---------------USUARIO-----------------
  final dbRefUsuario = FirebaseDatabase.instance.ref().child('usuarios');
  List<ResponsableArea> listaUsuario = [];
  String? tipoUsuario;
  String? tipoUsuario2;

  Future<void> _getUsuarios() async {
    final usuario = await dbRefUsuario.once();
    var temp = <ResponsableArea>[];
    for (var snapshot in usuario.snapshot.children) {
      var elem = ResponsableArea.fromSnapshot(snapshot);
      temp.add(elem);
    }
    setState(() {
      listaUsuario = temp;

      listaUsuario.sort((a, b) => a.nombreResponsableAreaSeccion
          .toLowerCase()
          .compareTo(b.nombreResponsableAreaSeccion.toLowerCase()));
      if (tipoUsuario != null &&
          !listaUsuario.any(
              (usuario) => usuario.idResponsableAreaSeccion == tipoUsuario)) {
        tipoUsuario = listaUsuario.isNotEmpty
            ? listaUsuario.first.idResponsableAreaSeccion
            : null;
      }
      if (tipoUsuario2 != null &&
          !listaUsuario.any(
              (usuario) => usuario.idResponsableAreaSeccion == tipoUsuario2)) {
        tipoUsuario2 = listaUsuario.isNotEmpty
            ? listaUsuario.first.idResponsableAreaSeccion
            : null;
      }
    });
  }

//-------------------------------------------

//---------------PARTE CUERPO-----------------
  final dbRefParteCuerpo =
      FirebaseDatabase.instance.ref().child('partes_cuerpo');
  List<MultiSelectItem<String>> partecuerpo = [];
  Set<String> valoresParteCuerpo = {};
  bool datosCargadosParteCuerpo = false;

  Future<void> _getParteCuerpo() async {
    if (datosCargadosParteCuerpo) {
      return;
    }

    final event = await dbRefParteCuerpo.once();
    var temp = <ParteCuerpo>[];
    for (var snapshot in event.snapshot.children) {
      var elem = ParteCuerpo.fromSnapshot(snapshot);
      temp.add(elem);
    }
    setState(() {
      partecuerpo = temp
          .map((parte) => MultiSelectItem<String>(
                parte.idParteCuerpo,
                parte.textoParteCuerpo,
              ))
          .toList();
      datosCargadosParteCuerpo = true; // Marcar datos como cargados
    });
  }

//-------------------------------------------

  bool _validacionesForm() {
    if (opcionValida == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Debes seleccionar la opción Notificación Validada (2)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
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

  Future<Uint8List?> _loadAssetImage(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  void _showSearchDialog() async {
    final selectedUsuario = await showSearch<ResponsableArea>(
      context: context,
      delegate: UsuarioSearchDelegate(listaUsuario),
    );

    if (selectedUsuario != null) {
      setState(() {
        tipoUsuario2 = selectedUsuario.idResponsableAreaSeccion;
        print('Usuario 2: $tipoUsuario2');
        _controller2.text = selectedUsuario.nombreResponsableAreaSeccion;
      });
    }
  }

  void _showSearchDialog2() async {
    final selectedUsuario = await showSearch<ResponsableArea>(
      context: context,
      delegate: UsuarioSearchDelegate(listaUsuario),
    );

    if (selectedUsuario != null) {
      setState(() {
        tipoUsuario = selectedUsuario.idResponsableAreaSeccion;
        print('Usuario: $tipoUsuario');
        _controller.text = selectedUsuario.nombreResponsableAreaSeccion;
      });
    }
  }

  pw.Widget buildCheckboxSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        const PdfColor.fromInt((158 << 16) | (204 << 8) | 236),
                    width: 2), // Borde del checkbox
              ),
              child: _hasFever
                  ? pw.Center(
                      child: pw.Container(
                        width: 8,
                        height: 8,
                        color: const PdfColor.fromInt((158 << 16) |
                            (204 << 8) |
                            236), // Color del relleno si está marcado
                      ),
                    )
                  : pw.Container(),
            ),
            pw.SizedBox(width: 4), // Espacio entre el checkbox y el texto
            pw.Text(
              'Fiebre',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        const PdfColor.fromInt((158 << 16) | (204 << 8) | 236),
                    width: 2), // Borde del checkbox
              ),
              child: _hasCough
                  ? pw.Center(
                      child: pw.Container(
                        width: 8,
                        height: 8,
                        color: const PdfColor.fromInt((158 << 16) |
                            (204 << 8) |
                            236), // Color del relleno si está marcado
                      ),
                    )
                  : pw.Container(),
            ),
            pw.SizedBox(width: 4), // Espacio entre el checkbox y el texto
            pw.Text(
              'Tos',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        const PdfColor.fromInt((158 << 16) | (204 << 8) | 236),
                    width: 2), // Borde del checkbox
              ),
              child: _hasFatigue
                  ? pw.Center(
                      child: pw.Container(
                        width: 8,
                        height: 8,
                        color: const PdfColor.fromInt((158 << 16) |
                            (204 << 8) |
                            236), // Color del relleno si está marcado
                      ),
                    )
                  : pw.Container(),
            ),
            pw.SizedBox(width: 4), // Espacio entre el checkbox y el texto
            pw.Text(
              'Fatiga',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        const PdfColor.fromInt((158 << 16) | (204 << 8) | 236),
                    width: 2), // Borde del checkbox
              ),
              child: _hasHeadache
                  ? pw.Center(
                      child: pw.Container(
                        width: 8,
                        height: 8,
                        color: const PdfColor.fromInt((158 << 16) |
                            (204 << 8) |
                            236), // Color del relleno si está marcado
                      ),
                    )
                  : pw.Container(),
            ),
            pw.SizedBox(width: 4), // Espacio entre el checkbox y el texto
            pw.Text(
              'Dolor de cabeza',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        const PdfColor.fromInt((158 << 16) | (204 << 8) | 236),
                    width: 2), // Borde del checkbox
              ),
              child: _hasWeakness
                  ? pw.Center(
                      child: pw.Container(
                        width: 8,
                        height: 8,
                        color: const PdfColor.fromInt((158 << 16) |
                            (204 << 8) |
                            236), // Color del relleno si está marcado
                      ),
                    )
                  : pw.Container(),
            ),
            pw.SizedBox(width: 4), // Espacio entre el checkbox y el texto
            pw.Text(
              'Debilidad',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Future<Uint8List?> _loadLocalImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        print('El archivo no existe en la ruta especificada');
        return null;
      }
    } catch (e) {
      print('Error al cargar la imagen: $e');
      return null;
    }
  }

  Future<void> _generatePdf(BuildContext context, int number) async {
    final pdf = pw.Document();
    final Uint8List? logo = await _loadAssetImage('assets/logoqhse.png');
    final Uint8List? gravedad =
        await _loadAssetImage('assets/gravedad_incidente.jpg');
    final Uint8List? imagenCuerpo =
        await _loadLocalImage(GlobalData.imagenCuerpo);

    String eventoid = tipoEvento ?? '';

    final eventoSeleccionado = listaEventos.firstWhere(
      (evento) => evento.idEvento == eventoid,
      orElse: () {
        print('No se encontró el evento seleccionado');
        return TipoEvento(idEvento: '', textoEvento: '');
      },
    );

    String eventoi = tipoeventoSeleccionado ?? '';

    final evento = listaEvento.firstWhere(
      (evento) => evento.idClaseEvento == eventoi,
      orElse: () {
        print('No se encontró el evento seleccionado');
        return Evento(
            idClaseEvento: '',
            textoEvento: '',
            idTipoEvento: '',
            textoEventoResumido: '');
      },
    );

    String centro2 = tipoCentro ?? '';

    final centrotrabajo = listaCentros.firstWhere(
      (centro) => centro.idCentroTrabajo == centro2,
      orElse: () {
        print('No se encontró el centro de trabajo seleccionado');
        return CentroTrabajo(
            idCentroTrabajo: '', textoCentroTrabajo: '', idDivision: '');
      },
    );

    final partescuerpo = partecuerpo
        .where((parte) => valoresParteCuerpo.contains(parte.value))
        .map((parte) => parte.label)
        .join(', ');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(children: [
            if (logo != null) pw.Image(pw.MemoryImage(logo), width: 100),
            pw.SizedBox(height: 10),
            pw.Text('INFORME QHSE $number',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('PRIMERA ETAPA DE REGISTRO',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          'Tipo de Evento: ${eventoSeleccionado.textoEvento}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Evento: ${evento.textoEvento}'),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                        'Centro de Trabajo: ${centrotrabajo.textoCentroTrabajo}'),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 10),
            pw.Text('Información del evento',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child:
                          pw.Text('Fecha del evento: ${dateController.text}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Hora del evento: ${timeController.text}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Ubicación: $textposition'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Row(
                        children: [
                          pw.Text('EEC Involucradas: '),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 12,
                                height: 12,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: const PdfColor.fromInt(
                                          (158 << 16) | (204 << 8) | 236),
                                      width: 2), // Borde del checkbox
                                ),
                                child: selectedOption == 1
                                    ? pw.Center(
                                        child: pw.Container(
                                          width: 8,
                                          height: 8,
                                          color: const PdfColor.fromInt((158 <<
                                                  16) |
                                              (204 << 8) |
                                              236), // Color del relleno si está marcado
                                        ),
                                      )
                                    : pw.Container(),
                              ),
                              pw.SizedBox(
                                  width:
                                      4), // Espacio entre el checkbox y el texto
                              pw.Text(
                                'Si',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          pw.SizedBox(width: 10),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 12,
                                height: 12,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: const PdfColor.fromInt(
                                          (158 << 16) | (204 << 8) | 236),
                                      width: 2), // Borde del checkbox
                                ),
                                child: selectedOption == 2
                                    ? pw.Center(
                                        child: pw.Container(
                                          width: 8,
                                          height: 8,
                                          color: const PdfColor.fromInt((158 <<
                                                  16) |
                                              (204 << 8) |
                                              236), // Color del relleno si está marcado
                                        ),
                                      )
                                    : pw.Container(),
                              ),
                              pw.SizedBox(
                                  width:
                                      4), // Espacio entre el checkbox y el texto
                              pw.Text(
                                'No',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (selectedOption == 1)
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            'Nombre de la empresa: ${textonombreempresa.text}'),
                      ),
                    ],
                  ),
                ],
              ),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          'Descripción del evento: ${textodescripcion.text}'),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Persona accidentada',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Nombre: ${_controller2.text} '),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          'Frencuencia Cardiaca: $_heartRate latidos/min'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Presión Sistólica: $_systolic mmHg'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Presión Diastólica: $_diastolic mmHg'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Oxígeno en sangre: $_oxygen %'),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Síntomas',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            buildCheckboxSection(),
            pw.SizedBox(height: 10),
            pw.Text('Validación de la notificación',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Row(
                      children: [
                        pw.Text('Notificación Validada: '),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: opcionValida == 1
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'Si',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: opcionValida == 2
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'No',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (opcionValida == 2)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          'Motivo de la no validación: ${textomotivono.text}'),
                    ),
                  ],
                ),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              if (opcionValida == 1)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Gravedad: $opcionGravedad'),
                    ),
                  ],
                ),
            ]),
          ]);
        },
      ),
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(children: [
            if (opcionValida == 1)
              pw.Column(children: [
                pw.Image(pw.MemoryImage(gravedad!), width: 400),
                pw.SizedBox(height: 10),
              ]),
            pw.Text('Categorización QHSE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Día de la semana: $selectedDay'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Hora de trabajo: $horatrabajo'),
                  ),
                ],
              ),
            ]),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Row(
                      children: [
                        pw.Text(
                            '¿Requiere actualización del Plan de Emergencias?'),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: planemergencias == 1
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'Si',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: planemergencias == 2
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'No',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 10),
            pw.Text('Investigación',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                        'Responsable de la Investigación: ${_controller.text}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Causas: ${textocausas.text}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                        'Acciones Correctivas: ${textocorrectivas.text}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Conclusiones: ${textoconclusiones.text}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                        'Recomendaciones: ${textorecomendaciones.text}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Severidad: ${textoseveridad.text}'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Lesiones: ${textolesiones.text}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Parte del cuerpo lesionada: $partescuerpo'),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 10),
            if (imagenCuerpo != null)
              pw.Image(pw.MemoryImage(imagenCuerpo), width: 500),
          ]);
        },
      ),
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text('Validación de la Investigación',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(width: 1), children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Row(
                      children: [
                        pw.Text(
                            '¿Investigación validada por Responsable de área?'),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: validacionresponsable == 1
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'Si',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: validacionresponsable == 2
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'No',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (validacionresponsable == 2)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          'Motivo de la no validación: ${textomotivo2.text}'),
                    ),
                  ],
                ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Row(
                      children: [
                        pw.Text('¿Investigación validada por HSE Planta?'),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: validacionhse == 1
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'Si',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: const PdfColor.fromInt(
                                        (158 << 16) | (204 << 8) | 236),
                                    width: 2), // Borde del checkbox
                              ),
                              child: validacionhse == 2
                                  ? pw.Center(
                                      child: pw.Container(
                                        width: 8,
                                        height: 8,
                                        color: const PdfColor.fromInt((158 <<
                                                16) |
                                            (204 << 8) |
                                            236), // Color del relleno si está marcado
                                      ),
                                    )
                                  : pw.Container(),
                            ),
                            pw.SizedBox(
                                width:
                                    4), // Espacio entre el checkbox y el texto
                            pw.Text(
                              'No',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ]);
        },
      ),
    );

    final pdfBytes = await pdf.save();

    try {
      // Obtener la ruta del directorio de descargas
      final directory = await getExternalStorageDirectory();
      final downloadsDirectory = Directory('/storage/emulated/0/Download');
      print('Directorio de descargas: ${downloadsDirectory!.path}');
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }

      // Nombre del archivo
      final fileName = '${number.toString()}.pdf';

      // Crear el archivo PDF en la ruta de descargas
      final filePath = '${downloadsDirectory.path}/$fileName';
      final file = File(filePath);

      // Escribir los bytes del PDF en el archivo
      await file.writeAsBytes(pdfBytes);

      print('PDF guardado en $filePath');
    } catch (e) {
      print('Error al guardar el PDF: $e');
    }
    return;
  }

  int _generateUniqueNumber() {
    final now = DateTime.now().toUtc();
    final uniqueNumber = int.parse(
        '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}');
    return uniqueNumber;
  }

  void _updateDatosForm() async {
    print('Actualizando datos...');
    final String fecha = DateTime.now().toUtc().toString();
    final String directorio =
        "cl${DateTime.now().toUtc().year}${DateTime.now().toUtc().month}${DateTime.now().toUtc().day}${DateTime.now().toUtc().hour}${DateTime.now().toUtc().minute}${DateTime.now().toUtc().second}";

    //Comprobar si la imagen del cuerpo existe

    String? imageUrl;
    if (File(GlobalData.imagenCuerpo).existsSync()) {
      imageUrl = await uploadImage(File(GlobalData.imagenCuerpo));
      print('URL de la imagen: $imageUrl');
    } else {
      print("Error: El archivo de imagen no existe");
      imageUrl = ""; // O algún valor por defecto
    }

    print('Documentos seleccionados: ${selectedFiles.length}');

    List<String> documentUrls = [];
    for (File document in selectedFiles) {
      String? documentUrl = await uploadDocument(document);
      if (documentUrl != null) {
        documentUrls.add(documentUrl);
      }
    }

    try {
      await _generatePdf(context, int.parse(miEvento.idEvento));
    } catch (e) {
      print('Error al generar el PDF: $e');
      // Si falla la generación del PDF, mostrar un mensaje de error
      _showPopup(
          "Error al generar el PDF, pero el formulario fue enviado", false);
    }

    final FactEventos factEventos = FactEventos(
      idEvento: miEvento.idEvento,
      tipoEvento: tipoEvento ?? miEvento.tipoEvento,
      evento: tipoeventoSeleccionado ?? miEvento.evento,
      centroTrabajo: tipoCentro ?? miEvento.centroTrabajo,
      dateController: dateController.text.isNotEmpty
          ? dateController.text
          : miEvento.dateController, // Valor por defecto si está vacío
      timeController: timeController.text.isNotEmpty
          ? timeController.text
          : miEvento.timeController, // Valor por defecto si está vacío
      selectedOption: selectedOption,
      textonombreempresa: textonombreempresa.text.isNotEmpty
          ? textonombreempresa.text
          : miEvento.textonombreempresa,
      textposition:
          textposition.isNotEmpty ? textposition : miEvento.textposition,
      textodescripcion: textodescripcion.text.isNotEmpty
          ? textodescripcion.text
          : miEvento.textodescripcion,
      selectedFiles: documentUrls,
      tipoUsuario2: tipoUsuario2 ??
          miEvento.tipoUsuario2, // Si es nulo, se asigna una cadena vacía
      heartRate: _heartRate,
      systolic: _systolic,
      diastolic: _diastolic,
      oxygen: _oxygen,
      hasFever: _hasFever,
      hasCough: _hasCough,
      hasFatigue: _hasFatigue,
      hasHeadache: _hasHeadache,
      hasWeakness: _hasWeakness,
      opcionValida: opcionValida,
      textomotivono: textomotivono.text.isNotEmpty
          ? textomotivono.text
          : miEvento.textomotivono,
      opcionGravedad: opcionGravedad,
      selectedDay: selectedDay.isNotEmpty
          ? selectedDay
          : miEvento.selectedDay, // Valor por defecto si está vacío
      horatrabajo: horatrabajo,
      planemergencias: planemergencias,
      tipoUsuario: tipoUsuario ??
          miEvento.tipoUsuario, // Si es nulo, se asigna una cadena vacía
      textocausas:
          textocausas.text.isNotEmpty ? textocausas.text : miEvento.textocausas,
      textocorrectivas: textocorrectivas.text.isNotEmpty
          ? textocorrectivas.text
          : miEvento.textocorrectivas,
      textoconclusiones: textoconclusiones.text.isNotEmpty
          ? textoconclusiones.text
          : miEvento.textoconclusiones,
      textorecomendaciones: textorecomendaciones.text.isNotEmpty
          ? textorecomendaciones.text
          : miEvento.textorecomendaciones,
      textoseveridad: textoseveridad.text.isNotEmpty
          ? textoseveridad.text
          : miEvento.textoseveridad,
      textolesiones: textolesiones.text.isNotEmpty
          ? textolesiones.text
          : miEvento.textolesiones,
      valoresParteCuerpo: valoresParteCuerpo.isNotEmpty
          ? valoresParteCuerpo.toList()
          : miEvento.valoresParteCuerpo,
      imagenCuerpo: imageUrl!.isNotEmpty
          ? imageUrl
          : miEvento.imagenCuerpo, // Si es nulo, se asigna una cadena vacía
      validacionResponsable: validacionresponsable,
      textomotivo2: textomotivo2.text.isNotEmpty
          ? textomotivo2.text
          : miEvento.textomotivo2,
      validacionHSE: validacionhse,
    );

    print('Datos del formulario:');

    print(factEventos.toJson());

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('fact_eventos/${miEvento.idEvento}');
    await ref.update(factEventos.toJson());

    _showPopup("Registro actualizado con éxito", true);
  }

  Future<void> _sendDatosForm() async {
    final String fecha = DateTime.now().toUtc().toString();
    final String directorio =
        "cl${DateTime.now().toUtc().year}${DateTime.now().toUtc().month}${DateTime.now().toUtc().day}${DateTime.now().toUtc().hour}${DateTime.now().toUtc().minute}${DateTime.now().toUtc().second}";

    String? imageUrl;
    if (File(GlobalData.imagenCuerpo).existsSync()) {
      imageUrl = await uploadImage(File(GlobalData.imagenCuerpo));
      print('URL de la imagen: $imageUrl');
    } else {
      print("Error: El archivo de imagen no existe");
      imageUrl = ""; // O algún valor por defecto
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

    try {
      await _generatePdf(context, numero);
    } catch (e) {
      print('Error al generar el PDF: $e');
      // Si falla la generación del PDF, mostrar un mensaje de error
      _showPopup(
          "Error al generar el PDF, pero el formulario fue enviado", false);
    }

    print('Antes de factEventos');

    final FactEventos factEventos = FactEventos(
      idEvento: numero.toString(),
      tipoEvento: tipoEvento ?? "", // Si es nulo, se asigna una cadena vacía
      evento: tipoeventoSeleccionado ??
          "", // Si es nulo, se asigna una cadena vacía
      centroTrabajo: tipoCentro ?? "", // Si es nulo, se asigna una cadena vacía
      dateController: dateController.text.isNotEmpty
          ? dateController.text
          : "1900-01-01", // Valor por defecto si está vacío
      timeController: timeController.text.isNotEmpty
          ? timeController.text
          : "00:00", // Valor por defecto si está vacío
      selectedOption: selectedOption,
      textonombreempresa:
          textonombreempresa.text.isNotEmpty ? textonombreempresa.text : "",
      textposition: textposition.isNotEmpty ? textposition : "",
      textodescripcion:
          textodescripcion.text.isNotEmpty ? textodescripcion.text : "",
      selectedFiles: documentUrls,
      tipoUsuario2:
          tipoUsuario2 ?? "", // Si es nulo, se asigna una cadena vacía
      heartRate: _heartRate,
      systolic: _systolic,
      diastolic: _diastolic,
      oxygen: _oxygen,
      hasFever: _hasFever,
      hasCough: _hasCough,
      hasFatigue: _hasFatigue,
      hasHeadache: _hasHeadache,
      hasWeakness: _hasWeakness,
      opcionValida: opcionValida,
      textomotivono: textomotivono.text.isNotEmpty ? textomotivono.text : "",
      opcionGravedad: opcionGravedad,
      selectedDay: selectedDay.isNotEmpty
          ? selectedDay
          : "Lunes", // Valor por defecto si está vacío
      horatrabajo: horatrabajo,
      planemergencias: planemergencias,
      tipoUsuario: tipoUsuario ?? "", // Si es nulo, se asigna una cadena vacía
      textocausas: textocausas.text.isNotEmpty ? textocausas.text : "",
      textocorrectivas:
          textocorrectivas.text.isNotEmpty ? textocorrectivas.text : "",
      textoconclusiones:
          textoconclusiones.text.isNotEmpty ? textoconclusiones.text : "",
      textorecomendaciones:
          textorecomendaciones.text.isNotEmpty ? textorecomendaciones.text : "",
      textoseveridad: textoseveridad.text.isNotEmpty ? textoseveridad.text : "",
      textolesiones: textolesiones.text.isNotEmpty ? textolesiones.text : "",
      valoresParteCuerpo:
          valoresParteCuerpo.isNotEmpty ? valoresParteCuerpo.toList() : [],
      imagenCuerpo: imageUrl ?? "", // Si es nulo, se asigna una cadena vacía
      validacionResponsable: validacionresponsable,
      textomotivo2: textomotivo2.text.isNotEmpty ? textomotivo2.text : "",
      validacionHSE: validacionhse,
    );

    print('Datos del formulario:');

    print(factEventos.toJson());

    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('fact_eventos');

    ref.child(numero.toString()).set(factEventos.toJson());

    _showPopup("Registro guardado con éxito", true);
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
      tipoEvento = null;
      tipoeventoSeleccionado = null;
      tipoCentro = null;
      dateController.text = '1900-01-01';
      timeController.text = '00:00';
      selectedOption = 0;
      textonombreempresa.clear();
      textposition = "";
      textodescripcion.clear();
      selectedFiles.clear();
      tipoUsuario2 = null;
      tipoUsuario = null;
      _heartRate = 0;
      _systolic = 0;
      _diastolic = 0;
      _oxygen = 0;
      _hasFever = false;
      _hasCough = false;
      _hasFatigue = false;
      _hasHeadache = false;
      _hasWeakness = false;
      opcionValida = 0;
      textomotivono.clear();
      opcionGravedad = 0;
      selectedDay = 'Lunes';
      horatrabajo = 1;
      planemergencias = 0;
      tipoUsuario = null;
      textocausas.clear();
      textocorrectivas.clear();
      textoconclusiones.clear();
      textorecomendaciones.clear();
      textoseveridad.clear();
      textolesiones.clear();
      valoresParteCuerpo.clear();
      validacionresponsable = 0;
      textomotivo2.clear();
      validacionhse = 0;
      GlobalData.imagenCuerpo = "";
    });
  }

  Widget _buildTab1Content() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Form(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset('assets/logoqhse.png', width: 110),
            ),
            const SizedBox(height: 40),
            AbsorbPointer(
              absorbing: !modoEdit,
              child: Center(
                heightFactor: 1.5,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: "Selecciona el tipo de evento",
                    ),
                    value: tipoEvento,
                    items: listaEventos
                        .map((tipoevento) => DropdownMenuItem(
                              value: tipoevento.idEvento,
                              child: Text(tipoevento.textoEvento),
                            ))
                        .toList(),
                    onChanged: (opt) {
                      setState(() {
                        tipoEvento = opt;
                        _getEvento();
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AbsorbPointer(
              absorbing: !modoEdit,
              child: Center(
                heightFactor: 1.5,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: "Evento",
                    ),
                    value: tipoeventoSeleccionado,
                    items: listaEvento
                        .map((evento) => DropdownMenuItem(
                              value: evento.idClaseEvento,
                              child: Text(evento.textoEvento),
                            ))
                        .toList(),
                    onChanged: (opt) {
                      setState(() {
                        tipoeventoSeleccionado = opt;
                        print(
                            'El valor del evento es: $tipoeventoSeleccionado');
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AbsorbPointer(
              absorbing: !modoEdit,
              child: Center(
                  heightFactor: 1.5,
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: "Centro de trabajo/Planta",
                      ),
                      value: tipoCentro,
                      items: listaCentros
                          .map((centro) => DropdownMenuItem(
                                value: centro.idCentroTrabajo,
                                child: Text(centro.textoCentroTrabajo),
                              ))
                          .toList(),
                      onChanged: (opt) {
                        tipoCentro = opt!;
                        setState(() {
                          print('El valor del centro es: $tipoCentro');
                        });
                      },
                    ),
                  )),
            ),
            const SizedBox(height: 20),
            //AbsorbPointer de otro dropdown que sea de etapa
            Column(
              children: [
                Center(
                  heightFactor: 1.5,
                  child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: "Etapa del Registro",
                        ),
                        value: tipoEtapa,
                        items: etapas,
                        onChanged: (opt) {
                          tipoEtapa = opt;
                          setState(() {
                            print('El valor de la etapa es: $tipoEtapa');
                            _toggleTab3Visibility();
                          });
                        },
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab2Content() {
    //Position? position;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AbsorbPointer(
          absorbing: !modoEdit,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '1. Notificación',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color.fromARGB(255, 0, 25, 48)),
                ),
              ),
              const SizedBox(height: 50),
              const Row(
                children: [
                  Icon(Icons.book),
                  SizedBox(width: 10),
                  Text('Información del Evento',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 0, 25, 48))),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 10),
                  Text('Zona del Evento',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 0, 25, 48))),
                ],
              ),
              const SizedBox(height: 50),
              TextField(
                  controller:
                      dateController, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      hintText: 'Fecha evento' //label text of field
                      ),
                  readOnly: false, // when true user cannot edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1800),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      // Formatea la fecha y asigna al controlador del campo de texto
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      dateController.text = formattedDate;
                    }
                    if (pickedDate == null) {
                      print('La fecha es nula');
                      dateController.text = '1900-01-01';
                    }
                  }),
              const SizedBox(height: 30),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.access_time), // Icono del campo de texto
                  hintText:
                      'Seleccionar Hora', // Texto de sugerencia del campo de texto
                ),
                readOnly: true, // No permitir la edición manual del texto
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(), // Hora inicial
                  );

                  if (pickedTime != null) {
                    // Formatear la hora seleccionada en el formato deseado
                    String formattedTime = DateFormat('HH:mm').format(
                        DateTime(0, 1, 1, pickedTime.hour, pickedTime.minute));

                    // Asignar la hora formateada al controlador
                    timeController.text = formattedTime;
                  }

                  if (pickedTime == null) {
                    print('ENTRO A pickedTime ${pickedTime}');
                    timeController.text = '00:00';
                  }
                },
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Align(
                      alignment: Alignment.topRight,
                      child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Row(
                            children: [
                              const Text('EEC involucradas'),
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: _showInfoDialog,
                              ),
                            ],
                          ))),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Si'),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: selectedOption,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 20,
                            onChanged: (value) {
                              setState(() {
                                textoeec = "SI";
                                selectedOption = value!;
                                print(textoeec);
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('No'),
                          leading: Radio<int>(
                            value: 2,
                            groupValue: selectedOption,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 25,
                            onChanged: (value) {
                              setState(() {
                                textoeec = "NO";
                                selectedOption = value!;
                                print(textoeec);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              if (selectedOption == 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: TextField(
                      controller: textonombreempresa,
                      // Configura las propiedades del TextField para Comunicación
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la empresa'),
                      onChanged: (text) {
                        textonombreempresa.text = text;
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      child: InkWell(
                        onTap: () async {
                          position = await getCurrentLocation();
                          setState(() {
                            textposition;
                          });
                        },
                        child: const FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Geolocalización"),
                              Spacer(),
                              Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 0, 25, 48),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                        widthFactor: 0.8, child: Text(textposition)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Icon(Icons.file_open),
                  SizedBox(width: 10),
                  Text('Descripción del Evento',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 0, 25, 48))),
                ],
              ),
              const SizedBox(height: 30),
              const FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Descripción del Evento (*)"))),
              FractionallySizedBox(
                widthFactor: 0.9,
                child: TextField(
                  controller: textodescripcion,
                  maxLines: 4,
                  selectionHeightStyle: BoxHeightStyle
                      .max, // Esto permite múltiples líneas de texto
                  keyboardType: TextInputType
                      .multiline, // Define el tipo de entrada como multilinea
                  decoration: InputDecoration(
                    labelText: '',
                    errorText: validDesc ? null : "Campo obligatorio",
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    textodescripcion.text = text;
                    if (text.isNotEmpty) validDesc = true;
                    // Manejar el texto ingresado
                  },
                ),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 30),
              const Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 10),
                  Text('Persona Accidentada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 0, 25, 48))),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller2,
                        decoration: const InputDecoration(
                          labelText: 'Persona accidentada',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true, // Establece el campo como solo lectura
                        onChanged: (value) {
                          tipoUsuario2 = value;
                          print(
                              'El valor de la persona accidentada es: $value');
                        },
                      ),
                    ),
                    const SizedBox(
                        width:
                            8), // Espacio entre el TextFormField y el IconButton
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _showSearchDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _heartRateController,
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia cardíaca',
                        suffixText: 'latidos por minuto',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => {
                        _heartRate = double.tryParse(value) ?? 0,
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                        controller: _systolicController,
                        decoration: const InputDecoration(
                          labelText: 'Presión sistólica',
                          suffixText: 'mm de Hg',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => {
                              _systolic = double.tryParse(value) ?? 0,
                            }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                        controller: _diastolicController,
                        decoration: const InputDecoration(
                          labelText: 'Presión diastólica',
                          suffixText: 'mm de Hg',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => {
                              _diastolic = double.tryParse(value) ?? 0,
                            }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oxygenController,
                      decoration: const InputDecoration(
                        labelText: 'Oxígeno en sangre',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => {
                        _oxygen = double.tryParse(value) ?? 0,
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _evaluateHealthStatus(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getHealthStatusColor(),
                ),
              ),
              const SizedBox(height: 40),
              const Row(
                children: [
                  Icon(Icons.sick),
                  SizedBox(width: 10),
                  Text('Sintomas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 25, 48))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Fiebre'),
                      value: _hasFever,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasFever = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Tos'),
                      value: _hasCough,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasCough = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Fatiga'),
                      value: _hasFatigue,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasFatigue = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Dolor de cabeza'),
                      value: _hasHeadache,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasHeadache = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                        title: const Text('Debilidad'),
                        value: _hasWeakness,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasWeakness = value ?? false;
                          });
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab3Content() {
    if (tipoEtapa == "2") {
      textoEstatus = 'Validación de Notificación';
      return Form(
        child: AbsorbPointer(
          absorbing: !modoEdit,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.topRight,
                  child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Text('¿Notificación validada? (*) :'))),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: const Text('Si'),
                      leading: Radio<int>(
                        value: 1,
                        groupValue: opcionValida,
                        activeColor: const Color.fromARGB(255, 158, 204, 236),
                        fillColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 158, 204, 236)),
                        splashRadius: 20,
                        onChanged: (value) {
                          setState(() {
                            opcionValida = value!;
                            textonotificacion = 'SI';
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('No'),
                      leading: Radio<int>(
                        value: 2,
                        groupValue: opcionValida,
                        activeColor: const Color.fromARGB(255, 158, 204, 236),
                        fillColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 158, 204, 236)),
                        splashRadius: 25,
                        onChanged: (value) {
                          setState(() {
                            opcionValida = value!;
                            textonotificacion = 'NO';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              if (opcionValida == 2)
                Column(
                  children: [
                    const FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Motivo de No Validación"),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: TextField(
                        controller: textomotivono,
                        maxLines: 4,
                        selectionHeightStyle: BoxHeightStyle.max,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (text) {
                          textomotivono.text = text;

                          // Manejar el texto ingresado
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 30,
              ),
              if (opcionValida == 1)
                Column(
                  children: [
                    const Align(
                        alignment: Alignment.topRight,
                        child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Text('Nivel de Gravedad'))),
                    buildRadio(1, '1', opcionGravedad, callback: () {
                      setState(() {
                        opcionGravedad = 1;
                        repintarc();
                      });
                    }),
                    buildRadio(2, '2', opcionGravedad, callback: () {
                      setState(() {
                        opcionGravedad = 2;
                        repintarc();
                      });
                    }),
                    buildRadio(3, '3', opcionGravedad, callback: () {
                      setState(() {
                        opcionGravedad = 3;
                        repintarc();
                      });
                    }),
                    buildRadio(4, '4', opcionGravedad, callback: () {
                      setState(() {
                        opcionGravedad = 4;
                        repintarc();
                      });
                    }),
                    const SizedBox(
                      height: 30,
                    ),
                    Image.asset('assets/gravedad_incidente.jpg'),
                  ],
                )
            ],
          ),
        ),
      );
    } else if (tipoEtapa == "3") {
      textoEstatus = 'Categorización QHSE';
      return Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          AbsorbPointer(
            absorbing: !modoEdit,
            child: Center(
              heightFactor: 1.5,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText:
                          'Día de la semana en el que se produce el evento:',
                    ),
                    value:
                        selectedDay, // Cambié `opcionValida` por `selectedDay`
                    items: diasSemana
                        .map((dia) => DropdownMenuItem(
                              value: dia,
                              child: Text(dia),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDay = newValue!;
                        print('Día seleccionado: $selectedDay');
                      });
                    }),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          AbsorbPointer(
            absorbing: !modoEdit,
            child: Center(
              heightFactor: 1.5,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('Hora del trabajo *:')),
                      Slider(
                        value: horatrabajo,
                        min: 1,
                        max: 12,
                        divisions: 11,
                        activeColor: const Color.fromARGB(255, 158, 204,
                            236), // Número de divisiones (de 1 a 12)
                        onChanged: (double value) {
                          setState(() {
                            horatrabajo = value;
                          });
                        },
                      ),
                      Text('${horatrabajo.toInt()}h'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AbsorbPointer(
            absorbing: !modoEdit,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  const Align(
                      alignment: Alignment.topRight,
                      child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Text(
                              '¿Requiere actualización del Plan de Emergencias?'))),
                  Row(children: <Widget>[
                    Expanded(
                      child: ListTile(
                        title: const Text('Si'),
                        leading: Radio<int>(
                          value: 1,
                          groupValue: planemergencias,
                          activeColor: const Color.fromARGB(255, 158, 204, 236),
                          fillColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 158, 204, 236)),
                          splashRadius: 20,
                          onChanged: (value) {
                            setState(() {
                              planemergencias = value!;
                              textoPlanEmergencias = "SI";
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('No'),
                        leading: Radio<int>(
                          value: 2,
                          groupValue: planemergencias,
                          activeColor: const Color.fromARGB(255, 158, 204, 236),
                          fillColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 158, 204, 236)),
                          splashRadius: 25,
                          onChanged: (value) {
                            setState(() {
                              planemergencias = value!;
                              textoPlanEmergencias = "NO";
                            });
                          },
                        ),
                      ),
                    ),
                  ])
                ]),
          )
        ],
      );
    } else if (tipoEtapa == "4") {
      textoEstatus = 'Investigación';
      return SingleChildScrollView(
        child: AbsorbPointer(
          absorbing: !modoEdit,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Responsable de la investigación',
                              border: OutlineInputBorder(),
                            ),
                            readOnly:
                                true, // Establece el campo como solo lectura
                            onChanged: (value) {
                              tipoUsuario = value;
                              print(
                                  'El valor de la persona responsable es: $value');
                            },
                          ),
                        ),
                        const SizedBox(
                            width:
                                8), // Espacio entre el TextFormField y el IconButton
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _showSearchDialog2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: textocausas,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Causas Identificadas',
                        border: OutlineInputBorder(),
                        hintText: 'Describa las causas principales...',
                      ),
                      onChanged: (text) {
                        textocausas.text = text;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: textocorrectivas,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Acciones Correctivas',
                        border: OutlineInputBorder(),
                        hintText:
                            'Describa las acciones correctivas tomadas...',
                      ),
                      onChanged: (value) {
                        textocorrectivas.text = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: textoconclusiones,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Conclusiones',
                        border: OutlineInputBorder(),
                        hintText:
                            'Resuma las conclusiones de la investigación...',
                      ),
                      onChanged: (value) {
                        textoconclusiones.text = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: textorecomendaciones,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Recomendaciones',
                        border: OutlineInputBorder(),
                        hintText: 'Ingrese cualquier recomendación...',
                      ),
                      onChanged: (value) {
                        textorecomendaciones.text = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nivel de Severidad',
                      ),
                      value: textoseveridad.text.isNotEmpty &&
                              ['Crítico', 'Alto', 'Medio', 'Bajo']
                                  .contains(textoseveridad.text)
                          ? textoseveridad.text
                          : null, // Valor por defecto si es válido
                      items: ['Crítico', 'Alto', 'Medio', 'Bajo']
                          .map((severidad) => DropdownMenuItem<String>(
                                value: severidad,
                                child: Text(severidad),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          textoseveridad.text = value;
                          print('El nivel de severidad es: $value');
                        }
                      },
                    ),
                  ),

                  // Campo para las lesiones de la persona
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: textolesiones,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Lesiones de la persona',
                        border: OutlineInputBorder(),
                        hintText: 'Describa las lesiones sufridas...',
                      ),
                      onChanged: (value) {
                        textolesiones.text = value;
                      },
                    ),
                  ),
                  // Dropdown para seleccionar partes del cuerpo accidentadas
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: MultiSelectDialogField(
                        buttonText: const Text('Parte Cuerpo Lesionada'),
                        buttonIcon: const Icon(Icons.arrow_right_outlined),
                        selectedColor: const Color.fromARGB(255, 158, 204, 236),
                        items: partecuerpo,
                        initialValue: valoresParteCuerpo.toList(),
                        onConfirm: (valores) {
                          setState(() {
                            valoresParteCuerpo = valores.toSet();
                          });
                          print('Valores seleccionados: $valoresParteCuerpo');
                        },
                      ),
                    ),
                  ),
                  // Imagen sobre la que se puede dibujar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'Dibuje las lesiones en el cuerpo pulsando la imagen',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 25, 48),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async {
                              // Navega a la pantalla de detalle y espera la respuesta
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DibujoWidget()),
                              );
                            },
                            child: (miEvento != null &&
                                    miEvento.imagenCuerpo != null &&
                                    miEvento.imagenCuerpo!.isNotEmpty)
                                ? Image.network(miEvento.imagenCuerpo!)
                                : (GlobalData.imagenCuerpo.isNotEmpty
                                    ? Image.file(File(GlobalData.imagenCuerpo))
                                    : Image.asset('assets/parte_lesiones.jpg')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (tipoEtapa == "5") {
      textoEstatus = 'Validación de Investigación';
      return Form(
          child: SingleChildScrollView(
        child: AbsorbPointer(
          absorbing: !modoEdit,
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  const Align(
                      alignment: Alignment.topRight,
                      child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Text(
                              '¿Investigación validada por Responsable de área?'))),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Si'),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: validacionresponsable,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 20,
                            onChanged: (value) {
                              setState(() {
                                validacionresponsable = value!;
                                textoValidadaResponsable = "SI";
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('No'),
                          leading: Radio<int>(
                            value: 2,
                            groupValue: validacionresponsable,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 25,
                            onChanged: (value) {
                              setState(() {
                                validacionresponsable = value!;
                                textoValidadaResponsable = "NO";
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (validacionresponsable == 2)
                    Column(
                      children: [
                        const FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text("Motivo de No Validación (*)"),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: TextField(
                            controller: textomotivo2,
                            maxLines: 4,
                            selectionHeightStyle: BoxHeightStyle.max,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              labelText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              textomotivo2.text = text;
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 30,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Align(
                      alignment: Alignment.topRight,
                      child: FractionallySizedBox(
                          widthFactor: 0.9,
                          child:
                              Text('¿Investigación validada por HSE Planta?'))),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: const Text('Si'),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: validacionhse,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 20,
                            onChanged: (value) {
                              setState(() {
                                validacionhse = value!;
                                textohse = "SI";
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('No'),
                          leading: Radio<int>(
                            value: 2,
                            groupValue: validacionhse,
                            activeColor:
                                const Color.fromARGB(255, 158, 204, 236),
                            fillColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 158, 204, 236)),
                            splashRadius: 25,
                            onChanged: (value) {
                              setState(() {
                                validacionhse = value!;
                                textohse = "NO";
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ));
    } else {
      return const Text("No hay contenido");
    }
    //devuelve el contenido de la pestaña 3
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      modoEdit = arguments['esNuevo'] ?? true;
      eventoLoaded = arguments['miEvento'] != null;
      if (eventoLoaded) {
        miEvento = arguments['miEvento'];
      }
      loaded = true;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'AP01-Gestión de Eventos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'LEMONMILK',
              color: Color.fromARGB(255, 0, 25, 48),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 204, 236),
        actions: [
          if (eventoLoaded && !modoEdit)
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
              if (eventoLoaded) {
                _updateDatosForm();
              } else {
                _sendDatosForm();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Visibility(
            visible: true,
            child: TabBar(
              controller: _tabController,
              tabs: myTabs,
              indicatorColor: const Color.fromARGB(255, 158, 204, 236),
              labelColor: const Color.fromARGB(255, 0, 25, 48),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTab1Content(),
                _buildTab2Content(),
                _buildTab3Content(),
                // Aquí puedes agregar más tabs y su contenido
              ],
            ),
          )
        ],
      ),
    );
  }

  void repintarc() {
    setState(() {});
  }
}
