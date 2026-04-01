-- Reporte de Perfil de Siniestros Pagados
-- Creado    : 09/08/2010 - Autor: Henry Giron 
-- Modificado: 09/08/2010 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec715_dw1 - DEIVID, S.A.
--execute procedure sp_rea25b('001','001','2014-07','2015-03',"*","*","001,003;","2014,2013,2012,2011,2010,2009,2008;","*")

drop procedure sp_rea25b_1;
create procedure "informix".sp_rea25b_1(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",  --a_codsucursal
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",  --a_codramo
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*",
a_subramo		char(255) default "*")
--returning	smallint;
returning	char(3),
			char(50),
			dec(16,2),
			dec(16,2),
			smallint,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			smallint,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			smallint,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(100),
			char(255),
			dec(16,2), --;  Se adiciona 3 columnas de retencion y 3 contratos (Primas Cobradas (rpt Izquierda)) 
			dec(16,2), -- ret_rc
			dec(16,2), -- ret_otros 
			dec(16,2), -- ret_casco 
			dec(16,2), -- bqx_rc
			dec(16,2), -- bqx_otros 
			dec(16,2), --; -- 2 -- bqx_casco 			
			dec(16,2), -- ret_rc
			dec(16,2), -- ret_otros 
			dec(16,2), -- ret_casco 
			dec(16,2), -- bqx_rc
			dec(16,2), -- bqx_otros 
			dec(16,2), --; -- 3 -- bqx_casco 	
			dec(16,2), -- ret_rc
			dec(16,2), -- ret_otros 
			dec(16,2), -- ret_casco 
			dec(16,2), -- bqx_rc
			dec(16,2), -- bqx_otros 
			dec(16,2); -- bqx_casco 

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
define _no_unidad			char(5);
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
define _pag_ret_otros		dec(16,2);
define _pag_ret_casco		dec(16,2);
define _pag_ret_rc			dec(16,2);
define _fac_car_1			dec(16,2);
define _fac_car_2			dec(16,2);
define _fac_car_3			dec(16,2);
define v_retenida			dec(16,2);
define v_cobrada			dec(16,2);
define v_bouquet			dec(16,2);
define v_fac_car			dec(16,2);
define _cp_otros			dec(16,2);
define _cp_casco			dec(16,2);
define _cp_rc				dec(16,2);
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
define _ramo_sis			smallint;  		 
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

LET v_filtros = sp_rec704(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,'*',a_codramo,'*','*','*','*',a_subramo); 

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
no_unidad		CHAR(5),
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
cp_pag_rc		DEC(16,2),
cp_pag_otros	DEC(16,2),
cp_pag_casco	DEC(16,2),
exc_pag			DEC(16,2),
otros_cont_pag	DEC(16,2),
cp_res			DEC(16,2),
exc_res			DEC(16,2),
cod_sucursal	CHAR(3)   NOT NULL,
serie			SMALLINT,
ret_pag			DEC(16,2),
ret_pag_rc		DEC(16,2),
ret_pag_otros	DEC(16,2),
ret_pag_casco	DEC(16,2),
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

