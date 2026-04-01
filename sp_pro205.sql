
-- Procedimiento que busca las evaluaciones Declinadas que NO han sido pagadas (Proveedor vida Individual/Cliente)

-- Creado    : 07/01/2011 - Autor: Armando Moreno M.
-- Modificado: 07/01/2011 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro205;

CREATE PROCEDURE "informix".sp_pro205(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;

DEFINE _monto        	DEC(16,2);
DEFINE a_no_remesa      CHAR(10);
DEFINE _no_evaluacion   CHAR(10);
DEFINE _mensaje         CHAR(100);
DEFINE _decicion		SMALLINT;
DEFINE _cod_cliente    	CHAR(10);
DEFINE _no_recibo       CHAR(10);
DEFINE _valor           SMALLINT;

--SET DEBUG FILE TO "sp_pro205.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error en el proceso', '';         
END EXCEPTION           


CREATE TEMP TABLE tmp_prov
 (cod_cliente      	char(10),
  monto             dec(16,2),
  PRIMARY KEY       (cod_cliente))
  WITH NO LOG;

let _monto = 0;
let a_no_remesa = "";
let _mensaje    = "";
let _valor      = 0;

--*********************
--Declina Ancon
--*********************
Foreach

	select no_evaluacion,
	       decicion
	  into _no_evaluacion,
	       _decicion
	  from emievalu
	 where pagado       = 0
	   and decicion     = 3   --declina ancon
	   and tipo_ramo    = 2	  --vida
	   and indivi_colec = 0	  --individual

	--Acumulacion por proveedor para sacar un solo chk.
	foreach

		select cod_cliente,
		       monto
		  into _cod_cliente,
		       _monto
		  from emiprovi
		 where no_evaluacion = _no_evaluacion

	     BEGIN
		      ON EXCEPTION IN(-239)
		         UPDATE tmp_prov
		            SET monto       = monto + _monto
		          WHERE cod_cliente = _cod_cliente;

		      END EXCEPTION

			INSERT INTO tmp_prov(cod_cliente,monto) VALUES (_cod_cliente,_monto);
	
		 END

	end foreach

	update emievalu
	   set pagado = 1
	 where no_evaluacion = _no_evaluacion;

End foreach

--***********************
--Declina Cliente
--***********************
let _monto = 0;

Foreach

	select no_evaluacion,
	       decicion,
		   no_recibo
	  into _no_evaluacion,
	       _decicion,
		   _no_recibo
	  from emievalu
	 where pagado       = 0
	   and decicion     = 8   --declina cliente
	   and tipo_ramo    = 2	  --vida
	   and indivi_colec = 0	  --individual

	--Monto total de proveedor de la evaluacion

	select sum(monto)
	  into _monto
	  from emiprovi
	 where no_evaluacion = _no_evaluacion;

	if _monto > 0 and _no_recibo is not null then

		call sp_pro204(a_compania,a_sucursal,a_user,_no_recibo,_monto) returning _valor, _mensaje,a_no_remesa; --creacion de remesa y chk para cte.

	else
		continue foreach;	
	end if

	--Acumulacion por proveedor para sacar un solo chk.
	foreach

		select cod_cliente,
		       monto
		  into _cod_cliente,
		       _monto
		  from emiprovi
		 where no_evaluacion = _no_evaluacion

	     BEGIN
		      ON EXCEPTION IN(-239)
		         UPDATE tmp_prov
		            SET monto       = monto + _monto
		          WHERE cod_cliente = _cod_cliente;

		      END EXCEPTION

			INSERT INTO tmp_prov(cod_cliente,monto) VALUES (_cod_cliente,_monto);
	
		 END

	end foreach

	update emievalu
	   set pagado = 1
	 where no_evaluacion = _no_evaluacion;

End Foreach

--**************************************************
--Confeccion de Requisiciones(cheques) por proveedor
--**************************************************
let _monto = 0;

Foreach

	select cod_cliente,
	       monto
	  into _cod_cliente,
		   _monto
	  from tmp_prov

	call sp_che121(_cod_cliente,_monto) returning _valor, _mensaje; --creacion de chk para proveedor.

End Foreach

DROP TABLE tmp_prov;

RETURN 0, 'Actualizacion Exitosa.', ''; 

END 

END PROCEDURE;
