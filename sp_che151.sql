------------------------------------------------
--   Detalle de Autoriza Cheque          --
---  Amado - 21/06/2016 --
------------------------------------------------
drop procedure sp_che151;
create procedure sp_che151(a_usuario char(8) default "%", 
			a_origen_chk char(1) default "%", 
			a_banco char(3), 
			a_chequera char(3), 
			a_compania char(3), 
			a_sucursal char(3), 
			a_en_firma smallint, 
			a_en_firma2 smallint, 
			a_pre_autorizado smallint, 
			a_pre_autorizado2 smallint)
			
returning	char(10) as no_requis,
            char(25) as cuenta,
			char(10) as cod_cliente,
			char(5)  as cod_agente,
			char(3)  as cod_banco,
			char(3)  as cod_chequera,
			char(3)  as cod_compania,
			char(3)  as cod_sucursal,
			integer  as no_cheque,
			date     as fecha_impresion,
			date     as fecha_captura,
			smallint as autorizado,
			smallint as pagado,
			varchar(100) as a_nombre_de,
			smallint as cobrado,
			date as fecha_cobrado,
			smallint as anulado,
			date as fecha_anulado,
			char(8) as anulado_por,
			dec(16,2) as monto,
			char(7) as periodo,
			char(8) as user_added,
			char(8) as autorizado_por,
			char(1) as origen_cheque,
			integer as incidente,
			smallint as aut_workflow,
			char(20) as firma1,
			char(20) as firma2,
			char(2)  as cod_ruta,
			smallint as en_firma,
			date as fecha,
			integer as dias,
			smallint as prioridad,
			varchar(100) as contratante,
			varchar(255) as nota_excepcion,
			char(8) as user_excepcion,
			datetime year to fraction(5) as date_excepcion,
			char(8) as user_pre_aut,
			datetime year to fraction(5) as date_pre_aut,
			varchar(50) as tipo_pago,
			smallint as desc_deducible,
			char(20) as reclamo,
			varchar(50) as ajustador,
			varchar(100) as nombre_corredor;
																																												  
begin
define _nombre_corredor		varchar(100);
define _no_requis 		char(10);   
define _cuenta          char(25);
define _cod_cliente     char(10);
define _cod_agente      char(5);
define _cod_banco       char(3);
define _cod_chequera    char(3);  
define _cod_compania    char(3);   
define _cod_sucursal    char(3);   
define _no_cheque       integer;
define _fecha_impresion date;   
define _fecha_captura 	date;   
define _autorizado 		smallint;   
define _pagado          smallint;
define _a_nombre_de		varchar(100);
define _cobrado         smallint;  
define _fecha_cobrado   date;   
define _anulado         smallint;   
define _fecha_anulado   date;   
define _anulado_por     char(8);   
define _monto 			dec(16,2);   
define _periodo         char(7);   
define _user_added      char(8);   
define _autorizado_por  char(8);   
define _origen_cheque   char(1);   
define _incidente       integer;
define _aut_workflow    smallint;
define _firma1          char(20);
define _firma2          char(20);
define _cod_ruta        char(2);
define _en_firma        smallint;

define _cod_ramo 		char(3);
define _cant   			smallint;
define _cantt			smallint;	 
define _cant_chqchrec   smallint;
define _numrecla        char(20);
define _transaccion     char(10);
define _prioridad 		smallint;  
define _prioridad_tmp 	smallint;  
define _cant_agt        smallint;
define _no_documento    char(20);
define _no_poliza       char(10);
define _perd_total      smallint;
define _agente          varchar(50);
define _cod_grupo       char(5);
define _cod_tipopago    char(3);
define _tipo_pago       varchar(50);
define _perdida         varchar(15);
define _saldo           dec(16,2);
define _dias            integer;
define _date_doc_comp   date;
define _cod_asignacion  char(10);
define _fecha_scan      date;
define _fecha_cont      date;
define _cod_contratante char(10);
define _contratante     varchar(100);
define _cod_area        smallint;
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
define _deducible       smallint;
define _sum_deducible   dec(16,2);
define _ajust_interno   char(3);
define _ajustador       varchar(50);

	--set debug file to "sp_che149.trc";
	--trace on;

