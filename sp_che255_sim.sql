------------------------------------------------
--      Buscando y pasando requisiones con 25 dias o mas de atraso          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure sp_che255_sim;
create procedure sp_che255_sim(a_fecha date)
returning	int,
	        varchar(255);
																																												  

define _autorizado 		smallint;   
define _no_requis 		char(10);   
define _fecha_captura 	date;   
define _monto 			dec(16,2);   
define _a_nombre_de		varchar(100);
define _cod_ramo 		char(3);
define _cant   			smallint;
define _cantt			smallint;	 
define _cant_chqchrec   smallint;
define _numrecla        char(20);
define _transaccion     char(10);
define _prioridad 		smallint;  
define _prioridad_tmp 	smallint;  
define _cant_agt        smallint;
define _cod_agente      char(5);
define _no_documento    char(20);
define _no_poliza       char(10);
define _perd_total      smallint;
define _agente          varchar(50);
define _cod_grupo       char(5);
define _cod_tipopago    char(3);
define _cod_cliente     char(10);
define _tipo_pago       varchar(50);
define _perdida         varchar(15);
define _saldo           dec(16,2);
define _dias            integer;
define _date_doc_comp   date;
define _cod_asignacion  char(10);
define _fecha_scan      date;
define _monto_tot       dec(16,2);
define _error_cod		integer;
define _error_isam		integer;
define _error_desc		char(255);
define _cod_entrada     char(10);
define _no_reclamo      char(10);
define _dias_compara    smallint;
define _dias_compara_tmp smallint;
define _no_tranrec      char(10);
define _dia_taller      smallint;
define _dia_asegurado   smallint;
define _cant_ajust      smallint;
define _cant_serv       smallint;
define _fecha_factura   date;
define _fecha_capt_ori  date;
define _sum_deducible   dec(16,2);
define _deducible       dec(16,2);
define _deducible_pagado dec(16,2);
define _cant_otros      smallint;
define _cod_tipo        char(3);
define _cant_tipo_dif   smallint;
define _orden           smallint;
define _por_prioridad   smallint;
define _nota_excepcion  varchar(255);
define _dias_max		integer;

--return 0, "Exito";

create temp table tmp_chqchmae(
       autorizado    smallint,
	   no_requis     char(10),
	   fecha_captura date,
	   dias          int,         
	   monto         dec(16,2),
	   a_nombre_de   varchar(100),
	   no_documento  char(20),
	   agente        varchar(50),
       tipo_pago     varchar(50),
	   perdida       varchar(15),
	   prioridad     smallint,
	   orden		 smallint,
	   nota_excepcion varchar(255) default null);

--	set debug file to "sp_che255.trc";
--	trace on;
begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

set isolation to dirty read;	
	
