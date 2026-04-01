-- reporte de siniestros pagados solo facultativos
-- creado    : 28/03/2011 - autor: henry giron 
-- modificado: 28/03/2011 - autor: henry giron
-- sis v.2.0 - d_recl_sp_rec716_dw1 - deivid, s.a.

--execute procedure sp_rec716bk('001','001','2012-10','2012-12',"*","*","001,003,010,011,012,013,014,021,022","2013,2012,2011,2010,2009,2008","*")

drop procedure sp_rec716;
create procedure "informix".sp_rec716(
	a_compania	char(3),
	a_agencia	char(3),
	a_periodo1	char(7),
	a_periodo2	char(7),
	a_sucursal	char(255) default "*",
	a_contrato	char(255) default "*",
	a_ramo		char(255) default "*",
	a_serie		char(255) default "*",
	a_coasegur	char(255) default "*",
	a_documento CHAR(20)  DEFAULT "*",
	a_numrecla  CHAR(20)  DEFAULT "*")
	
returning	char(18),
			char(20),
			char(100),
			date,
			char(10),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(50),
			char(255),
			smallint,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			dec(5,2),
			dec(16,2);

define v_filtros			char(255);
define v_cliente_nombre		char(100);
define v_contrato_nombre	char(50);
define v_compania_nombre	char(50);
define n_cod_coasegur		char(50);
define v_ramo_nombre		char(50);
define v_doc_poliza			char(20);
define v_doc_reclamo		char(18);
define v_transaccion		char(10);
define _cod_cliente			char(10);     
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _periodo				char(7);      
define _cod_sucursal		char(3);
define _cod_coasegur		char(3);
define _cod_contrato		char(5);
define _cod_ramo			char(3);
define _cod_cobertura		char(5);
define _cod_cober_reas		char(3);
define _tipo				char(1);
define _porcentaje			dec(5,2);
define _porc_reas			dec(9,6);
define v_incurrido_cedido	dec(16,2);
define v_reserva_cedido		dec(16,2);
define _incurrido_bruto		dec(16,2);
define v_pagado_cedido		dec(16,2);
define _incurrido_neto		dec(16,2);
define _reserva_bruto		dec(16,2);
define _part_res_dist		dec(16,2);
define _pagado_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_total			dec(16,2);
define v_suma_pag			dec(16,2);
define v_suma_res			dec(16,2);
define _porc_coas			dec(16,2);
define _pag_cont			dec(16,2);
define _res_cont			dec(16,2);
define _part_res			dec(16,2);
define _pag_ret				dec(16,2);
define _pag_fac				dec(16,2);
define _res_ret				dec(16,2);
define _res_fac				dec(16,2);
define _exc_pag				dec(16,2);
define _exc_res				dec(16,2);
define _cp_pag				dec(16,2);
define _cp_res				dec(16,2);
define _pag_5				dec(16,2);
define _pag_7				dec(16,2);
define _res_5				dec(16,2);
define _res_7				dec(16,2);
define _tipo_contrato		smallint;
define _tiene_fac			smallint;
define _renglon				smallint;
define _serie				smallint;
define v_fecha_siniestro	date;

-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);

