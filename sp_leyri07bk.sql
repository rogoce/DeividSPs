-- Busqueda de polizas con corredor directo afectadas por la cuenta 26401
--
-- creado    : 28/01/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_leyri07bk;
create procedure "informix".sp_leyri07bk(a_fecha1 date, a_fecha2 date)
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
define _tipo_agente     char(1);
define _porc_partic_agt decimal(5,2);

begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

--set debug file to "sp_leyri07.trc"; 
--trace on;

let _res_db = 0.00;
let	_res_cr	= 0.00;
let	_db_pro	= 0.00;
let _cr_pro	= 0.00;
let _porc_partic_agt = 0.00;

 CREATE TEMP TABLE tmp_cgl
           (cod_agente       CHAR(5),
		    no_poliza        CHAR(10),
			debito           DEC(16,2) default 0,
			credito          DEC(16,2) default 0,
			res_origen       char(3),
			res_notrx        integer,
			res_comprobante  char(15),
			porc_partic_agt  decimal(5,2) default 0,
			no_endoso        char(5)
			) WITH NO LOG;


foreach
	select res_origen,
	       res_notrx,
		   res_comprobante
	  into _res_origen,
	       _res_notrx,
		   _res_comprobante
      from sac:cglresumen
	 where res_fechatrx   >= a_fecha1
	   and res_fechatrx   <= a_fecha2
	   and res_cuenta     = '26401'
	   and res_origen     = 'PRO'

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
			  and cuenta    = '26401'
		 order by no_poliza,no_endoso

		   let _db_pro = 0.00;
		   let _cr_pro = 0.00;

	   	   foreach

				select cod_agente,porc_partic_agt
				  into _cod_agente,_porc_partic_agt
				  from endmoage
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso

                 let _db_pro = _res_db * _porc_partic_agt /100; 
				 let _cr_pro = _res_cr * _porc_partic_agt /100;

					insert into tmp_cgl(
					cod_agente,  
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito,
					porc_partic_agt,
					no_endoso
					)
					values(
					_cod_agente,
					_no_poliza,
					_res_origen,
					_res_notrx,
					_res_comprobante,
					_db_pro,
					_cr_pro,
					_porc_partic_agt,
					_no_endoso
					);
										
		   end foreach

	   end foreach

end foreach

foreach

	select no_poliza,
	       cod_agente,
		   res_comprobante,
		   res_notrx,
		   debito,
		   credito
	  into _no_poliza,
		   _cod_agente,
		   _res_comprobante,
		   _res_notrx,
		   _res_db,
		   _res_cr
	  from tmp_cgl
	 order by cod_agente,no_poliza

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre,tipo_agente
	  into _n_agente,_tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;

   return _cod_agente,_n_agente,_no_documento,_no_poliza,_res_comprobante,_res_notrx,_res_db,_res_cr,_tipo_agente with resume;

end foreach

DROP TABLE tmp_cgl;
		
end
end procedure