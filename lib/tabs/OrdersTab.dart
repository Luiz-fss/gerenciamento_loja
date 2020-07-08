import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamentolojavirtual/blocs/OrdersBloc.dart';
import 'package:gerenciamentolojavirtual/widgets/OrderTile.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _ordersBloc = BlocProvider.of<OrdersBloc>(context);


    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<Object>(
        stream: _ordersBloc.outOrders,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
              ),
            );
          }else if (snapshot.data == 0){
            return Center(
              child: Text("Nenhum pedido encontrado",
              style: TextStyle(
                color: Colors.pinkAccent
              ),)
            );
          }
          return ListView.builder(
              itemCount: snapshot.data,
              itemBuilder: (context,index){
                return OrderTile(snapshot.data);
              }
          );
        }
      )
    );
  }
}