set isolation to dirty read;	   

let _prioridad = 0;
let _nombre_corredor = '';
	   
foreach
  SELECT no_requis,   
         cuenta,   
         cod_cliente,   
         cod_agente,   
         cod_banco,   
         cod_chequera,   
         cod_compania,   
         cod_sucursal,   
         no_cheque,   
         fecha_impresion,   
         fecha_captura,   
         autorizado,   
         pagado,   
         a_nombre_de,   
         cobrado,   
         fecha_cobrado,   
         anulado,   
         fecha_anulado,   
         anulado_por,   
         monto,   
         periodo,   
         user_added,   
         autorizado_por,   
         origen_cheque,   
         incidente,   
         aut_workflow,   
         firma1,   
         firma2,   
         cod_ruta,   
         en_firma,
         nota_excepcion,
         user_excepcion,
         date_excepcion,
         user_pre_aut,
         date_pre_aut		 
	INTO _no_requis,   
         _cuenta,   
         _cod_cliente,   
         _cod_agente,   
         _cod_banco,   
         _cod_chequera,   
         _cod_compania,   
         _cod_sucursal,   
         _no_cheque,   
         _fecha_impresion,   
         _fecha_captura,   
         _autorizado,   
         _pagado,   
         _a_nombre_de,   
         _cobrado,   
         _fecha_cobrado,   
         _anulado,   
         _fecha_anulado,   
         _anulado_por,   
         _monto,   
         _periodo,   
         _user_added,   
         _autorizado_por,   
         _origen_cheque,   
         _incidente,   
         _aut_workflow,   
         _firma1,   
         _firma2,   
         _cod_ruta,   
         _en_firma,
         _nota_excepcion,		 
         _user_excepcion,
         _date_excepcion,
         _user_pre_aut,
         _date_pre_aut		 
    FROM chqchmae  
   WHERE ( user_added like a_usuario ) AND  
         ( origen_cheque like a_origen_chk ) AND  
         ( cod_banco = a_banco ) AND  
         ( cod_chequera = a_chequera ) AND  
         ( cod_compania = a_compania ) AND  
         ( cod_sucursal like a_sucursal ) AND  
         ( pagado = 0 ) AND  
         ( tipo_requis = 'C' ) AND  
         ( en_firma in ( a_en_firma, a_en_firma2 ) ) AND
		 ( pre_autorizado in (a_pre_autorizado, a_pre_autorizado2))
ORDER BY a_nombre_de
 
if _no_requis = '924460' then
	set debug file to "sp_che151.trc";
	trace on;
