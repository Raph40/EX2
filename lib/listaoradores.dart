import 'package:exercicioavaliacao2/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class listaoradores extends StatelessWidget {
  const listaoradores({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: listaPage(),
    );
  }
}

class listaPage extends StatefulWidget {
  const listaPage({super.key});

  @override
  State<listaPage> createState() => _listaPageState();
}

class _listaPageState extends State<listaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para buscar os utilizadores da base de dados Firestore
  Stream<List<Map<String, dynamic>>> _getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oradores do Evento'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              bool confirmar = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmar Saída'),
                    content: Text('Tem a certeza que deseja terminar a sessão?', style: TextStyle(fontSize: 16)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Cancela a saída
                        },
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirma a saída
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => loginScreen()),
                          );
                        },
                        child: Text('Sair'),
                      ),
                    ],
                  );
                },
              );

              if (confirmar == true) {
                await FirebaseAuth.instance.signOut(); // Termina a sessão
                Navigator.of(context).pushReplacementNamed('/login'); // Redireciona para a página de login
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Não há utilizadores registados.'));
          }

          var users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              return Slidable(
                key: ValueKey(user['id']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        bool confirmar = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmar Eliminação'),
                              content: Text('Tem a certeza que deseja eliminar este orador? Esta ação não pode ser desfeita.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false); // Cancela a ação
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true); // Confirma a ação
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar == true) {
                          await _firestore.collection('users').doc(user['id']).delete();

                          try {
                            if (user['foto'] != null && user['foto'].isNotEmpty) {
                              Reference fotoRef = FirebaseStorage.instance.refFromURL(user['foto']);

                              await fotoRef.delete();
                            }
                          } catch (e) {
                            print('Erro ao apagar a imagem do Storage: $e');
                          }

                          User? currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser != null && currentUser.uid == user['id']) {
                            await currentUser.delete();
                          }
                        }
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Eliminar',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        bool confirmar = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmar Eliminação'),
                              content: Text('Tem a certeza que deseja eliminar este orador? Esta ação não pode ser desfeita.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false); // Cancela a ação
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true); // Confirma a ação
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar == true) {
                          await _firestore.collection('users').doc(user['id']).delete();

                          try {
                            if (user['foto'] != null && user['foto'].isNotEmpty) {
                              Reference fotoRef = FirebaseStorage.instance.refFromURL(user['foto']);

                              await fotoRef.delete();
                            }
                          } catch (e) {
                            print('Erro ao apagar a imagem do Storage: $e');
                          }

                          User? currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser != null && currentUser.uid == user['id']) {
                            await currentUser.delete();
                          }
                        }
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Eliminar',
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['foto'] != null && user['foto'].isNotEmpty
                          ? NetworkImage(user['foto'])
                          : AssetImage('assets/placeholder.png') as ImageProvider,
                    ),
                    title: Text(user['nome']),
                    onTap: () {
                      // Mostra um popup com as informações do utilizador
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(user['nome']),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(user['foto']),
                                  SizedBox(height: 16),
                                  Text('Email: ${user['email']}',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text('Telefone: ${user['telefone']}',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text('Nota Biográfica: ${user['nota biografica']}',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fecha o popup
                                },
                                child: Text('Fechar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
