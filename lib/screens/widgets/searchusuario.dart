import 'package:flutter/material.dart';
import 'package:qhse/Utilidades/Domains/ResponsableArea.dart';

class UsuarioSearchDelegate extends SearchDelegate<ResponsableArea> {
  final List<ResponsableArea> listaUsuario;

  UsuarioSearchDelegate(this.listaUsuario);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(
            context,
            ResponsableArea(
              idResponsableAreaSeccion: '0',
              nombreResponsableAreaSeccion: '',
              idSeccion: '0',
            ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = listaUsuario.where((usuario) {
      return usuario.nombreResponsableAreaSeccion
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].nombreResponsableAreaSeccion),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = listaUsuario.where((usuario) {
      return usuario.nombreResponsableAreaSeccion
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].nombreResponsableAreaSeccion),
          onTap: () {
            query = suggestions[index].nombreResponsableAreaSeccion;
            close(context, suggestions[index]);
          },
        );
      },
    );
  }
}
