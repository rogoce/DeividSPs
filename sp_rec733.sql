-- Procedimiento que carga los cobros para que se generen los registros contables
-- 
-- Creado    : 26/01/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec733;		

create procedure "informix".sp_rec733(a_reclamo CHAR(10))
returning char(10), 
          date,
		  char(7),
		  varchar(50),
		  varchar(50),
		  dec(16,2),
		  dec(16,2),
		  smallint,
		  char(10),
		  char(10),
		  integer,
		  varchar(100),
		  integer,
		  integer,
		  char(10);
		  	 
define _transaccion   char(10);   
define _fecha         date; 
define _periodo       char(7);   
define _cod_tipotran  char(3);   
define _cod_tipopago  char(3);   
define _monto         dec(16,2);   
define _variacion     dec(16,2);    
define _pagado        smallint;   
define _no_requis     char(10);   
define _no_remesa     char(10);  
define _renglon       smallint;
define _cod_cliente   char(10);
define _cliente       varchar(100);
define _no_cheque     integer;
define _incidente     integer;
define _no_ajus_orden char(10);
define _tipotran      varchar(50);
define _tipopago      varchar(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);

set isolation to dirty read;

begin 
--on exception set _error, _error_isam, _error_desc
--	return _error, _error_desc;
--end exception

foreach with hold
 SELECT transaccion,   
        fecha,   
        periodo,   
        cod_tipotran,   
        cod_tipopago,   
        monto,   
        variacion,   
        pagado,   
        no_requis,   
        no_remesa,   
        renglon,
        cod_cliente 		
   INTO _transaccion,   
        _fecha,   
        _periodo,   
        _cod_tipotran,   
        _cod_tipopago,   
        _monto,   
        _variacion,   
        _pagado,   
        _no_requis,   
        _no_remesa,   
        _renglon,
        _cod_cliente		
    FROM rectrmae   
   WHERE no_reclamo = a_reclamo 
     AND actualizado = 1   
ORDER BY fecha, transaccion

    SELECT nombre  
	  INTO _cliente
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	LET _no_cheque = 0; 
	LET _incidente = 0; 
	LET _no_ajus_orden = NULL; 
	 
	IF _no_requis is not null AND trim(_no_requis) <> "" THEN
		SELECT no_cheque,
		       incidente
		  INTO _no_cheque,
		       _incidente
		  FROM chqchmae
		 WHERE no_requis = _no_requis;
		 
		SELECT no_ajus_orden
		  INTO _no_ajus_orden
		  FROM recordam
		 WHERE no_requis = _no_requis;
	END IF

	LET _tipotran = NULL; 
	LET _tipopago = NULL; 
	
	SELECT nombre 
	  INTO _tipotran
	  FROM rectitra
	 WHERE cod_tipotran = _cod_tipotran;

	SELECT nombre 
	  INTO _tipopago
	  FROM rectipag
	 WHERE cod_tipopago = _cod_tipopago;
	 
	RETURN _transaccion,   
           _fecha,   
           _periodo,   
           _tipotran,   
           _tipopago,   
           _monto,   
           _variacion,   
           _pagado,   
           _no_requis,   
           _no_remesa,   
           _renglon,
           _cliente,
		   _no_cheque,
           _incidente,
           _no_ajus_orden WITH RESUME;
		   
end foreach

end 


end procedure