-- cargar el incurrido
-- let v_filtros = sp_rec35(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*'); -- se le adiciono salvamentos y deducibles.
let v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*','*'); 


-- cargar el incurrido
--drop table tmp_sinis;

-- tabla temporal para los contratos
create temp table tmp_rec716(
cod_contrato	char(5),
no_reclamo		char(10),
transaccion		char(10),
no_poliza		char(10),
cod_ramo		char(3),
periodo			char(7),
numrecla		char(18),
ultima_fecha	date,
pagado_bruto	dec(16,2) not null,
reserva_bruto	dec(16,2) not null,
incurrido_bruto	dec(16,2) not null,
pagado_neto		dec(16,2) not null,
reserva_neto	dec(16,2) not null,
incurrido_neto	dec(16,2) not null,
cp_pag			dec(16,2),
exc_pag			dec(16,2),
cp_res			dec(16,2),
exc_res			dec(16,2),
cod_sucursal	char(3)   not null,
serie			smallint,
ret_pag			dec(16,2),
fac_pag			dec(16,2),
cont_pag		dec(16,2),
ret_res			dec(16,2),
fac_res			dec(16,2),
cont_res		dec(16,2),
seleccionado	smallint  default 1 not null,
part_res		dec(16,2),
primary key (cod_contrato, no_reclamo)) with no log;

create index xie01_tmp_rec716 on tmp_rec716(cod_contrato);
create index xie02_tmp_rec716 on tmp_rec716(cod_ramo);
create index xie03_tmp_rec716 on tmp_rec716(no_poliza);
create index xie04_tmp_rec716 on tmp_rec716(no_reclamo);

create temp table tmp_dist716(
no_reclamo		char(10),
cod_coasegur	char(3),
porcentaje		dec(5,2),
monto_reas		dec(16,2),
seleccionado	smallint  default 1 not null,
primary key (no_reclamo,cod_coasegur)) with no log;
create index xie01_tmp_dist716 on tmp_dist716(no_reclamo);
create index xie02_tmp_dist716 on tmp_dist716(cod_coasegur);


--set debug file to 'sp_rec716.trc';
--trace on;

set isolation to dirty read;

IF a_documento <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where doc_poliza <> a_documento;  
END IF 

IF a_numrecla <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where numrecla <> a_numrecla;
END IF 

foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   no_tranrec,
		   cod_sucursal,
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
		   _no_tranrec,
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto,
		   _incurrido_bruto,
		   _pagado_neto,
		   _reserva_neto,
		   _incurrido_neto	
	  from tmp_sinis 
	 where seleccionado = 1
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,no_tranrec,cod_sucursal
	 order by cod_ramo,numrecla,no_tranrec

	let v_transaccion = 'TODOS';
	let v_fecha_siniestro = current;

   	if _pagado_bruto is null  then
		let _pagado_bruto = 0;
	end if

	if _pagado_neto is null  then
		let _pagado_neto = 0;
	end if

	if _pagado_neto = 0 and _pagado_bruto = 0 then
		continue foreach;
	end if

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	let _tiene_fac = 0;

	select count(*)
	  into _tiene_fac
	  from reacomae	a,recreaco b
	 where b.no_reclamo = _no_reclamo	
	   and a.cod_contrato = b.cod_contrato
	   and a.tipo_contrato = 3;

	if _tiene_fac = 0 then
		continue foreach;  -- solo facultativos
	end if

   	foreach
		select a.transaccion,
			   --a.variacion,
			   a.no_tranrec
		  into v_transaccion,
			   --_reserva_total,
			   _no_tranrec
		  from rectrmae a,rectitra b
		 where a.no_reclamo   = _no_reclamo
		   and a.actualizado  = 1
		   and a.cod_tipotran = b.cod_tipotran
		   and b.tipo_transaccion in (4,5,6,7)
		   and a.periodo  >= a_periodo1 
		   and a.periodo  <= a_periodo2
		   and a.monto   <> 0
		
		let _part_res_dist = 0;
		let v_suma_pag 	= 0;
		let v_suma_res 	= 0;
		let _part_res   = 0;
		let _pag_cont 	= 0;
		let _res_cont 	= 0;
		let _exc_pag 	= 0;
		let _pag_ret 	= 0;
		let _pag_fac 	= 0;
		let _res_ret 	= 0;
		let _res_fac 	= 0;
		let _exc_res  	= 0;
		let _cp_pag 	= 0;
		let _cp_res 	= 0;
		let _pag_5 		= 0;
		let _res_5 		= 0;
		let _pag_7 		= 0;
		let _res_7 		= 0;
			
		foreach
			select monto,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and monto <> 0
			   
			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			select porc_partic_coas
			  into _porc_coas
			  from reccoas
			 where no_reclamo   = _no_reclamo
			   and cod_coasegur = '036';
			   
			let _pagado_bruto = _monto_total * _porc_coas / 100;
			
			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas
			
				if _porc_reas is null then
					let _porc_reas = 0;
				end if

				select tipo_contrato, serie 
				  into _tipo_contrato, _serie 
				  from reacomae
				 where cod_contrato = _cod_contrato;

				let v_pagado_cedido    = _pagado_bruto    * _porc_reas / 100;
				let v_reserva_cedido   = _reserva_bruto   * _porc_reas / 100;
				let v_incurrido_cedido = _incurrido_bruto * _porc_reas / 100;

				if _tipo_contrato = 1 then
					let _pag_ret = _pag_ret + v_pagado_cedido;		   
					let _res_ret = _res_ret + v_reserva_cedido;		   
				elif _tipo_contrato = 3 then
					let _pag_fac = _pag_fac + v_pagado_cedido;
					let _res_fac = _res_fac + v_reserva_cedido;		   
				else
					let _pag_cont = _pag_cont + v_pagado_cedido;
					let _res_cont = _res_cont + v_reserva_cedido;		   

					if _tipo_contrato = 5 then
						let _pag_5 = _pag_5 + v_pagado_cedido;
						let _res_5 = _res_5 + v_pagado_cedido;
					end if
					if _tipo_contrato = 7 then
						let _pag_7 = _pag_7 + v_pagado_cedido;
						let _res_7 = _res_7 + v_pagado_cedido;
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
				let v_suma_res = _res_ret + _res_fac + _res_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;
			end foreach

			if _tipo_contrato = 3 then			--	solo facultativos
				foreach	
					 select orden,
							porc_partic_prima
					   into _renglon,
							_porc_reas
					   from rectrrea
					  where no_tranrec    = _no_tranrec
						and cod_cober_reas = _cod_cober_reas
						and tipo_contrato = _tipo_contrato
						
					let _part_res = _pagado_bruto * _porc_reas / 100 ;
					
					foreach
						select cod_coasegur,porc_partic_reas
						  into _cod_coasegur,_porcentaje
						  from rectrref
						 where no_tranrec = _no_tranrec 
						   and cod_cober_reas = _cod_cober_reas
						   and orden      = _renglon

						if _porcentaje is null then
							let _porcentaje = 0.00;
						end if

						if _porcentaje <> 0 then
							let _part_res_dist = _pagado_bruto * _porc_reas / 100 * _porcentaje / 100 ;
						else
							let _part_res_dist = 0;
						end if	

						begin
						on exception in(-239)
							update tmp_dist716
							   set monto_reas   = monto_reas + _part_res_dist
							 where no_reclamo   = _no_reclamo 
							   and cod_coasegur = _cod_coasegur;
						end exception

							insert into tmp_dist716(
							no_reclamo,
							cod_coasegur,
							porcentaje,
							monto_reas)
							values(
							_no_reclamo,
							_cod_coasegur,
							_porcentaje,
							_part_res_dist);

						end 	
					end foreach										
				end foreach
			else
				let _part_res = 0 ;
			end if 
		end foreach

		begin
			on exception in(-239)
				update tmp_rec716
				   set cp_pag       =  cp_pag  	    + _pag_5,
					   exc_pag      =  exc_pag      + _pag_7,
					   cp_res       =  cp_res  	    + _res_5,
					   exc_res      =  exc_res      + _res_7,
					   ret_pag      =  ret_pag      + _pag_ret,
					   fac_pag      =  fac_pag      + _pag_fac,
					   cont_pag     =  cont_pag     + _pag_cont,
					   ret_res      =  ret_res      + _res_ret,--_exc_ret,
					   fac_res      =  fac_res      + _res_fac,--_exc_fac,
					   cont_res     =  cont_res     + _res_cont,
					   part_res     =  part_res     + _part_res,
					   pagado_bruto = pagado_bruto  + _pagado_bruto,
					   pagado_neto  = pagado_neto   + _pagado_neto
				 where cod_contrato = _cod_contrato
				   and no_reclamo   = _no_reclamo;
	--			 and transaccion = v_transaccion ;
			end exception

			insert into tmp_rec716(
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
					part_res)
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
					_part_res);
		end 
	end foreach
