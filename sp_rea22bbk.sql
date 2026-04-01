-- Reporte de Perfil de Siniestros Pagados
-- Creado    : 09/08/2010 - Autor: Henry Giron 
-- Modificado: 09/08/2010 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec715_dw1 - DEIVID, S.A.
--execute procedure sp_rea22b('001','001','2014-07','2015-03',"*","*","001,003;","2014,2013,2012,2011,2010,2009,2008;","*")

drop procedure sp_rea22b;
create procedure "informix".sp_rea22b(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_contrato	char(255) default "*",
a_ramo		char(255) default "*",
a_serie		char(255) default "*",
a_subramo	char(255) default "*") 
returning	smallint;
--RETURNING CHAR(3),CHAR(50),dec(16,2),dec(16,2),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

define v_filtros1			varchar(255);  		 
define v_filtros			varchar(255);
define v_cliente_nombre		varchar(100);    
define v_contrato_nombre	varchar(50);     
define v_compania_nombre	varchar(50);     
define v_ramo_nombre		varchar(50);     
define v_descr_cia			varchar(50);  		 
define v_desc_ramo			varchar(50);			 
define v_doc_poliza			char(20);     
define v_doc_reclamo		char(18);     
define v_transaccion		char(10);     
define _cod_cliente			char(10);     
define v_no_reclamo			char(10);
define _transaccion			char(10);
define _no_reclamo			char(10);     
define _no_tranrec			char(10);			 
define _no_poliza			char(10);     
define v_nopoliza			char(10);           
define v_periodo			char(7);        	 
define _periodo				char(7);      
define _cod_cobertura		char(5);
define v_cod_contrato		char(5);			 
define _cod_contrato		char(5);     
define v_no_unidad			char(5);
define v_noendoso			char(5);			 
define _cod_sucursal		char(3);      
define v_cod_ramo			char(3);
define _cod_ramo			char(3);      
define _tipo				char(1);
define _cod_cober_reas		char(3);
define v_cobertura			char(3);  		 
define v_cod_tipo2			char(3);  		 
define v_cod_tipo			char(3);			 
define _t_ramo				char(1);			 
define _porc_coas			decimal;--dec(7,4);
define v_porc_partic_prima	dec(9,6);
define v_incurrido_cedido	dec(16,2);
define v_reserva_cedido		dec(16,2);
define v_suma_asegurada		dec(16,2);			 
define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define v_rango_inicial		dec(16,2);           
define v_pagado_cedido		dec(16,2);
define _reserva_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define v_facultativo		dec(16,2);
define v_rango_final		dec(16,2);           
define _pagado_bruto		dec(16,2);
define _pagado_neto			dec(16,2);
define v_prima_tipo			dec(16,2);
define _monto_total			dec(16,2);
define _sum_fac_car			dec(16,2);
define v_acumulado			dec(16,2);
define v_acumulada			dec(16,2);
define _fac_car_1			dec(16,2);
define _fac_car_2			dec(16,2);
define _fac_car_3			dec(16,2);
define v_retenida			dec(16,2);
define v_cobrada			dec(16,2);
define v_bouquet			dec(16,2);
define v_fac_car			dec(16,2);
define _porc_reas			decimal;
define v_suma_pag			dec(16,2);
define v_suma_res			dec(16,2);
define v_prima_bq			dec(16,2);			 
define v_prima_ot			dec(16,2);			 
define _pag_cont			dec(16,2);
define _res_cont			dec(16,2);
define v_prima_7			dec(16,2);
define v_prima_5			dec(16,2);
define v_prima_3			dec(16,2);			 
define v_prima_1			dec(16,2);			 
define v_prima1				dec(16,2);     		 
define _pag_ret				dec(16,2);
define _pag_fac				dec(16,2);
define _res_ret				dec(16,2);
define _res_fac				dec(16,2);
define _exc_pag				dec(16,2);
define _exc_res				dec(16,2);
define v_otros				dec(16,2);			 
define ld_comp				dec(16,2);
define v_prima				dec(16,2);    		 
define _cp_pag				dec(16,2);
define _cp_res				dec(16,2);
define _pag_7				dec(16,2);
define _pag_5				dec(16,2);
define _res_5				dec(16,2);
define _res_7				dec(16,2);
define v_tipo_contrato		smallint;           
define _tipo_contrato		smallint;
define _facilidad_car		smallint;
define v_porcentaje			smallint;			 
define v_no_cambio			smallint;
define _cnt_existe			smallint;
define v_contador			smallint;
define _cantidad			smallint;  		 
define _bouquet				smallint;			 
define _serie				smallint;
define _cnt					smallint;
define _cant_pol			integer;
define v_fecha_siniestro	date;


