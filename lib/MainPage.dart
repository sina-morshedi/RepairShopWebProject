import 'package:flutter/material.dart';
import 'app/config/routes/app_pages.dart';
import 'app/config/themes/app_theme.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage>{

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Project Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.basic,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
// class _MainPageState extends State<MainPage> {
//   final List<String> todos = [
//     'Aracı kontrol et',
//     'Parçaları sipariş et',
//     'Test sürüşü yap',
//   ];
//
//   final TextEditingController todoController = TextEditingController();
//
//   void addTodo() {
//     final text = todoController.text.trim();
//     if (text.isNotEmpty) {
//       setState(() {
//         todos.add(text);
//         todoController.clear();
//       });
//     }
//   }
//
//   void removeTodo(int index) {
//     setState(() {
//       todos.removeAt(index);
//     });
//   }
//
//   Widget buildSidebar() {
//     return Container(
//       width: 250,
//       color: const Color(0xFF1E3A8A),
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Image.asset(
//                   'assets/logo.png',
//                   fit: BoxFit.fitWidth,
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//           ...List.generate(4, (i) {
//             return ExpansionTile(
//               collapsedIconColor: Colors.white,
//               iconColor: Colors.white,
//               title: Row(
//                 children: [
//                   if (i == 0)
//                     const Icon(
//                       Icons.person,
//                       color: Colors.black,
//                       size: 24,
//                     ),
//                   const SizedBox(width: 8), // فاصله بین آیکون و متن
//                   Text(
//                     'Sidebar ${i + 1}',
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ],
//               ),
//
//               children: List.generate(4, (j) {
//                 return ListTile(
//                   title: Text(
//                     'Alt Menü ${j + 1}',
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                 );
//               }),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//
//   Widget buildDashboard() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             children: List.generate(3, (index) {
//               return Container(
//                 width: 200,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Kutu ${index + 1}',
//                       style:
//                       const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text('İçerik bilgisi'),
//                   ],
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Görev Listesi',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: todoController,
//                   decoration: InputDecoration(
//                     hintText: 'Yeni görev ekleyin...',
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton(
//                 onPressed: addTodo,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2563EB),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Icon(Icons.add, color: Colors.white),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: todos.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                   child: ListTile(
//                     title: Text(
//                       todos[index],
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => removeTodo(index),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isMobile = constraints.maxWidth < 600;
//         return Scaffold(
//           backgroundColor: const Color(0xFFF3F4F6),
//           body: Row(
//             children: [
//               if (!isMobile) buildSidebar(),
//               Expanded(
//                 child: buildDashboard(),
//               ),
//             ],
//           ),
//           drawer: isMobile ? Drawer(child: buildSidebar()) : null,
//         );
//       },
//     );
//   }
// }
