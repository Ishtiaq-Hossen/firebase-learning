import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'book.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final List<Book>bookList=[];

  @override
  void initState(){
    super.initState();
    // getBooks();
  }

  // void getBooks() async{
  //   await _firebaseFirestore.collection("books").get().then((event) {
  //     bookList.clear();
  //     for (QueryDocumentSnapshot doc in event.docs) {
  //       bookList.add(Book.fromJson(doc.id, doc.data() as Map<String, dynamic>));
  //       print("${doc.id} => ${doc.data()}");
  //     }
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Book App'),
    ),
      body: StreamBuilder(
        stream: _firebaseFirestore.collection('books').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
        if(snapshot.hasError){
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        bookList.clear();
        for (QueryDocumentSnapshot doc in snapshot.data?.docs ?? []) {
          bookList.add(Book.fromJson(doc.id, doc.data() as Map<String, dynamic>));
          print("${doc.id} => ${doc.data()}");
        }
          return ListView.separated(itemBuilder: (context,index)=>ListTile(
            title: Text(bookList[index].title),
            subtitle: Text(bookList[index].author),
            leading: Text(bookList[index].language),
            trailing: Text(bookList[index].publisher),

          ), separatorBuilder: (_, __)=>const Divider(), itemCount: bookList.length);
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Map<String, dynamic> newBook={
            'title':'MR 9 sdaf',
            'author':'Kazi Anwar',
            'language':'BN',
            'publisher':'Sheba Pub'
          };
          //adding new entry in cloud firestore
          _firebaseFirestore.collection('books').doc('new-book-2').set(newBook);
          //updating entry in cloud firestore
          //_firebaseFirestore.collection('books').doc('new-book-2').update(newBook);

          //deleting entry in cloud firestore
          //_firebaseFirestore.collection('books').doc('new-book-2').delete();
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