-- Nombre de la Compania
LET v_compania_nombre = sp_sis01(a_compania);
LET v_descr_cia       = sp_sis01(a_compania);

let v_acumulada = '0.00';
let v_acumulado = '0.00';

LET v_filtros = sp_rec704(a_compania,a_agencia,a_periodo1,a_periodo2,a_sucursal,'*',a_ramo,'*','*','*','*',a_subramo); 

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis;
CREATE TEMP TABLE tmp_ramos_rea(
cod_ramo		CHAR(3),
cod_sub_tipo	CHAR(3),
porcentaje		SMALLINT default 100,
PRIMARY KEY(cod_ramo, cod_sub_tipo)) WITH NO LOG;

--CREATE INDEX xie01_tmp_ramos_rea ON tmp_ramos_rea(cod_ramo);
--CREATE INDEX xie01_tmp_ramos_rea ON tmp_ramos_rea(cod_sub_tipo);

-- Tabla Temporal para los Contratos
CREATE TEMP TABLE tmp_contrato1(
cod_contrato	CHAR(5),
no_reclamo		CHAR(10),
transaccion		CHAR(10),
no_poliza		CHAR(10),
cod_ramo		CHAR(3),
periodo			CHAR(7),
numrecla		CHAR(18),
ultima_fecha	DATE,
pagado_bruto	DEC(16,2) NOT NULL,
reserva_bruto	DEC(16,2) NOT NULL,
incurrido_bruto	DEC(16,2) NOT NULL,
pagado_neto		DEC(16,2) NOT NULL,
reserva_neto	DEC(16,2) NOT NULL,
incurrido_neto	DEC(16,2) NOT NULL,
cp_pag			DEC(16,2),
exc_pag			DEC(16,2),
cp_res			DEC(16,2),
exc_res			DEC(16,2),
cod_sucursal	CHAR(3)   NOT NULL,
serie			SMALLINT,
ret_pag			DEC(16,2),
fac_pag			DEC(16,2),
cont_pag		DEC(16,2),
ret_res			DEC(16,2),
fac_res			DEC(16,2),
cont_res		DEC(16,2),
fac_car_1		DEC(16,2),
fac_car_2		DEC(16,2),
fac_car_3		DEC(16,2),
seleccionado	SMALLINT DEFAULT 1 NOT NULL,
cod_cobertura	char(5),
PRIMARY KEY (cod_contrato, no_reclamo)) WITH NO LOG;

CREATE INDEX xie01_tmp_contrato1 ON tmp_contrato1(cod_contrato);
CREATE INDEX xie02_tmp_contrato1 ON tmp_contrato1(cod_ramo);
CREATE INDEX xie03_tmp_contrato1 ON tmp_contrato1(no_poliza);
CREATE INDEX xie04_tmp_contrato1 ON tmp_contrato1(no_reclamo);

