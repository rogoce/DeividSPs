-- Procedimiento que Marca como Entregados carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	31/08/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_che212;

create procedure sp_che212()
returning integer,
          char(10),
          char(1),
		  smallint,
		  smallint,
		  char(100),
		  char(50),
		  char(8),
		  date,
		  smallint,
		  datetime hour to second;

define _no_cheque		integer;
define _no_requis		char(10);
define _tipo_requis		char(1);
define _pagado			smallint;
define _anulado			smallint;
define _wf_nombre		char(100);
define _wf_cedula		char(50);
define _user_entrego	char(8);
define _wf_fecha		date;
define _wf_entregado	smallint;
define _wf_hora			datetime hour to second;

define _cantidad		smallint;

set isolation to dirty read;

foreach
 select cheque
   into _no_cheque
   from deivid_tmp:tmp_ckspend31082012

	select count(*)
	  into _cantidad
	  from chqchmae
	 where no_cheque = _no_cheque;

	if _cantidad = 0 then

			return _no_cheque,
			       "00000",
		 		   "C",
		           0,
		           0,
				   "",
				   "",
				   "",
				   null,
				   0,
				   null
				   with resume;

	else

		foreach
		 select no_requis,
		 		tipo_requis,
		        pagado,
		        anulado,
				wf_nombre,
				wf_cedula,
				user_entrego,
				wf_fecha,
				wf_entregado,
				wf_hora
		   into _no_requis,
		 		_tipo_requis,
		        _pagado,
		        _anulado,
				_wf_nombre,
				_wf_cedula,
				_user_entrego,
				_wf_fecha,
				_wf_entregado,
				_wf_hora
		   from chqchmae
		  where no_cheque = _no_cheque

			return _no_cheque,
			       _no_requis,
		 		   _tipo_requis,
		           _pagado,
		           _anulado,
				   _wf_nombre,
				   _wf_cedula,
				   _user_entrego,
				   _wf_fecha,
				   _wf_entregado,
				   _wf_hora
				   with resume;

		end foreach

	end if

end foreach

end procedure