end if 

    let _fecha_capt_ori = _fecha_captura;
    let _fecha_cont = _fecha_captura;  
	let _prioridad = 0;
	let _dias = today - _fecha_cont;    
	let _prioridad = 0;
    let _contratante = null; 	
	let _dia_asegurado = 25;
	let _dia_taller = 30;
	let _deducible = 0;
    let _ajustador = null;
     		
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
				no_reclamo,
				ajust_interno
		   into _no_documento,
		        _no_poliza,
				_perd_total,
				_date_doc_comp,
				_no_reclamo,
				_ajust_interno
		   from recrcmae
		  where numrecla = _numrecla;
		  
		  select nombre
		    into _ajustador
			from recajust
		   where cod_ajustador = _ajust_interno;

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
		  		  
		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		select cod_area
		  into _cod_area
		  from prdramo
		 where cod_ramo = _cod_ramo;
		 
		if _cod_area = 1 and _cod_tipopago = '004' then -- Pago a tercero
			let _date_doc_comp = null;
			select date_doc_comp
			  into _date_doc_comp -- Fecha de documentación completa Tercero de automóvil
			  from recterce
			 where no_reclamo = _no_reclamo
			   and cod_tercero = _cod_cliente;
		end if
		  
		if _cod_area = 1 then -- Automóvil		  
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
				let _dias_compara = 30;
			end if
		elif _cod_area = 2 then -- Personas
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
			
			if _cod_tipopago = '003' then --Pago a Asegurado
				let _dias_compara = 0; --Se cambia de 25 a 0 solicitado por Leyri Moreno 31-07-2019
			else
				let _dias_compara = 30;
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
			and b.cod_area = _cod_area
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
				and b.cod_area = _cod_area
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
			   
         -- Prioridad por Grupo
		 
		 select cod_grupo,
		        cod_contratante
		   into _cod_grupo,
		        _cod_contratante
		   from emipomae
		  where no_poliza = _no_poliza;
		  
		select nombre 
		  into _contratante
		  from cliclien
		 where cod_cliente = _cod_contratante;
		  
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
			and b.cod_area = _cod_area
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

         select cod_tipopago, 
		        cod_cliente
           into _cod_tipopago,
		        _cod_cliente
           from rectrmae
          where transaccion = _transaccion;		   

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
				and b.cod_area = _cod_area
			    and a.tipo_caso = 4;

			if _prioridad_tmp is null then
				let _prioridad_tmp = 0;
			end if				
				
			 if _prioridad < _prioridad_tmp then
				let _prioridad = _prioridad_tmp;
			 end if			 
		 end if
		 		   
		if _dias_compara_tmp is null then
			let _dias_compara_tmp = 0;
		end if
			
		if _dias_compara_tmp <> 0 and _dias_compara_tmp < _dias_compara then
			let _dias_compara = _dias_compara_tmp;
		end if
		
	-- Prioridades por días transcurridos
	
	    let _dias = sp_par389(_fecha_captura, today);	
	
	--    let _dias = today - _fecha_captura;
		
		if _cod_area = 1 then -- Automóvil		  	
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
			elif _cod_tipopago = '004' then --Pago a Tercero
				if _dias >= _dias_compara then
					let _prioridad = 100;
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
		elif _cod_area = 2 then -- Personas 
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

        select sum(monto)
          into _sum_deducible
          from rectrcon
         where no_tranrec = _no_tranrec
           and cod_concepto = '006';

        if _sum_deducible <> 0.00 then
			let _deducible = 1;
		end if
		
    end foreach

    select nombre
      into _tipo_pago
      from rectipag
     where cod_tipopago = _cod_tipopago;	  
	 
	select trim(nombre)||' - '||trim(cod_agente)
	  into _nombre_corredor
	  from agtagent
	 where cod_agente = _cod_agente;	 
	
	return   _no_requis,   
			 _cuenta,   
			 _cod_cliente,   
			 _cod_agente,   
			 _cod_banco,   
			 _cod_chequera,   
			 _cod_compania,   
			 _cod_sucursal,   
			 _no_cheque,   
			 _fecha_impresion,   
			 _fecha_captura,   
			 _autorizado,   
			 _pagado,   
			 _a_nombre_de,   
			 _cobrado,   
			 _fecha_cobrado,   
			 _anulado,   
			 _fecha_anulado,   
			 _anulado_por,   
			 _monto,   
			 _periodo,   
			 _user_added,   
			 _autorizado_por,   
			 _origen_cheque,   
			 _incidente,   
			 _aut_workflow,   
			 _firma1,   
			 _firma2,   
			 _cod_ruta,   
			 _en_firma,
             _fecha_cont,
			 _dias,
             _prioridad,
             _contratante,
             _nota_excepcion,
			 _user_excepcion,
			 _date_excepcion,
			 _user_pre_aut,
			 _date_pre_aut,
             _tipo_pago,
			 _deducible,
             _numrecla,
             _ajustador,
             _nombre_corredor with resume;  	

		
		
end foreach	


end

end procedure  

 
		