SET ISOLATION TO DIRTY READ;
delete from tmp_dif;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
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
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto,
		   _incurrido_bruto,
		   _pagado_neto,
		   _reserva_neto,
		   _incurrido_neto	
	  from tmp_sinis 
	 where seleccionado = 1
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal--,fecha,transaccion,
	 order by cod_ramo,numrecla

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

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	foreach
		select a.transaccion,
			   a.no_tranrec
		  into _transaccion,
			   _no_tranrec
		  from rectrmae a,rectitra b
		 where a.no_reclamo   = _no_reclamo
		   and a.actualizado  = 1
		   and a.cod_tipotran = b.cod_tipotran
		   and b.tipo_transaccion in (4,5,6,7)
		   and a.periodo  >= a_periodo1 
		   and a.periodo  <= a_periodo2
		   and a.monto   <> 0
		   
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

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF
			let _pagado_bruto = 0;
			LET _pagado_bruto = _monto_total  / 100 * _porc_coas;
		
			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_existe is null or _cnt_existe = 0 then
				RETURN -1;
			end if

			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas
				   
				let _fac_car_1  = 0; 
				let _fac_car_2  = 0;
				let _fac_car_3  = 0;
				let v_suma_pag 	= 0;
				let v_suma_res 	= 0;
				let _pag_cont 	= 0;
				let _res_cont 	= 0;
				let _pag_ret 	= 0;
				let _pag_fac 	= 0;
				let _res_ret 	= 0;
				let _res_fac 	= 0;
				let _exc_pag 	= 0;
				let _exc_res  	= 0;
				let _cp_pag 	= 0;
				let _cp_res 	= 0;
				let _pag_5 		= 0;
				let _res_5 		= 0;
				let _pag_7 		= 0;
				let _res_7 		= 0;				   
			
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
					elif _tipo_contrato = 7 then
						if _facilidad_car = 1 then 
						else
							let _pag_7 = _pag_7 + v_pagado_cedido;
							let _res_7 = _res_7 + v_pagado_cedido;
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

					let _fac_car_1 = _pag_ret + _pag_fac + _pag_cont;	  -- pago
					let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos
					let _fac_car_3 = _cp_res + _exc_res;					  -- reserva

					let _fac_car_1 = 0; 
					let _fac_car_2 = 0;
					let _fac_car_3 = 0;
					let _pag_cont  = 0;
					let _res_cont  = 0;
					let _pag_ret   = 0; 
					let _pag_fac   = 0;
					let _exc_pag   = 0;
					let _exc_res   = 0;
					let _res_ret   = 0; 
					let _res_fac   = 0;
					let _cp_res    = 0;
					let _cp_pag    = 0;
				end if
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
							   ret_res      =  ret_res      + _res_ret, --_exc_res,
							   fac_res      =  fac_res      + _res_fac, --_exc_fac,
							   cont_res     =  cont_res     + _res_cont,
							   fac_car_1	=  fac_car_1	+ _fac_car_1,
							   fac_car_2	=  fac_car_2	+ _fac_car_2,
							   fac_car_3	=  fac_car_3	+ _fac_car_3
						 where cod_contrato = _cod_contrato
						   and no_reclamo   = _no_reclamo;
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
							cod_cobertura)
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
							_cod_cobertura);
				end				
			end foreach	--ciclo de rectrmae
			
		end foreach	--ciclo de rectrcob


	end foreach
end foreach

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

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

	DROP TABLE tmp_codigos;

END IF			   

-- Inactiva los reclamos de tmp_sinis 
foreach
	select distinct cod_ramo,
		   no_poliza,
		   no_reclamo
	  into v_cod_ramo,
		   v_nopoliza,
		   _no_reclamo
	  from tmp_contrato1
	 where seleccionado = 0

	update tmp_sinis
	   set seleccionado = 0
	 where seleccionado = 1
	   and cod_ramo =  v_cod_ramo
	   and no_poliza = 	v_nopoliza 
	   and no_reclamo =  _no_reclamo;
end foreach

--- tabla de ramos:

foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from tmp_contrato1
	 where seleccionado = 1

	if v_cod_ramo in ("INI", "INT") THEN
		if v_cod_ramo in ("001") then
			let _t_ramo = "1";
		elif v_cod_ramo in ("003") then
			let _t_ramo = "3";
		end if

		begin
			on exception in(-239)
			end exception

		    let v_cod_tipo = "IN"||_t_ramo;

			insert into tmp_ramos_rea(cod_ramo,cod_sub_tipo,porcentaje)
			values (v_cod_ramo,v_cod_tipo,70);

		end
	else
		insert into tmp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
		values (v_cod_ramo,v_cod_ramo,100);
	end if	   	
