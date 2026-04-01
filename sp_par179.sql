-- Procedure que verifica que todas las polizas esten en la tabla emipoliza
-- Modificado    : 06/10/2010- Autor: Roman Gordon

drop procedure sp_par179;

create procedure sp_par179()
returning integer;

define _motivo_rechazo		varchar(50);
define _no_documento  		char(20);
define _no_tarjeta			char(19);
define v_cod_pagador		char(10);
define _no_poliza			char(10);
define _fecha_exp			char(7);
define v_cod_agente			char(5);
define v_cod_area			char(5);
define v_cod_grupo			char(5);
define v_cod_acreencia		char(3);
define v_cod_formapag		char(3);
define v_cod_pagos			char(3);
define v_cod_zona			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define v_cod_suc			char(3);
define v_cod_status			char(1);
define v_prima_bruta		dec(16,2);
define v_carta_aviso_canc	smallint;
define _cont_agente			smallint;
define v_dia_cob1			smallint;
define v_dia_cob2			smallint;
define _cont_acre			smallint;
define _cantidad			integer;
define v_vigencia_ini		date;
define v_vigencia_fin		date;

set isolation to dirty read;

--set debug file to "sp_par179.trc";
--trace on;

foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado  = 1
	   and no_documento is not null
	 group by no_documento
  
	{select distinct e.no_documento
	  into _no_documento
	  from cobgesti g, emipoliza e
	 where g.no_documento = e.no_documento
	   and g.cod_gestion in (select cod_gestion from cobcages where tipo_accion = 12)
	   and e.cod_status not in (2,4)
	   and e.saldo = e.exigible
	   and e.exigible > 0
	 order by e.no_documento}

	select count(*)
	  into _cantidad
	  from emipoliza
	 where no_documento = _no_documento;

	select cod_ramo
	  into _cod_ramo
	  from emipoliza
	 where no_documento = _no_documento;

	let _no_poliza = sp_sis21(_no_documento);  
	if _cantidad = 0 then
		
		let v_cod_agente 	= '';
		let v_cod_zona	 	= '';
		let v_cod_acreencia = '';
		let _motivo_rechazo = '';

		if _no_poliza is null then
			insert into emipoliza
			(no_documento)
			values
			(_no_documento);	
		else
			select cod_ramo,
				   cod_formapag,
				   cod_grupo,
				   cod_pagador,
				   cod_sucursal,
				   dia_cobros1,
				   dia_cobros2,
				   estatus_poliza,
				   vigencia_final,
				   vigencia_inic,
				   prima_bruta,
				   carta_aviso_canc,
				   no_tarjeta		   
			  into v_cod_ramo,
				   v_cod_formapag,
				   v_cod_grupo,
				   v_cod_pagador,
				   v_cod_suc,
				   v_dia_cob1,
				   v_dia_cob2,
				   v_cod_status,
				   v_vigencia_fin,
				   v_vigencia_ini,
				   v_prima_bruta,
				   v_carta_aviso_canc,
				   _no_tarjeta
			  from emipomae
			 where no_poliza = _no_poliza;
		  		
			select fecha_exp
			  into _fecha_exp
			  from cobtahab
			 where no_tarjeta = _no_tarjeta;

			select code_correg
			  into v_cod_area
			  from cliclien
			 where cod_cliente = v_cod_pagador;

			select count(*)
		      into _cont_acre
			  from emipoacr
			 where no_poliza = _no_poliza;
			
			if _cont_acre = 0 then
				let v_cod_acreencia = '002';
			else 
				let v_cod_acreencia = '001';
			end if

			select count(*)
			  into _cont_agente
			  from emipoagt
			 where no_poliza = _no_poliza;
			
			if _cont_agente = 0 then
				let v_cod_agente = '';
				let v_cod_zona	 = '';
			elif _cont_agente = 1 then
			 	select cod_agente
				  into v_cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza;

				select cod_cobrador
				  into v_cod_zona
				  from agtagent
				 where cod_agente = v_cod_agente;
			else
				let v_cod_agente = '00000';
				let v_cod_zona   = '000';	
			end if

		   
				insert into emipoliza(
					no_documento,
					cod_ramo,
					cod_formapag,
					cod_zona,
					cod_grupo,
					cod_pagador,
					cod_sucursal,
					dia_cobros1,
					dia_cobros2,
					cod_status,
					vigencia_inic,
					vigencia_fin,
					cod_area,
					cod_agente,
					cod_acreencia,
					prima_bruta,
					carta_aviso_canc,
					fecha_exp,
					motivo_rechazo)
				values(
					_no_documento,
					v_cod_ramo,
					v_cod_formapag,
					v_cod_zona,
					v_cod_grupo,
					v_cod_pagador,
					v_cod_suc,
					v_dia_cob1,
					v_dia_cob2,
					v_cod_status,
					v_vigencia_ini,
					v_vigencia_fin,
					v_cod_area,
					v_cod_agente,
					v_cod_acreencia,
					v_prima_bruta,
					v_carta_aviso_canc,
					_fecha_exp,
					_motivo_rechazo);			   		
		end if
	else
		if _cod_ramo is null then
			select cod_ramo,
				   cod_formapag,
				   cod_grupo,
				   cod_pagador,
				   cod_sucursal,
				   dia_cobros1,
				   dia_cobros2,
				   estatus_poliza,
				   vigencia_final,
				   vigencia_inic,
				   prima_bruta,
				   carta_aviso_canc,
				   no_tarjeta		   
			  into v_cod_ramo,
				   v_cod_formapag,
				   v_cod_grupo,
				   v_cod_pagador,
				   v_cod_suc,
				   v_dia_cob1,
				   v_dia_cob2,
				   v_cod_status,
				   v_vigencia_fin,
				   v_vigencia_ini,
				   v_prima_bruta,
				   v_carta_aviso_canc,
				   _no_tarjeta
			  from emipomae
			 where no_poliza = _no_poliza;

			let _motivo_rechazo = '';

			select fecha_exp
			  into _fecha_exp
			  from cobtahab
			 where no_tarjeta = _no_tarjeta;

			select motivo_rechazo
			  into _motivo_rechazo
			  from cobtatra
			 where no_documento = _no_documento;

			select code_correg
			  into v_cod_area
			  from cliclien
			 where cod_cliente = v_cod_pagador;

			select count(*)
		      into _cont_acre
			  from emipoacr
			 where no_poliza = _no_poliza;
			
			if _cont_acre = 0 then
				let v_cod_acreencia = '002';
			else 
				let v_cod_acreencia = '001';
			end if

			select count(*)
			  into _cont_agente
			  from emipoagt
			 where no_poliza = _no_poliza;
			
			if _cont_agente = 0 then
				let v_cod_agente = '';
				let v_cod_zona	 = '';
			elif _cont_agente = 1 then
			 	select cod_agente
				  into v_cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza;

				select cod_cobrador
				  into v_cod_zona
				  from agtagent
				 where cod_agente = v_cod_agente;
			else
				let v_cod_agente = '00000';
				let v_cod_zona   = '000';	
			end if

			update emipoliza 
			   set cod_ramo		 	= v_cod_ramo,
			   	   cod_formapag  	= v_cod_formapag,
			 	   cod_zona	  	 	= v_cod_zona,
			 	   cod_grupo	 	= v_cod_grupo,
			 	   cod_pagador	 	= v_cod_pagador,
			 	   cod_sucursal  	= v_cod_suc,
			 	   dia_cobros1	 	= v_dia_cob1,
			 	   dia_cobros2	 	= v_dia_cob2,
			 	   cod_status	 	= v_cod_status,
			 	   vigencia_inic 	= v_vigencia_ini,
			 	   vigencia_fin  	= v_vigencia_fin,
			 	   cod_area	  	 	= v_cod_area,
			 	   cod_agente	 	= v_cod_agente,
			 	   cod_acreencia 	= v_cod_acreencia,
			 	   prima_bruta	 	= v_prima_bruta,
			 	   carta_aviso_canc = v_carta_aviso_canc,
  			 	   fecha_exp		= _fecha_exp,
			 	   motivo_rechazo	= _motivo_rechazo
			 where no_documento  	= _no_documento;
		end if
	end if
end foreach

let _no_poliza = '';
foreach
 select no_documento
   into _no_documento
   from emipoliza

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then		
		delete from emipoliza
		 where no_documento = _no_documento;		 
	end if
	 
end foreach

update agtagent
   set email_cobros = null
 where email_cobros in('.','..','...');
 
 return 0;

end procedure