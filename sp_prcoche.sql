-- Busqueda de polizas con corredor directo afectadas por la cuenta 26401
--
-- creado    : 28/01/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_prcoche;
create procedure "informix".sp_prcoche(a_fecha1 date, a_fecha2 date)
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

           if _no_poliza is not null then

			   select no_documento
			     into _no_documento
				 from emipomae
				where no_poliza = _no_poliza;

		   end if

	   	   foreach

				select cod_agente,porc_partic_agt
				  into _cod_agente,_porc_partic_agt
				  from endmoage
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso

                 let _db_pro = _res_db * _porc_partic_agt /100; 
				 let _cr_pro = _res_cr * _porc_partic_agt /100;

					insert into prcoche(
					cod_agente,  
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito,
					porc_partic_agt,
					no_endoso,
					no_documento
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
					_no_endoso,
					_no_documento
					);
										
		   end foreach

	   end foreach

end foreach

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
	   and res_origen     = 'COB'	 

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
			  and cuenta    = '26401'

           select no_poliza,tipo_mov
		     into _no_poliza,_tipo_mov
			 from cobredet
			where no_remesa = _no_remesa
			  and renglon   = _renglon;

           if _no_poliza is not null then

			   select no_documento
			     into _no_documento
				 from emipomae
				where no_poliza = _no_poliza;

		   end if


           select count(*)
		     into _cnt
			 from cobreagt
			where no_remesa = _no_remesa
			  and renglon   = _renglon;

		  if _cnt > 0 then
			  foreach

		           select cod_agente,porc_partic_agt
				     into _cod_agente,_porc_partic_agt
					 from cobreagt
					where no_remesa = _no_remesa
					  and renglon   = _renglon


		                let _db_pro = _res_db * _porc_partic_agt /100; 
						let _cr_pro = _res_cr * _porc_partic_agt /100;
						
						insert into prcoche(
						cod_agente,  
						no_poliza,
						res_origen,
						res_notrx,
						res_comprobante,
						debito,
						credito,
						porc_partic_agt,
						no_remesa,
						renglon,
						tipo_mov,
						no_documento
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
						_no_remesa,
						_renglon,
						_tipo_mov,
						_no_documento
						);					
											
			  end foreach
		 else

			insert into prcoche(
			cod_agente,  
			no_poliza,
			res_origen,
			res_notrx,
			res_comprobante,
			debito,
			credito,
			porc_partic_agt,
			no_remesa,
			renglon,
			tipo_mov,
			no_documento
			)
			values(
			'',
			_no_poliza,
			_res_origen,
			_res_notrx,
			_res_comprobante,
			_res_db,
			_res_cr,
			0,
			_no_remesa,
			_renglon,
			_tipo_mov,
			_no_documento
			);					

		 end if

	   end foreach

end foreach

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
	   and res_origen     = 'CHE'	 

	  foreach

		select no_poliza,
		       debito,
			   credito,
			   no_requis
		  into _no_poliza,
			   _res_db,
		       _res_cr,
		       _no_requis
		  from chqchcta
		 where sac_notrx = _res_notrx
		   and cuenta    = '26401'

		   let _db_pro = 0;
		   let _cr_pro = 0;

		  if _no_poliza is null or _no_poliza = '' then
					insert into prcoche(
					cod_agente,  
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito,
					porc_partic_agt,
					no_requis
					)
					values(
					'ERR',
					_no_poliza,
					_res_origen,
					_res_notrx,
					_res_comprobante,
					_res_db,
					_res_cr,
					0,
					_no_requis
					);					

		  else

			   select no_documento
			     into _no_documento
				 from emipomae
				where no_poliza = _no_poliza;

		   foreach
				select cod_agente,porc_partic_agt
				  into _cod_agente,_porc_partic_agt
				  from emipoagt
				 where no_poliza = _no_poliza

                 let _db_pro = _res_db * _porc_partic_agt / 100; 
				 let _cr_pro = _res_cr * _porc_partic_agt / 100;

					insert into prcoche(
					cod_agente,  
					no_poliza,
					res_origen,
					res_notrx,
					res_comprobante,
					debito,
					credito,
					porc_partic_agt,
					no_requis,
					no_documento
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
					_no_requis,
					_no_documento
					);					
										
		   end foreach
		  end if

	  end foreach

end foreach

end
end procedure