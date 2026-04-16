import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  const GameScreen({super.key,required this.isSinglePlayer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<List<String>>board;
  late bool xturn;
  late bool gameOver;
  late String winner;
  bool isComputerThinking=false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    initializegame();
    _animationController=AnimationController(vsync: this,duration: Duration(milliseconds: 500),);
    _scaleAnimation=Tween<double>(begin: 0.0 ,end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

  }
  @override
  void dispose() {
    _animationController.dispose();
    // TODO: implement dispose
    super.dispose();

  }
  void initializegame(){
    board=List.generate(3, (_)=>List.filled(3, ''));
    xturn=true;
    gameOver=false;
    winner='';
    isComputerThinking=false;

  }
  void showgameoverdailogbox(){
    _animationController.forward(from: 0.0);
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ScaleTransition(scale: _scaleAnimation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: winner=='Draw'?Colors.orange.shade100:winner=="X"?Colors.blue.shade100:Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),

                        child: Icon(winner=="Draw"?
                        Icons.balance:
                        winner=="X"?
                        Icons.close:
                        Icons.circle_outlined,
                          size: 60,
                          color:  winner=="Draw"?
                          Colors.orange:
                          winner=="X"?
                          Colors.blue:
                          Colors.pink,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        winner=="Draw"?"Game Draw!":winner=="X" ?widget.isSinglePlayer ? "You Won" : "Player X Wins":widget.isSinglePlayer ? "Computer Wins" : "Player O Wins",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: winner=="Draw"?Colors.orange:winner=="X"?Colors.blue:Colors.pink
                        ),

                      ),
                      SizedBox(height: 20,),
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                )
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                              setState(() {
                                initializegame();
                              });
                            },
                            child: Text("Play Again",style: TextStyle(
                                fontSize: 16,
                                color: Colors.black
                            ),),
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                )
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                              Navigator.pop(context);

                            },
                            child: Text("Main Menu",style: TextStyle(
                                fontSize: 16,
                                color: Colors.white
                            ),),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
  void makemove(int row,int col){
    if(board[row][col]!=''|| gameOver||isComputerThinking) return;
    setState(() {
      board[row][col]=xturn?'X':'O';
      checkwinner(row, col);
      xturn=!xturn;

      if (!gameOver && widget.isSinglePlayer && !xturn) {
        setState(() {
          isComputerThinking = true; // Update the UI to show the thinking state
        });
        Timer(Duration(seconds: 1), () {
          if (!mounted) return;
          computerMove();
        });
      }

    });
  }

  void computerMove(){
    for(int i =0; i<3;i++){
      for(int j=0;j<3;j++){
        if(board[i][j]==''){
          board[i][j]="O";
          if(checkwinningMove(i,j,'O')){
            setState(() {
              checkwinner(i,j);
              xturn=!xturn;
              isComputerThinking=false;

            });
            return;
          }
          board[i][j]='';
        }
      }
    }
    for(int i =0; i<3;i++){
      for(int j=0;j<3;j++){
        if(board[i][j]==''){
          board[i][j]="X";
          if(checkwinningMove(i,j,'X')){
            setState(() {
              board[i][j]='O';
              checkwinner(i,j);
              xturn=!xturn;
              isComputerThinking=false;
            });return;
          }
          board[i][j]='';
        }
      }
    }
    List<List<int>>emptyCells=[];
    for(int i = 0;i < 3;i++){
      for(int j = 0 ;j<3;j++){
        if(board[i][j]==''){
          emptyCells.add([i,j]);

        }
      }
    }
    if(emptyCells.isNotEmpty){
      final random=Random();
      final move=emptyCells[random.nextInt(emptyCells.length)];
      setState(() {
        board[move[0]][move[1]]='O';
        checkwinner(move[0],move[1]);
        xturn=!xturn;
        isComputerThinking=false;
      });
    }
  }
  bool checkwinningMove(int row,int col,String player){
    // rowman
    if(board[row].every((cell)=>cell==player)) return true;
    // colman
    if(board.every((row)=>row[col]==player)) return true;
    // diagonalsman
    if(row==col){
      if(List.generate(3, (i)=>board[i][i]).every((cell)=>cell==player)){
        return true;
      }
    }
    if(row+col==2){
      if(List.generate(3, (i)=>board[i][2-i]).every((cell)=>cell==player)){
        return true;
      }
    }
    return false;
  }
  void checkwinner(int row,int col){
    final currentPlayer=board[row][col];
    if(checkwinningMove(row, col, currentPlayer)){
      gameOver=true;
      winner=currentPlayer;
      showgameoverdailogbox();
      return;
    }

    if(board.every((row)=>row.every((cell)=>cell !=''))){
      gameOver=true;
      winner='Draw';
      showgameoverdailogbox();

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.cyan,Colors.purple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
            ),

          ),
          child: SafeArea(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(gameOver?winner=="Draw"?
              'Game Draw!':
              'player $winner Wins ':isComputerThinking?
              'Computer is thinking...':
              "player ${xturn?"X" :"O"}\'s Turn",style: TextStyle(fontSize: 32,fontWeight:
              FontWeight.bold,color:
              Colors.white),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
                    (crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    // mainAxisExtent: 10,
                    mainAxisSpacing: 10,
                  ),

                  itemCount: 9,
                  itemBuilder:(context,index){
                    final row =index~/3;
                    final col=index%3;
                    return GestureDetector(
                      onTap: ()=>makemove(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:  BorderRadius.circular(10),

                        ),
                        child: Center(
                          child: Text(
                            board[row][col],
                            style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: board[row][col]=='X'?Colors.blue:Colors.pink
                            ),
                          ),
                        ),
                      ),
                    );
                  } ,
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15
                        ),
                        backgroundColor: Colors.white
                    ),
                    onPressed: (){
                      setState(() {
                        initializegame();
                      });
                    },
                    child: Text("Restart Game"
                      ,style: TextStyle(
                          fontSize: 18,
                          color: Colors.black
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15
                        ),
                        backgroundColor: Colors.white
                    ),
                    onPressed: (){
                      Navigator.pop(context);},
                    child: Text("Main Menu"
                      ,style: TextStyle(
                          fontSize: 18,
                          color: Colors.black
                      ),
                    ),
                  )
                ],
              )
            ],
          ),

          ),
        )
    );
  }
}
