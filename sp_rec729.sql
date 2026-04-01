-- Procedimiento para crear la descripcion de la transaccion.

-- Creado:     29/10/2014 - Autor: Armando Moreno M.
-- Modificado: 29/10/2014 -        Armando Moreno M.

DROP PROCEDURE sp_rec729;

CREATE PROCEDURE "informix".sp_rec729(a_periodo1 char(7), a_periodo2 char(7))
RETURNING char(18),char(20),char(100),date,date,decimal(16,2),decimal(16,2),decimal(16,2);



DEFINE _no_reclamo			CHAR(10);
DEFINE _transaccion			CHAR(10);
DEFINE _error   			INTEGER;
DEFINE _no_documento         CHAR(20); 
DEFINE _no_orden            CHAR(10);
DEFINE _dif			        DEC(16,2);
DEFINE _renglon             smallint;
DEFINE _genera_incidente    SMALLINT;
DEFINE _cod_asegurado       char(10);
DEFINE _monto_pendiente     DECIMAL(16,2);
define _numrecla			char(18);
define _error_isam          integer;
define _dif_precio          DECIMAL(16,2);
define _monto_orden_acum	DECIMAL(16,2);
define _monto_fact_acum 	DECIMAL(16,2);
define _monto_orden         DECIMAL(16,2);
define _tipo_opc            smallint;
define _cant,i              smallint;
define _desc_orden          varchar(50);
define _valor_pend          DECIMAL(16,2);
define _periodo             char(7);
define _fecha_reclamo		date;
define _fecha_siniestro		date;
define _mes                 smallint;
define _mes_char            char(2);
define v_por_vencer			DECIMAL(16,2);
define v_exigible 			DECIMAL(16,2);
define v_corriente			DECIMAL(16,2);
define v_monto_30 			DECIMAL(16,2);
define v_monto_60 			DECIMAL(16,2);
define v_monto_90			DECIMAL(16,2);
define v_saldo				DECIMAL(16,2);
define _n_nombre            char(100);
define _reserva             DECIMAL(16,2);
define _pagado              DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rec728.trc";
--trace on;

begin


let v_por_vencer = 0;
let v_exigible 	 = 0;
let v_corriente	 = 0;
let v_monto_30 	 = 0;
let v_monto_60 	 = 0;
let v_monto_90	 = 0;
let v_saldo		 = 0;

foreach
	select numrecla,
	       no_documento,
		   fecha_siniestro,
		   fecha_reclamo,
		   cod_asegurado,
		   no_reclamo
	  into _numrecla,
	       _no_documento,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _cod_asegurado,
		   _no_reclamo
	  from recrcmae
	 where actualizado = 1
	   and periodo >= a_periodo1
	   and periodo <= a_periodo2

	 select nombre
	   into _n_nombre
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	   
		let _mes      = month(_fecha_reclamo);
		if _mes < 10 then
			let _mes_char = '0' || _mes;
		else
		    let _mes_char = _mes;
		end if

		let _periodo  = year(_fecha_reclamo) || '-' || _mes_char;

	  
   	 call sp_cob33('001', '001', _no_documento, _periodo, _fecha_reclamo)
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               v_saldo;

	 let _reserva = 0;
	 let _pagado  = 0;
	                  
 	 let _monto_pendiente = 0;
 	 let _monto_pendiente =  v_monto_30 + v_monto_60 + v_monto_90;

 	 if _monto_pendiente > 1.00 then

		 SELECT sum(variacion)
		   INTO _reserva
		   FROM rectrmae
		  WHERE cod_compania = '001'
		    AND actualizado  = 1
			AND no_reclamo   = _no_reclamo
			AND periodo      >= a_periodo1 
			AND periodo      <= a_periodo2
		    AND variacion    <> 0;

         if _reserva is null then
			let _reserva = 0.00;
		 end if

		 SELECT sum(monto)
		   INTO _pagado
		   FROM rectrmae
		  WHERE cod_compania = '001'
		    AND actualizado  = 1
			AND cod_tipotran = '004'
			AND no_reclamo   = _no_reclamo
			AND periodo      >= a_periodo1 
			AND periodo      <= a_periodo2
		    AND monto        <> 0;

         if _pagado is null then
			let _pagado = 0.00;
		 end if


		return _numrecla,_no_documento, _n_nombre, _fecha_siniestro, _fecha_reclamo, _monto_pendiente,_reserva,_pagado with resume;

 	 end if						
	    

end foreach

end

END PROCEDURE