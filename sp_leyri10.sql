-- Busqueda de polizas con corredor directo afectadas por la cuenta 26401
--
-- creado    : 28/01/2013 - Autor: Armando Moreno
-- sis v.2.0

--drop procedure sp_leyri10;
create procedure "informix".sp_leyri10(a_fecha1 date, a_fecha2 date)
returning char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(7),
		  integer,
		  char(15),
		  integer,
		  date,
		  char(10);



define _error_desc		char(100);
define _no_tranrec		char(10);
define _no_remesa		char(10);
define _cod_formapag	char(3);
define _monto			dec(16,2);
define _res_origen	    char(3);
define _cod_agente      char(5);
define _error			smallint;
define _error_isam		smallint;
define _tipo_comp		smallint;
define _renglon,_cnt	integer;
define _res_notrx       integer;
define _n_agente        varchar(50);
define _no_documento    char(20);
define _no_endoso       char(5);
define _res_comprobante char(15);
define _db				dec(16,2);
define _cr,_dif				dec(16,2);
define _tipo_agente     char(1);
define _porc_partic_agt decimal(5,2);
define _periodo         char(7);
define _res_fechatrx    date;
define _transaccion     char(10);

begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

--set debug file to "sp_leyri07.trc"; 
--trace on;

let _db = 0.00;
let	_cr	= 0.00;


 CREATE TEMP TABLE tmp_cgl
           (no_tranrec       CHAR(10),
			debito           DEC(16,2) default 0,
			credito          DEC(16,2) default 0,
			periodo          char(7),
			res_notrx        integer,
			res_comprobante  char(15),
			tipo_comp        integer,
			res_fechatrx	 date
			) WITH NO LOG;


foreach
	select res_origen,
	       res_notrx,
		   res_comprobante,
		   res_fechatrx
	  into _res_origen,
	       _res_notrx,
		   _res_comprobante,
		   _res_fechatrx
      from sac:cglresumen
	 where res_fechatrx   >= a_fecha1
	   and res_fechatrx   <= a_fecha2
	   and res_cuenta     = '26612'
	   and res_origen     = 'REC'

	   foreach
		   select no_tranrec,
				  debito,
				  credito,
				  periodo,
				  tipo_comp
		   	 into _no_tranrec,
				  _db,
				  _cr,
				  _periodo,
				  _tipo_comp
		   	 from recasien
			where sac_notrx = _res_notrx
			  and cuenta    = '26612'
			order by no_tranrec

				insert into tmp_cgl(
				no_tranrec,
				debito,
				credito,
				periodo,
				tipo_comp,
				res_comprobante,
				res_notrx,
				res_fechatrx
				)
				values(
				_no_tranrec,
				_db,
				_cr,
				_periodo,
				_tipo_comp,
				_res_comprobante,
				_res_notrx,
				_res_fechatrx
				);
										
	   end foreach

end foreach

let _dif = 0;

foreach

	select no_tranrec,
		   debito,
		   credito,
		   periodo,
		   tipo_comp,
		   res_comprobante,
		   res_notrx,
		   res_fechatrx
	  into _no_tranrec,
		   _db,
		   _cr,
		   _periodo,
		   _tipo_comp,
		   _res_comprobante,
		   _res_notrx,
		   _res_fechatrx
	  from tmp_cgl
	 order by no_tranrec

   
	select transaccion
	  into _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;


    select count(*)
	  into _cnt
	  from reccietr
	 where transaccion = _transaccion;

	 if _cnt > 0 then

	  foreach
	    select monto
		  into _monto
		  from reccietr
		 where transaccion = _transaccion

		exit foreach;

	  end foreach
--		 let _dif = _db + _cr;

--		 if _dif <> 0 then

			   return _no_tranrec,_db,_cr,_monto,_dif,_periodo,_tipo_comp,_res_comprobante,_res_notrx,_res_fechatrx,_transaccion with resume;

--		 end if

	 end if

end foreach

DROP TABLE tmp_cgl;
		
end
end procedure