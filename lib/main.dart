import 'dart:io';

import 'package:dijkstra/create_server.dart';
import 'package:dijkstra/page_screen.dart';
import 'package:flutter/material.dart';
import 'package:dijkstra/graph_screen.dart';
import 'package:dijkstra/graph.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:graphview/GraphView.dart';
import 'package:dijkstra/dijkstra.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Graph _graph = Graph();
  late Algorithm _builder;

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  // final _json = {
  //   "nodes": [
  //     {"id": '8.8.8.8'},
  //     {"id": '8.8.8.6'},
  //     {"id": '8.8.8.1'},
  //     {"id": '8.8.8.0'},
  //     {"id": '8.8.8.5'},
  //     {"id": '8.8.8.4'},
  //     {"id": '8.8.8.2'},
  //     {"id": '8.8.8.3'}
  //   ],
  //   "edges": [
  //     {"from": '8.8.8.8', "to": '8.8.8.6'},
  //     {"from": '8.8.8.8', "to": '8.8.8.4'},
  //     {"from": '8.8.8.8', "to": '8.8.8.2'},
  //     {"from": '8.8.8.2', "to": '8.8.8.1'},
  //     {"from": '8.8.8.1', "to": '8.8.8.6'},
  //     {"from": '8.8.8.1', "to": '8.8.8.5'},
  //     {"from": '8.8.8.5', "to": '8.8.8.6'},
  //     {"from": '8.8.8.5', "to": '8.8.8.0'},
  //     {"from": '8.8.8.6', "to": '8.8.8.4'},
  //     {"from": '8.8.8.3', "to": '8.8.8.2'},
  //     {"from": '8.8.8.3', "to": '8.8.8.4'}
  //   ],
  //   "weights": [
  //     {"weight": 8},
  //     {"weight": 9},
  //     {"weight": 1},
  //     {"weight": 3},
  //     {"weight": 3},
  //     {"weight": 1},
  //     {"weight": 1},
  //     {"weight": 2},
  //     {"weight": 3},
  //     {"weight": 5},
  //     {"weight": 2}
  //   ]
  // };
  var _json = {"nodes": [], "edges": [], "weights": []};

  void callbackNode(Map<String, List<dynamic>> json) {
    setState(() {
      _json = json;
    });
  }

  @override
  void initState() {
    super.initState();
    _builder = FruchtermanReingoldAlgorithm(iterations: 1000);
  }

  @override
  Widget build(BuildContext context) {
    print(_json);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      decoration: const InputDecoration(labelText: 'source'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      decoration:
                          const InputDecoration(labelText: 'destination'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    final graph = AdjacencyList<String>();
                    final nodes = <String, Vertex<String>>{};

                    _json["nodes"]?.forEach((element) {
                      nodes.addAll({
                        '${element["id"]}':
                            graph.createVertex('${element["id"]}')
                      });
                    });

                    _json["edges"]?.asMap().forEach((index, element) {
                      var fromNodeId = element['from'];
                      var toNodeId = element['to'];
                      var weight = _json['weights']?[index]['weight'];
                      graph.addEdge(nodes[fromNodeId]!, nodes[toNodeId]!,
                          weight: double.parse(weight.toString()),
                          edgeType: EdgeType.directed);
                      graph.addEdge(nodes[toNodeId]!, nodes[fromNodeId]!,
                          weight: double.parse(weight.toString()),
                          edgeType: EdgeType.directed);
                    });
                    Map<String, Vertex<String>> graphMap = {};
                    for (int i = 0; i < graph.vertices.length; i++) {
                      graphMap.addAll({
                        graph.vertices.elementAt(i).toString():
                            graph.vertices.elementAt(i)
                      });
                    }

                    final dijkstra = Dijkstra(graph);
                    final source = graphMap[_sourceController.text];
                    final destination = graphMap[_destinationController.text];
                    // final path = dijkstra.shortestPath(a, d);
                    final path = dijkstra.shortestPath(source!, destination!);
                    if (path.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageScreen(
                            url: path.last.toString(),
                          ),
                        ),
                      );
                    }
                    print(source);
                    print(destination);
                    print(path);
                    List<String> pathToGo = [];
                    for (int i = 1; i < path.length; i++) {
                      pathToGo.add('${path[i - 1].toString()}'
                          '${path[i].toString()}');
                      pathToGo.add('${path[i].toString()}'
                          '${path[i - 1].toString()}');
                    }
                    setState(() {
                      _updateGraph(pathToGo);
                    });
                  } catch (e) {
                    print('error: $e');
                  }
                },
                child: const Text("Calculate Shortest Path"),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: RepaintBoundary(
              key: _printKey,
              child: GraphClusterViewPage(graph: _graph, builder: _builder),
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printScreen,
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateServer(
                    callback: callbackNode,
                    json: _json,
                  ),
                ),
              );
              if (result == null) {
                setState(() {
                  _addServer();
                });
              }
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              await _resetGraph();
              if (_json["nodes"]!.isEmpty) {
                setState(() {
                  _addServer();
                });
              }
            },
            icon: const Icon(Icons.restart_alt),
          )
        ],
      ),
    );
  }

  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWrapper.fromKey(key: _printKey);

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  void _addServer() {
    _json["edges"]?.asMap().forEach((index, element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      var weight = _json['weights']?[index]['weight'];
      _graph.addEdge(
        Node.Id(fromNodeId),
        Node.Id(toNodeId),
        weight: double.parse(weight.toString()),
        paint: Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..strokeWidth = 2,
      );
    });
  }

  Future<void> _resetGraph() async {
    _json["nodes"] = [];
    _json["edges"] = [];
    _json["weights"] = [];
    Phoenix.rebirth(context);
  }

  void _updateGraph(List<String> path) {
    Paint paintToRed = Paint();
    Paint paintToBlack = Paint();

    paintToRed.color = Colors.red;
    paintToRed.strokeWidth = 2;
    paintToBlack.color = Colors.black.withOpacity(0.5);
    paintToBlack.strokeWidth = 2;

    _json["edges"]?.forEach((element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      _graph.getEdgeBetween(Node.Id(fromNodeId), Node.Id(toNodeId))?.paint = [
        '${Node.Id(fromNodeId).key?.value}' '${Node.Id(toNodeId).key?.value}'
      ].every((element) => path.contains(element))
          ? paintToRed
          : paintToBlack;
    });
  }
}
