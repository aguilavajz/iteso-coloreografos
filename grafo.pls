create or replace package grafo is

    function obtener_grado(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return number;

    function obtener_grado_error(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return number;

    function obtener_vecinos(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return varchar2;

    function obtener_color_nodo(
        p_nodo  nodos.id%type
    ) return grafo_colores.id%type;

    procedure colorear(
        p_grafo     grafos.id%type,
        p_colores   number,
        p_salida    in out varchar2
    );

    function obtener_color_name(
        p_color_id  grafo_colores.id%type
    ) return grafo_colores.nombre%type;

    function obtener_color_code(
        p_color_id  grafo_colores.id%type
    ) return grafo_colores.color%type;

end;