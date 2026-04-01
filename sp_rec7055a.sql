--execute procedure sp_rec7055('001','001','2012-01','2012-03',"*","*","001,003,004,005,008,010,011,012,013,014,022","2012,2011,2010,2009,2008;")
-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros
--execute procedure sp_rec7055a('001','001','2016-05','2016-05','*','*','002,020,023;','2015,2014,2013,2012,2011,2010,2009,2008;','*')

drop procedure sp_rec7055a;
create procedure "informix".sp_rec7055a(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255)	default "*",
a_contrato	char(255)	default "*",
a_ramo		char(255)	default "*",
a_serie		char(255)	default "*",
a_subramo	char(255)	default "*") 

returning	char(18)		as Reclamo,
			char(20)		as Poliza,
			char(100)		as Cliente,
			date			as Fecha_Siniestro,
			char(10)		as Transaccion,
			dec(16,2)		as Pagado_Bruto,
			dec(16,2)		as Reserva_Bruta,
			dec(16,2)		as Incurrido_Bruto,
			char(50)		as Ramo,
			char(50)		as Contrato,
			char(50)		as Compania,
			char(255)		as Filtros,
			char(15)		as Serie,
			dec(16,2)		as Pagado_Neto,
			dec(16,2)		as Reserva_Neta,
			dec(16,2)		as Incurrido_Neto,
			dec(16,2)		as CP_Otros_pag,
			dec(16,2)		as Excedente_pag,
			dec(16,2)		as Res_CP,
			dec(16,2)		as Res_Excedente,
			dec(16,2)		as Ret_Pag,
			dec(16,2)		as Facultativo_Pag,
			dec(16,2)		as Contrato_Pag,
			dec(16,2)		as Ret_Res,
			dec(16,2)		as Facultativo_Res,
			dec(16,2)		as Contrato_Res,
			dec(16,2)		as Fac_Car1,
			dec(16,2)		as Fac_Car2,
			dec(16,2)		as Fac_Car3,
			dec(16,2)		as Suma_Asegurada,
			date			as Vigencia_Inic,
			date			as Vigencia_Final,	
			char(30)		as Cobertura,
			dec(16,2)		as Ret_Casco_Pag,
			dec(16,2)		as Ret_RC_pag,
			dec(16,2)		as Cp_Rc_pag,
			dec(16,2)		as Cp_Casco_pag;

define v_filtros			char(255);
define v_cliente_nombre		char(100);
define v_compania_nombre	char(50);
define v_contrato_nombre	char(50);
define v_ramo_nombre		char(50);
define _n_cober				char(30);
define v_doc_poliza			char(20);
define v_doc_reclamo		char(18);
define _serie_char			char(15);
define v_transaccion		char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_contrato		char(5);
define _serie_c				char(4);
define _cod_cober_reas		char(3);
define _cod_cober_reas2		char(3);
define _cod_sucursal		char(3);
define _cod_subramo			char(3);
define _cod_ramo          	char(3);
define _tipo				char(1);
define v_incurrido_cedido	dec(16,2);
define _incurrido_bruto		dec(16,2);
define v_reserva_cedido		dec(16,2);
define _incurrido_neto		dec(16,2);
define v_pagado_cedido		dec(16,2);
define _reserva_bruto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _ret_otros			dec(16,2);
define v_suma_pag			dec(16,2);
define v_suma_res			dec(16,2);
define _ret_casco			dec(16,2);
define _fac_car_1			dec(16,2);
define _fac_car_2			dec(16,2);
define _fac_car_3			dec(16,2);
define _pag_cont			dec(16,2);
define _res_cont			dec(16,2);
define _cp_casco			dec(16,2);
define _suma_as				dec(16,2);
define _pag_ret				dec(16,2);
define _pag_fac				dec(16,2);
define _res_ret				dec(16,2);
define _res_fac				dec(16,2);
define _exc_pag				dec(16,2);
define _exc_res				dec(16,2);
define _cp_pag				dec(16,2);
define _cp_res				dec(16,2);
define _cp_rc				dec(16,2);
define _pag_5				dec(16,2);
define _pag_7				dec(16,2);
define _res_5				dec(16,2);
define _res_7				dec(16,2);
define _causa_siniestro		smallint;
define _facilidad_car		smallint;
define _tipo_contrato		smallint;
define _ramo_sis			smallint;
define _cnt_existe			smallint;
define _serie2				smallint;
define _serie1				smallint;
define _si_hay				smallint;
define _serie				smallint;
define _cnt3				smallint;
define v_fecha_siniestro	date;
define _dt_siniestro		date;
define _vig_ini				date;
define _vig_fin				date;
define _porc_coas			dec;
define _porc_reas			dec;


