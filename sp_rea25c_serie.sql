-- Reporte de Perfil de Siniestros Pendientes
-- Creado    : 26/07/2011 - Autor: Henry Giron 
-- SIS v.2.0 DEIVID, S.A.	

--execute procedure sp_rea25c('001','001','2015-07','2016-05','*','*','002,020,023;','2015;','*')

DROP PROCEDURE sp_rea25_serie;
CREATE PROCEDURE 'informix'.sp_rea25_serie(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*",
a_subramo		char(255) default "*")
returning	char(3),
			char(50),
			smallint,
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

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_transaccion      CHAR(10);     
DEFINE v_pagado_cedido    dec(16,2);
DEFINE v_reserva_cedido   dec(16,2);
DEFINE v_incurrido_cedido dec(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_cober_reas          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _no_unidad      CHAR(5);     
DEFINE _cod_cliente       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;
DEFINE _ramo_sis	     SMALLINT;
DEFINE _porc_reas         dec;
define _porc_coas			dec;
DEFINE _pagado_bruto      dec(16,2);
DEFINE _reserva_bruto     dec(16,2);
DEFINE _incurrido_bruto   dec(16,2);
DEFINE _pagado_neto       dec(16,2);
DEFINE _reserva_neto      dec(16,2);
DEFINE _incurrido_neto    dec(16,2);
DEFINE _serie 			  SMALLINT;
DEFINE _cnt_cober_reas	  SMALLINT;
DEFINE _flag	  SMALLINT;
DEFINE _pag_ret           dec(16,2);
DEFINE _pag_fac           dec(16,2);
DEFINE _pag_cont          dec(16,2);
DEFINE _res_ret           dec(16,2);
DEFINE _res_fac           dec(16,2);
DEFINE _res_cont          dec(16,2);

DEFINE v_suma_pag         dec(16,2);
DEFINE v_suma_res         dec(16,2);

DEFINE _cp_pag            dec(16,2);
DEFINE _exc_pag           dec(16,2);
DEFINE _cp_res            dec(16,2);
DEFINE _exc_res           dec(16,2);
DEFINE _monto_bruto           dec(16,2);
DEFINE _monto_total          dec(16,2);
DEFINE _ret_casco          dec(16,2);
DEFINE _res_ret_otros          dec(16,2);
DEFINE _res_ret_rc          dec(16,2);
DEFINE _res_cp_rc         dec(16,2);
DEFINE _res_cp_otros          dec(16,2);
DEFINE _res_cp_casco          dec(16,2);
DEFINE _pag_5             dec(16,2);
DEFINE _pag_7             dec(16,2);
DEFINE _res_5             dec(16,2);
DEFINE _res_7             dec(16,2);
define v_prima_tipo		  DEC(16,2);			 
define v_prima_1 		  DEC(16,2);			 
define v_prima_3 		  DEC(16,2);			 
define v_prima_bq		  DEC(16,2);			 
define v_prima_Ot		  DEC(16,2);			 
define _bouquet			  smallint;			 
DEFINE v_rango_inicial	  DEC(16,2);           
DEFINE v_rango_final	  DEC(16,2);           
define v_prima_5 		  DEC(16,2);
define v_prima_7 		  DEC(16,2);
DEFINE v_cod_ramo,v_cod_tipo2         CHAR(03);
DEFINE v_nopoliza         CHAR(10);           
DEFINE v_prima            DEC(16,2);    		 
DEFINE v_prima1           DEC(16,2);     		 
DEFINE v_tipo_contrato    SMALLINT;           
DEFINE v_desc_ramo    	  CHAR(50);			 
DEFINE v_noendoso 		  CHAR(5);			 
DEFINE v_cod_contrato     CHAR(5);			 
define v_no_reclamo		  char(10);			 
DEFINE v_periodo          CHAR(7);        	 
define _no_tranrec		  char(10);			 
DEFINE v_cobertura        CHAR(03);  		 
DEFINE _cantidad          SMALLINT;  		 
DEFINE v_filtros1         CHAR(255);  		 
DEFINE v_descr_cia        CHAR(50);  		 
DEFINE v_cod_tipo		  CHAR(3);			 
DEFINE v_porcentaje		 							Smallint;			 
DEFINE v_suma_asegurada   							dec(16,2);			 
DEFINE _t_ramo			  							CHAR(1);			 
define v_no_cambio	       							smallint;
define v_no_unidad		    						char(5);
define v_porc_partic_prima							dec(9,6);
define ld_comp  									dec(16,2);
define _fac_car_1 	       							dec(16,2);
define _fac_car_2 	        						dec(16,2);
define _fac_car_3 	        						dec(16,2);
define _facilidad_car, v_contador, _cnt       			smallint;	
define _fac_car2, v_cobrada, v_acumulada, v_acumulado 	        dec(16,2);

define v_retenida,v_bouquet,v_facultativo,v_otros,v_fac_car  dec(16,2);
define _cant_pol   integer;
define _no_documento      char(20);
define _cod_cobertura char(5);
	
-- Nombre de la Compania
let v_compania_nombre = sp_sis01(a_compania);
let v_descr_cia = v_compania_nombre;

-- Cargar el Incurrido
 
--CALL sp_rea22c1(a_compania, a_agencia, a_periodo2,a_codsucursal,'*','*',a_codramo,'*') RETURNING v_filtros; 
call sp_rec02(a_compania, a_agencia, a_periodo2,a_codsucursal,'*','*',a_codramo,'*') returning v_filtros; 

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis_rea;
create temp table temp_ramos_rea
(cod_ramo		char(3),
cod_sub_tipo	char(3),
porcentaje		smallint default 100,
primary key(cod_ramo, cod_sub_tipo)) with no log;


-- Tabla Temporal para los Contratos
create temp table tmp_contrato_rea(
cod_contrato		 char(5),
no_reclamo           char(10),
transaccion			 char(10),
no_poliza            char(10),
no_unidad            char(7),
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
cp_res_rc 	         dec(16,2),
cp_res_otros         dec(16,2),
cp_res_casco         dec(16,2),
exc_res    			 dec(16,2),
cod_sucursal         char(3)   not null,
serie                smallint,
ret_pag 		     dec(16,2),
fac_pag    			 dec(16,2),
cont_pag    		 dec(16,2),
ret_res_rc 		     dec(16,2),
ret_res_otros	     dec(16,2),
ret_res_casco	     dec(16,2),
ret_res 		     dec(16,2),
fac_res    			 dec(16,2),
cont_res    		 dec(16,2),
fac_car_1			dec(16,2),
fac_car_2			dec(16,2),
fac_car_3			dec(16,2),
otros_cont_res		dec(16,2),
seleccionado		smallint default 1 not null,
primary key (cod_contrato, no_reclamo)) with no log;

create index xie01_tmp_contrato_rea on tmp_contrato_rea(cod_contrato);
create index xie02_tmp_contrato_rea on tmp_contrato_rea(cod_ramo);
create index xie03_tmp_contrato_rea on tmp_contrato_rea(no_poliza);
create index xie04_tmp_contrato_rea on tmp_contrato_rea(no_reclamo);
create index xie05_tmp_contrato_rea on tmp_contrato_rea(no_unidad);

create temp table tmp_tabla_rea(
cod_ramo			char(3),
desc_ramo			char(50),
serie				smallint,
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
p_acumulada1		dec(16,2) default 0,
p_filtro			char(255), 
p_suma_asegurada	dec(16,2),
no_documento		char(20) default '',
primary key (cod_ramo,serie,rango_inicial,rango_final)) with no log;

set isolation to dirty read;
delete from tmp_dif;

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
	 where seleccionado = 1
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal
	 order by cod_ramo,numrecla

  	select no_documento 
	  into _no_documento 
	  from emipomae where no_poliza = _no_poliza;

	select count(*) 
	  into _cnt 
	  from reaexpol 
	 where no_documento = _no_documento
       and activo       = 1;  			--tabla para excluir polizas

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

	let _cod_contrato = null;

	select no_unidad
	  into _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

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
			
			let _cnt_cober_reas = 0;
			let _monto_bruto = 0;
			let _monto_bruto = _monto_total  / 100 * _porc_coas;
			let _cod_contrato = null;							

			select count(*)
			  into _cnt_cober_reas
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_cober_reas is null then
				let _cnt_cober_reas = 0;
			end if

			let _flag = 0;

			if _cnt_cober_reas = 0 then
				if _cod_cober_reas = '002' then
					let _cod_cober_reas = '033';
					let _flag = 1;
				elif _cod_cober_reas = '031' then
					if _no_tranrec in ('1555383','1555327') then
						let _cod_cober_reas = '002';
						let _flag = 1;
					else
						let _cod_cober_reas = '034';
						let _flag = 1;
					end if
				elif _cod_cober_reas = '033' then
					let _cod_cober_reas = '002';
					let _flag = 1;
				elif _cod_cober_reas = '034' then
					let _cod_cober_reas = '031';
					let _flag = 1;
				end if
			end if

			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

				let _pag_ret 	= 0;
				let _pag_fac 	= 0;
				let _pag_cont 	= 0;
				let _res_ret 	= 0;
				let _res_fac 	= 0;
				let _res_cont 	= 0;
				let v_suma_pag 	= 0;
				let v_suma_res 	= 0;
				let _cp_pag 	= 0;
				let _exc_pag 	= 0;
				let _cp_res 	= 0;
				let _exc_res  	= 0;
				let _pag_5 		= 0;
				let _res_5 		= 0;
				let _pag_7 		= 0;
				let _res_7 		= 0;
				let _fac_car_1  = 0; 
				let _fac_car_2  = 0;
				let _fac_car_3  = 0;
				let _ret_casco  = 0;
				let _res_ret_otros  = 0;
				let _res_ret_rc  = 0;
				let _res_cp_rc  = 0;
				let _res_cp_casco  = 0;
				let _res_cp_otros  = 0;
				let v_prima_ot  = 0;

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

				let v_reserva_cedido   = _monto_bruto   * _porc_reas / 100;

				if _flag = 1 then
					--continue foreach;
					let _tipo_contrato = 5;
				end if

				if _tipo_contrato = 1 then
					let _res_ret = _res_ret + v_reserva_cedido;
					
					if _ramo_sis = 1 then
						if _cod_cober_reas in ('031','034') then
							let _ret_casco = _ret_casco + v_reserva_cedido;
						else
							if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
								let _res_ret_rc = _res_ret_rc + v_reserva_cedido;
							else
								let _res_ret_otros = _res_ret_otros + v_reserva_cedido;							
							end if
						end if
					else
						let _res_ret_otros = _res_ret_otros + v_reserva_cedido;
					end if
				elif _tipo_contrato = 3 then
					let _res_fac = _res_fac + v_reserva_cedido;		   
				else
					let _res_cont = _res_cont + v_reserva_cedido;		   

					if _tipo_contrato = 5 then
						let _res_5 = _res_5 + v_reserva_cedido;
						
						if _ramo_sis = 1 then
							if _cod_cober_reas in ('031','034') then
								let _res_cp_casco = _res_cp_casco + v_reserva_cedido;
							else
								if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
									let _res_cp_rc = _res_cp_rc + v_reserva_cedido;
								else
									let _res_cp_otros = _res_cp_otros + v_reserva_cedido;							
								end if
							end if
						else
							let _res_cp_otros = _res_cp_otros + v_reserva_cedido;
						end if
					elif _tipo_contrato = 7 then
						let _res_7 = _res_7 + v_reserva_cedido;
					else
						let v_prima_ot = v_prima_ot + v_reserva_cedido;
					end if
				end if

				let v_suma_res = _res_ret + _res_fac + _res_cont;
				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;

				if _facilidad_car = 1 then --_cod_contrato = '00574' or _cod_contrato = '00584' or _cod_contrato = '00594' or _cod_contrato = '00604' then

				   let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- siniestros pendiente
				   let _fac_car_2 = _cp_res + _exc_res;					  -- reserva

				   let _cp_pag   = 0;
				   let _exc_pag  = 0;
				   let _pag_ret  = 0; 
				   let _pag_fac  = 0;
				   let _pag_cont = 0;
				   let _res_ret  = 0; 
				   let _res_fac  = 0;
				   let _res_cont = 0;
				end if

				begin
				on exception in(-239)
					update tmp_contrato_rea
					   set reserva_bruto 	= reserva_bruto + v_suma_res,
						   reserva_neto 	=  reserva_neto + _res_ret,
						   cp_res       	=  cp_res + _res_5,
						   cp_res_rc    	=  cp_res_rc + _res_cp_rc,
						   cp_res_otros 	=  cp_res_otros + _res_cp_otros,
						   cp_res_casco 	=  cp_res_casco + _res_cp_casco,
						   ret_res      	=  ret_res + _res_ret, --_exc_ret,
						   ret_res_rc		=  ret_res_rc + _res_ret_rc, --_exc_ret,
						   ret_res_otros	=  ret_res_otros + _res_ret_otros, --_exc_ret,
						   ret_res_casco	=  ret_res_casco + _ret_casco, --_exc_ret,
						   exc_res      	=  exc_res + _res_7,
						   fac_res      	=  fac_res + _res_fac, --_exc_fac,
						   cont_res     	=  cont_res + _res_cont,
						   fac_car_1		=  fac_car_1 + _fac_car_1,
						   fac_car_2		=  fac_car_2 + _fac_car_2,
						   fac_car_3		=  fac_car_3	+ _fac_car_3,
						   otros_cont_res	=  otros_cont_res + v_prima_ot
					 where cod_contrato = _cod_contrato
					   and no_reclamo = _no_reclamo;
				end exception

				insert into tmp_contrato_rea(
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
						cp_res,
						cp_res_rc,
						cp_res_otros,
						cp_res_casco,
						exc_res,
						ret_res,
						ret_res_rc,
						ret_res_otros,
						ret_res_casco,
						fac_res,
						cont_res,
						fac_car_1,
						fac_car_2,
						fac_car_3,
						incurrido_neto,
						cp_pag,
						exc_pag,
						ret_pag,
						fac_pag,
						cont_pag,
						otros_cont_res,
						no_unidad)
				values(	_cod_contrato,
						_no_reclamo,
						v_transaccion,           
						_no_poliza,           
						_cod_ramo,            
						_periodo,             
						v_doc_reclamo,            
						0.00,        
						v_suma_res,       
						0.00,
						_cod_sucursal,
						_serie,
						0.00,        
						_res_ret,       
						_res_5,
						_res_cp_rc,
						_res_cp_otros,
						_res_cp_casco,
						_res_7,
						_res_ret,
						_res_ret_rc,
						_res_ret_otros,
						_ret_casco,
						_res_fac,
						_res_cont,
						_fac_car_1,
						_fac_car_2,
						_fac_car_3,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						v_prima_ot,
						_no_unidad);
				end
			end foreach
		end foreach
	end foreach
end foreach

-- Procesos para Filtros

LET v_filtros = '';

IF a_codsucursal <> '*' THEN

	LET v_filtros = TRIM(v_filtros) || ' Sucursal: ' ||  TRIM(a_codsucursal);

	LET _tipo = sp_sis04(a_codsucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> 'E' THEN -- Incluir los Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_contrato <> '*' THEN

	LET v_filtros = TRIM(v_filtros) || ' Contrato: ' ||  TRIM(a_contrato);

	LET _tipo = sp_sis04(a_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> 'E' THEN -- Incluir los Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_codramo <> '*' THEN

	LET v_filtros = TRIM(v_filtros) || ' Ramo: ' ||  TRIM(a_codramo);

	LET _tipo = sp_sis04(a_codramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> 'E' THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_serie <> '*' THEN

	LET v_filtros = TRIM(v_filtros) || ' Serie: ' ||  TRIM(a_serie);

	LET _tipo = sp_sis04(a_serie);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> 'E' THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF			   

--- tabla de ramos:
foreach
	select distinct cod_ramo,
		   serie
	  into v_cod_ramo,
		   _serie
	  from tmp_contrato_rea
	 where seleccionado = 1

	begin
		on exception in(-239)
		end exception

		insert into temp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
		values (v_cod_ramo,v_cod_ramo,100);
	end

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

		begin
			on exception in(-239)
			end exception
			insert into tmp_tabla_rea(
					cod_ramo,							
					desc_ramo,
					serie,
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
					_serie,
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
					'');
		end 
	end foreach
end foreach

let v_prima_tipo = 0;
let v_prima_1  = 0;
let v_prima_3  = 0;
let v_prima_5  = 0;
let v_prima_7  = 0;
let v_prima_bq = 0;
let v_prima_ot = 0;
let _fac_car_1 = 0;
let _fac_car_2 = 0;
let _fac_car_3 = 0;

foreach
	select distinct cod_ramo, 
		   no_poliza,
		   no_unidad,
		   serie
	  into v_cod_ramo, 
		   v_nopoliza,
		   _no_unidad,
		   _serie
	  from tmp_contrato_rea 
	 where seleccionado = 1 

	select suma_asegurada
	  into v_suma_asegurada
	  from emipouni
	 where no_poliza = v_nopoliza
	   and no_unidad = _no_unidad;

	if v_suma_asegurada is null then
		let v_suma_asegurada = 0.00;
	end if

	select sum(reserva_bruto),
		   sum(reserva_neto),
		   sum(ret_res_rc),
		   sum(ret_res_otros),
		   sum(ret_res_casco),						
		   sum(fac_res),
		   sum(cp_res),
		   sum(cp_res_rc),
		   sum(cp_res_otros),
		   sum(cp_res_casco),						
		   sum(exc_res),
		   sum(fac_car_1),
		   sum(fac_car_2),
		   sum(fac_car_3),			   
		   sum(otros_cont_res)
	  into v_prima,
		   v_prima_1,
		   _res_ret_rc,
		   _res_ret_otros,
		   _ret_casco,		   
		   v_prima_3,
		   v_prima_5,
		   _res_cp_rc,
		   _res_cp_otros,
		   _res_cp_casco,
		   v_prima_7,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3,
		   v_prima_ot
	  from tmp_contrato_rea
	 where cod_ramo = v_cod_ramo
	   and no_poliza = v_nopoliza
	   and no_unidad = _no_unidad
	   and seleccionado = 1;

	let v_prima_bq = v_prima_5 + v_prima_7;

	if 	v_prima is null then
		let v_prima = 0;
	end if

	if 	v_prima_1 is null then
		let v_prima_1 = 0;
	end if
	
	select parinfra.rango1, 
		   parinfra.rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where parinfra.cod_ramo = v_cod_ramo 
	   and parinfra.rango1 <= v_suma_asegurada 
	   and parinfra.rango2 >= v_suma_asegurada; 

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
		  from temp_ramos_rea
		 where cod_ramo = v_cod_ramo										

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		let ld_comp = v_prima - (v_prima_1 + v_prima_bq +	v_prima_3 + v_prima_ot);

		if	abs(ld_comp) > 10 then
			insert into tmp_dif (cod_ramo,no_poliza,prima,prima1,prima3,prima5,prima7,primabq)
			values (v_cod_tipo,v_nopoliza,v_prima,v_prima_1,v_prima_3,v_prima_5,v_prima_7,v_prima_bq);
			let v_prima_bq = v_prima_bq + ld_comp ;
		end if

		begin
			on exception in(-239)
				update tmp_tabla_rea
				   set cant_polizas1	= cant_polizas1		+ 1,
					   p_cobrada1		= p_cobrada1		+ v_prima + _fac_car_1 * v_porcentaje/100,
					   p_retenida1		= p_retenida1		+ v_prima_1 * v_porcentaje/100,
					   p_retenida_rc	= p_retenida_rc		+ _res_ret_rc * v_porcentaje/100,
					   p_retenida_otros	= p_retenida_otros	+ _res_ret_otros * v_porcentaje/100,
					   p_retenida_casco	= p_retenida_casco	+ _ret_casco * v_porcentaje/100,
					   p_bouquet1		= p_bouquet1		+ v_prima_bq * v_porcentaje/100,
					   p_bouquet_rc		= p_bouquet_rc		+ _res_cp_rc * v_porcentaje/100,
					   p_bouquet_otros	= p_bouquet_otros	+ _res_cp_otros * v_porcentaje/100,
					   p_bouquet_casco	= p_bouquet_casco	+ _res_cp_casco * v_porcentaje/100,
					   p_facultativo1	= p_facultativo1	+ v_prima_3 * v_porcentaje/100,
					   p_otros1			= p_otros1			+ v_prima_ot * v_porcentaje/100,
					   p_fac_car1		= p_fac_car1		+ _fac_car_1 * v_porcentaje/100,
					   p_suma_asegurada		= p_suma_asegurada		+ v_suma_asegurada * v_porcentaje/100
				 where cod_ramo       = v_cod_tipo
				   and serie = _serie
				   and rango_inicial  = v_rango_inicial
				   and rango_final    = v_rango_final;  

			end exception

			insert into tmp_tabla_rea(
					cod_ramo,							
					desc_ramo,
					serie,
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
					p_suma_asegurada,
					p_acumulada1)
			values(	v_cod_tipo, 
					v_desc_ramo,
					_serie,
					v_rango_inicial, 
					v_rango_final, 
					1, 
					v_prima + _fac_car_1 * v_porcentaje/100, 
					v_prima_1 * v_porcentaje/100,
					_res_ret_rc * v_porcentaje/100,
					_res_ret_otros * v_porcentaje/100,
					_ret_casco * v_porcentaje/100,
					v_prima_bq * v_porcentaje/100, 
					_res_cp_rc * v_porcentaje/100,
					_res_cp_otros * v_porcentaje/100,
					_res_cp_casco * v_porcentaje/100,
					v_prima_3 * v_porcentaje/100, 
					v_prima_ot * v_porcentaje/100, 
					_fac_car_1 * v_porcentaje/100,
					v_suma_asegurada * v_porcentaje/100,
					0.00);
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
	let _res_ret      = 0;			  
	let _res_cont     = 0;
	let _fac_car_1    = 0;
	let _fac_car_2    = 0;
	let _fac_car_3    = 0;
end foreach

let v_acumulada = 0.00;
foreach
	select cod_ramo,
		   desc_ramo,
		   serie,
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
		   _serie,
		   v_rango_inicial,
		   v_rango_final,
		   _cantidad,
		   _reserva_bruto,
		   _reserva_neto,
		   v_prima_bq,
		   v_prima_3,
		   v_prima_ot,
		   _fac_car_1,
		   _res_ret_rc,
		   _res_ret_otros,
		   _ret_casco,
		   _res_cp_rc,
		   _res_cp_otros,
		   _res_cp_casco,
		   v_suma_asegurada,
		   v_filtros
	  from tmp_tabla_rea 
	 order by cod_ramo,rango_inicial 

	let v_acumulada  = v_acumulada  + _reserva_bruto;
	
	return	_cod_ramo, 
			v_desc_ramo,
			_serie,
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
			0, 
			0.00, 
			0.00, 
			0.00, 
			0.00, 
			0.00,
			0.00,
			0.00, 
			_cantidad, 
			_reserva_bruto, 
			_reserva_neto, 
			v_prima_bq, 		--16
			v_prima_3,
			v_prima_ot,
			_fac_car_1,
			v_acumulada,
			v_descr_cia, 
			v_filtros,
			v_suma_asegurada,
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
			_res_ret_rc,
			_ret_casco,
			_res_ret_otros,
			_res_cp_rc,
			_res_cp_casco,
			_res_cp_otros
			with resume;
end foreach
drop table if exists tmp_sinis;
drop table if exists temp_ramos_rea;
drop table if exists tmp_contrato_rea;
drop table if exists tmp_tabla_rea;

end procedure;