end foreach

let v_prima_tipo = 0;
let v_prima_bq = 0;
let v_prima_ot = 0;
let _fac_car_1 = 0;
let _fac_car_2 = 0;
let _fac_car_3 = 0;
let v_prima_1  = 0;
let v_prima_3  = 0;
let v_prima_5  = 0;
let v_prima_7  = 0;

--**********
foreach
	select distinct cod_ramo, 
		   no_poliza 
	  into v_cod_ramo, 
		   v_nopoliza 
	  from tmp_contrato1 
	 where seleccionado = 1 

	select sum(pagado_bruto), 		
		   sum(pagado_neto)
	  into v_prima,
		   v_prima_1
	  from tmp_sinis 
	 where no_poliza    = v_nopoliza	
	   and cod_ramo     = v_cod_ramo 
	   and seleccionado = 1;

	if 	v_prima is null then
		let v_prima = 0;
	end if

	if 	v_prima_1 is null then
		let v_prima_1 = 0;
	end if

	select suma_asegurada
	  into v_suma_asegurada
	  from emipomae 
	 where no_poliza    = v_nopoliza
	   and cod_compania = "001"
	   and actualizado  = 1;

	let _sum_fac_car  = 0;

	foreach
		select cod_contrato,
			   cod_cobertura,
			   sum(fac_pag),
			   sum(cp_pag),
			   sum(exc_pag),
			   sum(ret_pag),
			   sum(cont_pag),
			   sum(fac_car_1),
			   sum(fac_car_2),
			   sum(fac_car_3)
		  into v_cod_contrato,
			   _cod_cobertura,
			   v_prima_3,
			   v_prima_5,
			   v_prima_7,
			   _pag_ret,			  
			   _pag_cont,
			   _fac_car_1,
			   _fac_car_2,
			   _fac_car_3			   	
		  from tmp_contrato1
		 where cod_ramo     = v_cod_ramo
		   and no_poliza    = v_nopoliza 
		   and seleccionado = 1
		  group by cod_contrato,cod_cobertura

		let v_prima_tipo =  v_prima_5 + v_prima_7; -- + _fac_car_2 ;

		let v_no_cambio = null;

		select cod_cober_reas
		  into v_cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		select bouquet 
		  into _bouquet 
		  from reacocob 
		 where cod_contrato   = v_cod_contrato 
		   and cod_cober_reas = v_cobertura;

		let _facilidad_car = 0;

		select facilidad_car
		  into _facilidad_car
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		if _bouquet = 1 or v_cobertura in ('021','015') then
			if _facilidad_car = 1 then --contratos excedente, pero que son facilidad car y deben salir en la columna de facilidad car.armando 28/08/2012
				let _sum_fac_car = _sum_fac_car + v_prima_tipo;
			else					
				let v_prima_bq = v_prima_bq + v_prima_tipo;					
			end if			
		end if 

		let v_prima_tipo = 0;
	end foreach

	select sum(fac_pag),
		   sum(cp_pag),
		   sum(exc_pag),
		   sum(fac_car_1),
		   sum(fac_car_2),
		   sum(fac_car_3)			   			   
	  into v_prima_3,
		   v_prima_5,
		   v_prima_7,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3
	  from tmp_contrato1
	 where cod_ramo     = v_cod_ramo
	   and no_poliza    = v_nopoliza 
	   and seleccionado = 1;

	let v_prima_ot = (v_prima_5 + v_prima_7) - v_prima_bq - _sum_fac_car; 
	
	select parinfra.rango1, 
		   parinfra.rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where cod_ramo = v_cod_ramo 
	   and rango1 <= v_suma_asegurada 
	   and rango2 >= v_suma_asegurada; 

	if v_rango_inicial is null then
		let v_rango_inicial = 0;	

		select rango2
		  into v_rango_final
		  from parinfra
		 where cod_ramo = v_cod_ramo
		   and parinfra.rango1 = v_rango_inicial;
	end if;

	foreach
		select cod_sub_tipo, porcentaje
		  into v_cod_tipo, v_porcentaje
		  from tmp_ramos_rea
		 where cod_ramo = v_cod_ramo										

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		if v_cod_tipo[1,2] = "IN" then
			let v_desc_ramo = Trim(v_desc_ramo)||"-INCENDIO";
		elif v_cod_tipo[1,2] = "TE" then
			let v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";
		end if
			 
			 let ld_comp = v_prima - (v_prima_1 + v_prima_bq +	v_prima_3 + v_prima_Ot);

			 if	abs(ld_comp) > 10 then     
				INSERT INTO tmp_dif (cod_ramo,no_poliza,prima,prima1,prima3,prima5,prima7,primabq)
				VALUES (v_cod_tipo,v_nopoliza,v_prima,v_prima_1,v_prima_3,v_prima_5,v_prima_7,v_prima_bq);
			 end if
			{IF v_cod_ramo <> '003' OR v_cod_ramo <> '001' THEN 
				
			END IF}
			
			let v_prima = v_prima_1 + v_prima_3 + v_prima_Ot + _fac_car_1 + v_prima_bq;
			
			     BEGIN
			        ON EXCEPTION IN(-239)
			           UPDATE tmp_tabla_rea
			              SET cant_polizas1   = cant_polizas1   + 1,
				 		      p_cobrada1      = p_cobrada1      + v_prima * v_porcentaje/100,   		
						 	  p_retenida1     = p_retenida1     + v_prima_1 * v_porcentaje/100,	
						 	  p_bouquet1      = p_bouquet1      + v_prima_bq * v_porcentaje/100,	
						 	  p_facultativo1  = p_facultativo1  + v_prima_3 * v_porcentaje/100,
						 	  p_otros1		  = p_otros1        + v_prima_Ot * v_porcentaje/100,
							  p_fac_car1	  = p_fac_car1      + _fac_car_1 * v_porcentaje/100,
							  p_acumulada1    = 0.00
					/*        fac_car_1	     = fac_car_1      + _fac_car_1 * v_porcentaje/100,
			                  fac_car_2	     = fac_car_2      + _sum_fac_car * v_porcentaje/100,
			                  fac_car_3	     = fac_car_3      + _fac_car_3 * v_porcentaje/100       */
			            WHERE cod_ramo       = v_cod_tipo  
			              AND rango_inicial  = v_rango_inicial  
			              AND rango_final    = v_rango_final;  

			           END EXCEPTION

			          INSERT INTO tmp_tabla_rea
							(cod_ramo,							
							 desc_ramo,							
							 rango_inicial,					
							 rango_final,  					
							 cant_polizas1, 					
							 p_cobrada1,    					
							 p_retenida1,   					
							 p_bouquet1,    					
							 p_facultativo1,					
							 p_otros1,
							 p_fac_car1,
							 p_acumulada
							)
					  VALUES(v_cod_tipo, 
							 v_desc_ramo, 
							 v_rango_inicial, 
							 v_rango_final, 
							 1, 
							 v_prima    * v_porcentaje/100, 
							 v_prima_1  * v_porcentaje/100, 
							 v_prima_bq * v_porcentaje/100, 
							 v_prima_3  * v_porcentaje/100, 
							 v_prima_Ot * v_porcentaje/100, 
							 _fac_car_1 * v_porcentaje/100,
							 10.00
							 );				 
			       END
			
		   END FOREACH

	        LET v_prima    	  = 0; 
			LET v_prima_1  	  = 0;
			LET v_prima_3  	  = 0;
			LET v_prima_5  	  = 0;
			LET v_prima_7  	  = 0;
			LET v_prima_bq 	  = 0;
			LET v_prima_Ot 	  = 0;
			LET v_prima_tipo  = 0;
			LET _pag_ret      = 0;			  
			LET _pag_cont     = 0;
			LET _fac_car_1    = 0;
			LET _fac_car_2    = 0;
			LET _fac_car_3    = 0;