create temp table tmp_tabla_rea(
cod_ramo			char(3),
desc_ramo			char(50),
rango_inicial		dec(16,2),
rango_final			dec(16,2),
cant_polizas1		integer  default 0,
p_cobrada1			dec(16,2) default 0,
p_retenida1			dec(16,2) default 0,
p_retenida_otros	dec(16,2) default 0,
p_retenida_rc       dec(16,2) default 0,
p_retenida_casco	dec(16,2) default 0,
p_bouquet1        	dec(16,2) default 0,
p_bouquet_otros    	dec(16,2) default 0,
p_bouquet_rc        dec(16,2) default 0,
p_bouquet_casco		dec(16,2) default 0,
p_facultativo1		dec(16,2) default 0,
p_otros1			dec(16,2) default 0,
p_fac_car1			dec(16,2) default 0,
p_acumulada			dec(16,2) default 0,
p_filtro			char(255), 
p_suma_asegurada	dec(16,2),
no_documento		char(20) default '',
primary key (cod_ramo,rango_inicial,rango_final)) with no log;

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
		   sum(pagado_neto)
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _pagado_bruto,
		   _pagado_neto
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

	select no_unidad
	  into _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

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

			if _porc_coas is null then
				let _porc_coas = 0;
			end if

			let _pagado_bruto = 0;
			LET _pagado_bruto = _monto_total  / 100 * _porc_coas;
		
			let _cnt_existe = 0;

			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if
			
			if _cnt_existe = 0 then
				--RETURN -1;
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
				let v_prima_ot 	= 0;
				let _pag_cont 	= 0;
				let _res_cont 	= 0;
				let _pag_ret 	= 0;
				let _pag_ret_rc = 0;
				let _pag_ret_casco = 0;
				let _pag_ret_otros = 0;
				let _pag_fac 	= 0;
				let _res_ret 	= 0;
				let _res_fac 	= 0;
				let _exc_pag 	= 0;
				let _exc_res  	= 0;
				let _cp_pag 	= 0;
				let _cp_res 	= 0;
				let _cp_rc	 	= 0;
				let _cp_otros 	= 0;
				let _cp_casco 	= 0;
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

				let v_pagado_cedido = _pagado_bruto * _porc_reas / 100;
				
				if _tipo_contrato = 1 then
					let _pag_ret = _pag_ret + v_pagado_cedido;

					if _ramo_sis = 1 then
						if _cod_cober_reas in ('031','034') then
							let _pag_ret_casco = _pag_ret_casco + v_pagado_cedido;
						else
							if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
								let _pag_ret_rc = _pag_ret_rc + v_pagado_cedido;
							else
								let _pag_ret_otros = _pag_ret_otros + v_pagado_cedido;							
							end if
						end if
					else
						let _pag_ret_otros = _pag_ret_otros + v_pagado_cedido;
					end if
				elif _tipo_contrato = 3 then
					let _pag_fac = _pag_fac + v_pagado_cedido;
				else
					let _pag_cont = _pag_cont + v_pagado_cedido;

					if _tipo_contrato = 5 then
						let _pag_5 = _pag_5 + v_pagado_cedido;
						
						if _ramo_sis = 1 then
							if _cod_cober_reas in ('031','034') then
								let _cp_casco = _cp_casco + v_pagado_cedido;
							else
								if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
									let _cp_rc = _cp_rc + v_pagado_cedido;
								else
									let _cp_otros = _cp_otros + v_pagado_cedido;							
								end if
							end if
						else
							let _cp_otros = _cp_otros + v_pagado_cedido;
						end if
					elif _tipo_contrato = 7 then
						if _facilidad_car = 1 then 
						else
							let _pag_7 = _pag_7 + v_pagado_cedido;
						end if
					else
						let v_prima_ot = v_prima_ot + v_pagado_cedido;
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				if _facilidad_car = 1 then --_cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then

					let _fac_car_1 = _pag_ret + _pag_fac + _pag_cont;	  -- pago
					let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos
					--let _fac_car_3 = _cp_res + _exc_res;					  -- reserva

					--let _fac_car_1 = 0; 
					--let _fac_car_2 = 0;
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
					let v_prima_ot = 0;
				end if

				
				begin
					on exception in(-239)
						update tmp_contrato1
						   set cp_pag       	=  cp_pag  	    + _pag_5,
							   cp_pag_rc		= cp_pag_rc + _cp_rc,
							   cp_pag_otros		= cp_pag_otros + _cp_otros,
							   cp_pag_casco		= cp_pag_casco + _cp_casco,
							   exc_pag      	=  exc_pag      + _pag_7,
							   ret_pag      	=  ret_pag      + _pag_ret,
							   ret_pag_rc		= ret_pag_rc + _pag_ret_rc,
							   ret_pag_otros	= ret_pag_otros + _pag_ret_otros,
							   ret_pag_casco	= ret_pag_casco + _pag_ret_casco,
							   fac_pag			=  fac_pag      + _pag_fac,
							   cont_pag     	=  cont_pag     + _pag_cont,
							   fac_car_1		=  fac_car_1	+ _fac_car_1,
							   fac_car_2		=  fac_car_2	+ _fac_car_2,
							   otros_cont_pag	=  otros_cont_pag	+ v_prima_ot,
							   fac_car_3		=  fac_car_3	+ _fac_car_3,
							   pagado_bruto		=  pagado_bruto	+ v_suma_pag,
							   pagado_neto		=  pagado_neto	+ _pag_ret
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
							cp_pag,--
							cp_pag_rc,--
							cp_pag_otros,--
							cp_pag_casco,--
							exc_pag,--
							cp_res,
							exc_res,
							ret_pag,--
							ret_pag_rc,--
							ret_pag_otros,--
							ret_pag_casco,--
							fac_pag,--
							cont_pag,--
							ret_res,
							fac_res,
							cont_res,
							fac_car_1,--
							fac_car_2,--
							fac_car_3,
							otros_cont_pag,--
							cod_cobertura,
							no_unidad)
					values(	_cod_contrato,
							_no_reclamo,
							v_transaccion,           
							_no_poliza,           
							_cod_ramo,            
							_periodo,             
							v_doc_reclamo,            
							v_suma_pag,        
							0.00,       
							0.00,
							_cod_sucursal,
							_serie,
							_pag_ret,        
							0.00,       
							0.00,
							_pag_5,
							_cp_rc,
							_cp_otros,
							_cp_casco,
							_pag_7,
							0.00,
							0.00,
							_pag_ret,
							_pag_ret_rc,
							_pag_ret_otros,
							_pag_ret_casco,
							_pag_fac,
							_pag_cont,
							0.00,
							0.00,
							0.00,
							_fac_car_1,
							_fac_car_2,
							0.00,
							v_prima_ot,
							_cod_cobertura,
							_no_unidad);
				end				
			end foreach	--ciclo de rectrmae			
		end foreach	--ciclo de rectrcob
	end foreach
