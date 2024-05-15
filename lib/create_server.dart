// import 'package:flutter/material.dart';

// class CreateServer extends StatefulWidget {
//   const CreateServer({super.key, required this.callback, required this.json});
//   final Map<String, List<dynamic>> json;
//   final Function(Map<String, List<dynamic>>) callback;

//   @override
//   State<CreateServer> createState() => _CreateServerState();
// }

// class _CreateServerState extends State<CreateServer> {
//   final TextEditingController _edgeFrom = TextEditingController();
//   final TextEditingController _edgeTo = TextEditingController();
//   final TextEditingController _weight = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create the graph'),
//       ),
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _edgeFrom,
//                   decoration: const InputDecoration(labelText: 'From'),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: _edgeTo,
//                   decoration: const InputDecoration(labelText: 'To'),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: _weight,
//                   decoration: const InputDecoration(labelText: 'Weight'),
//                 ),
//               ),
//             ],
//           ),
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 if (!widget.json["nodes"]!.contains({"id": _edgeFrom.text})) {
//                   widget.json["nodes"]?.add({"id": _edgeFrom.text});
//                 }
//                 if (!widget.json["nodes"]!.contains({"id": _edgeTo.text})) {
//                   widget.json["nodes"]?.add({"id": _edgeTo.text});
//                 }
//                 if (!widget.json["edges"]!.contains(
//                         {"from": _edgeFrom.text, "to": _edgeTo.text}) &&
//                     !widget.json["edges"]!.contains(
//                         {"from": _edgeTo.text, "to": _edgeFrom.text})) {
//                   widget.json["edges"]
//                       ?.add({"from": _edgeFrom.text, "to": _edgeTo.text});
//                   widget.json["weights"]
//                       ?.add({"weight": double.parse(_weight.text)});
//                 }
//                 widget.callback(widget.json);
//                 Navigator.pop(context);
//               },
//               child: const Text('Save!'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