END FOREACH

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('001','003');

if _cnt = 2 then

	foreach
		 select rango_inicial,
		        sum(p_retenida1),
				sum(p_bouquet1),
				sum(p_facultativo1),
				sum(p_otros1), 
				sum(p_fac_car1), 
				sum(p_cobrada1),
				sum(cant_polizas1)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('001','003')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	     from tmp_tabla_rea
		WHERE cod_ramo      = '001'
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol
			 WHERE cod_ramo       = '001'  
	   		   AND rango_inicial  = v_rango_inicial;  
	   else
			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol,
				   cod_ramo       = '001'
			 WHERE cod_ramo       = '003'  
	   		   AND rango_inicial  = v_rango_inicial;  

	   end if

		 delete from tmp_tabla_rea
		  where cod_ramo = '003'
		    and rango_inicial = v_rango_inicial;

	end foreach
end if

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('010','011','012','014','013','022');


if _cnt > 1 then

	foreach

		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('010','011','012','014','013','022')

	    exit foreach;

	end foreach

	foreach
		 select rango_inicial,
		        sum(p_retenida1),
				sum(p_bouquet1),
				sum(p_facultativo1),
				sum(p_otros1), 
				sum(p_fac_car1), 
				sum(p_cobrada1),
				sum(cant_polizas1)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('010','011','012','014','013','022')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	     from tmp_tabla_rea
		WHERE cod_ramo      = v_cod_tipo
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol
			 WHERE cod_ramo       = v_cod_tipo
			   AND rango_inicial  = v_rango_inicial;  

	   else

		  foreach
			   select distinct cod_ramo
			     into v_cod_tipo2
			     from tmp_tabla_rea
			    where cod_ramo in('010','011','012','014','013','022')
			      and rango_inicial = v_rango_inicial
			  exit foreach;
		  end foreach


			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol,
				   cod_ramo       = v_cod_tipo
			 WHERE cod_ramo       = v_cod_tipo2
			   AND rango_inicial  = v_rango_inicial;  


	   end if

		 delete from tmp_tabla_rea
		  where cod_ramo not in(v_cod_tipo)
		    and cod_ramo in('010','011','012','014','013','022')
		    and rango_inicial = v_rango_inicial;  

	end foreach