end foreach

-- Procesos para Filtros

LET v_filtros = "";

IF a_codsucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_codsucursal);

	LET _tipo = sp_sis04(a_codsucursal);  -- Separa los Valores del String en una tabla de codigos

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

IF a_codramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_codramo);

	LET _tipo = sp_sis04(a_codramo);  -- Separa los Valores del String en una tabla de codigos

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
{foreach
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
end foreach}

--- tabla de ramos:

foreach
	select distinct cod_ramo
	  into v_cod_ramo
	  from tmp_contrato1
	 where seleccionado = 1

	insert into tmp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
	values (v_cod_ramo,v_cod_ramo,100);
	
	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;

	foreach
		select parinfra.rango1, 
			   parinfra.rango2
		  into v_rango_inicial,
			   v_rango_final
		  from parinfra
		 where parinfra.cod_ramo = v_cod_ramo

		insert into tmp_tabla_rea(
				cod_ramo,							
				desc_ramo,							
				rango_inicial,					
				rango_final,  					
				cant_polizas1, 					
				p_cobrada1,    					
				p_retenida1,   					
				p_retenida_otros,   					
				p_retenida_rc,   					
				p_retenida_casco,   					
				p_bouquet1,    					
				p_bouquet_otros,    					
				p_bouquet_rc,    					
				p_bouquet_casco,    					
				p_facultativo1,					
				p_otros1,
				p_fac_car1,
				p_filtro,
				p_suma_asegurada,
				no_documento)
		values(	v_cod_ramo, 
				v_desc_ramo, 
				v_rango_inicial, 
				v_rango_final, 
				0, 
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				v_filtros,
				0.00,
				''
				);
	end foreach
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
		   no_poliza,
		   no_unidad
	  into v_cod_ramo, 
		   v_nopoliza,
		   _no_unidad
	  from tmp_contrato1 
	 where seleccionado = 1 

	{select sum(pagado_bruto), 		
		   sum(pagado_neto)
	  into v_prima,
		   v_prima_1
	  from tmp_sinis 
	 where no_poliza    = v_nopoliza	
	   and cod_ramo     = v_cod_ramo 
	   and seleccionado = 1;}

	select suma_asegurada
	  into v_suma_asegurada
	  from emipouni 
	 where no_poliza = v_nopoliza
	   and no_unidad = _no_unidad;

	if v_suma_asegurada is null then
		let v_suma_asegurada = 0.00;
	end if

	let _sum_fac_car  = 0;

	{foreach
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
	end foreach}

	select sum(pagado_bruto), 		
		   sum(pagado_neto),
		   sum(ret_pag_rc),
		   sum(ret_pag_otros),
		   sum(ret_pag_casco),
		   sum(fac_pag),
		   sum(cp_pag),
		   sum(cp_pag_rc),
		   sum(cp_pag_otros),
		   sum(cp_pag_casco),
		   sum(exc_pag),
		   sum(fac_car_1),
		   sum(fac_car_2),
		   sum(fac_car_3),		   			   
		   sum(otros_cont_pag)		   			   
	  into v_prima,
		   v_prima_1,
		   _pag_ret_rc,
		   _pag_ret_otros,
		   _pag_ret_casco,
		   v_prima_3,
		   v_prima_5,
		   _cp_rc,
		   _cp_otros,
		   _cp_casco,
		   v_prima_7,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3,
		   v_prima_ot
	  from tmp_contrato1
	 where cod_ramo     = v_cod_ramo
	   and no_poliza    = v_nopoliza
	   and no_unidad = _no_unidad
	   and seleccionado = 1;

	if _sum_fac_car is null then
		let _sum_fac_car = 0.00;
	end if

	let v_prima_bq = (v_prima_5 + v_prima_7) - _sum_fac_car;

	if 	v_prima is null then
		let v_prima = 0;
	end if

	if 	v_prima_ot is null then
		let v_prima_ot = 0;
	end if

	if 	v_prima_1 is null then
		let v_prima_1 = 0;
	end if
	select parinfra.rango1, 
		   parinfra.rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where cod_ramo = v_cod_ramo 
	   and rango1 <= round(v_suma_asegurada,0) 
	   and rango2 >= round(v_suma_asegurada,0); 

	if v_rango_inicial is null then
		let v_rango_inicial = 0;	

		select rango2
		  into v_rango_final
		  from parinfra
		 where cod_ramo = v_cod_ramo
		   and parinfra.rango1 = v_rango_inicial;
	end if

	foreach
		select cod_sub_tipo,
			   porcentaje
		  into v_cod_tipo,
			   v_porcentaje
		  from tmp_ramos_rea
		 where cod_ramo = v_cod_ramo										

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		let ld_comp = v_prima - (v_prima_1 + v_prima_bq +	v_prima_3 + v_prima_Ot);

		if	abs(ld_comp) > 10 then
			insert into tmp_dif (cod_ramo,no_poliza,prima,prima1,prima3,prima5,prima7,primabq)
			values (v_cod_tipo,v_nopoliza,v_prima,v_prima_1,v_prima_3,v_prima_5,v_prima_7,v_prima_bq);
		end if
			
		--let v_prima = v_prima_1 + v_prima_3 + v_prima_ot + _fac_car_1 + v_prima_bq;
			
		begin
			on exception in(-239)
				update tmp_tabla_rea
				   set cant_polizas1   = cant_polizas1   + 1,
					   p_cobrada1      = p_cobrada1      + v_prima * v_porcentaje/100,
					   p_retenida1     = p_retenida1     + v_prima_1 * v_porcentaje/100,
					   p_retenida_rc = p_retenida_rc     + _pag_ret_rc * v_porcentaje/100,
					   p_retenida_otros = p_retenida_otros     + _pag_ret_otros * v_porcentaje/100,
					   p_retenida_casco = p_retenida_casco     + _pag_ret_casco * v_porcentaje/100,
					   p_bouquet1      = p_bouquet1      + v_prima_bq * v_porcentaje/100,
					   p_bouquet_rc      = p_bouquet_rc      + _cp_rc * v_porcentaje/100,
					   p_bouquet_otros      = p_bouquet_otros      + _cp_otros * v_porcentaje/100,
					   p_bouquet_casco      = p_bouquet_casco      + _cp_casco * v_porcentaje/100,
					   p_facultativo1  = p_facultativo1  + v_prima_3 * v_porcentaje/100,
					   p_otros1		  = p_otros1        + v_prima_ot * v_porcentaje/100,
					   p_fac_car1	  = p_fac_car1      + _fac_car_1 * v_porcentaje/100,
					   p_suma_asegurada	  = p_suma_asegurada  + v_suma_asegurada * v_porcentaje/100
				 where cod_ramo       = v_cod_tipo  
				   and rango_inicial  = v_rango_inicial  
				   and rango_final    = v_rango_final;  
			end exception

			insert into tmp_tabla_rea(
					cod_ramo,							
					desc_ramo,							
					rango_inicial,					
					rango_final,  					
					cant_polizas1, 					
					p_cobrada1,    					
					p_retenida1,   					
					p_retenida_rc,   					
					p_retenida_otros,   					
					p_retenida_casco,   					
					p_bouquet1,    					
					p_bouquet_rc,    					
					p_bouquet_otros,    					
					p_bouquet_casco,    					
					p_facultativo1,					
					p_otros1,
					p_fac_car1,
					p_acumulada,
					p_filtro,
					p_suma_asegurada)
			VALUES(	v_cod_tipo, 
					v_desc_ramo, 
					v_rango_inicial, 
					v_rango_final, 
					1, 
					v_prima    * v_porcentaje/100, 
					v_prima_1  * v_porcentaje/100,
					_pag_ret_rc  * v_porcentaje/100, 
					_pag_ret_otros  * v_porcentaje/100, 
					_pag_ret_casco  * v_porcentaje/100, 
					v_prima_bq * v_porcentaje/100,
					_cp_rc * v_porcentaje/100, 
					_cp_otros * v_porcentaje/100, 
					_cp_casco * v_porcentaje/100, 
					v_prima_3  * v_porcentaje/100, 
					v_prima_Ot * v_porcentaje/100, 
					_fac_car_1 * v_porcentaje/100,
					0.00,
					v_filtros,
					v_suma_asegurada
					);				 
		end			
	end foreach

	let v_prima    	  = 0; 
	let v_prima_1  	  = 0;
	let v_prima_3  	  = 0;
	let v_prima_5  	  = 0;
	let v_prima_7  	  = 0;
	let v_prima_bq 	  = 0;
	let v_prima_ot 	  = 0;
	let v_prima_tipo  = 0;
	let _pag_ret      = 0;
	let _pag_cont     = 0;
	let _fac_car_1    = 0;
	let _fac_car_2    = 0;
	let _fac_car_3    = 0;
	let _pag_ret_rc    = 0;
	let _pag_ret_otros    = 0;
	let _pag_ret_casco    = 0;
	let _cp_rc    = 0;
	let _cp_otros    = 0;
	let _cp_casco    = 0;

