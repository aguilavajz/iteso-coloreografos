
def list_input(splitter):
    r = input()
    r = r.split(splitter)
    r = [int(x) for x in r]

    return r

def list_aristas(splitter):
    r = input()
    r = r.split(splitter)
    return r

def getNum(letra):
    return ord(letra)-ord('A')

def getLetra(num):
    return chr(num+ord('A'))

class Vertex():
    def __init__(self,value, degree) -> None:
        self.value = value
        self.degree = degree
        self.error = -1
        self.color = -1
        self.neighbors = []

    def setError(self, error):
        self.error = self.degree + error
    
    def setColor(self, color):
        self.color = color

    def __lt__(self, other):
        if isinstance(other, Vertex):
            if self.degree < other.degree:
                return True
            elif self.degree > other.degree:
                return False
            elif self.degree == other.degree:
                return self.error < other.error
    
    def __eq__(self,other):
        if isinstance(other, Vertex):
            return self.degree == other.degree and self.error == other.error

    def __str__(self) -> str:
        return f"{getLetra(self.value)}: grado: {self.degree} error: {self.error}"

        
def selectionSort(arr):
    for i in range(0, len(arr)-1):
        max  = i
        #find max
        for j in range(i + 1, len(arr)):
            if arr[j] > arr[max]:
                max = j
        if max != i:
            arr[i],arr[max] = arr[max], arr[i]


def createListVertex(graph):
    '''
    Crea lista de nodos
    '''

    vertex_list:list[Vertex] = []
    #Crea nodos con su grado
    for i in range(len(graph)):
        vertex_list.append(Vertex(i,sum(graph[i])))

    for v in vertex_list:
        error = 0
        for i in range(len(graph)):
            if graph[v.value][i] == True:
                v.neighbors.append(i)
                if vertex_list[i].degree >= v.degree:
                    error+=1
        v.setError(error)

    return vertex_list

###########################################################################################

def colorGraph(listOfColoredNodes, listOfColors, listOfNodes):
    for v in listOfNodes:
        for c in listOfColors:
            exists = False
                     
            for n in v.neighbors:
                if c == listOfColoredNodes[n]:
                    exists = True
                    break

            if exists == False: 
                listOfColoredNodes[v.value] = c
                break
        
        if exists == True: return False

    return True

Colores = int(input("Introduce la cantidad de Colores a usar: "))
color_list = [*range(1,Colores+1)]

colores = []
for i in range(len(color_list)):
    colores.append(input(f"Introduce color {i}: ").upper())

print("Introduce numero de nodos y aristas: ")
nodos, aristas = list_input(" ")
colored_vertex_list = [0] * nodos

#crea grafo
graph = [[False] * nodos for x in range(nodos)]
for i in range (aristas):
    node1, node2 = list_aristas(" ")
    node1 = getNum(node1)
    node2 = getNum(node2)
    graph[node1][node2] = True
    graph[node2][node1] = True 

#Crea lista the Nodos para ordenar
vlist = createListVertex(graph)
selectionSort(vlist)

isColored = colorGraph(colored_vertex_list, color_list, vlist)
if isColored :
    for i in range(len(colored_vertex_list)):
        print(f"V{getLetra(i)}: Color:{ colores[colored_vertex_list[i]-1]}")
else:
    print("No es posible colorear")
