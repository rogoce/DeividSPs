-- Procedure que Anula las transacciones con mas de 90 dias
-- Inctrucciones Leyri Moreno, Correo del 11/06/2015

drop procedure sp_rec287;
create procedure sp_rec287()
returning char(10) as tramite,
          varchar(100) as asegurado,
		  char(20) as poliza,
		  varchar(100) as tercero,
          date as fecha_apertura,
		  char(10) as transaccion,
		  dec(16,2) as monto,
		  date as fecha_tr,
		  date as fecha_siniestro,
		  date as documentacion_completa,
		  dec(16,2) as reserva;


define _numrecla	char(20);
define _no_tranrec2	char(10);
define _transaccion	char(10);
define _no_tranrec	char(10);
define _no_reclamo	char(10);
define _no_requis	char(10);
define _anular_nt	char(10);
define _valor_nvo	char(10);
define _no_orden	char(10);
define _user		char(10);
define _compania	char(3); 
define _sucursal	char(3); 
define _monto		dec(16,2);
define _ord_pagado	smallint;
define _pagado		smallint;
define _cant_sec	integer;
define _cantidad	integer;
define _error		integer;
define _dias		integer;
define _cant        smallint;
define _cod_tercero char(10);
define _no_tramite  char(10);
define _cod_asegurado char(10);
define _no_documento  char(20);
define _fecha_siniestro date;
define _date_doc_comp date;
define _asegurado    char(20);
define _tercero    char(20);
define _date_added date;
define _fecha_tr      date;
define _reserva     dec(16,2);

let _user     = "GERENCIA";
let _error    = 0;
let _cant_sec = 0;

--set debug file to "sp_rec245.trc";
--trace on;

set isolation to dirty read;

foreach with hold
 select a.pagado,
	    a.no_requis,
		a.numrecla,
		a.no_tranrec,
		a.no_reclamo,
		a.cod_compania,
		a.cod_sucursal,
		a.transaccion,
		a.fecha,
		a.monto,
		(today - a.fecha),
		b.cod_tercero
   into _pagado,
	    _no_requis,
		_numrecla,
		_no_tranrec,
	    _no_reclamo,
		_compania,
		_sucursal,
		_transaccion,
		_fecha_tr,
		_monto,
		_dias,
		_cod_tercero
   from rectrmae a, recterce b
  where a.no_reclamo        = b.no_reclamo
    and a.cod_cliente       = b.cod_tercero
    and a.cod_compania    	= "001"
    and a.actualizado     	= 1
    and a.cod_tipotran    	= "004"
	and a.periodo        	    >= "2014-01"
    and a.pagado          	= 0
    and a.monto           	> 0
--    and (today - a.fecha)	    > 90
--	and a.periodo             <= '2018-04'
    and a.no_requis       	is not null
    and a.anular_nt       	is null
    and a.numrecla[1,2]   	in("02","23","20")
  order by a.fecha, a.numrecla[6,7], a.numrecla[4,5], a.numrecla	

  select no_tramite,
         cod_asegurado,
		 no_documento,
		 fecha_siniestro
	into _no_tramite,
	     _cod_asegurado,
		 _no_documento,
		 _fecha_siniestro
	from recrcmae
   where no_reclamo = _no_reclamo;
   
   select date_doc_comp,
          date_added
     into _date_doc_comp,
	      _date_added
	 from recterce
	where no_reclamo = _no_reclamo
	  and cod_tercero = _cod_tercero;

	select nombre
	  into _asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _tercero
	  from cliclien
	 where cod_cliente = _cod_tercero;	  

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;	 
	 
		return _no_tramite,
			   _asegurado,
			   _no_documento,
			   _tercero,
			   _date_added,
			   _transaccion,
			   _monto,
			   _fecha_tr,
			   _fecha_siniestro,
			   _date_doc_comp,
			   _reserva
			   with resume;
end foreach

end procedure;