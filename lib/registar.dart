import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'login.dart';

class registar extends StatelessWidget {
  const registar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}

class registarPage extends StatefulWidget {
  const registarPage({super.key});

  @override
  State<registarPage> createState() => _registarPageState();
}

class _registarPageState extends State<registarPage> {
  final chaveUnica = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();
  TextEditingController nome = TextEditingController();
  TextEditingController telefone = TextEditingController();
  TextEditingController notaBiografica = TextEditingController();

  File? selecionarFoto;

  // Método para escolher a imagem
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selecionarFoto = File(pickedImage.path); // Apenas suporta ficheiros locais
      });
    }
  }

  // Método para carregar a imagem para o Firebase Storage
  Future<String?> atualizarImagem(File image) async {
    try {
      String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.png';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(image);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // URL da imagem no Firebase Storage
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Método para registar o utilizador
  Future<void> _registerUser() async {
    if (chaveUnica.currentState!.validate()) {
      try {
        // Criar utilizador no Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: senha.text,
        );

        String uid = userCredential.user!.uid;

        // Fazer upload da imagem (se existir)
        String? imageUrl;
        if (selecionarFoto != null) {
          imageUrl = await atualizarImagem(selecionarFoto!);
        }

        // Guardar os dados no Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email.text,
          'nome': nome.text,
          'password': senha.text,
          'telefone': telefone.text,
          'nota biografica': notaBiografica.text,
          'foto': imageUrl ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilizador registado com sucesso!')),
        );
      } on FirebaseAuthException catch (e) {
        print('Erro de autenticação: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de autenticação: ${e.message}')),
        );
      } on FirebaseException catch (e) {
        print('Erro Firebase: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Firebase: ${e.message}')),
        );
      } catch (e) {
        print('Erro desconhecido: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro desconhecido: $e')),
        );
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => loginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: chaveUnica,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crie sua conta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: nome,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: telefone,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu número de telefone';
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: notaBiografica ,
                      decoration: InputDecoration(
                        labelText: 'Nota Biográfica',
                        prefixIcon: Icon(Icons.note_alt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua nota biográfica';
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: senha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    if (selecionarFoto != null)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        padding: EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selecionarFoto!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Nenhuma imagem selecionada',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Selecionar imagem',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      child: Text(
                        'Registar',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => loginScreen()),
                        );
                      },
                      child: Text(
                        'Já tem uma conta? Faça login',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