end foreach

foreach
	select cod_ramo,
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
		   p_retenida_rc,
		   p_retenida_otros,
		   p_retenida_casco,
		   p_bouquet_rc,
		   p_bouquet_otros,
		   p_bouquet_casco,
		   p_suma_asegurada,
		   p_filtro
	  into _cod_ramo,
		   v_desc_ramo,
		   v_rango_inicial,
		   v_rango_final,
		   _cantidad,
		   _pagado_bruto,
		   _pagado_neto,
		   v_prima_bq,
		   v_prima_3,
		   v_prima_ot,
		   _fac_car_1,
		   _pag_ret_rc,
		   _pag_ret_otros,
		   _pag_ret_casco,
		   _cp_rc,
		   _cp_otros,
		   _cp_casco,
		   v_suma_asegurada,
		   v_filtros
	  from tmp_tabla_rea 
	 order by cod_ramo,rango_inicial 

	let v_acumulada  = v_acumulada  + _pagado_bruto;
	
	return	_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			0, 
			0.00, 
			0.00, 
			0.00, 
			0.00, 
			0.00,
			0.00,
			0.00,
			_cantidad, 
			_pagado_bruto, 
			_pagado_neto, 
			v_prima_bq, 		--16
			v_prima_3,
			v_prima_ot,
			_fac_car_1,
			v_acumulada,
			0, 
			0.00, 
			0.00, 
			0.00, 
			0.00, 
			0.00,
			0.00,
			0.00, 
			v_descr_cia, 
			v_filtros,
			v_suma_asegurada,
			0.00,			
			0.00,			
			0.00,			
			0.00,			
			0.00,			
			0.00,			
			_pag_ret_rc,			
			_pag_ret_casco,			
			_pag_ret_otros,			
			_cp_rc,			
			_cp_casco,			
			_cp_otros,			
			0.00,			
			0.00,			
			0.00,			
			0.00,			
			0.00, 			
			0.00			
			with resume;
end foreach

--return 0;
drop table if exists tmp_sinis;
drop table if exists tmp_ramos_rea;
drop table if exists tmp_contrato1;
drop table if exists tmp_tabla_rea;

end procedure;