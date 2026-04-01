--execute procedure sp_rec706('001','001','2014-06','2014-06',"*","*","002;","*","*")
--execute procedure sp_rec706c_dif('001','001','2016-05','2016-05',"*","*","002;","*","*","0210-01288-01","*",0)
drop procedure sp_rec706c_dif;
create procedure "informix".sp_rec706c_dif(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_contrato	char(255) default "*",
a_ramo		char(255) default "*",
a_serie		char(255) default "*",
a_cober		char(255) default "*",
a_documento CHAR(20)  DEFAULT "*",
a_numrecla  CHAR(20)  DEFAULT "*",
a_cant_dias smallint  default 0 )
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
			char(15),
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
			dec(16,2),
			dec(16,2),
			dec(16,2),
			date,
			date,
			char(30),
			dec(16,2),
			integer,
			varchar(50),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);

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
define v_incurrido_cedido	dec(16,2);
define v_reserva_cedido		dec(16,2);
define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define _suma_asegurada		dec(16,2);
define v_pagado_cedido		dec(16,2);
define _res_ret_otros		dec(16,2);
define _reserva_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_bruto			dec(16,2);
define _monto_total			dec(16,2);
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
define _res_otro			dec(16,2);
define v_xl					dec(16,2);
define _res_cp_rc			dec(16,2);
define _res_cp_casco		dec(16,2);
define _facilidad_car		smallint;
define _tipo_contrato		smallint;
define _ramo_sis			smallint;
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
define _otro_res            dec(16,2);
define _ult_fecha           date;
define _cantidad            char(2);
define _nombre   varchar(100);
define _cod_cober_reas_no	char(3);
define _cod_cober_reas_tmp	char(3);
define _cnt_existe			smallint;
define _transaccion		    char(10);
define _user_added          char(10);
define _cod_tipotran		smallint;



-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);
call sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') returning v_filtros; 

--set debug file to "sp_rec706.trc"; 
--trace on; 
let _n_evento = '';

-- Tabla Temporal para los Contratos
create temp table tmp_contrato1(
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
otro_res        dec(16,2),
cod_sucursal	char(3)   not null,
serie			smallint,
ret_pag			dec(16,2),
fac_pag			dec(16,2),
cont_pag		dec(16,2),
ret_res			dec(16,2),
fac_res			dec(16,2),
cont_res		dec(16,2),
fac_car_1		dec(16,2),
fac_car_2		dec(16,2),
fac_car_3		dec(16,2),
seleccionado	smallint  default 1 not null,
cod_cobertura	char(5),
serie_char		char(15),
ret_casco		dec(16,2) default 0,
ret_otros		dec(16,2) default 0,
res_cp_casco	dec(16,2) default 0,
res_cp_rc		dec(16,2) default 0,
primary key (cod_contrato, no_reclamo, serie_char)) with no log;

IF a_documento <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where no_documento <> a_documento;  
END IF 

IF a_numrecla <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where numrecla <> a_numrecla;
END IF 

if a_cant_dias is null  then
	let a_cant_dias = 0;
end if	

let _cantidad = a_cant_dias;
--set debug file to "sp_rec706.trc"; 
--trace on; 

