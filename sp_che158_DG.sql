------------------------------------------------
--      Detalle Pantalla Operativa          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure sp_che158;
create procedure sp_che158(a_no_requis char(10))
returning	smallint;
																																												  
begin

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
define _nota_excepcion  varchar(255);
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
define _user_pre_aut    char(8);
define _date_pre_aut    datetime year to fraction(5);  
define _user_excepcion  char(8);
define _date_excepcion  datetime year to fraction(5);
define _fecha_estimada  date;
define _sum_deducible   dec(16,2);
define _origen_cheque   char(1);
define _deducible       dec(16,2);
define _deducible_pagado dec(16,2);

--	set debug file to "sp_che149.trc";
--	trace on;


set isolation to dirty read;	   

let _nota_excepcion = null;
let _dia_asegurado = 25;
let _dia_taller = 30;
	   
foreach
  SELECT autorizado,   
		 no_requis,   
         fecha_captura,   
         monto,   
         a_nombre_de,
		 nota_excepcion,
		 user_pre_aut,
		 date_pre_aut,
		 user_excepcion,
		 date_excepcion,
		 origen_cheque
    INTO _autorizado,   
		 _no_requis,   
         _fecha_captura,   
         _monto,   
         _a_nombre_de,
         _nota_excepcion,		 
		 _user_pre_aut,
		 _date_pre_aut,
		 _user_excepcion,
		 _date_excepcion,
		 _origen_cheque
    FROM chqchmae  
   WHERE no_requis = a_no_requis
 
	if _origen_cheque <> '3' then
		return 0;
	end if
 
    let _fecha_capt_ori = _fecha_captura;
     
	let _cantt = 0; 
	 
	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = _no_requis
		 exit foreach;
    end foreach	
	
	foreach
		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where numrecla = _numrecla
    end foreach	
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
    select cod_area
	  into _cantt
	  from prdramo
	 where cod_ramo = _cod_ramo;
		
	if _cantt = 0 or _origen_cheque <> '3' then
		return null;
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
				no_reclamo
		   into _no_documento,
		        _no_poliza,
				_perd_total,
				_date_doc_comp, -- Fecha de documentación completa Asegurados de automóvil
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
		  
		if _cantt = 1 and _cod_tipopago = '004' then -- Pago a tercero
			let _date_doc_comp = null;
			select date_doc_comp
			  into _date_doc_comp -- Fecha de documentación completa Tercero de automóvil
			  from recterce
			 where no_reclamo = _no_reclamo
			   and cod_tercero = _cod_cliente;
		end if
		  
		if _cantt = 1 then -- Automóvil				
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
				let _dias_compara = 0; --Se cambia de 25 a 0 solicitado por Leyri Moreno 31-07-2019
			else
				let _dias_compara = 0;
			end if
		elif _cantt = 2 then -- Personas 
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
				let _dias_compara = 0; --Se cambia de 25 a 0 solicitado por Leyri Moreno 31-07-2019
			else
				let _dias_compara = 0;
			end if
        end if
		
		let _prioridad_tmp = 0;  
		let _dias_compara_tmp = 0;
		
         -- Prioridad por Poliza	
		 
		 select a.prioridad,
		        a.dias
		   into _prioridad_tmp,
		        _dias_compara_tmp
		   from chepripag a, prdramo b
		  where a.valor_caso = _no_documento
		    and a.cod_ramo = b.cod_ramo
			and b.cod_area = _cantt
			and a.tipo_caso = 1;
			
		if _prioridad_tmp is null then
			let _prioridad_tmp = 0;
		end if
		
		if _prioridad < _prioridad_tmp then
			let _prioridad = _prioridad_tmp;		
		end if
		
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
			  
			 let _prioridad_tmp = 0;  
			 let _dias_compara_tmp = 0;
			  
			 select a.prioridad,
			        a.dias
			   into _prioridad_tmp,
			        _dias_compara_tmp
			   from chepripag a, prdramo b
			  where a.valor_caso = _cod_agente
		        and a.cod_ramo = _cod_ramo
				and a.cod_ramo = b.cod_ramo
				and b.cod_area = _cantt
			    and a.tipo_caso = 2;
				
			if _prioridad_tmp is null then
				let _prioridad_tmp = 0;
			end if
			
			if _prioridad < _prioridad_tmp then
				let _prioridad = _prioridad_tmp;
			end if	

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
		  
		 select a.prioridad,
		        a.dias
		   into _prioridad_tmp,
		        _dias_compara_tmp
		   from chepripag a, prdramo b
		  where a.valor_caso = _cod_grupo
		    and a.cod_ramo = _cod_ramo
			and a.cod_ramo = b.cod_ramo
			and b.cod_area = _cantt
			and a.tipo_caso = 3;

		if _prioridad_tmp is null then
			let _prioridad_tmp = 0;
		end if
			
		 if _prioridad < _prioridad_tmp then
			let _prioridad = _prioridad_tmp;
		 end if			 

		if _dias_compara_tmp is null then
			let _dias_compara_tmp = 0;
		end if
			
		if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
			let _dias_compara = _dias_compara_tmp;
		end if
		 
         -- Prioridad por Proveedor

		 let _prioridad_tmp = 0;  
		 let _dias_compara_tmp = 0;
		  
         if _cod_tipopago = '001' then		 
			 select a.prioridad,
			        a.dias
			   into _prioridad_tmp,
			        _dias_compara_tmp
			   from chepripag a, prdramo b
			  where a.valor_caso = _cod_cliente
				and a.cod_ramo = _cod_ramo
				and a.cod_ramo = b.cod_ramo
				and b.cod_area = _cantt
			    and a.tipo_caso = 4;

			if _prioridad_tmp is null then
				let _prioridad_tmp = 0;
			end if				
				
			if _prioridad < _prioridad_tmp then
				let _prioridad = _prioridad_tmp;
			end if			 
			 
			if _dias_compara_tmp is null then
				let _dias_compara_tmp = 0;
			end if
				
			if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
				let _dias_compara = _dias_compara_tmp;
			end if
		 end if
		 
		let _cant_chqchrec = _cant_chqchrec + 1;
		   
	-- Prioridades por días transcurridos
	
	    let _dias = today - _fecha_captura;
		
		if _cantt = 1 then -- Automóvil		  	
			if _cod_tipopago = '003' then --Pago a Asegurado
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
			--	if _dias >= _dia_asegurado then
			--		let _prioridad = 100;
			--	end if	
			elif _cod_tipopago = '004' then --Pago a Tercero y deducible pagado
			
			    let _deducible = 0.00;
				let _deducible_pagado = 0.00;
				
				foreach
					select a.deducible, a.deducible_pagado
					  into _deducible, _deducible_pagado
					  from recrccob a, prdcober b
					 where a.cod_cobertura = b.cod_cobertura
					   and a.no_reclamo = _no_reclamo
					   and b.nombre like '%PROPIEDAD AJENA%'					   
				end foreach
				
				if _deducible is null then
					let _deducible = 0.00;
				end if
				
				if _deducible_pagado is null then
					let _deducible_pagado = 0.00;
				end if
				
				if _deducible = 0.00 then
					if _dias >= _dia_asegurado then
						let _prioridad = 100;
					end if	
				elif _deducible > 0.00 then
					select sum(monto)
					  into _sum_deducible
					  from rectrcon
					 where no_tranrec = _no_tranrec
					   and cod_concepto = '006';
					
					if _dias >= _dia_asegurado and (_sum_deducible <> 0.00 or _deducible_pagado <> 0.00) then 
						let _prioridad = 100;
					end if	
				end if
			else  -- Pago a Proveedor o Pago a Taller
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
		elif _cantt = 2 then -- Personas 
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
	
end foreach


return _prioridad;

end
DROP TABLE tmp_chqchmae;
end procedure  

 
		