import 'dart:async';

class LoginValidators {
  //Stram Transformers: são objetos que vão transformar uma Stream em alguma outra coisa
  /*necessário passar a entrada e a saida para o StreamTransformer
  * nesse caso ambos serão String. E passar uma função ao fromHandlers*/
  final validateEmail = StreamTransformer<String,String>.fromHandlers(
    handleData: (email, sink){
      //função que verifica se o email é valido ou não
      if(email.contains("@")){
        //email valido, passar para a saida
        sink.add(email);
      }else{
        sink.addError("Insira um e-mail valido");
      }
    }
  );

  final validatePassword = StreamTransformer<String,String>.fromHandlers(
    handleData: (password,sink){
      if(password.length > 4){
        sink.add(password);
      }else{
        sink.addError("Senha inválida, deve conter pelo menos 4 caracteres");
      }
    }
  );

}