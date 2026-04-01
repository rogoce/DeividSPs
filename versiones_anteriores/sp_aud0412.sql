-- Busqueda de polizas con corredor directo afectadas por la cuenta 26401
-- creado    : 28/01/2013 - Autor: Henry Giron
-- sis v.2.0
-- execute procedure sp_aud0412 ()

drop procedure sp_aud0412;
create procedure "informix".sp_aud0412()
returning   char(20),
			char(10),
			char(15),
			integer,
			dec(16,2),
			dec(16,2);

define _error_desc		char(100);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _cod_formapag	char(3);
define _monto			dec(16,2);
define _res_origen	    char(3);
define _error			smallint;
define _error_isam		smallint;
define _fronting		smallint;
define _renglon,_cnt	integer;
define _res_notrx       integer;
define _no_documento    char(20);
define _no_endoso       char(5);
define _res_comprobante char(15);
define _res_db			dec(16,2);
define _res_cr			dec(16,2);
define _res_cuenta      char(20);
drop table if exists tmp_cgl;
begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

--set debug file to "sp_leyri07.trc"; 
--trace on;

let _res_db = 0.00;
let	_res_cr	= 0.00;

 CREATE TEMP TABLE tmp_cgl
           (no_poliza        CHAR(10),
			debito           DEC(16,2) default 0,
			credito          DEC(16,2) default 0,
			res_origen       char(3),
			res_notrx        integer,
			res_comprobante  char(15)
			) WITH NO LOG;


foreach
	select a.res_origen,
	       a.res_notrx,
		   a.res_comprobante,
		   a.res_cuenta
	  into _res_origen,
	       _res_notrx,
		   _res_comprobante,
		   _res_cuenta
      from cglresumen a, cglver c, prdramo d
	 where a.res_fechatrx between '01/11/2019' and '30/11/2019'
	   and a.res_origen not in ('CGL')
	   and a.res_cuenta in ('13101010101', '13101010201','13101010301', '13101010401','13101020201',
	       '13101020301','13101020401', '131020101', '131020102','131020103',
	       '131020104',    '131020105', '131020106','131020107', '13102010802',
	       '13102010804','131020201','131020205',  '131030104')
	   and a.res_cuenta = c.cuenta
	   and res_origen not in ('CGL')
		--and a.res_ccosto = '001'
	   and d.cod_Ramo = c.cod_ramo
	   and c.cod_ramo = '002'
	
	
    if _res_origen = 'PRO' then

	   foreach
		   select no_poliza,
		          no_endoso,
				  debito,
				  credito
		     into _no_poliza,
			      _no_endoso,
				  _res_db,
				  _res_cr
		     from endasien
			where sac_notrx = _res_notrx
			  and cuenta    = _res_cuenta


					insert into tmp_cgl(
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito
					)
					values(
					_no_poliza,
					_res_origen,
					_res_notrx,
					_res_comprobante,
					_res_db,
					_res_cr
					);					

	   end foreach

	elif _res_origen = 'COB' then

	   foreach
		   select no_remesa,
		          renglon,
				  debito,
				  credito
			 into _no_remesa,
			      _renglon,
				  _res_db,
				  _res_cr
	         from cobasien
			where sac_notrx = _res_notrx
			  and cuenta    = _res_cuenta

           select no_poliza
		     into _no_poliza
			 from cobredet
			where no_remesa = _no_remesa
			  and renglon   = _renglon;


					insert into tmp_cgl(
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito
					)
					values(
					_no_poliza,
					_res_origen,
					_res_notrx,
					_res_comprobante,
					_res_db,
					_res_cr
					);					


	   end foreach

	elif _res_origen = 'CHE' then

	  foreach

		select no_poliza,
		       debito,
			   credito
		  into _no_poliza,
			   _res_db,
		       _res_cr
		  from chqchcta
		 where sac_notrx = _res_notrx
		   and cuenta    = _res_cuenta

        if _no_poliza is not null then


					insert into tmp_cgl(
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito
					)
					values(
					_no_poliza,
					_res_origen,
					_res_notrx,
					_res_comprobante,
					_res_db,
					_res_cr
					);					
										

		else

		   let _no_poliza = 'ERR';

			insert into tmp_cgl(
			no_poliza,
			res_origen,
			res_notrx,
			res_comprobante
			)
			values(
			_no_poliza,
			_res_origen,
			_res_notrx,
			_res_comprobante
			);					

		end if

	  end foreach

	else
		continue foreach;
	end if

end foreach

foreach
	select a.res_origen,
	       a.res_notrx,
		   a.res_comprobante,
		   a.res_cuenta
	  into _res_origen,
	       _res_notrx,
		   _res_comprobante,
		   _res_cuenta
      from cglresumen a, cglver c, prdramo d
	 where a.res_fechatrx between '01/11/2019' and '30/11/2019'
	   and a.res_origen in ('CGL')
	   and a.res_cuenta in ('13101010101', '13101010201','13101010301', '13101010401','13101020201',
	       '13101020301','13101020401', '131020101', '131020102','131020103',
	       '131020104',    '131020105', '131020106','131020107', '13102010802',
	       '13102010804','131020201','131020205',  '131030104')
	   and a.res_cuenta = c.cuenta
	   and res_origen in ('CGL')
		--and a.res_ccosto = '001'
	   and d.cod_Ramo = c.cod_ramo
	   and c.cod_ramo = '002'


		   let _no_poliza = 'CGL';

			insert into tmp_cgl(
			no_poliza,
			res_origen,
			res_notrx,
			res_comprobante,
			debito,
			credito			
			)
			values(
			_no_poliza,
			_res_origen,
			_res_notrx,
			_res_comprobante,
			_res_db,
			_res_cr			
			);	
		
	
end foreach

foreach

	select no_poliza,
		   res_comprobante,
		   res_notrx,
		   debito,
		   credito
	  into _no_poliza,
		   _res_comprobante,
		   _res_notrx,
		   _res_db,
		   _res_cr
	  from tmp_cgl
	 order by no_poliza


	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

   return _no_documento,_no_poliza,_res_comprobante,_res_notrx,_res_db,_res_cr with resume;



end foreach

--DROP TABLE tmp_cgl;
		
end
end procedure