foreach
  SELECT autorizado,   
		 no_requis,   
         fecha_captura,   
         monto,   
         a_nombre_de
    INTO _autorizado,   
		 _no_requis,   
         _fecha_captura,   
         _monto,   
         _a_nombre_de		 
    FROM chqchmae  
   WHERE origen_cheque in ('3','M')
     AND pagado = 0  
     AND en_firma = 2  
	 AND pre_autorizado = 1
	 AND aut_imp_tec = 0
     AND tipo_requis = 'A'     
	 
    let _fecha_capt_ori = _fecha_captura;
	
	let _cantt = 0; 
	let _cant_otros = 0; 
	let _cant_tipo_dif = 0; 
	let _orden = 0;
	 	
	select count(*)	 
	  into _cantt
	  from chqchrec
	 where no_requis = _no_requis
	   and numrecla[1,2] in ('18','04','19');
			
	if _cantt = 0 then
		continue foreach;
	end if
	
	select count(*)	 
	  into _cant_otros
	  from chqchrec
	 where no_requis = _no_requis
	   and numrecla[1,2] not in ('18', '04');
	   
	if _cant_otros > 0 then
		--continue foreach;
	end if	
	
	select count(*)	  
	  into _cant_tipo_dif
	  from chqchrec a, rectrmae b, atcdocde c
	 where a.transaccion = b.transaccion
	   and b.cod_asignacion = c.cod_asignacion
	   and a.no_requis = _no_requis
	   and c.cod_tipo not in ('29','09','23','25','27','28');
		
	if _cant_tipo_dif is null then
		let _cant_tipo_dif = 0;
	end if
		
	let _prioridad = 99;  		
	let _dias_compara = 0;
	let _cant_chqchrec = 0;
	let _dia_asegurado = 25;
	let _dia_taller = 30;
	let _cod_tipo = null;
	let _por_prioridad = 0;
	let _nota_excepcion = null;
	let _dias_max = 0;
	
	foreach
		select numrecla, 
		       transaccion
		  into _numrecla,
		       _transaccion
		  from chqchrec
		 where no_requis = _no_requis 
		 
		let _date_doc_comp = null;
		let _fecha_scan = null;
		 
		select no_documento,
			   no_poliza,
			   perd_total,
			   date_doc_comp,
			   no_reclamo
		  into _no_documento,
			   _no_poliza,
			   _perd_total,
			   _date_doc_comp,
			   _no_reclamo
		  from recrcmae
		 where numrecla = _numrecla;

		select no_tranrec,
			   cod_tipopago, 
			   cod_cliente,
			   cod_asignacion,
			   fecha_factura
		  into _no_tranrec,
			   _cod_tipopago,
			   _cod_cliente,
			   _cod_asignacion,
			   _fecha_factura
		  from rectrmae
		 where transaccion = _transaccion;		   
		  
		select cod_entrada,
			   cod_tipo
		  into _cod_entrada, -- Número del bloque
			   _cod_tipo
		  from atcdocde
		 where cod_asignacion = _cod_asignacion;
			 
		    select date(fecha) -- Fecha en que se creó el bloque
			  into _fecha_scan
			  from atcdocma
			 where cod_entrada = _cod_entrada;
			 
			if _fecha_scan is not null then  		
				if _fecha_scan < _fecha_captura then
					let _fecha_captura = _fecha_scan;
				end if
			End If
			if _cod_tipopago = '003' then --Pago a Asegurado
				let _dias_compara = 0; --Se cambia de 25 a 0 solicitado por Leyri Moreno 31-07-2019
			else
				let _dias_compara = 30;
			end if

		let _dias_compara_tmp = 0;

         -- Prioridad por Poliza
		 
		if _no_documento = '0208-00482-01' and _perd_total = 0 then -- Se prioriza el pago de la poliza de suntracs que sea perdidas 05-07-2017 Amado
		else
			 select a.dias
			   into _dias_compara_tmp
			   from chepripag a, prdramo b
			  where a.valor_caso = _no_documento
				and a.cod_ramo = b.cod_ramo
				and b.cod_area = 2
				and a.tipo_caso = 1;
		end if			
		
		if _dias_compara_tmp is null then
			let _dias_compara_tmp = 0;
		end if
		
		if _dias_compara_tmp > 0 then
			let _por_prioridad = 1;
			let _nota_excepcion = "Prioridad por Poliza";
		end if
			
		if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
			let _dias_compara = _dias_compara_tmp;
		end if

 		 select cod_grupo,
		        cod_ramo
		   into _cod_grupo,
		        _cod_ramo
		   from emipomae
		  where no_poliza = _no_poliza;
		  
        -- Prioridad por Agente		 
		 
		 let _cant_agt = 0;
		 
         foreach		 
			 select cod_agente
			   into _cod_agente
			   from emipoagt
			  where no_poliza = _no_poliza
			  
			 let _dias_compara_tmp = 0;
			  
			 select a.dias
			   into _dias_compara_tmp
			   from chepripag a, prdramo b
			  where a.valor_caso = _cod_agente
		        and a.cod_ramo = _cod_ramo
				and a.cod_ramo = b.cod_ramo
				and b.cod_area = 2
			    and a.tipo_caso = 2;
				
			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
			end if

			if _dias_compara_tmp > 0 then
				let _por_prioridad = 1;
				let _nota_excepcion = "Prioridad por Agente";
			end if
				
			if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
				let _dias_compara = _dias_compara_tmp;
			end if
			 
            let _cant_agt = _cant_agt + 1;			 
         end foreach    	

         if _cant_agt = 1 then
            select nombre 
              into _agente
              from agtagent
             where cod_agente = _cod_agente;
         else 
            let _agente = 'Detalle';
         end if			
			   
         -- Prioridad por Grupo
		 		  
		 let _prioridad_tmp = 0;  
		 let _dias_compara_tmp = 0;
		  
		 select a.dias
		   into _dias_compara_tmp
		   from chepripag a, prdramo b
		  where a.valor_caso = _cod_grupo
		    and a.cod_ramo = _cod_ramo
			and a.cod_ramo = b.cod_ramo
			and b.cod_area = 2
			and a.tipo_caso = 3;

			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
			end if
				
			if _dias_compara_tmp > 0 then
				let _por_prioridad = 1;
				let _nota_excepcion = "Prioridad por Grupo";
			end if
		
			if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
				let _dias_compara = _dias_compara_tmp;
			end if
		 
         -- Prioridad por Proveedor

		 let _dias_compara_tmp = 0;
		  
         if _cod_tipopago = '001' then		 
			 select a.dias
			   into _dias_compara_tmp
			   from chepripag a, prdramo b
			  where a.valor_caso = _cod_cliente
				and a.cod_ramo = _cod_ramo
				and a.cod_ramo = b.cod_ramo
				and b.cod_area = 2
			    and a.tipo_caso = 4;

			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
			end if
				
			if _dias_compara_tmp > 0 then
				let _por_prioridad = 1;
				let _nota_excepcion = "Prioridad por Proveedor";
			end if

			if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
				let _dias_compara = _dias_compara_tmp;
			end if
		 end if
		 		
		let _dias = sp_par389(_fecha_captura, today);
		
		if _dias > _dias_max then
			let _dias_max = _dias;
		end if		
		 		 
		if _cod_tipopago = '003' then --Pago a Asegurado
			if _monto <= 5000.00 then
				if _cod_ramo = '018' then
					let _prioridad = 99 + _por_prioridad;
					if _por_prioridad = 1 then
						let _nota_excepcion = trim(_nota_excepcion) || " y Prioridad por Monto menor o igual a 5,000";
					else
						let _nota_excepcion = "Prioridad por Monto menor o igual a 5,000";
					end if
				else
					select count(*)
					  into _cant
					  from rectrcob
					 where no_tranrec = _no_tranrec
					   and monto > 0 
					   and cod_cobertura in ('00205','00210');
					   
					if _cant > 0 then
    					let _prioridad = 99 + _por_prioridad;
						if _por_prioridad = 1 then
							let _nota_excepcion = trim(_nota_excepcion) || " y Prioridad por Monto menor o igual a 5,000";
						else
							let _nota_excepcion = "Prioridad por Monto menor o igual a 5,000";
						end if
					end if
				end if
			else
				if _dias >= _dias_compara then
					let _prioridad = 99 + _por_prioridad;
				end if
			end if
			if _nota_excepcion is not null and trim(_nota_excepcion) <> "" then
				let _orden = 1;
			else
				let _orden = 4;
			end if
		elif _cod_tipopago = '001' then --Pago a Proveedor	TBD818 SD 14849 11-09-2025
			if _cant_otros = 0 and _monto <= 5000.00 then -- 018-SALUD y 004-ACCIDENTES PERSONALES, MONTO IGUAL O MENOR A 5,000.00 
				--29-HONORARIOS MEDICOS MENOR DE 200                                	
				--09-ACCIDENTE PERSONAL                                	
				--23-GASTOS FUNERARIOS                                 	
				--25-ASISTENCIA EN VIAJE                               	
				--27-ATENCION MEDICA DOMICILIARIA                      	
				--28-AMBULATORIA**	
				if _cant_tipo_dif = 0 then
					let _prioridad = 99 + _por_prioridad;
					if _por_prioridad = 1 then
						let _nota_excepcion = trim(_nota_excepcion) || " y Prioridad por Monto menor o igual a 5,000";
					else
						let _nota_excepcion = "Prioridad por Monto menor o igual a 5,000";
					end if
				end if
			end if
			if _dias >= _dias_compara then
				let _prioridad = 99 + _por_prioridad;
			end if	
			if _nota_excepcion is not null and trim(_nota_excepcion) <> "" then
				let _orden = 2;
			else
				let _orden = 5;
			end if
		else
			if _dias >= _dias_compara then
				let _prioridad = 99 + _por_prioridad;
			end if	
			if _nota_excepcion is not null and trim(_nota_excepcion) <> "" then
				let _orden = 3;
			else
				let _orden = 6;
			end if
		end if

		let _cant_chqchrec = _cant_chqchrec + 1;
	
	end foreach
	
	let _agente = null;
	
	if _prioridad >= 99 then

		select nombre 
		  into _tipo_pago
		  from rectipag
		 where cod_tipopago = _cod_tipopago;
	
		if _cant_chqchrec = 1 then
			 
			if _perd_total = 1 then
				let _perdida = 'Si';
			else
				let _perdida = 'No';
			end if
			
		else
			--let _tipo_pago = 'Detalle';
			let _perdida = 'Detalle';
			let _no_documento = 'Detalle';
			let _agente = 'Detalle';
			let _perdida = 'Detalle';
		end if					
		
		insert into tmp_chqchmae(
		   autorizado,
		   no_requis,
		   fecha_captura,
		   dias,
		   monto,
		   a_nombre_de,
		   no_documento,
		   agente,
		   tipo_pago,
		   perdida,
		   prioridad,
		   orden,
		   nota_excepcion)
		values(
		   0,
		   _no_requis,
		   _fecha_captura,
		   _dias_max,
		   _monto,
		   _a_nombre_de,
		   _no_documento,
		   _agente,
		   _tipo_pago,
		   _perdida,
		   _prioridad,
		   _orden,
		   _nota_excepcion
		   );		
	   
	end if	
	