--DEFINE _exc_ret           DECIMAL(16,2);

--DROP TABLE tmp_sinis;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_sinis;
drop table if exists tmp_contrato1;

-- Cargar el Incurrido
--LET v_filtros = sp_rec35(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*'); -- se le adiciono salvamentos y deducibles.
LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*','*'); 
--LET v_filtros = "Ramo: 002,020,023; Serie: 2015;";
let _ret_casco = 0;

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

-- Tabla Temporal para los Contratos
create temp table tmp_contrato1(
cod_contrato		 char(5),
no_reclamo           char(10),
transaccion			 char(10),
no_poliza            char(10),
cod_ramo             char(3),
periodo              char(7),
numrecla             char(18),
ultima_fecha         date,
pagado_bruto         dec(16,2) not null,
reserva_bruto        dec(16,2) not null,
incurrido_bruto      dec(16,2) not null,
pagado_neto          dec(16,2) not null,
reserva_neto         dec(16,2) not null,
incurrido_neto       dec(16,2) not null,
cp_pag 		         dec(16,2),
exc_pag    			 dec(16,2),
cp_res 		         dec(16,2),
exc_res    			 dec(16,2),
cod_sucursal         char(3)   not null,
serie                smallint,
ret_pag 		     dec(16,2),
fac_pag    			 dec(16,2),
cont_pag    		 dec(16,2),
ret_res 		     dec(16,2),
fac_res    			 dec(16,2),
cont_res    		 dec(16,2),
fac_car_1 	         dec(16,2),
fac_car_2 	         dec(16,2),
fac_car_3 	         dec(16,2),
seleccionado         smallint  default 1 not null,
cod_subramo          char(3),
serie_char           char(15),
ret_casco            dec(16,2),
ret_otros            dec(16,2),
cp_casco			dec(16,2),
cp_rc				dec(16,2),
primary key (cod_contrato, no_reclamo, serie_char)) with no log;
create index xie01_tmp_contrato1 on tmp_contrato1(cod_contrato);
create index xie02_tmp_contrato1 on tmp_contrato1(cod_ramo);
create index xie03_tmp_contrato1 on tmp_contrato1(no_poliza);
create index xie04_tmp_contrato1 on tmp_contrato1(no_reclamo);
create index xie05_tmp_contrato1 on tmp_contrato1(cod_subramo);

--set debug file to 'sp_rec705.trc';
--trace on;

set isolation to dirty read;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --tabla para excluir polizas
 
 { update tmp_sinis
   set seleccionado = 0;
   
update tmp_sinis
   set seleccionado = 1
 where doc_poliza in('0298-09664-01');  }
 

foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   cod_subramo,
		   sum(pagado_bruto),
		   sum(reserva_bruto),
		   sum(incurrido_bruto),
		   sum(pagado_neto),
		   sum(reserva_neto),
		   sum(incurrido_neto)
	  into _no_reclamo, 		
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _cod_subramo,
		   _pagado_bruto,
		   _reserva_bruto,
		   _incurrido_bruto,
		   _pagado_neto,
		   _reserva_neto,
		   _incurrido_neto	
	  from tmp_sinis
	 where seleccionado = 1
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
	 order by cod_ramo,numrecla

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;
	end if

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let v_transaccion = 'TODOS';
	let v_fecha_siniestro = current;

   	if _pagado_bruto is null  then
		let _pagado_bruto = 0;
	end if

	if _pagado_neto is null  then
		let _pagado_neto = 0;
	end if

	if _pagado_neto = 0 and _pagado_bruto = 0 then
		--continue foreach;
	end if

	-- informacion de reaseguro para sacar la distribucion de
	-- los contratos

	let _cod_contrato = null;

   	foreach
		select a.no_tranrec
		  into _no_tranrec
		  from rectrmae a,rectitra b
		 where a.no_reclamo   = _no_reclamo
		   and a.actualizado  = 1
		   and a.cod_tipotran = b.cod_tipotran
		   and b.tipo_transaccion in (4,5,6,7)
		   and a.periodo  >= a_periodo1
		   and a.periodo  <= a_periodo2
		   and a.monto   <> 0
		
		let _facilidad_car = 0;
		let _fac_car_1 = 0;
		let v_suma_pag = 0;
		let v_suma_res = 0;
		let _fac_car_2 = 0;
		let _fac_car_3 = 0;
		let _ret_casco = 0;
		let _ret_otros = 0;
		let _res_cont = 0;
		let _pag_cont = 0;
		let _pag_ret = 0;
		let _pag_fac = 0;
		let _res_ret = 0;
		let _res_fac = 0;
		let _exc_res = 0;
		let _exc_pag = 0;
		let _cp_casco = 0;
		let _cp_rc = 0;
		let _cp_pag = 0;
		let _cp_res = 0;
		let _pag_5 = 0;
		let _res_5 = 0;
		let _pag_7 = 0;
		let _res_7 = 0;
				
		foreach
			select monto,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0

			select cod_cober_reas,
				   causa_siniestro
			  into _cod_cober_reas,
				   _causa_siniestro
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			select porc_partic_coas
			  into _porc_coas
			  from reccoas
			 where no_reclamo   = _no_reclamo
			   and cod_coasegur = '036';

			if _porc_coas is null then
				let _porc_coas = 0;
			end if
		 
			let _monto_bruto = 0;
			let _monto_bruto = _monto_total  / 100 * _porc_coas;

			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			let _cod_cober_reas2 = _cod_cober_reas;

			if _cnt_existe is null or _cnt_existe = 0 then
				if _cod_cober_reas in ('031','034') then
					if _cod_cober_reas = '031' then
						let _cod_cober_reas2 = '002';
					else
						let _cod_cober_reas2 = '033';
					end if
					
					select count(*)
					  into _cnt_existe
					  from rectrrea
					 where no_tranrec     = _no_tranrec
					   and cod_cober_reas = _cod_cober_reas2;

					if _cnt_existe is null or _cnt_existe = 0 then

						RETURN	v_doc_reclamo,         --1
								'',		  --2
								'', 	  --3
								'01/01/1900', 	  --4
								_no_tranrec,		  --5
								0,		  --6
								0,  	  --7
								0,	  --8
								'',		  --9
								'',	  --10
								'',	  --11
								'No hay Distribucion de Reaseguro para la Transaccion: ' || _no_tranrec || ' '  || _cod_cober_reas,			  --12
								'',			  --13
								0,          --14
								0,         --15
								0,		  --16
								0,				  --17
								0,			  --18
								0,				  --19
								0,			  --20
								0,			  --21
								0,			  --22
								0,			  --23
								0,			  --24
								0,			  --25
								0,			  --26
								0,			  --27
								0,			  --28
								0,			  --29
								0,
								'01/01/1900',
								'01/01/1900',
								'',
								0,
								0,
								0,
								0;
					end if
				else
					RETURN v_doc_reclamo,         --1
								'',		  --2
								'', 	  --3
								'01/01/1900', 	  --4
								_no_tranrec,		  --5
								0,		  --6
								0,  	  --7
								0,	  --8
								'',		  --9
								'',	  --10
								'',	  --11
								'No hay Distribucion de Reaseguro para la Transaccion: ' || _no_tranrec || ' '  || _cod_cober_reas,			  --12
								'',			  --13
								0,          --14
								0,         --15
								0,		  --16
								0,				  --17
								0,			  --18
								0,				  --19
								0,			  --20
								0,			  --21
								0,			  --22
								0,			  --23
								0,			  --24
								0,			  --25
								0,			  --26
								0,			  --27
								0,			  --28
								0,			  --29
								0,
								'01/01/1900',
								'01/01/1900',
								'',
								0,
								0,
								0,
								0;
				end if
			end if
			 
			 
			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas2

				select tipo_contrato,
					   serie,
					   facilidad_car
				  into _tipo_contrato,
					   _serie,
					   _facilidad_car
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _porc_reas is null then
					let _porc_reas = 0;
				end if

				let v_pagado_cedido    = _monto_bruto    * _porc_reas / 100;

				let _serie_char = "";
				let _serie_c    = "";
				let _serie_c    = _serie;
				let _serie_char = _serie_c;
				if _cnt3 > 0 and _serie >= 2011 then
					let _serie_char = _serie_c || ' INUNDACION';
				end if

				if _tipo_contrato = 1 then

					if _ramo_sis = 1 then
						if _cod_cober_reas in ('031','034') then
							let _ret_casco = _ret_casco + v_pagado_cedido;
						else
							if _causa_siniestro in (1,7,8) then
							--if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
								let _pag_ret = _pag_ret + v_pagado_cedido;
							else
								let _ret_otros = _ret_otros + v_pagado_cedido;							
							end if
						end if
					else
						let _ret_otros = _ret_otros + v_pagado_cedido;
					end if
				elif _tipo_contrato = 3 then
					let _pag_fac = _pag_fac + v_pagado_cedido;
				else
					let _pag_cont = _pag_cont + v_pagado_cedido;

					if _tipo_contrato = 5 then
						if _ramo_sis = 1 then
							if _cod_cober_reas in ('031','034') then
								let _cp_casco = _cp_casco + v_pagado_cedido;
							else
								if _causa_siniestro in (1,7,8) then
								--if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
									let _cp_rc = _cp_rc + v_pagado_cedido;
								else
									let _pag_5 = _pag_5 + v_pagado_cedido;							
								end if
							end if
						else
							let _pag_5 = _pag_5 + v_pagado_cedido;
						end if
					elif _tipo_contrato = 7 then
						if _facilidad_car = 1 then
						else
							let _pag_7 = _pag_7 + v_pagado_cedido;
						end if
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
				let v_suma_res = _res_ret + _res_fac + _res_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;

				if _facilidad_car = 1 then --_cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then

				   let _fac_car_1 = _fac_car_1 + v_pagado_cedido;--_pag_fac +_pag_ret + _pag_cont;	  -- pago
				   let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos
				   let _fac_car_3 = _cp_res + _exc_res;					  -- reserva

				   let _cp_pag   = 0;
				   let _exc_pag  = 0;
				   --let _pag_ret  = 0; 
				   let _pag_fac  = 0;
				   let _pag_cont = 0;
				   let _res_ret  = 0; 
				   let _res_fac  = 0;
				   let _res_cont = 0;

				end if
			end foreach	 --rectrrea
		end foreach	 --rectrcob

		if _cod_contrato is null then
			continue foreach;
		end if
		 
		let _pagado_neto = _ret_casco + _pag_ret + _ret_otros;

		begin
			on exception in(-239)
				update tmp_contrato1
				   set cp_pag       =  cp_pag  	    + _pag_5,
					   exc_pag      =  exc_pag      + _pag_7,
					   cp_res       =  cp_res  	    + _res_5,
					   exc_res      =  exc_res      + _res_7,
					   ret_pag      =  ret_pag      + _pag_ret,
					   fac_pag      =  fac_pag      + _pag_fac,
					   cont_pag     =  cont_pag     + _pag_cont,
					   ret_res      =  ret_res      + _res_ret,
					   fac_res      =  fac_res      + _res_fac,
					   cont_res     =  cont_res     + _res_cont,
					   fac_car_1	=  fac_car_1	+ _fac_car_1,
					   fac_car_2	=  fac_car_2	+ _fac_car_2,
					   fac_car_3	=  fac_car_3	+ _fac_car_3,
					   cp_rc    	=  cp_rc    	+ _cp_rc,
					   cp_casco    =  cp_casco      + _cp_casco,
					   ret_casco    =  ret_casco    + _ret_casco,
					   ret_otros    =  ret_otros    + _ret_otros,
					   pagado_neto  =  pagado_neto  + _pagado_neto
				 where cod_contrato = _cod_contrato
				   and no_reclamo   = _no_reclamo
				   and serie_char   = _serie_char;
			end exception

			insert into tmp_contrato1(
					cod_contrato,
					no_reclamo,           
					transaccion,
					no_poliza,           
					cod_ramo,            
					periodo,             
					numrecla,            
					pagado_bruto,        
					reserva_bruto,       
					incurrido_bruto,
					cod_sucursal,
					serie,
					pagado_neto,        
					reserva_neto,       
					incurrido_neto,
					cp_pag,
					exc_pag,
					cp_res,
					exc_res,
					ret_pag,
					fac_pag,
					cont_pag,
					ret_res,
					fac_res,
					cont_res,
					fac_car_1,
					fac_car_2,
					fac_car_3,
					cod_subramo,
					serie_char,
					ret_casco,
					ret_otros,
					cp_rc,
					cp_casco)
			values(	_cod_contrato,
					_no_reclamo,
					v_transaccion,           
					_no_poliza,           
					_cod_ramo,            
					_periodo,             
					v_doc_reclamo,            
					_pagado_bruto,        
					_reserva_bruto,       
					_incurrido_bruto,
					_cod_sucursal,
					_serie,
					_pagado_neto,        
					_reserva_neto,       
					_incurrido_neto,
					_pag_5,
					_pag_7,
					_res_5,
					_res_7,
					_pag_ret,
					_pag_fac,
					_pag_cont,
					_res_ret,
					_res_fac,
					_res_cont,
					_fac_car_1,
					_fac_car_2,
					_fac_car_3,
					_cod_subramo,
					_serie_char,
					_ret_casco,
					_ret_otros,
					_cp_rc,
					_cp_casco);
		end 
	end foreach
end foreach

-- Procesos para Filtros

let v_filtros = "";

if a_sucursal <> "*" then

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  trim(a_sucursal);

	let _tipo = sp_sis04(a_sucursal);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_contrato <> "*" then

	let v_filtros = trim(v_filtros) || " Contrato: " ||  trim(a_contrato);

	let _tipo = sp_sis04(a_contrato);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros

		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: " ||  trim(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros

		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);

	else		        -- (e) excluir estos registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_subramo <> "*" then
	let v_filtros = trim(v_filtros) ||" Sub Ramo "||trim(a_subramo);
	let _tipo = sp_sis04(a_subramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_contrato1
	       set seleccionado = 0
	     where seleccionado = 1
	       and cod_subramo not in(select codigo from tmp_codigos);
	else
		update tmp_contrato1
	       set seleccionado = 0
	     where seleccionado = 1
	       and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_serie <> "*" then

	let v_filtros = trim(v_filtros) || " Serie: " ||  trim(a_serie);
	let _tipo = sp_sis04(a_serie);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in (select codigo from tmp_codigos);

	else		        -- (e) excluir estos registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie in (select codigo from tmp_codigos);

	end if
	--drop table tmp_codigos;
end if

foreach
	select no_reclamo,
		   transaccion,
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   pagado_bruto,
		   reserva_bruto,
		   incurrido_bruto,
		   serie_char,
		   pagado_neto,
		   reserva_neto,
		   incurrido_neto,
		   sum(cp_pag),
		   sum(exc_pag),
		   sum(cp_res),
		   sum(exc_res),
		   sum(ret_pag),
		   sum(fac_pag),
		   sum(cont_pag),
		   sum(ret_res),
		   sum(fac_res),
		   sum(cont_res),
		   sum(fac_car_1),
		   sum(fac_car_2),
		   sum(fac_car_3),
		   sum(cp_casco),
		   sum(cp_rc),
		   sum(ret_casco),
		   sum(ret_otros)
	  into _no_reclamo,
		   v_transaccion,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   v_pagado_cedido,
		   v_reserva_cedido,
		   v_incurrido_cedido,
		   _serie_char,
		   _pagado_neto,
		   _reserva_neto,
		   _incurrido_neto,
		   _cp_pag,
		   _exc_pag,
		   _cp_res,
		   _exc_res,
		   _pag_ret,
		   _pag_fac,
		   _pag_cont,
		   _res_ret,
		   _res_fac,
		   _res_cont,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3,
		   _cp_casco,
		   _cp_rc,
		   _ret_casco,
		   _ret_otros
	  from tmp_contrato1
	 where seleccionado = 1
	 group by no_reclamo,transaccion,no_poliza,cod_ramo,periodo,numrecla,pagado_bruto,reserva_bruto,incurrido_bruto,serie_char,pagado_neto,reserva_neto,incurrido_neto

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 
--	let _pag_ret = 0;
	--let _pag_cont = _cp_pag + _exc_pag;
 
	let _pag_cont = _cp_pag + _exc_pag + _cp_casco + _cp_rc;
	let v_transaccion = _no_reclamo ;

	select fecha_siniestro
	  into v_fecha_siniestro
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
    end foreach

	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_as,
		   _vig_ini,
		   _vig_fin
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre 
	  into v_cliente_nombre	
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	if _cod_ramo = '006' then
	   let v_ramo_nombre = 'R.C.G.';
	   let _n_cober = "1";
	elif _cod_ramo = '001' or _cod_ramo = '003' then
	   let v_ramo_nombre = 'Incendio';
	   let _n_cober = "2";
	elif _cod_ramo in("010","011","012","013","014","021","022") then
	   let v_ramo_nombre = 'Ramos Tecnicos';
	   let _n_cober = "3";
	elif _cod_ramo = '008' then
	   let v_ramo_nombre = 'Fianzas';
	   let _n_cober = "4";
	elif _cod_ramo = '004' then
	   let v_ramo_nombre = 'Acc. Personales';
	   let _n_cober = "5";
	elif _cod_ramo = '019' then
	   let v_ramo_nombre = 'Vida Indindividual';
	   let _n_cober = "7";
	elif _cod_ramo = '016' then
	   let v_ramo_nombre = 'Colectivo de Vida';
	   let _n_cober = "6";
	else
	   let _n_cober = "8";
	end if

	let v_pagado_cedido = 0;
	--let v_pagado_cedido = _pag_cont + _pag_ret + _ret_casco + _ret_otros + _pag_fac + _fac_car_1 + _cp_rc +_cp_casco;  -- estaba asi
		--let v_pagado_cedido = _pag_cont + _pag_ret + _pag_ret_casco + _pag_fac + _fac_car_1 + _pag_ret_otros;            -- sp_rec705a		
		
		let v_pagado_cedido =  _cp_rc + _cp_casco + _cp_pag + _ret_casco + _ret_otros + _pag_ret +_exc_pag + _pag_fac ;

	
---	/***************** la serie cambia por la vigencia del contrato ********/

	return v_doc_reclamo,         --1
	       v_doc_poliza,		  --2
	 	   v_cliente_nombre, 	  --3
	 	   v_fecha_siniestro, 	  --4
		   v_transaccion,		  --5
		   v_pagado_cedido,		  --6
		   v_reserva_cedido,  	  --7
		   v_incurrido_cedido,	  --8
		   v_ramo_nombre,		  --9
		   v_contrato_nombre,	  --10
		   v_compania_nombre,	  --11
		   v_filtros,			  --12
		   _serie_char,			  --13
		   _pagado_neto,          --14
		   _reserva_neto,         --15
	       _incurrido_neto,		  --16
		   _cp_pag,				  --17
		   _exc_pag,			  --18
	       _cp_res,				  --19
		   _exc_res,			  --20
		   _pag_ret,			  --21
		   _pag_fac,			  --22
		   _pag_cont,			  --23
		   _res_ret,			  --24
		   _res_fac,			  --25
		   _res_cont,			  --26
		   _fac_car_1,			  --27
		   _fac_car_1,			  --28
		   _fac_car_3,			  --29
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _n_cober,
		   _ret_casco,
		   _ret_otros,
		   _cp_rc,
		   _cp_casco
		   with resume;

end foreach

if a_serie <> "*" then
	drop table tmp_codigos;
end if

drop table tmp_sinis;
drop table tmp_contrato1;
end procedure;