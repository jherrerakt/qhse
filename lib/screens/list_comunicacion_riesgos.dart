import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:qhse/Utilidades/Domains/ComunicacionRiesgo.dart';
import 'package:qhse/Utilidades/Domains/Usuario.dart';

class ListComunicacionRiesgos extends StatefulWidget {
  const ListComunicacionRiesgos({super.key});

  @override
  _ListComunicacionRiesgosState createState() =>
      _ListComunicacionRiesgosState();
}

List<EstadosRiesgo> estados = <EstadosRiesgo>[];
List<ComunicacionRiesgo> riesgos = <ComunicacionRiesgo>[];
late ComunicacionRiesgoDataSource riesgoDataSource;
final DataGridController _dataGridController = DataGridController();

class _ListComunicacionRiesgosState extends State<ListComunicacionRiesgos> {
  double startRowIndex = 0;
  final int _rowsPerPage = 10;
  double totalItems = 1;
  late StreamSubscription<DatabaseEvent> _estadosSub;
  late StreamSubscription<DatabaseEvent> _riesgosSub;

  double endRowIndex = 0;

  late Usuario usuario;

  @override
  void initState() {
    super.initState();
    print('initState');
    _loadEstadosRiesgo();
    _loadComunicacionRiesgos();
    riesgoDataSource = ComunicacionRiesgoDataSource();
    _dataGridController.selectedRow = null;
  }

  @override
  void dispose() {
    super.dispose();
    _estadosSub.cancel();
    _riesgosSub.cancel();
    riesgos.clear();
  }

  Future<void> _loadEstadosRiesgo() async {
    final dbRef = FirebaseDatabase.instance.ref().child('estados');
    _estadosSub = dbRef.onValue.listen((event) {
      var temp = <EstadosRiesgo>[];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var estado = EstadosRiesgo.fromSnapshot(snapshot);
        temp.add(estado);
      });

      print('Estados cargados: ${temp.length}');

      if (mounted) {
        setState(() {
          estados = temp;
        });
      }
    }, onError: (error) {
      print('Error cargando estados: $error');
    });
  }

  Future<void> _loadComunicacionRiesgos() async {
    final dbRef = FirebaseDatabase.instance.ref().child('comunicacion_riesgos');
    _riesgosSub = dbRef.onValue.listen((event) {
      var temp = <ComunicacionRiesgo>[];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        var riesgo = ComunicacionRiesgo.fromSnapshot(snapshot);
        temp.add(riesgo);
      });

      print('Riesgos cargados: ${temp.length}');

      if (mounted) {
        setState(() {
          riesgos = temp;
          totalItems = riesgos.length.toDouble();
          riesgoDataSource.updateDataGridRows();
        });
      }
    }, onError: (error) {
      print('Error cargando riesgos: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Center(
            child: Text(
              'Lista de Comunicación de Riesgos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                fontFamily: 'LEMONMILK',
                color: Color.fromARGB(255, 0, 25, 48),
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 158, 204, 236)),
      body: riesgos.isEmpty
          ? const Center(
              child: Text('No hay registros disponibles'),
            )
          : Column(
              children: [
                Expanded(
                  child: SfDataGrid(
                    rowsPerPage: _rowsPerPage,
                    selectionMode: SelectionMode.single,
                    controller: _dataGridController,
                    onSelectionChanged: (addedRows, removedRows) {
                      int idRiesgo = addedRows[0]
                          .getCells()
                          .where((cell) => cell.columnName == "Nº")
                          .first
                          .value;
                      _dataGridController.selectedRow = null;
                      Navigator.pushNamed(
                        context,
                        '/formRiesgos',
                        arguments: {
                          'esNuevo': false,
                          'miRiesgo':
                              riesgos.firstWhere((r) => r.num == idRiesgo),
                        },
                      );
                    },
                    source: riesgoDataSource,
                    rowHeight: 70,
                    columnWidthMode: ColumnWidthMode.fill,
                    columns: [
                      GridColumn(
                          width: 100,
                          columnName: 'Nº',
                          label: Container(
                              color: const Color.fromARGB(255, 158, 204, 236),
                              padding: const EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Nº',
                              ))),
                      GridColumn(
                          columnName: 'Desc',
                          width: 300,
                          label: Container(
                              color: const Color.fromARGB(255, 158, 204, 236),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Resumen',
                                maxLines: 4,
                              ))),
                      GridColumn(
                          columnName: 'Autor',
                          width: 300,
                          label: Container(
                              color: const Color.fromARGB(255, 158, 204, 236),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text('Autor'))),
                      GridColumn(
                          columnName: 'Fecha',
                          width: 150,
                          label: Container(
                              color: const Color.fromARGB(255, 158, 204, 236),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Fecha',
                                overflow: TextOverflow.ellipsis,
                              ))),
                      GridColumn(
                          columnName: 'Estado',
                          width: 150,
                          label: Container(
                              color: const Color.fromARGB(255, 158, 204, 236),
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text('Estado'))),
                    ],
                  ),
                ),
                SfDataPager(
                  pageCount: (totalItems / _rowsPerPage).ceilToDouble(),
                  visibleItemsCount: 3,
                  delegate: riesgoDataSource,
                ),
              ],
            ),
    );
  }
}

class ComunicacionRiesgoDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows => riesgos
      .map<DataGridRow>((e) => DataGridRow(cells: [
            DataGridCell<int>(columnName: 'Nº', value: e.num),
            DataGridCell<String>(
                columnName: 'Desc',
                value:
                    e.idTipoComunicacion == "OC" ? e.dialogo : e.descripcion),
            DataGridCell<String>(
                columnName: 'Autor', value: e.nombreUsuarioDeclarante),
            DataGridCell<String>(
                columnName: 'Fecha', value: e.fechaEntrada.split(' ')[0]),
            DataGridCell<String>(
                columnName: 'Estado',
                value: estados
                    .where((est) => est.idEstadoRiesgo == e.idEstatus)
                    .first
                    .textoEstadoRiesgo)
          ]))
      .toList();

  void updateDataGridRows() {
    notifyListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.columnName == 'Nº') {
          // Aplica un padding específico a la columna "Nº"
          return Container(
            padding:
                const EdgeInsets.only(left: 16.0), // Espacio a la izquierda
            alignment: Alignment.centerLeft, // Alineación a la izquierda
            child: Text(
              e.value.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: Text(
              e.value.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }
}
