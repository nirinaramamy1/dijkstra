import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class GraphClusterViewPage extends StatefulWidget {
  const GraphClusterViewPage({
    super.key,
    required this.graph,
    required this.builder,
  });
  final Graph graph;
  final Algorithm builder;

  @override
  State<GraphClusterViewPage> createState() => _GraphClusterViewPageState();
}

class _GraphClusterViewPageState extends State<GraphClusterViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(8),
              minScale: 0.001,
              maxScale: 100,
              child: GraphView(
                graph: widget.graph,
                algorithm: widget.builder,
                paint: Paint()
                  ..color = Colors.green
                  ..strokeWidth = 4
                  ..style = PaintingStyle.fill,
                builder: (Node node) {
                  // // I can decide what widget should be shown here based on the id
                  var a = node.key!.value as String?;
                  // if (a == '2') {
                  //   return rectangWidget(a);
                  // }
                  return rectangWidget(a);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int n = 8;
  Random r = Random();

  Widget rectangWidget(String? ip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        // borderRadius: BorderRadius.circular(4),
        // boxShadow: const [
        //   BoxShadow(color: Colors.blue, spreadRadius: 1),
        // ],
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
            'assets/images/serveur3.png',
          ),
        ),
      ),
      child: Text(
        '$ip',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
