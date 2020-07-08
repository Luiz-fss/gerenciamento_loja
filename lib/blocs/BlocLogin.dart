import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenciamentolojavirtual/validators/LoginValidators.dart';
import 'package:rxdart/rxdart.dart';

/*definindo os estado possiveis para a tela de login com o enum*/

enum LoginState {IDLE, LOADING, SUCCESS, FAIL}
 
/*"with para acessar a classe de validação que foi criada*/

class BlocLogin extends BlocBase with LoginValidators{



  /*Definindo o controlador que vai ficar responsavel por saber qual
  * o estado atual*/
  final _stateController = BehaviorSubject<LoginState>();

  //controlador do tipo String por ser o mesmo tipo do campo de email
  final _emailController = BehaviorSubject<String>();
  //controlador do tipo String por ser o mesmo tipo do campo de senha
  final _passwordController = BehaviorSubject<String>();

  /*declaração das Streams
  * Strams são onde os dados irão sair. Os dados vão entrar no "sink" do
  * controlador e vão sair na stream do controlador*/
  //Stream do tipo String, pois o contolador é do tipo String
  /*transform vai receber o que vamos passar aqui, e vai enviar para a class
  * de validação para validar o dado que estamos passando*/
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outState => _stateController.stream;
  Stream<bool> get outSubmitValid => Observable.combineLatest2(
      outEmail, outPassword, (a,b) =>true
  );

  /*quando enviar algo na função onChanged vai ser mandado para a entrada
  * da stream pelo sink*/

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  StreamSubscription _streamSubscription;

  BlocLogin(){
    //pegar as alterações do login do usuario
    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen((user)async{
      if(user != null){
        //verificando se os usuarios tem o privilégios de adm
        if(await verifyPrivileges(user)){
          _stateController.add(LoginState.SUCCESS);
        }else{
          //usuario existe mas não é adm
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.FAIL);
        }
      }else{
        _stateController.add(LoginState.IDLE);
      }
    });
  }

  //função de login
  void submit(){
    //recebendo os valores da Stream
    final email = _emailController.value;
    final password = _passwordController.value;
    //informando para a tela que estou carregando
    _stateController.add(LoginState.LOADING);
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
    ).catchError((){
      _stateController.add(LoginState.FAIL);
    });
  }

  Future<bool> verifyPrivileges(FirebaseUser user)async{
    return await Firestore.instance.collection("admins").document(user.uid).get()
        .then((doc){
      if(doc.data != null){
        return true;
      }else{
        return false;
      }
    }).catchError((e){
      return false;
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.close();
    _passwordController.close();
    _stateController.close();
    _streamSubscription.cancel();
  }


}