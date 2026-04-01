-- Procedure que Cancelacion perdida total
-- Creado    : 31/10/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro584;
create procedure "informix".sp_pro584(a_cia CHAR(3),a_periodo CHAR(7),a_periodo2 CHAR(7))
returning	char(20) as poliza,  
			char(50) as cliente,  
			date as vigencia_inicial,
			date as vigencia_final,
			char(100) as agente, 
			char(50) as forma_pago,  
			char(18) as reclamo,
			date as fecha_siniestro,
			char(10) as remesa,
			date as fecha_remesa,
			char(10) as recibo,
			dec(16,2) as monto_recibo,
			char(50) as descr_cia,
			date as fecha_emision;					


define _fecha_remesa		date;
define _vig_ini		        date;
define _vig_fin		        date;
define _fecha_emision       date;
define _monto           	dec(16,2);
define _monto_recibo      	dec(16,2);
define _numrecla			char(18);
define _fecha_siniestro		date;
define _nombre_cli			char(50);
define _forma_pag			char(50);
define _nombre_agente		char(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_recibo			char(10);
define _cod_agente  		char(5);
define _cod_formapag		char(3);
define v_descr_cia			char(50);

--set debug file to "sp_pro584.trc";
--trace on;
set isolation to dirty read;
let _monto = 0;

LET v_descr_cia = sp_sis01(a_cia);
foreach
	select distinct no_documento, fecha_emision   -- cod_tipocalc in ('005','006') 
	  into _no_documento, _fecha_emision
	  from endedmae
	 where periodo >= a_periodo
	   and periodo <= a_periodo2	 
   and cod_endomov = '002'   -- CANCELACION
   and cod_tipocan = '008'   -- PERIDDA TOTAL

	let _no_poliza = sp_sis21(_no_documento);		
	let _monto = 0.00;
	
	select sum(monto) --m.no_remesa, d.no_recibo,  m.fecha  
	  into _monto
	  from cobremae m, cobredet d
	 where m.no_remesa = d.no_remesa
	   and d.doc_remesa = _no_documento
	   and d.tipo_mov in ('P','N','X')
	   and m.fecha  >= _fecha_emision
	   and m.actualizado = 1;
	   
	   if _monto > 0 then   
	
			select vigencia_inic,
				   vigencia_final,	
				   cod_formapag,
				   cod_contratante
			 into _vig_ini,
				  _vig_fin,
				  _cod_formapag,
				  _cod_cliente
			 from emipomae
			where no_poliza = _no_poliza;
			
		   --Asegurado
		   select nombre
			 into _nombre_cli
			 from cliclien
			where cod_cliente = _cod_cliente;			
			
		   --Sacar el corredor
		   foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			  exit foreach;
			   end foreach

			select nombre
			  into _nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			select nombre
			  into _forma_pag
			  from cobforpa
			 where cod_formapag = _cod_formapag;			 			 
			 
		   --Sacar el siniestro
		  -- foreach
			select numrecla,fecha_siniestro
			  into _numrecla, _fecha_siniestro
			  from recrcmae
			 where no_documento = _no_documento
		       and perd_total = 1;			 
            --  exit foreach;
			---   end foreach			  
			   
			   let _monto_recibo = 0.00;
			 
		foreach	 
		select m.no_remesa, d.no_recibo,  m.fecha  , d.monto
		  into _no_remesa, _no_recibo, _fecha_remesa, _monto_recibo
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.doc_remesa = _no_documento
		   and d.tipo_mov in ('P','N','X')
		   and m.fecha  >= _fecha_emision
		   and m.actualizado = 1			 

			return _no_documento,
				   _nombre_cli,	
				   _vig_ini,      
				   _vig_fin,
				   _nombre_agente,
				   _forma_pag,		
				   _numrecla, 
				   _fecha_siniestro,				   
				   _no_remesa,		
				   _fecha_remesa,
				   _no_recibo,
				   _monto_recibo,
				   v_descr_cia,
				   _fecha_emision
				   with resume;	
				   
		end foreach				   
				   
	end if
end foreach
end procedure;