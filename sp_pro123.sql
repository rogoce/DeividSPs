-- Procedimiento que Genera los Cobros por Cobrador	semanal, por cobra poliza. 
-- 
-- Creado    : 18/06/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 23/06/2003 - Autor: Marquelda Valdelamar

--DROP PROCEDURE sp_pro123;

CREATE PROCEDURE "informix".sp_pro123()
returning char(20),
          char(100),
          char(50),
          char(30),
          char(50);

define _no_poliza	    char(10);
define _no_documento	char(20);
define _cod_agente		char(5);
define _nombre_agente	char(50);
define _nombre_cliente	char(100);
define _cod_contratante	char(10);

define _cod_modelo		char(5);
define _nombre_modelo	char(50);
define _no_motor		char(30);

foreach
 select p.no_poliza,
        p.no_documento,
		p.cod_contratante,
		v.cod_modelo,
		v.no_motor
   into _no_poliza,
	    _no_documento,
		_cod_contratante,
		_cod_modelo,
		_no_motor
   from emipomae p, emiauto a, emivehic v
  where p.no_poliza      = a.no_poliza
    and a.no_motor       = v.no_motor
    and v.cod_marca      = "00098"
    and p.actualizado    = 1
    and v.ano_auto       = 2003
    and p.estatus_poliza = 1

	foreach
	 select cod_agente 
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	   	exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _nombre_modelo
	  from emimodel
	 where cod_marca  = "00098"
	   and cod_modelo = _cod_modelo;

	 return _no_documento,
			_nombre_cliente,
			_nombre_modelo,
			_no_motor,
	        _nombre_agente
			with resume;
	     	
	   	
end foreach

end procedure
