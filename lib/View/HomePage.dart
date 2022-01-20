import 'package:estudo_de_teste_tecnico/ViiewModel/Request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum SelectedPopup { stars, repositories }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Request request = Request();

  SortOrNot _sortOrNot = SortOrNot.notSort;

  bool _isSearching = false;
  String _searchQuery = '';
  TextEditingController _searchQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActionsFromAppBar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: request.getRepositories(_searchQuery, _sortOrNot),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5.0,
                    ),
                  );
                  default:
                    if (snapshot.hasError) {
                      return Container(); //Exibir mensagem de erro
                    } else {
                      return _createCardList(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return const Text(
      'Github Repositories',
      textAlign: TextAlign.start,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Digite sua busca",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onSubmitted: (query) {
        _updateSearchQuery(query);
      },
    );
  }

  List<Widget> _buildActionsFromAppBar() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        )
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      PopupMenuButton(
        onSelected: (SelectedPopup result) {
          switch (result) {
            case SelectedPopup.stars:
              setState(() {
                _sortOrNot = SortOrNot.stars;
              });
              break;
            case SelectedPopup.repositories:
              break;
            //Ordenar por Repositorios
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<SelectedPopup>>[
          const PopupMenuItem(
            value: SelectedPopup.stars,
            child: Text(
              'Ordenar por Estrelas',
            ),
          ),
          const PopupMenuItem(
            value: SelectedPopup.repositories,
            child: Text(
              'Ordenar por Repositorio',
            ),
          ),
        ],
      )
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)?.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: _stopSearching),
    );

    setState(() {
      _isSearching = true;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      _updateSearchQuery("");
    });
  }

  Widget _createCardList(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemCount: snapshot.data['items'].length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 10.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 110,
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(snapshot.data['items'][index]['name']),
                        Text(
                            snapshot.data['items'][index]['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(snapshot.data['items'][index]['stargazers_count']
                                .toString()),
                            const Padding(padding: EdgeInsets.all(10)),
                            Text(snapshot.data['items'][index]['forks_count']
                                .toString())
                          ],
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
