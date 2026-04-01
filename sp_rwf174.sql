-- Reportes de transacciones aprobadas por ajustadores automovil, soda y auto flota
-- 
-- Creado    : 03/08/2004 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf174;
CREATE PROCEDURE sp_rwf174()
returning CHAR(18) as reclamo,
          CHAR(10) as tramite,
		  VARCHAR(100) as asegurado,
		  VARCHAR(50) as ajustador,
		  DATE as fecha,
		  VARCHAR(50) as cobertura,
		  CHAR(10) as transaccion,
		  DEC(16,2) as monto,
		  VARCHAR(100) as a_nombre_de,
		  VARCHAR(50) as tipo_pago;

define _no_tranrec     CHAR(10);
define _no_reclamo     CHAR(10);
define _numrecla       CHAR(18);
define _fecha          DATE;
define _transaccion    CHAR(10);
define _monto          DEC(16,2);
define _cod_cliente    CHAR(10);
define _cod_tipopago   CHAR(3);
define _cod_cobertura  CHAR(5);
define _cobertura      VARCHAR(50);
define _no_tramite     CHAR(10);
define _cod_asegurado  CHAR(10);
define _asegurado      VARCHAR(100);
define _a_nombre_de    VARCHAR(100);
define _tipo_pago      VARCHAR(50);
define _ajustador      VARCHAR(50);

define _user_added CHAR(8);


set isolation to dirty read;

foreach
	select no_tranrec,
		   no_reclamo,
		   numrecla,
		   user_added,
		   fecha,
		   transaccion,
		   monto,
		   cod_cliente,
		   cod_tipopago
	  into _no_tranrec,
		   _no_reclamo,
		   _numrecla,
		   _user_added,
		   _fecha,
		   _transaccion,
		   _monto,
		   _cod_cliente,
		   _cod_tipopago
	  from rectrmae
	 where date(wf_apr_js_fh) = today -1	--between '27/11/2020' and '09/03/2021'
	   and wf_apr_js is not null
	   and trim(wf_apr_js) <> ""
	   and actualizado = 1
	   and numrecla[1,2] in ('02','20','23')
   
	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from rectrcob
		 where no_tranrec = _no_tranrec
		   and monto <> 0 
		
		exit foreach;
	end foreach
	
	select nombre
	  into _cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;
	 
	select no_tramite,
	       cod_asegurado
	  into _no_tramite,
	       _cod_asegurado
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select nombre
	  into _asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	select nombre
	  into _a_nombre_de
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	let _tipo_pago = "";
	
	if _cod_tipopago is not null and trim(_cod_tipopago) <> "" then 	
		select nombre
		  into _tipo_pago
		  from rectipag
		 where cod_tipopago = _cod_tipopago;
    end if
	 
	select nombre
	  into _ajustador
	  from recajust
	 where usuario = _user_added;
	 
    return _numrecla,
	       _no_tramite,
		   _asegurado,
		   _ajustador,
		   _fecha,
		   _cobertura,
		   _transaccion,
		   _monto,
		   _a_nombre_de,
		   _tipo_pago WITH RESUME;

end foreach
end procedure