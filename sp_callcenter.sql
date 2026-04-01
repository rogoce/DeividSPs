-- Procedimiento que realiza la re-Distribucion de cartera del callcenter para tipo gestores
-- 
-- Creado    : 11/11/2008 - Autor: Armando Moreno M.
-- Modificado: 11/11/2008 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_callcenter;
CREATE PROCEDURE "informix".sp_callcenter(a_cod_cobrador char(3))
       RETURNING  int,char(100);

DEFINE _cod_cliente  CHAR(10);
DEFINE _cod_cobrador CHAR(3);
DEFINE _error        integer;
DEFINE _error_2      integer;
DEFINE _error_desc   char(50);
DEFINE _mensaje      char(100);

LET _cod_cliente  = null;
LET _cod_cobrador = null;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION
 
foreach

	 select cod_cliente
	   into _cod_cliente
	   from cascliente
	  where cod_cobrador = a_cod_cobrador

	 let _cod_cobrador = sp_cas006('001', 1);

	 update cascliente
	    set cod_cobrador = _cod_cobrador,
		    cant_call    = 0
      where cod_cliente  = _cod_cliente;

	 update cobcapen
	    set cod_cobrador = _cod_cobrador
      where cod_cliente  = _cod_cliente;

end foreach

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END
END PROCEDURE