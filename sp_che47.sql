-- Reporte para proceso diario de cheques vencidos

-- Creado    : 28/04/2006 - Autor: Armando Moreno

DROP PROCEDURE sp_che47;

CREATE PROCEDURE sp_che47()
RETURNING integer,	 -- chque
		  CHAR(100), -- a nombre de
		  DEC(16,2), -- monto
		  date,		 -- fecha impresion
		  CHAR(2),	 -- cod ruta
		  CHAR(50),  -- nombre ruta
		  integer,	 -- dias
		  CHAR(50);  -- nombre cia

DEFINE _cod_ruta	  	CHAR(2);  
DEFINE _nombre_ruta		CHAR(50); 
DEFINE _a_nombre_de		CHAR(100); 
DEFINE _monto       	DEC(16,2);
DEFINE _fecha_impresion	date;
DEFINE v_nombre_cia   	CHAR(50);
DEFINE _dias       		integer;
define _no_cheque       integer;

		
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "c:\sp_che47.trc";
--TRACE ON;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01("001"); 

FOREACH
	SELECT no_cheque,
		   a_nombre_de,
	       monto,
		   fecha_impresion,
		   cod_ruta
	  INTO _no_cheque,
	   	   _a_nombre_de,
		   _monto,
		   _fecha_impresion,
		   _cod_ruta
	  FROM chqchmae
	 WHERE wf_entregado <> 1
	   and anulado      <> 1
	   and autorizado   = 1
	   and pagado       = 1
--	   and wf_firmado   = 1
	   and tipo_requis  = "C"
	   and fecha_impresion >= "01/01/2011"

--	if _cod_ruta is null or _cod_ruta = "" then
--		continue foreach;
--	end if

	let _dias = today - _fecha_impresion;

	if _dias <= 80 then
		continue foreach;
	end if

	select nombre
	  into _nombre_ruta
	  from chqruta
	 where cod_ruta = _cod_ruta;

	RETURN  _no_cheque,		 
			_a_nombre_de,
			_monto,     
			_fecha_impresion,    
			_cod_ruta,
			_nombre_ruta,
			_dias,
			v_nombre_cia
			WITH RESUME;
END FOREACH

END PROCEDURE;