create temp table tmp_dif_bx2(
no_reclamo        char(10),
numrecla          char(18), 
transaccion       char(10),
periodo           char(7),
fecha             date,
user_added        char(10),
cod_contrato      char(5),
tipo_contrato     smallint,
cod_tipotran      smallint,
no_tranrec        char(10),
variacion         dec(16,2) ,
cod_cobertura     char(5),
cod_cober_reas    char(3),
cod_cober_reas_no char(3),
porc_partic_coas  dec(16,2) ,
monto_total       dec(16,2) ,
cod_ramo          char(3),
primary key (no_reclamo, numrecla, transaccion,periodo,no_tranrec,cod_tipotran,cod_cobertura,cod_cober_reas,cod_cober_reas_no,porc_partic_coas,monto_total)) with no log;

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
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal 
	 
	 
	 if a_cant_dias <> 0 then
	 
		select max(fecha) 
		  into _ult_fecha 
		  from rectrmae 
		 where no_reclamo   = _no_reclamo 
		   and actualizado  = 1; 
			   
		if (today - _ult_fecha) > a_cant_dias then	
		else
			continue foreach; 
		end if 
	
	end if

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
       and activo       = 1;  			-- Tabla para excluir polizas

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
			let _cod_cober_reas_tmp = _cod_cober_reas ;
			
			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas	;			   
				   
			let _cod_cober_reas_no = '';				   							
			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if						   
				   
				   if _cnt_existe = 0 then				   					 
				   
					let _cod_cober_reas_no = '';						
					
				   	if  _cod_ramo = '023' then
						if _cod_cober_reas = '031' or _cod_cober_reas = '034' then	
							select first 1 cod_cober_reas
								  into _cod_cober_reas_no
								  from rectrrea
								 where no_tranrec     = _no_tranrec
								   and cod_cober_reas in ('031','034');		
						end if					
						if _cod_cober_reas = '002' or _cod_cober_reas = '033' then	
							select first 1 cod_cober_reas
								  into _cod_cober_reas_no
								  from rectrrea
								 where no_tranrec     = _no_tranrec
								   and cod_cober_reas in ('002','033');		
						end if							
					end if   				   				   				   									
					
				   	if  _cod_ramo = '002' then
						if _cod_cober_reas = '031' or _cod_cober_reas = '002' then	
							select first 1 cod_cober_reas
								  into _cod_cober_reas_no
								  from rectrrea
								 where no_tranrec     = _no_tranrec
								   and cod_cober_reas in ('031','002');		
						end if					
						if _cod_cober_reas = '033' or _cod_cober_reas = '034' then	
							select first 1 cod_cober_reas
								  into _cod_cober_reas_no
								  from rectrrea
								 where no_tranrec     = _no_tranrec
								   and cod_cober_reas in ('034','033');		
						end if							
					end if   																									 					   				   
				   
				   select first 1 transaccion,user_added,cod_tipotran
					  into _transaccion,_user_added,_cod_tipotran
					  from rectrmae 
					 where cod_compania = a_compania
					   and periodo     <= a_periodo2 
					   and actualizado  = 1
					   and no_reclamo   = _no_reclamo
					   and numrecla = v_doc_reclamo
					   and no_tranrec = _no_tranrec;
					   
				select first 1 cod_contrato
				  into _cod_contrato
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas_no	;				   
					   
				select tipo_contrato,
					   serie,
					   facilidad_car
				  into _tipo_contrato,
					   _serie,
					   _facilidad_car
				  from reacomae
				 where cod_contrato = _cod_contrato;					   
		   
					   insert into tmp_dif_bx2(
						no_reclamo,
						numrecla, 
						transaccion,
						periodo,
						fecha,
						user_added,
						cod_contrato,						
						tipo_contrato,
						cod_tipotran,
						no_tranrec,
						variacion,
						cod_cobertura,
						cod_cober_reas,
						cod_cober_reas_no,
						porc_partic_coas,
						monto_total,
						cod_ramo)
						values(
						_no_reclamo,
						v_doc_reclamo,
						_transaccion,
						_periodo,
						current,
						_user_added,
						_cod_contrato,
						_tipo_contrato,
						_cod_tipotran,
						_no_tranrec,
						_reserva_bruto,
						_cod_cobertura,
						_cod_cober_reas,
						_cod_cober_reas_no,
						_porc_coas,
						_monto_bruto,
						_cod_ramo
						);
						
					    let _cod_cober_reas = _cod_cober_reas_no ;								 								  
					    let _cod_cober_reas_no = _cod_cober_reas_tmp;											

				   else				   
						let _cod_cober_reas_no = _cod_cober_reas ;								 								  
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
				let _res_otro   = 0;
				let _fac_car_1  = 0;
				let _fac_car_2  = 0;
				let _fac_car_3  = 0;
				let _exc_ret    = 0;
				let _exc_fac    = 0;
				let _ret_casco  = 0;
				let _res_ret_otros  = 0;
				let _res_cp_rc  = 0;
				let _res_cp_casco  = 0;

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
					{if (_cod_ramo = '002' and _cod_cober_reas = '031') or (_cod_ramo = '023' and _cod_cober_reas = '034' ) then
						let _ret_casco = _ret_casco + v_reserva_cedido; 
					else
						if _cod_ramo in ('002','023') then
							if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
								let _res_ret = _res_ret + v_reserva_cedido;
							else
								let _res_ret_otros = _res_ret_otros + v_reserva_cedido;
							end if
						else
							let _res_ret = _res_ret + v_reserva_cedido;
						end if
					end if}
					if _ramo_sis = 1 then
						if _cod_cober_reas in ('031','034') then
							let _ret_casco = _ret_casco + v_reserva_cedido;
						else
							if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
								let _res_ret = _res_ret + v_reserva_cedido;
							else
								let _res_ret_otros = _res_ret_otros + v_reserva_cedido;							
							end if
						end if
					else
						let _res_ret_otros = _res_ret_otros + v_reserva_cedido;
					end if
				elif _tipo_contrato = 3 then
					--let _pag_fac = _pag_fac + v_pagado_cedido;
					let _res_fac = _res_fac + v_reserva_cedido;		   
				else
					--let _pag_cont = _pag_cont + v_pagado_cedido;
					let _res_cont = _res_cont + v_reserva_cedido;		   

					if _tipo_contrato = 5 then
						--let _pag_5 = _pag_5 + v_pagado_cedido;
						--let _res_5 = _res_5 + v_reserva_cedido;
						if _ramo_sis = 1 then
							if _cod_cober_reas in ('031','034') then
								let _res_cp_casco = _res_cp_casco + v_reserva_cedido;
							else
								if _cod_cobertura in ('00102','00107','00113','00117','01299','01302','01304','01305') then
									let _res_cp_rc = _res_cp_rc + v_reserva_cedido;
								else
									let _res_5 = _res_5 + v_reserva_cedido;							
								end if
							end if
						else
							let _res_5 = _res_5 + v_reserva_cedido;
						end if
					elif _tipo_contrato = 7 then
						--let _pag_7 = _pag_7 + v_pagado_cedido;
						let _res_7 = _res_7 + v_reserva_cedido;
					else
					    let _res_otro = _res_otro + v_reserva_cedido;
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
				let v_suma_res = _res_ret + _res_fac + _res_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;

				if _facilidad_car = 1 then
					let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- pago
					let _fac_car_2 = _cp_res + _exc_res;				  -- reserva
					let _fac_car_3 = _cp_pag + _exc_pag;				  -- contratos
					let _cp_pag   = 0;
					let _exc_pag  = 0;
					let _pag_ret  = 0; 
					let _pag_fac  = 0;
					let _pag_cont = 0;
					--let _res_ret  = 0; 
					--let _res_fac  = 0;
					let _res_cont = 0;
				end if
				
				if _cod_contrato is null then
					continue foreach;
				end if
				
				--Calculo de Reserva Neta 13/11/2013
				let _reserva_neto = _res_ret + _ret_casco + _res_ret_otros;				
				
				--Calculo de Reserva Bruta 07/10/2014
				let _reserva_bruto = _res_ret + _ret_casco + _res_ret_otros +  _res_cont + _res_fac;
				
			{	if _cod_cober_reas <> _cod_cober_reas_no then
					begin
						on exception in(-239)
							update tmp_contrato1
							   set reserva_bruto = reserva_bruto + _reserva_bruto
							   
							 where cod_contrato = _cod_contrato
							   and no_reclamo = _no_reclamo
							   and serie_char = _serie_char;
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
						otro_res,
						ret_pag,
						fac_pag,
						cont_pag,
						ret_res,
						fac_res,
						cont_res,
						fac_car_1,
						fac_car_2,
						fac_car_3,
						cod_cobertura,
						serie_char,
						ret_casco,
						ret_otros,
						res_cp_rc,
						res_cp_casco
						)
						values(
						_cod_contrato,
						_no_reclamo,
						v_transaccion,           
						_no_poliza,           
						_cod_ramo,            
						_periodo,             
						v_doc_reclamo,            
						0,        
						_reserva_bruto,       
						0,
						_cod_sucursal,
						_serie,
						0,        
						0,       
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						0,
						_cod_cobertura,
						_serie_char,
						0,
						0,
						0,
						0);
					end 				
				else				}
					begin
						on exception in(-239)
							update tmp_contrato1
							   set cp_pag       = cp_pag		+ _pag_5,
								   exc_pag      = exc_pag		+ _pag_7,
								   cp_res       = cp_res		+ _res_5,
								   exc_res      = exc_res		+ _res_7,
								   otro_res     = otro_res      + _res_otro,
								   ret_pag      = ret_pag		+ _pag_ret,
								   fac_pag      = fac_pag		+ _pag_fac,
								   cont_pag     = cont_pag		+ _pag_cont,
								   ret_res      = ret_res		+ _res_ret,
								   fac_res      = fac_res		+ _res_fac,
								   cont_res     = cont_res		+ _res_cont,
								   fac_car_1	= fac_car_1		+ _fac_car_1,
								   fac_car_2	= fac_car_2		+ _fac_car_2,
								   fac_car_3	= fac_car_3		+ _fac_car_3,
								   ret_casco    = ret_casco		+ _ret_casco,
								   ret_otros    = ret_otros		+ _res_ret_otros,
								   res_cp_rc    = res_cp_rc		+ _res_cp_rc,
								   res_cp_casco    = res_cp_casco	+ _res_cp_casco,
								   reserva_neto = reserva_neto	+ _reserva_neto,
								   reserva_bruto = reserva_bruto + _reserva_bruto
							 where cod_contrato = _cod_contrato
							   and no_reclamo = _no_reclamo
							   and serie_char = _serie_char;
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
						otro_res,
						ret_pag,
						fac_pag,
						cont_pag,
						ret_res,
						fac_res,
						cont_res,
						fac_car_1,
						fac_car_2,
						fac_car_3,
						cod_cobertura,
						serie_char,
						ret_casco,
						ret_otros,
						res_cp_rc,
						res_cp_casco
						)
						values(
						_cod_contrato,
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
						_res_otro,
						_pag_ret,
						_pag_fac,
						_pag_cont,
						_res_ret,
						_res_fac,
						_res_cont,
						_fac_car_1,
						_fac_car_2,
						_fac_car_3,
						_cod_cobertura,
						_serie_char,
						_ret_casco,
						_res_ret_otros,
						_res_cp_rc,
						_res_cp_casco);
					end 
				--end if
			end foreach
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
IF a_cant_dias <> 0 THEN
	LET v_filtros = TRIM(v_filtros) || " Cantidad de dias: " ||  TRIM(_cantidad);
