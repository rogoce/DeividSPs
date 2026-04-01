-- Extraer datos del rutero para insertar en tablas para los (cobros moviles).
-- 
-- Creado    : 09/09/2005 - Autor: Armando Moreno M.
-- Modificado: 13/09/2005 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE ap_facturas;

CREATE PROCEDURE "informix".ap_facturas()
Returning char(18) as reclamo,   --  _numrecla,
          char(20) as poliza,   --  _no_documento,
		  char(10) as factura,
		  char(10) as cod_cliente,	  -- _cod_cliente,
		  varchar(100) as cliente,	--   _proveedor,
		  varchar(50) as tipo_transaccion,
          varchar(50) as tipo_pago , --     _tipo_pago,
		  char(10) as cod_cpt, --	   _cod_cpt,
		  varchar(255) as procedimiento, --	   _procedimiento,
     	  char(10) as transaccion, 	 --  _transaccion,
          date as fecha,    -- _fecha,
		  dec(16,2) as monto, --	   _monto,
          char(8) as user_added, --    _user_added,
          varchar(100) as usuario, --     _usuario,
          char(10) as requisicion,   --  _no_requis,
          integer as cheque,    -- _no_cheque,
          smallint as anulado, --     _anulado,
          date as fecha_anulado;   --  _fecha_anulado;

define _no_documento char(20);
define _numrecla     char(18);
define _cod_cpt      char(10);
define _transaccion  char(10); 
define _cant         smallint;
define _no_factura   char(10);
define _cod_tipopago char(3);
define _cod_tipotran char(3);
define _cod_cliente  char(10);
define _proveedor    varchar(100);
define _tipo_pago    varchar(50);
define _procedimiento varchar(255);
define _user_added   char(8);
define _usuario      varchar(100);
define _no_cheque    integer;
define _anulado      smallint;
define _fecha_anulado date;
define _no_reclamo   char(10);
define _fecha        date;
define _monto        dec(16,2);
define _no_requis    char(10);
define _tipo_transaccion varchar(50);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;


BEGIN

--ON EXCEPTION SET _error 
 	--RETURN _error,_mensaje;         
--END EXCEPTION


foreach
	SELECT no_reclamo,
	       cod_tipotran,
	       no_factura, 
		   cod_cpt, 
		   monto,
		   count(*)
	  INTO _no_reclamo,
	       _cod_tipotran,
	       _no_factura,
		   _cod_cpt,
		   _monto,
		   _cant
	  FROM rectrmae
	 WHERE fecha >= "01/01/2016"
		  AND actualizado = 1
		 AND pagado = 0
		 and no_factura is not null
		 and trim(no_factura) <> ""
		 and anular_nt is null
		 and cod_cpt is not null
		 and monto <> 0.00
	GROUP BY  no_reclamo,cod_tipotran,no_factura,cod_cpt,monto
	having count(*) > 1
	
	select numrecla,
	       no_documento 
	  into _numrecla,
	       _no_documento
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	
    foreach	
		select cod_cliente,
			   cod_tipotran,
			   cod_tipopago,
			   transaccion,
			   fecha,
			   monto,
			   user_added,
			   no_requis
		  into _cod_cliente,
			   _cod_tipotran,
			   _cod_tipopago,
			   _transaccion,
			   _fecha,
			   _monto,
               _user_added,
               _no_requis			   
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   AND actualizado = 1
		   AND pagado = 1
		   and no_factura = _no_factura
 		   and anular_nt is null
      	   and cod_cpt = _cod_cpt
		   
	   select nombre
	     into _proveedor
		 from cliclien
		where cod_cliente = _cod_cliente;
		
	   select nombre 
	     into _tipo_transaccion
		 from rectitra
		where cod_tipotran = _cod_tipotran;
		
	   select nombre
	     into _tipo_pago
		 from rectipag
		where cod_tipopago = _cod_tipopago;
		
	   select nombre
	     into _procedimiento
		 from reccpt
		where cod_cpt = _cod_cpt;
		
	   select descripcion
	     into _usuario
		 from insuser
		where usuario = _user_added;
		 
	   select no_cheque,
	          anulado,
			  fecha_anulado
	     into _no_cheque,
		      _anulado,
			  _fecha_anulado
		 from chqchmae
		where no_requis = _no_requis;

		return _numrecla,
               _no_documento,
			   _no_factura,
			   _cod_cliente,
			   _proveedor,
			   _tipo_transaccion,
               _tipo_pago,
			   _cod_cpt,
			   _procedimiento,
     		   _transaccion,
               _fecha,
			   _monto,
               _user_added,
               _usuario,
               _no_requis,
               _no_cheque,
               _anulado,
               _fecha_anulado with resume;
    end foreach		 
	  
end foreach

end

end procedure