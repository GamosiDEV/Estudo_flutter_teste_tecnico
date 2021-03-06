import 'package:estudo_de_teste_tecnico/ViewModel/Request.dart';
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

  int _setPage = 1;
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
              future:
                  request.getRepositories(_searchQuery, _sortOrNot, _setPage),
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
            _clearPage();
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
                _clearPage();
                _sortOrNot = SortOrNot.stars;
              });
              break;
            case SelectedPopup.repositories:
              setState(() {
                _clearPage();
                _sortOrNot = SortOrNot.repositories;
              });
              //_sortOrNot = SortOrNot.notSort;
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
      _clearPage();
      _isSearching = true;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _clearPage();
      _searchQuery = query;
    });
  }

  void _stopSearching() {
    setState(() {
      _clearPage();
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      _updateSearchQuery("");
    });
  }

  void _clearPage() {
    _setPage = 1;
  }

  void _nextPage() {
    setState(() {
      _setPage++;
    });
  }

  Widget _createCardList(BuildContext context, AsyncSnapshot snapshot) {
    List list = snapshot.data['items'].toList();
    switch (_sortOrNot) {
      case SortOrNot.repositories:
        list.sort((a, b) {
          return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
        });
        list.forEach((element) {
          print(element['name']);
        });
        break;
      default:
        break;
    }
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemCount: list.length < 29 ? list.length : list.length+1  ,
      itemBuilder: (context, index) {
        if (index == list.length && index == 30) {
          return TextButton(
            onPressed: _nextPage,
            child: const Text(
              'Carregar Mais',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            style:
                TextButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
          );
        } else {
          return Card(
            elevation: 10.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 140.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            list[index]['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          Divider(),
                          Text(
                            list[index]['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Icon(Icons.star)),
                              Flexible(
                                flex: 1,
                                child: Text(
                                    list[index]['stargazers_count'].toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Divider(),
                              Flexible(child: Icon(Icons.account_tree)),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  list[index]['forks_count'].toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: ClipOval(
                              child: SizedBox.fromSize(
                                size: Size.fromRadius(32), // Image radius
                                child: Image.network(
                                  list[index]['owner']['avatar_url'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Flexible(
                            flex: 1,
                            child: Text(
                              list[index]['owner']['login'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
