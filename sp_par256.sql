-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/12/2000 - Autor: Armando Moreno Montenegro.
--
-- SIS v.2.0 - d_cobr_sp_cob40_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par256;

CREATE PROCEDURE "informix".sp_par256()
RETURNING char(20),
          char(50),
		  dec(16,2),
		  dec(16,2);

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_no_remesa		 CHAR(10);

define _poliza			char(20);
define _no_poliza		char(10);
define _cod_agente		char(10);
define _nombre_agente	char(50);
define _saldo			dec(16,2);
define _comision		dec(16,2);
define _porc_comision	dec(16,2);

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

let _comision = 0.00;

foreach 
 select poliza,
        saldo
   into _poliza,
        _saldo
   from	deivid_tmp:psc0709

	let _no_poliza = sp_sis21(_poliza);
	
	foreach
	 select cod_agente,
	        porc_comis_agt
	   into _cod_agente,
	        _porc_comision
	   from emipoagt
	  where no_poliza = _no_poliza
	  
		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		let _comision = _saldo * _porc_comision / 100;

		return _poliza,
		       _nombre_agente,
			   _saldo,
			   _comision
			   with resume;

		exit foreach;

	end foreach 		

END FOREACH;

END PROCEDURE;

