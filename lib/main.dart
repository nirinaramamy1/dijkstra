import 'dart:math';
import 'package:collection/collection.dart';
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
  final TextEditingController _edgeFrom = TextEditingController();
  final TextEditingController _edgeTo = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _server = TextEditingController();
  final TextEditingController _domains = TextEditingController();
  final TextEditingController _nodeUrls = TextEditingController();

  final Graph _graph = Graph();
  late Algorithm _builder;

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  // final _json = {
  //   "nodes": [
  //     {"id": '8.8.8.8', "url": ["facebook", "youtube"]},
  //     {"id": '8.8.8.6', "url": ["twitter", "google"]},
  //     {"id": '8.8.8.1', "url": ["amazon"]},
  //     {"id": '8.8.8.0', "url": ["google", "twitter"]},
  //     {"id": '8.8.8.5', "url": ["youtube"]},
  //     {"id": '8.8.8.4', "url": ["youtube", "google"]},
  //     {"id": '8.8.8.2', "url": ["google", "amazon"]},
  //     {"id": '8.8.8.3', "url": ["twitter", "youtube"]}
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
  var _urlLists = [];
  Map<String, List<String>> _jsonUrls = {};
  // void callbackNode(Map<String, List<dynamic>> json) {
  //   setState(() {
  //     _json = json;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _builder = FruchtermanReingoldAlgorithm(iterations: 1000);
  }

  @override
  Widget build(BuildContext context) {
    var originalNode = _json["nodes"];
    List<Map<String, dynamic>> uniqueNode = [];

    for (var item in originalNode!) {
      bool isDuplicate = false;
      for (var existingItem in uniqueNode) {
        if (existingItem['id'] == item['id']) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        uniqueNode.add(item);
      }
    }
    _json["nodes"] = uniqueNode;
    // print(_json);
    // print(_jsonUrls);
    // print(_urlLists);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sourceController,
                            decoration:
                                const InputDecoration(labelText: 'source'),
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          // if (path.isNotEmpty) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => PageScreen(
                          //         url: path.last.toString(),
                          //       ),
                          //     ),
                          //   );
                          // }
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
                          // final destination =
                          //     graphMap[_destinationController.text];
                          // var path =
                          //     dijkstra.shortestPath(source!, destination!);
                          List<Vertex<String>>? path;
                          List<List<Vertex<String>>> allPaths = [];
                          List<double> allPathsWeights = [];
                          int j = 0;
                          double min = 0;
                          // All paths

                          var _jsonTmp = _json["nodes"];
                          bool isPass = false;
                          // for (var destination in _jsonTmp!) {
                          for (int k = 0; k < _jsonTmp!.length; k++) {
                            if (_jsonTmp[k]["id"] == source.toString()) {
                              if (_jsonUrls[_jsonTmp[k]["id"]]!
                                  .contains(_destinationController.text)) {
                                print("Found it");
                                path = dijkstra.shortestPath(
                                    source!, graphMap[_jsonTmp[k]["id"]]!);
                                print(path);
                                allPaths.add(path);
                                // _jsonTmp = [];
                                print("JSON $_jsonTmp");
                                isPass = true;
                              }
                            }
                            if (_jsonTmp[k]["id"] != source.toString()) {
                              path = dijkstra.shortestPath(
                                  source!, graphMap[_jsonTmp[k]["id"]]!);
                              allPaths.add(path);
                              // print(
                              //     "Path destination ${destination["id"]} : $path");
                              // print("Urls ${_jsonUrls[destination["id"]]}");
                              if (_jsonUrls[_jsonTmp[k]["id"]]!
                                  .contains(_destinationController.text)) {
                                // print("Ok");
                                print(
                                    "Path destination ${_jsonTmp[k]["id"]} : $path");
                                String fromTo, toFrom;
                                List<String> fromToTofrom = [];
                                for (int i = 0;
                                    i < _json["edges"]!.length;
                                    i++) {
                                  fromToTofrom.add(
                                      "${_json["edges"]![i]["to"]}${_json["edges"]![i]["from"]}");
                                  fromToTofrom.add(
                                      "${_json["edges"]![i]["from"]}${_json["edges"]![i]["to"]}");
                                }
                                double pathWeights = 0.0;
                                for (int i = 1; i < path.length; i++) {
                                  fromTo = "${path[i - 1]}${path[i]}";
                                  toFrom = "${path[i]}${path[i - 1]}";
                                  if (fromToTofrom.contains(fromTo) ||
                                      fromToTofrom.contains(toFrom)) {
                                    print("Oui");
                                    print(_json["weights"]![j]["weight"]);
                                    pathWeights +=
                                        _json["weights"]![j]["weight"];
                                  }
                                }
                                allPathsWeights.add(pathWeights);
                              }
                              j++;
                            }
                            print("JSON $_jsonTmp");
                            if (isPass) {
                              k = _jsonTmp.length;
                              for (var p in allPaths) {
                                if (p.length == 1) {
                                  allPaths = [p];
                                }
                              }
                            }
                          }
                          print(allPathsWeights);
                          print(allPaths);

                          if (allPathsWeights.isNotEmpty) {
                            min = allPathsWeights.min;
                            path = allPaths[allPathsWeights.indexOf(min)];
                          }
                          print(path);

                          // print(source);
                          // print(destination);
                          // print(path);
                          List<String> pathToGo = [];
                          for (int i = 1; i < path!.length; i++) {
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
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 5,
          ),
          Expanded(
            child: Row(
              // child: Column(
              children: [
                const VerticalDivider(
                  width: 5,
                ),
                Expanded(
                  flex: 2,
                  child: RepaintBoundary(
                    key: _printKey,
                    child: Container(
                      color: Colors.red,
                      width: double.infinity,
                      height: double.infinity,
                      child: GraphClusterViewPage(
                        graph: _graph,
                        builder: _builder,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _edgeFrom,
                              decoration:
                                  const InputDecoration(labelText: 'From'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _edgeTo,
                              decoration:
                                  const InputDecoration(labelText: 'To'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _weight,
                              decoration:
                                  const InputDecoration(labelText: 'Weight'),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_json["edges"]!.contains({
                                  "from": _edgeFrom.text,
                                  "to": _edgeTo.text
                                }) &&
                                !_json["edges"]!.contains({
                                  "from": _edgeTo.text,
                                  "to": _edgeFrom.text
                                })) {
                              if (_edgeFrom.text.isNotEmpty &&
                                  _edgeTo.text.isNotEmpty) {
                                _json["edges"]?.add({
                                  "from": _edgeFrom.text,
                                  "to": _edgeTo.text
                                });
                                if (!_json["nodes"]!
                                    .contains({"id": _edgeFrom.text})) {
                                  if (_edgeFrom.text.isNotEmpty) {
                                    _json["nodes"]?.add({"id": _edgeFrom.text});
                                  }
                                }
                                if (!_json["nodes"]!
                                    .contains({"id": _edgeTo.text})) {
                                  if (_edgeTo.text.isNotEmpty) {
                                    _json["nodes"]?.add({"id": _edgeTo.text});
                                  }
                                }
                              }
                            }
                            if (_weight.text.isNotEmpty) {
                              _json["weights"]
                                  ?.add({"weight": double.parse(_weight.text)});
                            }
                            setState(() {
                              _json = _json;
                              _addServer();
                              _edgeFrom.text = '';
                              _edgeTo.text = '';
                              _weight.text = '';
                            });
                          },
                          child: const Text('Save edge'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text("Node")),
                      TextField(
                        controller: _server,
                        decoration: const InputDecoration(labelText: 'Server'),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text("Urls")),
                      TextField(
                        controller: _domains,
                        decoration: const InputDecoration(labelText: 'Domains'),
                      ),
                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         if (_jsonUrls[_server.text]!.isNotEmpty) {
                      //           _jsonUrls[_server.text]!
                      //               .addAll(_domains.text.split(","));
                      //         } else {
                      //           _jsonUrls[_server.text] = [];
                      //           _jsonUrls[_server.text]!
                      //               .addAll(_domains.text.split(","));
                      //         }
                      //         _server.text = '';
                      //         _domains.text = '';
                      //       });
                      //     },
                      //     child: const Text('Save url'),
                      //   ),
                      // ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Ensure _jsonUrls[_server.text] is not null before adding elements
                            if (_jsonUrls.containsKey(_server.text)) {
                              var urls = _jsonUrls[_server.text];
                              if (urls != null && urls.isNotEmpty) {
                                urls.addAll(_domains.text.split(","));
                              } else {
                                urls = [];
                                urls.addAll(_domains.text.split(","));
                              }
                              _jsonUrls[_server.text] = urls;
                            } else {
                              // Initialize _jsonUrls[_server.text] if it doesn't exist
                              _jsonUrls[_server.text] = [];
                              _jsonUrls[_server.text]!
                                  .addAll(_domains.text.split(","));
                            }
                            _server.text = '';
                            _domains.text = '';
                          },
                          child: const Text('Save url'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text("Urls lists")),
                      TextField(
                        controller: _nodeUrls,
                        decoration: const InputDecoration(labelText: 'Node'),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_nodeUrls.text.isEmpty) {
                                _urlLists = [''];
                              } else {
                                _urlLists = _jsonUrls[_nodeUrls.text]!;
                              }
                            });
                          },
                          child: const Text('View'),
                        ),
                      ),
                      Column(
                        children: List.generate(
                          _urlLists.length,
                          (index) => Text(_urlLists[index]),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printScreen,
          ),
          // IconButton(
          //   onPressed: () async {
          //     final result = await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => CreateServer(
          //           callback: callbackNode,
          //           json: _json,
          //         ),
          //       ),
          //     );
          //     if (result == null) {
          //       setState(() {
          //         _addServer();
          //       });
          //     }
          //   },
          //   icon: const Icon(Icons.settings),
          // ),
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
