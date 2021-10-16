create or replace package body grafo is

    function obtener_grado(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return number is
        l_count number;
    begin
        select count(1)
        into l_count
        from aristas
        where grafo_id = p_grafo
        and (from_node = p_nodo or to_node = p_nodo);

        return l_count;
    end obtener_grado;

    function obtener_grado_error(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return number is
        l_grado number := obtener_grado(p_grafo,p_nodo);
        l_grado_vecino number;
        l_error number;
    begin

        l_error := l_grado;
        for c in (select * from aristas where grafo_id = p_grafo and (from_node = p_nodo or to_node = p_nodo))
        loop
            if c.from_node = p_nodo then
                l_grado_vecino := obtener_grado(p_grafo,c.to_node);
            else
                l_grado_vecino := obtener_grado(p_grafo,c.from_node);
            end if;

            if l_grado_vecino >= l_grado then
                l_error := l_error + 1;
            end if;

        end loop;

        return l_error;

    end obtener_grado_error;

    function obtener_vecinos(
        p_grafo grafos.id%type,
        p_nodo  nodos.id%type
    ) return varchar2 is
        l_return varchar2(1000);
    begin
        for c in (select from_node, to_node from aristas where grafo_id = p_grafo and (from_node = p_nodo or to_node = p_nodo))
        loop
            if c.from_node = p_nodo then
                l_return := l_return || c.to_node || ':';
            else
                l_return := l_return || c.from_node || ':';
            end if;
        end loop;
        return rtrim(l_return,':');
    end obtener_vecinos;

    function obtener_color_nodo(
        p_nodo  nodos.id%type
    ) return grafo_colores.id%type is
        l_return grafo_colores.id%type;
    begin
        select color
        into l_return
        from nodos
        where id = p_nodo;

        return l_return;
    exception
        when no_data_found then
            return null;
    end obtener_color_nodo;

    procedure colorear(
        p_grafo     grafos.id%type,
        p_colores   number,
        p_salida    in out varchar2
    ) is
        l_exists        boolean;
        l_color_vecino  number;
    begin

        update nodos
        set color = null
        where grafo_id = p_grafo;

        for c in (SELECT * FROM NODOS
        WHERE GRAFO_ID = p_grafo
        order by grado desc, grado_error desc, nombre) loop

            apex_debug.log_message(
                c.nombre,
                true,
                1
            );

            for d in (select * from grafo_colores
                      where rownum <= p_colores
                      order by id) loop
                
                apex_debug.log_message(
                d.nombre,
                true,
                1
            );
                l_exists    := false;

                for e in (select column_value
                          from table(apex_string.split(obtener_vecinos(p_grafo,c.id),':')))
                loop
                    apex_debug.log_message(
                        e.column_value,
                        true,
                1
                    );
                    l_color_vecino  := obtener_color_nodo(e.column_value);
                    apex_debug.log_message(
                        obtener_color_name(l_color_vecino),
                        true,
                1
                    );
                    if d.id = l_color_vecino then
                        l_exists := true;
                        exit;
                    end if;
                    
                end loop;

                if not l_exists then
                    update nodos
                    set color = d.id
                    where grafo_id = p_grafo
                    and id = c.id;
                    exit;
                end if;

            end loop;

            if l_exists then
                p_salida := 'No se pudo colorear con '||p_colores || ' colores. El conflicto esta en el nodo '|| c.nombre;
                exit;
            end if;

        end loop;

        if not l_exists then
            p_salida := 'Grafo coloreado correctamente.';
        end if;

    end colorear;

    function obtener_color_name(
        p_color_id  grafo_colores.id%type
    ) return grafo_colores.nombre%type is
        l_return  grafo_colores.nombre%type;
    begin
        select nombre
        into l_return
        from grafo_colores
        where id = p_color_id;

        return l_return;
    exception
        when no_data_found then
            return null;
    end obtener_color_name;

    function obtener_color_code(
        p_color_id  grafo_colores.id%type
    ) return grafo_colores.color%type is
        l_return  grafo_colores.color%type;
    begin
        select color
        into l_return
        from grafo_colores
        where id = p_color_id;

        return l_return;
    exception
        when no_data_found then
            return null;
    end obtener_color_code;

end;