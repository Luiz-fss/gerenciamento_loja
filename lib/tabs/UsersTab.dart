import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamentolojavirtual/blocs/UserBloc.dart';
import 'package:gerenciamentolojavirtual/widgets/UserTile.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _userBloc = BlocProvider.of<UserBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: TextField(
            onChanged: _userBloc.onChangedSearch,
            style: TextStyle(
              color: Colors.white
            ),
            decoration: InputDecoration(
              hintText: "Pesquisar",
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(Icons.search,color: Colors.white,),
              border: InputBorder.none
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List>(
            stream: _userBloc.outUser,
            builder: (context, snapshot) {

              if(!snapshot.hasData){
                return Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white,)),);
              }else if(snapshot.data.length == 0){
                return Center(
                  child: Text("Nenhum Usuario encontrado"),);
              }

              return ListView.separated(
                  itemBuilder: (context,index){
                    return UserTile(snapshot.data[index]);
                  },
                  separatorBuilder: (context,index){
                    return Divider();
                  },
                  itemCount: snapshot.data.length
              );
            }
          ),
        )
      ],
    );
  }
}