end foreach

-- Procesos para Filtros
let v_filtros = "";

if a_sucursal <> "*" then

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  trim(a_sucursal);

	let _tipo = sp_sis04(a_sucursal);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "e" then -- incluir los registros
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_rec716
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
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contrato not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_rec716
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
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_serie <> "*" then

	let v_filtros = trim(v_filtros) || " Serie: " ||  trim(a_serie);

	let _tipo = sp_sis04(a_serie);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_rec716
		   set seleccionado = 0
		 where seleccionado = 1
		   and serie in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_coasegur <> "*" then
	let v_filtros = trim(v_filtros) || " Reasegurador : " ||  trim(a_coasegur);

	let _tipo = sp_sis04(a_coasegur);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_dist716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_coasegur not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_dist716
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_coasegur in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
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
		   serie,
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
		   sum(part_res)
	  into _no_reclamo,
		   v_transaccion,_no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   v_pagado_cedido,
		   v_reserva_cedido,
		   v_incurrido_cedido,
		   _serie,
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
		   _part_res 
	  FROM tmp_rec716
	 WHERE seleccionado = 1
	 group by no_reclamo,transaccion,no_poliza,cod_ramo,periodo,numrecla,pagado_bruto,reserva_bruto,incurrido_bruto,serie,pagado_neto,reserva_neto,incurrido_neto

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 

	let _pag_ret = 0;
	let _pag_cont = _cp_pag + _exc_pag;

	let v_transaccion = _no_reclamo ;

	select fecha_siniestro
	  into v_fecha_siniestro
	  from recrcmae
	 where no_reclamo = _no_reclamo;


	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select no_documento,
		   cod_contratante	
	  into v_doc_poliza,
	       _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre 
	  into v_cliente_nombre	
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	let _tiene_fac = 0;

	select count(*)
	  into _tiene_fac
	  from tmp_dist716
	 where no_reclamo = _no_reclamo 
	   and seleccionado = 1;

	if _tiene_fac = 0 then
		let n_cod_coasegur = '';
		let _porcentaje =  0;
		let _part_res_dist = 0;

		if a_coasegur <> "*" then
			continue foreach;
		end if
	else
		foreach	
			select cod_coasegur,
				   porcentaje,
				   monto_reas
			  into _cod_coasegur,
				   _porcentaje,
				   _part_res_dist
			  from tmp_dist716
			 where no_reclamo = _no_reclamo 
			   and seleccionado = 1
			   and porcentaje <> 0

			select nombre
			  into n_cod_coasegur
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

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
				   _serie,				  --13
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
					_part_res_dist,       --_part_res,
					n_cod_coasegur,
					_porcentaje,
					_part_res_dist with resume;

		end foreach
	end if
end foreach

drop table tmp_sinis;
drop table tmp_rec716;
drop table tmp_dist716;

end procedure;