import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamentolojavirtual/blocs/UserBloc.dart';

class OrderHearder extends StatelessWidget {

  final DocumentSnapshot order;

  OrderHearder(this.order);

  @override
  Widget build(BuildContext context) {

    final _userBloc = BlocProvider.of<UserBloc>(context);


    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("${_userBloc.getUser(order.data["clientId"]["name"])}"),
              Text("${_userBloc.getUser(order.data["clientId"]["address"])}")
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text("Produtos: R\$${order.data["productsPrice"].toString()}",style: TextStyle(fontWeight: FontWeight.w500),),
            Text("Total: R\$${order.data["totalPrice"].toString()}",style: TextStyle(fontWeight: FontWeight.w500),)
          ],
        )
      ],
    );
  }
}
