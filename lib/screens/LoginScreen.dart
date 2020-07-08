import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamentolojavirtual/blocs/BlocLogin.dart';
import 'package:gerenciamentolojavirtual/widgets/InputField.dart';
import 'package:gerenciamentolojavirtual/screens/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //declarando o bloc

  final _loginBlock = BlocLogin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //adicionar um listener para o outState
    _loginBlock.outState.listen((state){
      switch(state){
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomeScreen()));
          break;
        case LoginState.FAIL:
          showDialog(context: context, builder: (context)=> AlertDialog(
            title: Text("Erro"),
            content: Text("Você não possui os privilégios necessários"),
          ));
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _loginBlock.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      /*centralização dos conteudos foi feita através do Stack
      * a Stack vai se adaptar ao tamanho do SingleChild, e não vai corrigir
      * portanto antes do SingleChild foi passado um container*/
      body: StreamBuilder<LoginState>(
        initialData: LoginState.LOADING,
        stream: _loginBlock.outState,
        builder: (context, snapshot) {
          switch(snapshot.data){
            case LoginState.LOADING:
              return Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                Colors.pinkAccent),),);

            case LoginState.FAIL:
            case LoginState.SUCCESS:
            case LoginState.IDLE:
              return Stack(
                children: <Widget>[
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.store_mall_directory,
                            color: Colors.pinkAccent,
                            size: 170,
                          ),
                          InputField(
                            iconData: Icons.person_outline,
                            hint: "Usuário",
                            obscure: false,
                            stream: _loginBlock.outEmail,
                            onChanged: _loginBlock.changeEmail,
                          ),
                          InputField(
                            iconData: Icons.lock_outline,
                            hint: "Senha",
                            obscure: true,
                            stream: _loginBlock.outPassword,
                            onChanged: _loginBlock.changePassword,
                          ),
                          SizedBox(height: 32,),
                          StreamBuilder<bool>(
                            stream: _loginBlock.outSubmitValid,
                            builder: (context,snapshot){
                              return SizedBox(
                                height: 50,
                                child: RaisedButton(
                                  color: Colors.pinkAccent,
                                  child: Text(
                                    "Entrar",
                                  ),
                                  onPressed: snapshot.hasData ? _loginBlock.submit : null,
                                  textColor: Colors.white,
                                  disabledColor: Colors.pinkAccent.withAlpha(140),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
          }
          return Container();
        }
      ),
    );
  }
}
