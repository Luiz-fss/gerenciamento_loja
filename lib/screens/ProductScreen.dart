import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamentolojavirtual/blocs/ProductBloc.dart';
import 'package:gerenciamentolojavirtual/validators/ProductValidator.dart';
import 'package:gerenciamentolojavirtual/widgets/ImagesWidget.dart';
import 'package:gerenciamentolojavirtual/widgets/ProductSizes.dart';

class ProductScreen extends StatefulWidget {

  final String categoryId;
  final DocumentSnapshot product;



  ProductScreen({this.categoryId,this.product});

  @override
  _ProductScreenState createState() => _ProductScreenState(categoryId,product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator{
  final ProductBloc _productBloc;
  _ProductScreenState(String categoryId, DocumentSnapshot product):
        _productBloc = ProductBloc(categoryId: categoryId,product: product);

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    InputDecoration _buildDecoration(String label){
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey)
      );
    }

    final _fieldStayle = TextStyle(color: Colors.white,fontSize: 16);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
          stream: _productBloc.outCreated,
          initialData: false,
          builder: (context, snapshot) {
            return Text(
              snapshot.data ? "Editar produto" : "Criar produto"
            );
          }
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context,snapshot){
              if(snapshot.data){
                return StreamBuilder<bool>(
                    stream: _productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: snapshot.data ? null : (){
                          _productBloc.deleteProduct();
                          Navigator.of(context).pop();
                        },
                      );
                    }
                );
              }else{
                return Container();
              }
            },
          ),
          StreamBuilder<bool>(
            stream: _productBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.save),
                onPressed: snapshot.data ? null : saveProduct,
              );
            }
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
              stream: _productBloc.outData,
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container();
                return ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    Text("Imagem(s)",style: TextStyle(color: Colors.grey,fontSize: 12),),
                    ImagesWidget(
                      context: context,
                      initialValue: snapshot.data["images"],
                      onSaved: _productBloc.saveImages,
                      validator: validateImages,
                    ),
                    TextFormField(
                      initialValue: snapshot.data["title"],
                      style: _fieldStayle,
                      decoration: _buildDecoration("titulo"),
                      onSaved: _productBloc.saveTitle,
                      validator: validateTitle,
                    ),
                    TextFormField(
                      initialValue: snapshot.data["description"],
                      style: _fieldStayle,
                      maxLines: 6,
                      decoration: _buildDecoration("desc"),
                      onSaved: _productBloc.saveDescription,
                      validator: validateDescription,
                    ),
                    TextFormField(
                      initialValue: snapshot.data["price"]?.toString(),
                      style: _fieldStayle,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildDecoration("preco"),
                      onSaved: _productBloc.savePrice,
                      validator: validatePrice,
                    ),
                    SizedBox(height: 16,),
                    Text("Tamanhos",style: TextStyle(color: Colors.grey,fontSize: 12),),
                    ProdcutSizes(
                      context: context,
                      initialValue: snapshot.data["sizes"],
                      onSaved: _productBloc.saveSizes,
                      validator: (v){
                        if(v.isEmpty){
                          return "Adicione um tamanho";
                        }
                      },
                    )
                  ],
                );
              }
            ),
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ?Colors.black : Colors.transparent,
                  ),
                );
              }
          )
        ],
      ),
    );
  }

  void saveProduct()async{
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Salvando produto...",style: TextStyle(color: Colors.white),),
          duration: Duration(minutes: 1),
          backgroundColor: Colors.pinkAccent,
        )
      );
    }
    bool success = await _productBloc.saveProduct();
    _scaffoldKey.currentState.removeCurrentSnackBar();

    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(success ? "Produto salvo" : "Erro ao salvar produto",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.pinkAccent,
        )
    );
  }

}
