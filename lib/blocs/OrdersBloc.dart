import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria {READY_FIRST, READY_LAST}

class OrdersBloc extends BlocBase{

  final _ordersController = BehaviorSubject<List>();

  List<DocumentSnapshot> _orders = [];

  SortCriteria _criteria;

  Firestore _firestore = Firestore.instance;

  Stream<List> get outOrders => _ordersController.stream;


  void _addOrdersListeners(){
    _firestore.collection("orders").snapshots().listen((snapshot){
      snapshot.documentChanges.forEach((change){
        String oid = change.document.documentID;
        switch(change.type){
          case DocumentChangeType.added:
            _orders.add(change.document);
            break;
          case DocumentChangeType.modified:
            _orders.removeWhere((order)=> order.documentID==oid);
            _orders.add(change.document);
            break;
          case DocumentChangeType.removed:
            _orders.removeWhere((order)=> order.documentID==oid);
            break;
        }
      });
      _sort();
    });
  }

  void setOrderCriteria(SortCriteria criteria){
    _criteria = criteria;
    _sort();
  }

  void _sort(){
    switch(_criteria){
      case SortCriteria.READY_FIRST:
        _orders.sort((a,b){
          int sa = a.data["status"];
          int sb = b.data["status"];
          if(sa < sb){
            return 1;
          }else if(sa > sb){
            return -1;
          }else{
            return 0;
          }
        });
        break;
      case SortCriteria.READY_LAST:
        _orders.sort((a,b){
          int sa = a.data["status"];
          int sb = b.data["status"];
          if(sa > sb){
            return 1;
          }else if(sa < sb){
            return -1;
          }else{
            return 0;
          }
        });
        break;
    }
    _ordersController.add(_orders);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _ordersController.close();
  }

}