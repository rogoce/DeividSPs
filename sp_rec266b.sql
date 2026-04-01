--execute procedure sp_rec706('001','001','2014-06','2014-06',"*","*","002;","*","*")
drop procedure sp_rec266b;
create procedure "informix".sp_rec266b(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_contrato	char(255) default "*",
a_ramo		char(255) default "*",
a_serie		char(255) default "*",
a_cober		char(255) default "*")
returning	char(50)	as Ramo,					--9
			char(20)	as Poliza,					--2
			date        as Fecha_Suscripcion,
			date		as Vigencia_Inic,			--31
			date		as Vigencia_Final,			--32
			dec(16,2)	as Suma_Asegurada,			--30
			char(100)	as Cliente,					--3
			char(18)	as Numrecla,				--1
			char(10)	as Transaccion,				--5
			date		as Fecha_Siniestro,			--4
			char(15)	as Serie_Char,				--13
			char(30)	as Coberertura_Reaseguro,	--33
			dec(9,6)	as Porc_Partic_Prima,		--37
			dec(16,2)	as Reserva_Bruta, 			--7
			dec(16,2)	as Reserva_Neto,			--15
			dec(16,2)	as Retencion,				--24
			dec(16,2)	as Retencion_Casco,			--34
			dec(16,2)	as Contrato,				--26
			dec(16,2)	as Cuota_Parte,				--19
			dec(16,2)	as Excedente,				--20
			dec(16,2)	as Otros_Contratos,			--35
			dec(16,2)	as Facultativo,				--25
			dec(16,2)	as fac_car_1,				--27
			dec(16,2)	as fac_car_2,				--28
			dec(16,2)	as fac_car_3,				--29
			char(255)	as Filtros,					--12
			char(50)	as Compania,
			varchar(100) as Beneficiario_Pago,
			varchar(255) as Patologia,
			varchar(50) as Tipo_Servicio;	    --11

-- Reporte de Siniestros Incurridos
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec706_dw1 - DEIVID, S.A.

define v_filtros			char(255);
define v_cliente_nombre		char(100);  
define v_contrato_nombre	char(50);
define v_compania_nombre	char(50);
define v_ramo_nombre		char(50);
define _n_cober				char(30);
define _no_documento		char(20);
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
define _no_unidad           char(5);
define _serie_c				char(4);
define _cod_cober_reas		char(3);
define _cod_sucursal		char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define _porc_partic_prima	dec(9,6);
define v_incurrido_cedido	dec(16,2);
define v_reserva_cedido		dec(16,2);
define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define _suma_asegurada		dec(16,2);
define v_pagado_cedido		dec(16,2);
define _reserva_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _res_otros			dec(16,2);
define _ret_casco			dec(16,2);
define v_suma_pag			dec(16,2);
define v_suma_res			dec(16,2);
define _fac_car_1			dec(16,2);
define _fac_car_2			dec(16,2);
define _fac_car_3			dec(16,2);	
define _inc_bruto			dec(16,2);
define _pag_cont			dec(16,2);
define _res_cont			dec(16,2);
define _pag_ret				dec(16,2);
define _pag_fac				dec(16,2);
define _res_ret				dec(16,2);
define _res_fac				dec(16,2);
define _exc_pag				dec(16,2);
define _exc_res				dec(16,2);
define _exc_fac				dec(16,2);
define _exc_ret				dec(16,2);
define _cp_pag				dec(16,2);
define _cp_res				dec(16,2);
define _pag_5				dec(16,2);
define _pag_7				dec(16,2);
define _res_5				dec(16,2);
define _res_7				dec(16,2);
define v_xl					dec(16,2);
define _facilidad_car		smallint;
define _tipo_contrato		smallint;
define _si_hay				smallint;
define _serie1				smallint;
define _serie				smallint;
define _cnt3				smallint;
define _cnt					smallint;
define _cant                integer;
define v_fecha_siniestro	date;
define _vigencia_inic		date;
define _dt_siniestro		date;
define _vig_ini				date;
define _vig_fin				date;
define _porc_reas			dec;
define _porc_coas			dec;
define _cod_evento          char(10);
define _n_evento            varchar(50);
define v_nombre_tr        varchar(100);
define _cod_icd           char(10);
define v_icd              varchar(255);
define _cod_concepto      char(3);
define v_concepto         varchar(50);
define _fecha_suscripcion date;

