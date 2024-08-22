import 'package:flutter/material.dart';
import 'package:qhse/screens/widgets/entities/PrimitiveWrapper.dart';

List<DropdownMenuItem<String>> getOpcionesDropdown(List miLista) {
  List<DropdownMenuItem<String>> lista = [];
  for (var element in miLista) {
    lista.add(
      DropdownMenuItem(
        // ignore: sort_child_properties_last
        child: Text(element['nombre']),
        value: element['codigo'].toString(),
      ),
    );
  }
  return lista;
}

DropdownButtonFormField crearDropDown(
    String? text,
    PrimitiveWrapper tipoSeleccionado,
    List<DropdownMenuItem<String>> listaManual,
    {required void Function() callback}) {
  List<DropdownMenuItem<String>> listado = listaManual;

  return DropdownButtonFormField(
    isExpanded: true,
    decoration: InputDecoration(
      labelText: text,
      // Etiqueta del campo
    ),
    value: tipoSeleccionado.value.toString(),
    items: listado,
    onChanged: (opt) {
      tipoSeleccionado.value = opt!;
      print('El valor es ${tipoSeleccionado.value.toString()}');
      callback();
    }
  );
}

Widget buildRadio(
    int value, String label, int opcion,{required void Function() callback}) {
  return ListTile(
    title: Text(label),
    leading: Radio<int>(
      value: value,
      groupValue: opcion,
      activeColor: const Color.fromARGB(255, 158, 204, 236),
      fillColor:
          MaterialStateProperty.all(const Color.fromARGB(255, 158, 204, 236)),
      splashRadius: 20,
      onChanged: (value) {
          opcion = value!;
           callback();
      },
    ),
  );
}
