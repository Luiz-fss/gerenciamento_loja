import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerenciamentolojavirtual/blocs/OrdersBloc.dart';
import 'package:gerenciamentolojavirtual/blocs/UserBloc.dart';
import 'package:gerenciamentolojavirtual/tabs/OrdersTab.dart';
import 'package:gerenciamentolojavirtual/tabs/ProductTab.dart';
import 'package:gerenciamentolojavirtual/tabs/UsersTab.dart';
import 'package:gerenciamentolojavirtual/widgets/EditCategoryDialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController _pageController;
  int _page = 0;
  UserBloc _userBloc;
  OrdersBloc _ordersBloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _userBloc = UserBloc();
    _ordersBloc = OrdersBloc();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.pinkAccent,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: TextStyle(color: Colors.white)
          )
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (page){
            //faz o controle das passagens de tela do PageView
            _pageController.animateToPage(page, duration: Duration(microseconds: 500), curve: Curves.ease);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
              title: Text("Clientes")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                title: Text("Pedidos")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.list),
                title: Text("Produtos")
            )
          ],
        ),
      ),
      body: SafeArea(
        child: BlocProvider<UserBloc>(
          bloc: _userBloc,
          child: BlocProvider<OrdersBloc>(
            bloc: _ordersBloc,
            child: PageView(
              onPageChanged: (page){
                setState(() {
                  _page = page;
                });
              },
              controller: _pageController,
              children: <Widget>[
                UsersTab(),
                OrdersTab(),
                ProductTab()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }
  Widget _buildFloating(){
    switch(_page){
      case 0:
        return null;
      case 1:
        return SpeedDial(
          child: Icon(Icons.sort),
          backgroundColor: Colors.pinkAccent,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          //secundarios
          children: [
            SpeedDialChild(
              child: Icon(Icons.arrow_downward,color: Colors.pinkAccent,),
              backgroundColor: Colors.white,
              label: "Concluidos abaixo",
              labelStyle: TextStyle(
                fontSize: 14,
              ),
              onTap: (){
                _ordersBloc.setOrderCriteria(SortCriteria.READY_LAST);
              }
            ),
            SpeedDialChild(
                child: Icon(Icons.arrow_upward,color: Colors.pinkAccent,),
                backgroundColor: Colors.white,
                label: "Concluidos acima",
                labelStyle: TextStyle(
                  fontSize: 14,
                ),
                onTap: (){
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
                }
            )
          ],
        );
      case 2:
      return  FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
        onPressed: (){
          showDialog(context: context,builder: (context)=> EditCategoryDialog(

          ));
        },
      );
    }
  }
}