set isolation to dirty read;

drop table if exists tmp_sinis;
drop table if exists tmp_contrato1;

-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);
call sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') returning v_filtros; 

--set debug file to "sp_rec706.trc"; 
--trace on; 
let _n_evento = '';

-- Tabla Temporal para los Contratos
create temp table tmp_contrato1(
periodo			char(7),
no_poliza		char(10),
cod_sucursal	char(3)   not null,
cod_ramo		char(3),
cod_subramo		char(3),
numrecla		char(18),
no_reclamo		char(10),
transaccion		char(10),
no_tranrec		char(10),
cod_contrato	char(5),
cod_cobertura	char(5),
cod_cober_reas	char(3),
serie			smallint,
serie_char		char(15),
porc_partic_ret	dec(9,6),
reserva_bruto	dec(16,2) not null,
reserva_neto	dec(16,2) not null,
ret_res			dec(16,2),
ret_casco		dec(16,2),
cont_res		dec(16,2),
cp_res			dec(16,2),
exc_res			dec(16,2),
res_otros		dec(16,2),
fac_res			dec(16,2),
fac_car_1		dec(16,2),
fac_car_2		dec(16,2),
fac_car_3		dec(16,2),
seleccionado	smallint  default 1 not null,
primary key (no_tranrec, cod_cober_reas)) with no log;


foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   sum(reserva_bruto),
		   sum(reserva_neto)
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _reserva_bruto,
		   _reserva_neto
	  from tmp_sinis
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;
	end if

	select no_documento,
		   vigencia_inic
	  into _no_documento,
		   _vigencia_inic
	  from emipomae 
	 where no_poliza = _no_poliza;

	{if _vigencia_inic < '01/07/2014' then
		continue foreach;
	end if}
	
	select count(*) 
	  into _cnt 
	  from reaexpol 
	 where no_documento = _no_documento
       and activo       = 1;  			--Tabla para excluir polizas

    if _cnt > 0 then
		continue foreach;
	end if

	let v_transaccion = 'TODOS';
	let v_fecha_siniestro = current;


   	if _reserva_bruto is null  then
		let _reserva_bruto = 0;
	end if
	if _reserva_neto is null  then
		let _reserva_neto = 0;
	end if

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
		exit foreach;
	end foreach

	{IF _reserva_neto = 0 and _reserva_bruto = 0 then
		CONTINUE FOREACH;
	END IF}

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	let _cod_contrato = null;	

	foreach 
		select no_tranrec
		  into _no_tranrec
		  from rectrmae 
		 where cod_compania = a_compania
		   and periodo     <= a_periodo2 
		   and actualizado  = 1
		   and no_reclamo   = _no_reclamo

		foreach
			select variacion,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and variacion <> 0

			select cod_cober_reas
			  into _cod_cober_reas
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
			let _cod_contrato = null;

			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

				let _res_ret 	= 0;
				let _res_fac 	= 0;
				let _res_cont 	= 0;
				let v_suma_pag 	= 0;
				let v_suma_res 	= 0;
				let _cp_res 	= 0;
				let _exc_res  	= 0;
				let _res_5 		= 0;
				let _res_7 		= 0;
				let _fac_car_1  = 0;
				let _fac_car_2  = 0;
				let _fac_car_3  = 0;
				let _ret_casco  = 0;
				let _res_otros  = 0;
				
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

				let v_reserva_cedido = _monto_bruto * _porc_reas / 100;
				let _serie_char = "";
				let _serie_c    = "";
				let _serie_c    = _serie;
				let _serie_char = _serie_c;
				
				if _cnt3 > 0 and _serie >= 2011 then
					let _serie_char = _serie_c || ' INUNDACION';
				end if

				if _tipo_contrato = 1 then --retencion
					if (_cod_ramo = '002' and _cod_cober_reas = '031') or (_cod_ramo = '023' and _cod_cober_reas = '034' ) then
						let _ret_casco = _ret_casco + v_reserva_cedido; 
					else
						let _res_ret = _res_ret + v_reserva_cedido;
					end if
				elif _tipo_contrato = 3 then
					let _res_fac = _res_fac + v_reserva_cedido;		   
				else
					let _res_cont = _res_cont + v_reserva_cedido;		   

					if _tipo_contrato = 5 then
						let _res_5 = _res_5 + v_reserva_cedido;
					elif _tipo_contrato = 7 then
						let _res_7 = _res_7 + v_reserva_cedido;
					else
						let _res_otros = _res_otros + v_reserva_cedido;
					end if
				end if

				let v_suma_res = _res_ret + _res_fac + _res_cont;

				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;

				if _facilidad_car = 1 then
					let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- pago
					let _fac_car_2 = _cp_res + _exc_res;					  -- reserva
					let _fac_car_3 = _cp_pag + _exc_pag;					  -- contratos
					--let _res_ret  = 0; 
					--let _res_fac  = 0;
					let _res_cont = 0;
				end if
				
				if _cod_contrato is null then
					continue foreach;
				end if
				
				--Calculo de Reserva Neta 13/11/2013
				let _reserva_neto = _res_ret + _ret_casco;
				
				--Calculo de Reserva Neta 07/10/2014
				let _reserva_bruto = _res_ret + _ret_casco + _res_cont + _res_fac;
				
				begin
					on exception in(-239)
						update tmp_contrato1
						   set cp_res       = cp_res		+ _res_5,
							   exc_res      = exc_res		+ _res_7,
							   ret_res      = ret_res		+ _res_ret,
							   fac_res      = fac_res		+ _res_fac,
							   res_otros	= res_otros		+ _res_otros,
							   cont_res     = cont_res		+ _res_cont,
							   fac_car_1	= fac_car_1		+ _fac_car_1,
							   fac_car_2	= fac_car_2		+ _fac_car_2,
							   fac_car_3	= fac_car_3		+ _fac_car_3,
							   ret_casco    = ret_casco		+ _ret_casco,
							   reserva_neto = reserva_neto	+ _reserva_neto,
							   reserva_bruto = reserva_bruto + _reserva_bruto
						 where no_tranrec = _no_tranrec
						   and cod_cober_reas = _cod_cober_reas;
					end exception

					insert into tmp_contrato1(
							cod_contrato,
							no_reclamo,           
							transaccion,
							no_poliza,           
							cod_ramo,            
							periodo,             
							numrecla,            
							reserva_bruto,       
							cod_sucursal,
							serie,
							reserva_neto,       
							cp_res,
							exc_res,
							res_otros,
							ret_res,
							fac_res,
							cont_res,
							fac_car_1,
							fac_car_2,
							fac_car_3,
							cod_cobertura,
							serie_char,
							ret_casco,
							cod_cober_reas,
							no_tranrec)
					values(	_cod_contrato,
							_no_reclamo,
							v_transaccion,           
							_no_poliza,           
							_cod_ramo,            
							_periodo,             
							v_doc_reclamo,            
							_reserva_bruto,       
							_cod_sucursal,
							_serie,
							_reserva_neto,       
							_res_5,
							_res_7,
							_res_otros,
							_res_ret,
							_res_fac,
							_res_cont,
							_fac_car_1,
							_fac_car_2,
							_fac_car_3,
							_cod_cobertura,
							_serie_char,
							_ret_casco,
							_cod_cober_reas,
							_no_tranrec);
				end 
			end foreach
			
			select porc_partic_prima
			  into _porc_partic_prima
			  from rectrrea r, reacomae c
			 where c.cod_contrato = r.cod_contrato
			   and no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas
			   and c.tipo_contrato = 1;

			if _porc_partic_prima is null then
				let _porc_partic_prima = 0.00;
			end if

			update tmp_contrato1
			   set porc_partic_ret = _porc_partic_prima
			 where no_tranrec = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;
		end foreach
	end foreach
end foreach

-- Procesos para Filtros

let v_filtros = "";

if a_sucursal <> "*" THEN

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  trim(a_sucursal);

	let _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);

	else		        -- Excluir estos Registros
		update tmp_contrato1
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