end if

let _inc_bruto = 0;
foreach
	select no_reclamo,           
		   transaccion,
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   pagado_bruto,
		   incurrido_bruto,
		   serie_char,
		   pagado_neto,
		   incurrido_neto,
		   sum(reserva_bruto),
		   sum(reserva_neto),
		   sum(cp_pag),
		   sum(exc_pag),
		   sum(cp_res),
		   sum(exc_res),
		   sum(otro_res),
		   sum(ret_pag),
		   sum(fac_pag),
		   sum(cont_pag),
		   sum(ret_res),
		   sum(fac_res),
		   sum(cont_res),
		   sum(fac_car_1),
		   sum(fac_car_2),
		   sum(fac_car_3),
		   sum(ret_casco),
		   sum(ret_otros),
		   sum(res_cp_rc),
		   sum(res_cp_casco)
	  into 	_no_reclamo,
		   v_transaccion,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   v_pagado_cedido,
		   v_incurrido_cedido,
		   _serie_char,
		   _pagado_neto,
		   _incurrido_neto,
		   v_reserva_cedido,
		   _reserva_neto,
		   _cp_pag,
		   _exc_pag,
		   _cp_res,
		   _exc_res,
		   _otro_res,
		   _pag_ret,
		   _pag_fac,
		   _pag_cont,
		   _res_ret,
		   _res_fac,
		   _res_cont,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3,
		   _ret_casco,
		   _res_ret_otros,
		   _res_cp_rc,
		   _res_cp_casco
	  FROM tmp_contrato1
	 WHERE seleccionado = 1
	 group by	no_reclamo,
				transaccion,
				no_poliza,
				cod_ramo,
				periodo,
				numrecla,
				pagado_bruto,
				incurrido_bruto,
				serie_char,
				pagado_neto,
				incurrido_neto

	if v_reserva_cedido = 0 and _reserva_neto = 0 then
		continue Foreach;
	end if

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 

	 --let _res_ret = 0;
	--let _res_cont = _cp_res + _exc_res ; --v_reserva_cedido - _reserva_neto;

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
		   cod_evento
	  into v_fecha_siniestro,
		   _no_unidad,
		   _cod_evento
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;	 

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
	end foreach

	select nombre
	  into _n_cober
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into v_cliente_nombre		
	  from cliclien 
	 where cod_cliente = _cod_cliente;

   --let _inc_bruto = v_reserva_cedido + _fac_car_1;
	let _incurrido_neto = 0;

    select count(*)
	  into _cant
	  from emipouni
	 where no_poliza = _no_poliza;

	RETURN v_doc_reclamo,         --1
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
		   _fac_car_2,			  --28
		   _fac_car_3,			  --29
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin,
		   _n_cober,
		   _ret_casco,
		   _cant,
		   _n_evento,
		   _res_ret_otros,
		   _otro_res,
		   _res_cp_rc,
		   _res_cp_casco
		   with resume;
end foreach
{insert into contrato1
select * from tmp_contrato1;}
drop table tmp_sinis;
drop table tmp_contrato1;

end procedure;	     

