/* Procedimientos */

/* 1. Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: Cliente inexistente, Actividad Inexistente, Actividad realizada en régimen de Todo Incluido y El cliente nunca ha realizado esa actividad.*/

---Procedimiento que, ingresando NIF del cliente comprueba si existe en la tabla personas.
CREATE OR REPLACE PROCEDURE ClienteInexistente (v_codcliente personas.NIF%type) IS
    v_cliente NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cliente
    FROM personas
    WHERE NIF=v_codcliente;
    IF v_cliente=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El cliente especificado no existe');
    END IF;
END;
/

---FALLO
EXEC ClienteInexistente ('12345678A');

---Funciona correctamente
EXEC ClienteInexistente ('54890865P');


---Procedimiento que, ingresando el código de la actividad comprueba si existe en la tabla actividades.
CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad actividades.codigo%type) IS
    v_actividad NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_actividad
    FROM actividades
    WHERE codigo=v_codactividad;
    IF v_actividad=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'La actividad especificada no existe');
    END IF;
END;
/

---FALLO
EXEC ActividadInexistente ('A003');

---Funciona correctamente
EXEC ActividadInexistente ('A001');

---Procedimiento que, ingresando codigo de actividad Y NIF de persona Comprueba si la actividad se realizó en régimen de todo incluido
CREATE OR REPLACE PROCEDURE ActividadTodoIncluido (v_codactividad Actividades.Codigo%type, v_codcliente Estancias.NIFCliente%type)
IS
    v_codreg    regimenes.CodigoRegimen%type;
BEGIN
    SELECT CodigoRegimen INTO v_codreg
    FROM Estancias
    WHERE NIFCliente=v_codcliente
    AND WHERE Codigo = (
        SELECT CodigoEstancia
        FROM ActividadesRealizadas
        WHERE CodigoActividad=v_codactividad
    );

END;
/
