-- Sacar diferencia de comision de comisrep(comision por corredor) vs prcoche(pro+cob+che de la cuenta 26401)
--
-- creado    : 19/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_prcoche3;
create procedure "informix".sp_prcoche3()
returning   char(10),
			varchar(50),
			char(20),
			char(10),
			char(15),
			integer,
			dec(16,2),
			dec(16,2),
			char(1);

define _error_desc		char(100);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _cod_formapag	char(3);
define _monto			dec(16,2);
define _res_origen	    char(3);
define _cod_agente      char(5);
define _error			smallint;
define _error_isam		smallint;
define _fronting		smallint;
define _renglon,_cnt	integer;
define _res_notrx       integer;
define _n_agente        varchar(50);
define _no_documento    char(20);
define _no_endoso       char(5);
define _res_comprobante char(15);
define _res_db,_db_pro	dec(16,2);
define _res_cr,_cr_pro	dec(16,2);
define _resdbcr         dec(16,2);
define _tipo_agente     char(1);
define _porc_partic_agt decimal(5,2);
define _tipo_mov        char(1);
define _no_requis      char(10);

begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

--set debug file to "sp_prcoche.trc"; 
--trace on;

let _res_db = 0.00;
let	_res_cr	= 0.00;
let	_db_pro	= 0.00;
let _cr_pro	= 0.00;
let _porc_partic_agt = 0.00;
let _resdbcr = 0.00;

foreach
	select cod_agente,
	       no_poliza,
	       sum(comis_agt)
	  into _cod_agente,
	       _no_poliza,
		   _monto
      from comisrep
	group by 1,2
	order by 1,2

	select count(*)
	  into _cnt
	  from prcoche
	 where cod_agente = _cod_agente
	   and no_poliza  = _no_poliza;

	if _cnt > 0 then

		select sum(debito),
		       sum(credito),
		       sum(debito + credito)
		  into _res_db,
			   _res_cr,
			   _resdbcr
		  from prcoche
		 where cod_agente = _cod_agente
		   and no_poliza  = _no_poliza;


		if abs(_monto) <> abs(_resdbcr) then

	        if _no_poliza is not null then

			   select no_documento
			     into _no_documento
				 from emipomae
				where no_poliza = _no_poliza;

			end if

			insert into comisdif(
			cod_agente,
			no_poliza,
			comis_agt,
			db,
			cr,
			dbcr,
			no_documento
			)
			values(
			_cod_agente,
			_no_poliza,
			_monto,
			_res_db,
			_res_cr,
			_resdbcr,
			_no_documento
			);					


		end if
   	{else
		if _monto <> 0 then
			insert into comisdif(
			cod_agente,
			no_poliza,
			comis_agt,
			db,
			cr,
			dbcr,
			prcoche
			)
			values(
			_cod_agente,
			_no_poliza,
			_monto,
			0,
			0,
			0,'N'
			);
		end if}
	end if

end foreach

foreach
	select cod_agente,
	       no_poliza,
		   sum(debito),
		   sum(credito),
		   sum(debito + credito)
	  into _cod_agente,
	       _no_poliza,
		   _res_db,
		   _res_cr,
		   _resdbcr
	  from prcoche
      where (cod_agente is not null
        and no_poliza is not null)
        and cod_agente <> ''
	group by 1,2
	order by 1,2

	select count(*)
	  into _cnt
	  from comisrep
	 where cod_agente = _cod_agente
	   and no_poliza  = _no_poliza;

	if _cnt = 0 then

		if _no_poliza is not null then
		   select no_documento
		     into _no_documento
			 from emipomae
			where no_poliza = _no_poliza;

		end if

		insert into comisdif(
		cod_agente,
		no_poliza,
		comis_agt,
		db,
		cr,
		dbcr,
		prcoche,
		no_documento
		)
		values(
		_cod_agente,
		_no_poliza,
		0,
		_res_db,
		_res_cr,
		_resdbcr,
		'N',
		_no_documento
		);					

	end if

end foreach

end
end procedure