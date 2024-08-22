import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qhse/Utilidades/Domains/ResponsableArea.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:qhse/Utilidades/Domains/Fact_Eventos.dart';
import 'package:qhse/Utilidades/Domains/Usuario.dart';

class ListEventos extends StatefulWidget {
  const ListEventos({super.key});

  @override
  _ListEventosState createState() => _ListEventosState();
}

List<FactEventos> eventos = <FactEventos>[];
late List<ResponsableArea> listaUsuario = [];
late FactEventosDataSource eventoDataSource;
final DataGridController _dataGridController = DataGridController();

class _ListEventosState extends State<ListEventos> {
  double startRowIndex = 0;
  final int _rowsPerPage = 8;
  double totalItems = 1;
  late StreamSubscription<DatabaseEvent> _eventosSub;

  double endRowIndex = 0;

  late Usuario usuario;

  @override
  void initState() {
    super.initState();
    _loadFactEventos();
    _getUsuarios();
    eventoDataSource = FactEventosDataSource(listaUsuario);
    _dataGridController.selectedRow = null;
  }

  @override
  void dispose() {
    super.dispose();
    _eventosSub.cancel();
  }

  final dbRefUsuario = FirebaseDatabase.instance.ref().child('usuarios');

  bool datosCargadosUsuario = false;

  Future<void> _getUsuarios() async {
    if (datosCargadosUsuario) {
      return;
    }
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

      eventoDataSource = FactEventosDataSource(listaUsuario);
      eventoDataSource.updateDataGridRows();
    });

    datosCargadosUsuario = true;
  }

  Future<void> _loadFactEventos() async {
    print('Cargando eventos');
    final dbRef = FirebaseDatabase.instance.ref().child('fact_eventos');
    _eventosSub = dbRef.onValue.listen((event) {
      var temp = <FactEventos>[];
      for (var snapshot in event.snapshot.children) {
        var evento = FactEventos.fromSnapshot(snapshot);
        temp.add(evento);
      }

      if (mounted) {
        setState(() {
          eventos = temp;
          eventos.sort((a, b) => a.idEvento.compareTo(b.idEvento));
          totalItems = eventos.length.toDouble();
          eventoDataSource.updateDataGridRows();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Center(
            child: Text(
              'Lista de Eventos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                fontFamily: 'LEMONMILK',
                color: Color.fromARGB(255, 0, 25, 48),
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 158, 204, 236)),
      body: eventos.isEmpty
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
                      String idEvento = addedRows[0]
                          .getCells()
                          .where((cell) => cell.columnName == "Nº")
                          .first
                          .value;
                      _dataGridController.selectedRow = null;
                      print('Seleccionado evento $idEvento');
                      Navigator.pushNamed(
                        context,
                        '/formEventos',
                        arguments: {
                          'esNuevo': false,
                          'miEvento':
                              eventos.firstWhere((r) => r.idEvento == idEvento),
                        },
                      );
                    },
                    source: eventoDataSource,
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
                    ],
                  ),
                ),
                SfDataPager(
                  pageCount: (totalItems / _rowsPerPage).ceilToDouble(),
                  visibleItemsCount: 3,
                  delegate: eventoDataSource,
                ),
              ],
            ),
    );
  }
}

class FactEventosDataSource extends DataGridSource {
  final List<ResponsableArea> listaUsuario;

  FactEventosDataSource(this.listaUsuario);

  @override
  List<DataGridRow> get rows => eventos.map<DataGridRow>((e) {
        final nombreUsuario = listaUsuario
            .firstWhere((u) => u.idResponsableAreaSeccion == e.tipoUsuario,
                orElse: () => ResponsableArea(
                    nombreResponsableAreaSeccion: 'Desconocido',
                    idResponsableAreaSeccion: '',
                    idSeccion: ''))
            .nombreResponsableAreaSeccion;

        return DataGridRow(cells: [
          DataGridCell<String>(columnName: 'Nº', value: e.idEvento),
          DataGridCell<String>(columnName: 'Desc', value: e.textodescripcion),
          DataGridCell<String>(columnName: 'Autor', value: nombreUsuario),
          DataGridCell<String>(
              columnName: 'Fecha', value: e.dateController.toString()),
        ]);
      }).toList();

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
