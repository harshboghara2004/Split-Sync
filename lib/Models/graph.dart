class Graph {
  final int vertices;
  late List<List<List<int>>> adjacencyList;

  Graph(this.vertices) {
    adjacencyList = List<List<List<int>>>.generate(vertices, (_) => []);
  }

  void addEdge(int from, int to, int weight) {
    adjacencyList[from].add([to, weight]);
  }

  void printGraph() {
    for (int i = 0; i < vertices; i++) {
      print("Vertex $i -> ${adjacencyList[i]}");
    }
  }
}