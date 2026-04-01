------------------------------------------------
--      Buscando y pasando requisiones con 25 dias o mas de atraso          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure sp_che150b;
create procedure sp_che150b(a_area smallint, a_anio integer, a_mes smallint)
returning	char(10),
	        dec(16,2);
																																												  

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
define _error_desc		char(100);
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
	   prioridad     smallint);

	set debug file to "sp_che150.trc";
	trace on;
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
   WHERE origen_cheque = '3'  
--     AND pagado = 0  
--     AND en_firma = 2  
--	 AND pre_autorizado = 0
	 and no_requis = '756292'
     
    let _fecha_capt_ori = _fecha_captura;
	
	let _cantt = 0; 
	 
    foreach   
	   select cod_ramo
	     into _cod_ramo
		 from prdramo
	    where cod_area = a_area
	
	   select count(*)	 
		 into _cant
		 from chqchrec
		where no_requis = _no_requis
		  and numrecla[1,2] = _cod_ramo[2,3];
		
	   let _cantt = _cantt + _cant;
    end foreach
	
	if _cantt = 0 then
		continue foreach;
	end if
	
	let _prioridad = 0;  		
	let _dias_compara = 0;
	let _cant_chqchrec = 0;
	let _dia_asegurado = 25;
	let _dia_taller = 30;
	
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
				cod_asignacion,
				no_reclamo
		   into _no_documento,
		        _no_poliza,
				_perd_total,
				_date_doc_comp,
				_cod_asignacion,
				_no_reclamo
		   from recrcmae
		  where numrecla = _numrecla;

         select no_tranrec,
		        cod_tipopago, 
		        cod_cliente,
				fecha_factura
           into _no_tranrec,
		        _cod_tipopago,
		        _cod_cliente,
				_fecha_factura
           from rectrmae
          where transaccion = _transaccion;		   
		  
		if a_area = 1 and _cod_tipopago = '004' then -- Pago a tercero
			let _date_doc_comp = null;
			select date_doc_comp
			  into _date_doc_comp -- Fecha de documentación completa Tercero de automóvil
			  from recterce
			 where no_reclamo = _no_reclamo
			   and cod_tercero = _cod_cliente;
		end if
		  
		if a_area = 1 then -- Automóvil		  
			if _date_doc_comp is not null then  		
				if _date_doc_comp < _fecha_captura then
					let _fecha_captura = _date_doc_comp;
				end if
			End If
			
			select count(*) -- Verificando si es una requisición de pago por ajuste
			  into _cant_ajust			
			  from recordam
			 where no_requis = _no_requis;
			 
			if _cant_ajust > 0 then
				let _date_doc_comp = null;
				
				select fecha_recibido
				  into _date_doc_comp
				  from recordam
				 where no_requis = _no_requis;
				 
				if _date_doc_comp is not null then
					let _fecha_captura = _date_doc_comp;
				End If
            end if		
			
			select count(*) -- Verificando si es proveedores de servicios
			  into _cant_serv
			  from rectrcon a, chepripag b
			 where a.no_tranrec = _no_tranrec
			   and a.cod_concepto = b.valor_caso
			   and b.tipo_caso = 5; 
			   
			if _cant_serv > 0 then
				if _fecha_factura is not null then
					let _fecha_captura = _fecha_factura;  -- Fecha de la factura	
                else
					let _fecha_captura = _fecha_capt_ori; -- Fecha en que se capturó la requisicion
				end if
			end if

			if _cod_tipopago = '003' or _cod_tipopago = '004' then --Pago a Asegurado o Tercero
				let _dias_compara = 25;
			else
				let _dias_compara = 30;
			end if
		elif a_area = 2 then -- Personas
		    select cod_entrada
			  into _cod_entrada -- Número del bloque
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
				let _dias_compara = 25;
			else
				let _dias_compara = 30;
			end if
        end if

		let _dias_compara_tmp = 0;

         -- Prioridad por Poliza	
		 
		 select a.dias
		   into _dias_compara_tmp
		   from chepripag a, prdramo b
		  where a.valor_caso = _no_documento
		    and a.cod_ramo = b.cod_ramo
			and b.cod_area = a_area
			and a.tipo_caso = 1;
					
		if _dias_compara_tmp is null then
			let _dias_compara_tmp = 0;
		end if
			
		if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
			let _dias_compara = _dias_compara_tmp;
		end if
		
		-- Buscando grupo y ramo
		
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
				and b.cod_area = a_area
			    and a.tipo_caso = 2;
				
			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
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
			and b.cod_area = a_area
			and a.tipo_caso = 3;

			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
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
				and b.cod_area = a_area
			    and a.tipo_caso = 4;

			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
			end if
				
			if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
				let _dias_compara = _dias_compara_tmp;
			end if
		 end if
		 
		let _cant_chqchrec = _cant_chqchrec + 1;
		
		let _dias = today - _fecha_captura;
				
		if a_area = 1 then -- Automóvil		  	
			if _cod_tipopago = '003' or _cod_tipopago = '004' then --Pago a Asegurado o Tercero
				if _dias >= _dia_asegurado then
					let _prioridad = 100;
				end if	
			else
				let _dias_compara_tmp = 0;
				
				foreach
					select b.dias
					  into _dias_compara_tmp
					  from rectrcon a, chepripag b
					 where a.no_tranrec = _no_tranrec
					   and a.cod_concepto = b.valor_caso
					   and b.tipo_caso = 5 
				 
					if _dias_compara_tmp is null then
						let _dias_compara_tmp = 0;
					end if
						
					if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
						let _dias_compara = _dias_compara_tmp;
					end if
				end foreach

				if _dias >= _dias_compara then
					let _prioridad = 100;
				end if	
			end if		
		elif a_area = 2 then -- Personas 
			if _cod_tipopago = '003' then --Pago a Asegurado
				if _dias >= _dias_compara then
					let _prioridad = 100;
				end if	
				
			else
				if _dias >= _dia_taller then
					let _prioridad = 100;
				end if	
			end if
		end if		
	
	end foreach
	
	if _prioridad = 100 then
	
		if _cant_chqchrec = 1 then
			select nombre 
			  into _tipo_pago
			  from rectipag
			 where cod_tipopago = _cod_tipopago;
			 
			if _perd_total = 1 then
				let _perdida = 'Si';
			else
				let _perdida = 'No';
			end if
			
		else
			let _tipo_pago = 'Detalle';
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
		   prioridad)
		values(
		   0,
		   _no_requis,
		   _fecha_captura,
		   _dias,
		   _monto,
		   _a_nombre_de,
		   _no_documento,
		   _agente,
		   _tipo_pago,
		   _perdida,
		   _prioridad
		   );		
	   
	end if	
	
end foreach	

select saldo
  into _saldo
  from cheprereq
 where anio = a_anio
   and mes = a_mes
   and opc = a_area;
   
if _saldo is null then
	let _saldo = 0;
end if

let _monto_tot = 0;   
   
foreach with hold
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
		   prioridad
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
		   _prioridad
	  from tmp_chqchmae
	 order by prioridad desc, fecha_captura asc
	 
	 let _saldo = _saldo - _monto;
	 
	 if _saldo >= 0 then
		return _no_requis,
		       _monto with resume;
	 end if
	 
end foreach

DROP TABLE tmp_chqchmae;

end
end procedure  

 
		