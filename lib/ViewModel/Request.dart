import 'dart:convert';
import 'package:http/http.dart' as http;

enum SortOrNot { repositories , stars,  notSort }

class Request {

  Future<Map> getRepositories(
      String query, SortOrNot sortOrNot, {int offSet=1}) async {
    http.Response response;

    if (query == null || query == '') {
      query = '';
    } else {
      query = query+ '+';
    }

    switch (sortOrNot) {
      case SortOrNot.notSort:
      case SortOrNot.repositories:
        response = await http.get(
            'https://api.github.com/search/repositories?q=${query}language:Java&page=$offSet');
        break;
      case SortOrNot.stars:
        response = await http.get(
            'https://api.github.com/search/repositories?q=${query}language:Java&sort=stars&page=$offSet');
        break;
    }

    return json.decode(response.body);
  }
}
