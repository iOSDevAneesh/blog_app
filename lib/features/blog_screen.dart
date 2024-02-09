import 'package:blog_app/features/auth_screen/login_screen.dart';
import 'package:blog_app/features/create_blog_screen.dart';
import 'package:blog_app/services/cruds_method.dart';
import 'package:blog_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CrudMethods crudMethods = CrudMethods();
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 10;
  bool _loading = false;
  bool _hasMoreData = true;
  final List<DocumentSnapshot> _data = [];

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print('Logout Error: $e');
      CustomErrorDialog.show(context, "Logout Error", e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!_loading && _hasMoreData) {
      setState(() => _loading = true);
      QuerySnapshot querySnapshot;
      if (_data.isNotEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('blogs')
            .startAfterDocument(_data.last)
            .limit(_perPage)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('blogs')
            .limit(_perPage)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _data.addAll(querySnapshot.docs);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _hasMoreData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "blog",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
            Text(
              "App",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 20),
            )
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: FloatingActionButton(
            elevation: 1,
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBlogScreen(),
                ),
              ).then((value) {
                if (value == true) {
                  setState(() {
                    _data.clear();
                    _fetchData();
                  });
                }
              });
            },
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_circle_outline_outlined,
              color: Colors.blue,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _data.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _data.length) {
            var document = _data[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      document['imageUrl'],
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        document['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document['authorName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        document['desc'],
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return _loading
                ? const Center(child: CircularProgressIndicator())
                : Container();
          }
        },
      ),
    );
  }
}
