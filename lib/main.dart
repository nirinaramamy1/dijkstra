import 'package:flutter/material.dart';
import 'package:dijkstra/graph_screen.dart';
import 'package:dijkstra/graph.dart';
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  final Graph graph = Graph();
  late Algorithm builder;

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

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

  var json = {
    "nodes": [
      // {"id": 'A', "label": ''},
      // {"id": 'B', "label": ''},
      // {"id": 'C', "label": ''},
      // {"id": 'D', "label": ''},
      // {"id": 'E', "label": ''},
      // {"id": 'F', "label": ''},
      // {"id": 'G', "label": ''},
      // {"id": 'H', "label": ''}
      {"id": '8.8.8.8', "label": ''},
      {"id": '8.8.8.6', "label": ''},
      {"id": '8.8.8.1', "label": ''},
      {"id": '8.8.8.0', "label": ''},
      {"id": '8.8.8.5', "label": ''},
      {"id": '8.8.8.4', "label": ''},
      {"id": '8.8.8.2', "label": ''},
      {"id": '8.8.8.3', "label": ''}
    ],
    "edges": [
      // {"from": 'A', "to": 'B'},
      // {"from": 'A', "to": 'F'},
      // {"from": 'A', "to": 'G'},
      // {"from": 'G', "to": 'C'},
      // {"from": 'C', "to": 'B'},
      // {"from": 'C', "to": 'E'},
      // {"from": 'E', "to": 'B'},
      // {"from": 'E', "to": 'D'},
      // {"from": 'B', "to": 'F'},
      // {"from": 'H', "to": 'G'},
      // {"from": 'H', "to": 'F'}
      {"from": '8.8.8.8', "to": '8.8.8.6'},
      {"from": '8.8.8.8', "to": '8.8.8.4'},
      {"from": '8.8.8.8', "to": '8.8.8.2'},
      {"from": '8.8.8.2', "to": '8.8.8.1'},
      {"from": '8.8.8.1', "to": '8.8.8.6'},
      {"from": '8.8.8.1', "to": '8.8.8.5'},
      {"from": '8.8.8.5', "to": '8.8.8.6'},
      {"from": '8.8.8.5', "to": '8.8.8.0'},
      {"from": '8.8.8.6', "to": '8.8.8.4'},
      {"from": '8.8.8.3', "to": '8.8.8.2'},
      {"from": '8.8.8.3', "to": '8.8.8.4'}
    ],
    "weights": [
      {"weight": 8},
      {"weight": 9},
      {"weight": 1},
      {"weight": 3},
      {"weight": 3},
      {"weight": 1},
      {"weight": 1},
      {"weight": 2},
      {"weight": 3},
      {"weight": 5},
      {"weight": 2}
    ]
  };

  @override
  void initState() {
    super.initState();

    // json["nodes"]

    json["edges"]?.asMap().forEach((index, element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      var weight = json['weights']?[index]['weight'];
      graph.addEdge(
        Node.Id(fromNodeId),
        Node.Id(toNodeId),
        weight: double.parse(weight.toString()),
        paint: Paint()
          // ..style = PaintingStyle()
          ..color = Colors.black.withOpacity(0.5)
          ..strokeWidth = 2,
      );
    });

    // final a = Node.Id('192.168.1.15');
    // final b = Node.Id('8.8.8.6');
    // final c = Node.Id('8.8.8.1');
    // final d = Node.Id('8.8.8.0');
    // final e = Node.Id('8.8.8.5');
    // final f = Node.Id('8.8.8.4');
    // final g = Node.Id('8.8.8.2');
    // final h = Node.Id('8.8.8.3');

    // graph.addEdge(a, b, paint: Paint()..color = Colors.black);
    // graph.addEdge(a, f, paint: Paint()..color = Colors.black);
    // graph.addEdge(a, g, paint: Paint()..color = Colors.black);
    // graph.addEdge(g, c, paint: Paint()..color = Colors.black);
    // graph.addEdge(c, b, paint: Paint()..color = Colors.black);
    // graph.addEdge(c, e, paint: Paint()..color = Colors.black);
    // graph.addEdge(e, b, paint: Paint()..color = Colors.black);
    // graph.addEdge(e, d, paint: Paint()..color = Colors.black);
    // graph.addEdge(b, f, paint: Paint()..color = Colors.black);
    // graph.addEdge(h, g, paint: Paint()..color = Colors.black);
    // graph.addEdge(h, f, paint: Paint()..color = Colors.black);

    builder = FruchtermanReingoldAlgorithm(iterations: 1000);
  }

  @override
  Widget build(BuildContext context) {
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
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'source'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: destinationController,
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
                    // final a = graph.createVertex('192.168.1.15');
                    // final b = graph.createVertex('8.8.8.6');
                    // final c = graph.createVertex('8.8.8.1');
                    // final d = graph.createVertex('8.8.8.0');
                    // final e = graph.createVertex('8.8.8.5');
                    // final f = graph.createVertex('8.8.8.4');
                    // final g = graph.createVertex('8.8.8.2');
                    // final h = graph.createVertex('8.8.8.3');

                    json["nodes"]?.forEach((element) {
                      nodes.addAll({
                        '${element["id"]}':
                            graph.createVertex('${element["id"]}')
                      });
                    });

                    json["edges"]?.asMap().forEach((index, element) {
                      var fromNodeId = element['from'];
                      var toNodeId = element['to'];
                      var weight = json['weights']?[index]['weight'];
                      // var from =
                      //     graph.createVertex(Node.Id(fromNodeId).key?.value);
                      // var to = graph.createVertex(Node.Id(toNodeId).key?.value);
                      // var from = nodes[fromNodeId];
                      // var to = nodes[toNodeId];
                      graph.addEdge(nodes[fromNodeId]!, nodes[toNodeId]!,
                          weight: double.parse(weight.toString()),
                          edgeType: EdgeType.directed);
                      graph.addEdge(nodes[toNodeId]!, nodes[fromNodeId]!,
                          weight: double.parse(weight.toString()),
                          edgeType: EdgeType.directed);
                    });

                    // graph.addEdge(a, b, weight: 8, edgeType: EdgeType.directed);
                    // graph.addEdge(b, a, weight: 8, edgeType: EdgeType.directed);

                    // graph.addEdge(a, f, weight: 9, edgeType: EdgeType.directed);
                    // graph.addEdge(f, a, weight: 9, edgeType: EdgeType.directed);

                    // graph.addEdge(a, g, weight: 1, edgeType: EdgeType.directed);
                    // graph.addEdge(g, a, weight: 1, edgeType: EdgeType.directed);

                    // graph.addEdge(g, c, weight: 3, edgeType: EdgeType.directed);
                    // graph.addEdge(c, g, weight: 3, edgeType: EdgeType.directed);

                    // graph.addEdge(c, b, weight: 3, edgeType: EdgeType.directed);
                    // graph.addEdge(b, c, weight: 3, edgeType: EdgeType.directed);

                    // graph.addEdge(c, e, weight: 1, edgeType: EdgeType.directed);
                    // graph.addEdge(e, c, weight: 1, edgeType: EdgeType.directed);

                    // graph.addEdge(e, b, weight: 1, edgeType: EdgeType.directed);
                    // graph.addEdge(b, e, weight: 1, edgeType: EdgeType.directed);

                    // graph.addEdge(e, d, weight: 2, edgeType: EdgeType.directed);
                    // graph.addEdge(d, e, weight: 2, edgeType: EdgeType.directed);

                    // graph.addEdge(b, f, weight: 3, edgeType: EdgeType.directed);
                    // graph.addEdge(f, b, weight: 3, edgeType: EdgeType.directed);

                    // graph.addEdge(h, g, weight: 5, edgeType: EdgeType.directed);
                    // graph.addEdge(f, h, weight: 5, edgeType: EdgeType.directed);

                    // graph.addEdge(h, f, weight: 2, edgeType: EdgeType.directed);
                    // graph.addEdge(f, h, weight: 2, edgeType: EdgeType.directed);

                    Map<String, Vertex<String>> graphMap = {};
                    for (int i = 0; i < graph.vertices.length; i++) {
                      graphMap.addAll({
                        graph.vertices.elementAt(i).toString():
                            graph.vertices.elementAt(i)
                      });
                    }

                    final dijkstra = Dijkstra(graph);
                    final source = graphMap[sourceController.text];
                    final destination = graphMap[destinationController.text];
                    // final path = dijkstra.shortestPath(a, d);
                    final path = dijkstra.shortestPath(source!, destination!);
                    print(source);
                    print(destination);
                    print(path);
                    List<String> pathToGo = [];
                    for (int i = 1; i < path.length; i++) {
                      pathToGo.add(
                          '${path[i - 1].toString()}' '${path[i].toString()}');
                      pathToGo.add(
                          '${path[i].toString()}' '${path[i - 1].toString()}');
                    }
                    setState(() {
                      updateGraph(pathToGo);
                    });
                  } catch (e) {
                    print('error: $e');
                  }
                },
                child: const Text('Calculate Shortest Path'),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: RepaintBoundary(
              key: _printKey,
              child: GraphClusterViewPage(graph: graph, builder: builder),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _printScreen,
        child: const Icon(Icons.print),
      ),
    );
  }

  void updateGraph(List<String> path) {
    // final a = Node.Id('192.168.1.15');
    // final b = Node.Id('8.8.8.6');
    // final c = Node.Id('8.8.8.1');
    // final d = Node.Id('8.8.8.0');
    // final e = Node.Id('8.8.8.5');
    // final f = Node.Id('8.8.8.4');
    // final g = Node.Id('8.8.8.2');
    // final h = Node.Id('8.8.8.3');

    Paint paintToRed = Paint();
    Paint paintToBlack = Paint();

    paintToRed.color = Colors.red;
    paintToRed.strokeWidth = 2;
    paintToBlack.color = Colors.black.withOpacity(0.5);
    paintToBlack.strokeWidth = 2;

    json["edges"]?.forEach((element) {
      var fromNodeId = element['from'];
      var toNodeId = element['to'];
      graph.getEdgeBetween(Node.Id(fromNodeId), Node.Id(toNodeId))?.paint = [
        '${Node.Id(fromNodeId).key?.value}' '${Node.Id(toNodeId).key?.value}'
      ].every((element) => path.contains(element))
          ? paintToRed
          : paintToBlack;
    });
    // graph.getEdgeBetween(a, f)?.paint = ['${a.key?.value}' '${f.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(a, b)?.paint = ['${a.key?.value}' '${b.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(a, g)?.paint = ['${a.key?.value}' '${g.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(g, c)?.paint = ['${g.key?.value}' '${c.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(c, b)?.paint = ['${c.key?.value}' '${b.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(c, e)?.paint = ['${c.key?.value}' '${e.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(e, b)?.paint = ['${e.key?.value}' '${b.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(e, d)?.paint = ['${e.key?.value}' '${d.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(b, f)?.paint = ['${b.key?.value}' '${f.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(h, g)?.paint = ['${h.key?.value}' '${g.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
    // graph.getEdgeBetween(h, f)?.paint = ['${h.key?.value}' '${f.key?.value}']
    //         .every((element) => path.contains(element))
    //     ? paintToRed
    //     : paintToBlack;
  }
}
