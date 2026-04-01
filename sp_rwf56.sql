-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 19/12/2006 - Autor: Armando Moreno

drop procedure sp_rwf56;

create procedure sp_rwf56(a_no_cheque integer)
 returning   integer,
             char(100),
		   	 dec(16,2),
		   	 char(8),
		   	 char(8),
		   	 smallint,
		   	 char(10),
		   	 date,
		   	 datetime hour to fraction(5),
		   	 date,
			 smallint;

define _no_requis		char(10);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _user_added      char(8);
define _fecha_captura   date;
define _cant_firmas     smallint;
define _e_mail          char(30);
define _no_cheque       integer;
define _autorizado_por  char(8);
define _wf_entregado    smallint;
define _wf_fecha		date;
define _wf_hora         datetime hour to fraction(5);
define _fecha_impresion	date;
define _anulado         smallint;

SET ISOLATION TO DIRTY READ;

foreach
	SELECT no_cheque,   
	       a_nombre_de,   
	       monto,   
	       autorizado_por,   
	       user_added,   
	       wf_entregado,   
	       no_requis,   
	       wf_fecha,   
	       wf_hora,   
	       fecha_impresion,
		   anulado
	  INTO _no_cheque,
		   _a_nombre_de,
		   _monto,
		   _autorizado_por,
		   _user_added,
		   _wf_entregado,
		   _no_requis,
		   _wf_fecha,
		   _wf_hora,
		   _fecha_impresion,
		   _anulado
      FROM chqchmae  
	 WHERE ((incidente is not null 
	   AND incidente <> 0 
	   AND (anulado = 1 
	    OR wf_entregado = 1)) 
	    OR (en_firma = 2 
	   AND (anulado = 1 
	    OR wf_entregado = 1)))
	   AND no_cheque = a_no_cheque   

	return _no_cheque,
		   _a_nombre_de,
		   _monto,
		   _autorizado_por,
		   _user_added,
		   _wf_entregado,
		   _no_requis,
		   _wf_fecha,
		   _wf_hora,
		   _fecha_impresion,
		   _anulado
		   with resume;

end foreach

end procedure
