import 'package:flutter/material.dart';
import 'gamescreen.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.cyan,Colors.purple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text("Tic Tac Toe",style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),)),
            SizedBox(height: 50,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GameScreen(isSinglePlayer:false)));

            },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15
                    ),
                    backgroundColor: Colors.white
                ),
                child: Text("Two Player",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GameScreen(isSinglePlayer:true)));
            },
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15
                    ),
                    backgroundColor: Colors.white
                ),

                child: Text("Player Vs Computer",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Developed By Manohar45",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