end if
-------
select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('015','007');


if _cnt > 1 then

	foreach

		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('015','007')

	    exit foreach;

	end foreach

	foreach
		 select rango_inicial,
		        sum(p_retenida1),
				sum(p_bouquet1),
				sum(p_facultativo1),
				sum(p_otros1), 
				sum(p_fac_car1), 
				sum(p_cobrada1),
				sum(cant_polizas1)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('015','007')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	     from tmp_tabla_rea
		WHERE cod_ramo      = v_cod_tipo
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol
			 WHERE cod_ramo       = v_cod_tipo
			   AND rango_inicial  = v_rango_inicial;  

	   else

		  foreach
			   select distinct cod_ramo
			     into v_cod_tipo2
			     from tmp_tabla_rea
			    where cod_ramo in('015','007')
			      and rango_inicial = v_rango_inicial
			  exit foreach;
		  end foreach


			update tmp_tabla_rea
			   set p_retenida1    = v_retenida,
				   p_bouquet1	  = v_bouquet, 
				   p_facultativo1 = v_facultativo,
				   p_otros1		  = v_otros, 
				   p_fac_car1	  = v_fac_car, 
				   p_cobrada1	  = v_cobrada,
				   cant_polizas1  = _cant_pol,
				   cod_ramo       = v_cod_tipo
			 WHERE cod_ramo       = v_cod_tipo2
			   AND rango_inicial  = v_rango_inicial;  


	   end if

		 delete from tmp_tabla_rea
		  where cod_ramo not in(v_cod_tipo)
		    and cod_ramo in('015','007')
		    and rango_inicial = v_rango_inicial;  

	end foreach

end if

RETURN 0;
DROP TABLE tmp_sinis;
DROP TABLE tmp_ramos_rea;
DROP TABLE tmp_contrato1;

--DROP TABLE tmp_tabla_rea;

END PROCEDURE
			 