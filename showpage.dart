import 'dart:io';

import 'package:birddetection/login.dart';
import 'package:birddetection/view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
class Showpage extends StatefulWidget {
  const Showpage({Key? key}) : super(key: key);

  @override
  State<Showpage> createState() => _ShowpageState();
}

class _ShowpageState extends State<Showpage> {
  String srch="";
  final img='assets/prof.jpg';
  TextEditingController search=TextEditingController();
  ScrollController bar=ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.black,
        backgroundColor: Colors.black87,
        leading: const Padding(
          padding: EdgeInsets.fromLTRB(80, 0, 0, 0),
          child:Icon(Icons.person),
        ),
        title: const Text("Student Profile List"),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w900,fontSize: 20.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child:Column(
            children: [
              Container(
                height: 50,
                child:TextField(
                  controller: search,
                  onChanged: (val) => {
                    setState((){
                      srch=val;
                    })
                  },
                  cursorColor: Colors.black87,
                  decoration:InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical:10.0 ,horizontal:10.0 ),
                    hintText: "Search",


                    suffixIcon: Icon(Icons.search_sharp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ),
              SizedBox(height: 30,),

              SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("Login").snapshots(),
                  builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),
                      );
                    }
                    if(snapshot.hasData){
                      return  ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data=snapshot.data!.docs[index].data() as Map<String,dynamic>;
                          if(srch.isEmpty){
                            return studentCard(data);
                          }
                          if(data['name'].toString().toLowerCase().contains(srch.toLowerCase())||
                              data['roll_no'].toString().toLowerCase().contains(srch.toLowerCase())){
                            return studentCard(data);
                          }
                          return ColoredBox(color: Colors.white);

                        },
                      );
                    }
                    return Text("No Details to View", style: GoogleFonts.nunito(fontSize: 17,color:Colors.white ),);
                  },
                ),
              )

            ],
          ),

        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Select Image"),
        onPressed: (){
          showBottomSheet(context: context, builder: (context)=>Container(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  label: 'Camera',
                    onPressed: () async{
                  final img=await ImagePicker().pickImage(source: ImageSource.camera);
                  setState(() {

                  });
                }),
                SizedBox(width: 70,),
                FloatingActionButton.extended(onPressed: () async{
                  final img=await ImagePicker().pickImage(source: ImageSource.gallery);
                  setState(() {

                  });
                })
              ],
            ),
          ));
        },
        icon: Icon(Icons.person_add),
      ),
    );
  }

  Widget studentCard(Map<String,dynamic> doct) {

    return GestureDetector(
      onTap:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> viewpage(doct)));
      } ,
      child:Column(
          children:[
            Container(

              decoration: BoxDecoration(border: Border.all(width: 2.0),borderRadius: BorderRadius.circular(10.0)),
              child:
              ListTile(

                // decoration: BoxDecoration(
                //   color: Colors.black87,
                //
                //   borderRadius: BorderRadius.circular(8.0),
                // ) ,
                tileColor: Colors.white70,

                selected: true,
                title: Text(
                  doct['name'],
                  style:GoogleFonts.notoSansHanunoo(color: Colors.black,fontWeight:FontWeight.bold),
                  overflow: TextOverflow.fade,
                ),

                // decoration: UnderlineTabIndicator( insets: EdgeInsets.all(2.0)),
                leading:Container(
                  width: 90,
                  height: 90,
                  child:Row(
                    children: [
                      if(doct['ipath']=="")CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(img),
                      ),
                      if(doct['ipath']!="")CircleAvatar(
                        radius: 30,
                        backgroundImage: FileImage(File(doct['ipath'])),
                      ),


                    ],
                  ),
                ),
                trailing: IconButton(
                    icon:Icon(Icons.delete),
                    onPressed:(){
                      FirebaseFirestore.instance.collection('Login').doc(doct['docid']).delete();
                    }

                ),

              ),
            ),
          ]
      ),
    );
  }

}