end foreach	

select saldo
  into _saldo
  from chepresem
 where a_fecha between fecha_desde and fecha_hasta
   and opc = 2;
   
if _saldo is null then
	let _saldo = 0;
end if

let _monto_tot = 0;   
   
foreach
    select autorizado,
		   no_requis,
		   fecha_captura,
		   dias,
		   monto,
		   a_nombre_de,
		   no_documento,
		   agente,
		   tipo_pago,
		   perdida,
		   prioridad,
		   orden,
		   nota_excepcion
	  into _autorizado,
		   _no_requis,
		   _fecha_captura,
		   _dias,
		   _monto,
		   _a_nombre_de,
		   _no_documento,
		   _agente,
		   _tipo_pago,
		   _perdida,
		   _prioridad,
		   _orden,
		   _nota_excepcion
	  from tmp_chqchmae
	 order by prioridad desc, orden asc, dias desc	 
	 
--	 if _saldo >= _monto then
		let _saldo = _saldo - _monto;
		let _monto_tot = _monto_tot + _monto;		
	{	update chqchmae 
		   set aut_imp_tec = 1,
               user_aut_imp_tec = 'informix', 
   			   date_aut_imp_tec = current,
			   nota_excepcion = _nota_excepcion
		 where no_requis = _no_requis;}
--	 end if
	 
end foreach

--DROP TABLE tmp_chqchmae;

{update chepresem
   set saldo = saldo - _monto_tot,
       preautorizado = preautorizado + _monto_tot
 where a_fecha between fecha_desde and fecha_hasta
   and opc = 2;}

   return 0, "Exito";
end
end procedure