IF a_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Contrato: " ||  TRIM(a_contrato);

	LET _tipo = sp_sis04(a_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_serie <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Serie: " ||  TRIM(a_serie);

	LET _tipo = sp_sis04(a_serie);  -- Separa los Valores del String en una tabla de codigos

   	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN (SELECT codigo FROM tmp_codigos);

	END IF	 

END IF

IF a_serie <> "*" THEN
	DROP TABLE tmp_codigos;
END IF

IF a_cober <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobertura: " ||  TRIM(a_cober);

	LET _tipo = sp_sis04(a_cober);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobertura NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobertura IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


let _inc_bruto = 0;
foreach
	select no_reclamo,           
		   transaccion,
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   serie_char,
		   reserva_bruto,
		   reserva_neto,
		   cp_res,
		   exc_res,
		   res_otros,
		   ret_res,
		   fac_res,
		   cont_res,
		   fac_car_1,
		   fac_car_2,
		   fac_car_3,
		   ret_casco,
		   porc_partic_ret,
		   no_tranrec,
		   cod_cober_reas
	  into _no_reclamo,
		   v_transaccion,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _serie_char,
		   v_reserva_cedido,
		   _reserva_neto,
		   _cp_res,
		   _exc_res,
		   _res_otros,
		   _res_ret,
		   _res_fac,
		   _res_cont,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3,
		   _ret_casco,
		   _porc_partic_prima,
		   _no_tranrec,
		   _cod_cober_reas
	  FROM tmp_contrato1
	 WHERE seleccionado = 1

	if v_reserva_cedido = 0 and _reserva_neto = 0 then
		continue Foreach;
	end if

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 

	 --let _res_ret = 0;
	let _res_cont = _cp_res + _exc_res ; --v_reserva_cedido - _reserva_neto;
	
	select transaccion, 
	       cod_cliente
	  into v_transaccion, 
	       _cod_cliente
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	select nombre
	  into v_nombre_tr
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	--LET v_transaccion = _no_reclamo ;

	{LET v_XL = v_reserva_cedido - _reserva_neto;

	if v_XL <> _res_cont then
		-- Informacion de Reaseguro
		LET _porc_reas = 0;

	    FOREACH
		SELECT recreaco.porc_partic_suma
		  INTO _porc_reas
		  FROM recreaco, reacomae
		 WHERE recreaco.no_reclamo    = _no_reclamo
		   AND recreaco.cod_contrato  = reacomae.cod_contrato
		   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;
		EXIT FOREACH;
		END FOREACH

		LET _reserva_neto = ( v_reserva_cedido * _porc_reas ) / 100;
		
	end if}

	select fecha_siniestro,
		   no_unidad,
		   cod_evento,
		   cod_icd
	  into v_fecha_siniestro,
		   _no_unidad,
		   _cod_evento,
		   _cod_icd
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre
      into v_icd
      from recicd
	 where cod_icd = _cod_icd;

	let _cod_concepto = null;
	let v_concepto = null;
	
    foreach
		select cod_concepto
		  into _cod_concepto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		 
		exit foreach;	
    end foreach	

	select nombre
	  into v_concepto
	  from recconce
	 where cod_concepto = _cod_concepto;
	 
	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _n_cober
	  from reacobre
	 where cod_cober_reas = _cod_cober_reas;

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin,
		   _fecha_suscripcion
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into v_cliente_nombre		
	  from cliclien 
	 where cod_cliente = _cod_cliente;

    select count(*)
	  into _cant
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	RETURN	v_ramo_nombre,		--9
			v_doc_poliza,		--2
			_fecha_suscripcion,
			_vig_ini,			--31
			_vig_fin,			--32
			_suma_asegurada,	--30
			v_cliente_nombre,	--3
			v_doc_reclamo,		--1
			v_transaccion,		--5
			v_fecha_siniestro,	--4
			_serie_char,		--13
			_n_cober,			--33
			_porc_partic_prima,	--37
			v_reserva_cedido,	--7
			_reserva_neto,		--15
			_res_ret,			--24
			_ret_casco,			--34
			_res_cont,			--6		     		     
			_cp_res,			--19
			_exc_res,			--20
			_res_otros,			--35
			_res_fac,			--25
			_fac_car_1,			--27
			_fac_car_2,			--28
			_fac_car_3,			--29
			v_filtros,			--12
			v_compania_nombre,	--11
		    v_nombre_tr,           --12
		    v_icd,                 --13
		    v_concepto             --14
			with resume;
end foreach

drop table tmp_sinis;
drop table tmp_contrato1;

end procedure;	   