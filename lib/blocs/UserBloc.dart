import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase{


  Firestore _firestore = Firestore.instance;

  //controlador da lista de usuarios
  final _usersController = BehaviorSubject<List>();

  //saida
  Stream<List> get outUser => _usersController.stream;

  //mapa para a coleção de usuarios
  //mapa vai passar o uid e receber em um mapa os dados do usuario
  Map<String,Map<String,dynamic>> _users = {};

  UserBloc(){
    _addUsersListeners();
  }

  void onChangedSearch(String search){
    if(search.trim().isEmpty){
      _usersController.add(_users.values.toList());
    }else{
      _usersController.add(_filter(search.trim()));
    }
  }

  List<Map<String,dynamic>>_filter (String search){
    List<Map<String,dynamic>> filteredUsers = List.from(_users.values.toList());
    filteredUsers.retainWhere((user){
      return user["name"].toUpperCase().contains(search.toUpperCase());
    });
    return filteredUsers;
  }

  _addUsersListeners(){
    //adciona o listener
    _firestore.collection("users").snapshots().listen((snapshot){
      snapshot.documentChanges.forEach((change){
        //função para pegar as mudanças
        String uid = change.document.documentID;

        //sabendo qual mudança foi feita
        switch(change.type){
          case DocumentChangeType.added:
            _users[uid] = change.document.data;
            _subscribeToOrder(uid);
            break;
          case DocumentChangeType.modified:
          //ao ter modificação, coloca as change no mapa de usuario
            _users[uid].addAll(change.document.data);
            _usersController.add(_users.values.toList());
            break;
          case DocumentChangeType.removed:
            _users.remove(uid);
            _unsubscribeToOrders(uid);
            _usersController.add(_users.values.toList());
            break;

        }
      });
    });
  }

  void _subscribeToOrder(String uid){
    //_users necessario para caso algo seja deletado, o listener tbm seja
    //sem isso teriamos listeners para coisas que não existem mais
    _users[uid]["subscription"] = _firestore.collection("users").document(uid).collection("orders").snapshots()
        .listen((orders)async{
      //quantidade de orders do usuario
      int numOrders = orders.documents.length;
      double money = 0.0;

      //para cada documento in orders.documents
      for(DocumentSnapshot d in orders.documents){
        //para cada pedido dentro do usuario vamos acesssar a coleção orders
        DocumentSnapshot order = await _firestore.collection("orders").document(d.documentID).get();
        //caso o pedido seja excluido dará prblema, por isso  o if para corrigir
        if(order.data == null){
          continue;
        }
        money += order.data["totalPrice"];
      }
      _users[uid].addAll(
          {
            "money" : money,
            "orders" : numOrders
          }
      );
      //values para pegar somentes os valores do mapa sem o uid
      //uid é o primeiro map
      _usersController.add(_users.values.toList());
    });
  }

  Map<String,dynamic> getUser(String uid){
    return _users[uid];
  }

  void _unsubscribeToOrders(String uid){
    _users[uid]["subscription"].cancel();
  }


  @override
  void dispose() {
    // TODO: implement dispose


    _usersController.close();
  }

}