-- Reporte de Primas Pendientes por Aplicar
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob16_dw1 - DEIVID, S.A.

drop procedure sp_cob16;

create procedure "informix".sp_cob16(
a_compania char(3), 
a_agencia  char(3), 
a_periodo  char(7)	default '*'
) returning date,		-- fecha
			char(30),	-- documento
			dec(16,2),	-- monto
			char(50),	-- poliza
			char(50),	-- asegurado
			char(50),	-- coaseguro
			char(50),	-- ramo
			char(50),	-- compania
			char(10),
			char(8),
			char(50),
			char(30),
			varchar(100),
			varchar(30);

define v_compania_nombre	char(50);
define v_asegurado			char(50); 
define v_coaseguro			char(50);
define _corredor			char(50);
define v_poliza				char(50); 
define v_ramo				char(50);
define v_doc_suspenso		char(30); 
define _cedula				char(30);
define _no_recibo_otro		char(10);
define _user_added			char(8);
define v_monto				dec(16,2);
define v_fecha				date;
define _poliza_coaseg       varchar(30);
define _observacion         varchar(100);

-- Nombre de la Compania

let  v_compania_nombre = sp_sis01(a_compania); 

-- Seleccion de las Primas en Suspenso
let _corredor   = "";
let _user_added	= "";
let _cedula		= "";

if a_periodo = '*' then
	foreach 
		select fecha,
			   doc_suspenso,
			   monto,
			   poliza,
			   asegurado,
			   coaseguro,
			   ramo,
			   corredor,
			   user_added,
			   cedula,
			   observacion,
			   poliza_coaseg
		  into v_fecha,
		  	   v_doc_suspenso,
		  	   v_monto,
		  	   v_poliza,
		  	   v_asegurado,
		  	   v_coaseguro,
		  	   v_ramo,
		  	   _corredor,
		  	   _user_added,
		  	   _cedula,
			   _observacion,
			   _poliza_coaseg
		  from cobsuspe
		 where cod_compania = a_compania
		   and actualizado = 1
		 order by fecha,doc_suspenso

		let _no_recibo_otro = null;

		foreach	
			select no_recibo
			  into _no_recibo_otro
			  from cobredet
			 where doc_remesa = v_doc_suspenso
			   and tipo_mov   = 'E'
			 order by fecha	desc
			exit foreach;
		end foreach

		return	v_fecha,			
				v_doc_suspenso,	
				v_monto,			
				v_poliza,		
				v_asegurado, 	
				v_coaseguro, 	
				v_ramo,
			    v_compania_nombre,
				_no_recibo_otro,
				_user_added,
				_corredor,
				_cedula,
				_observacion,
				_poliza_coaseg
				with resume;	 		

	end foreach
else
	foreach 
		select fecha,
			   doc_suspenso,
			   monto,
			   poliza,
			   asegurado,
			   coaseguro,
			   ramo,
			   corredor,
			   user_added,
			   cedula,
			   observacion,
			   poliza_coaseg
		  into v_fecha,
		  	   v_doc_suspenso,
		  	   v_monto,
		  	   v_poliza,
		  	   v_asegurado,
		  	   v_coaseguro,
		  	   v_ramo,
		  	   _corredor,
		  	   _user_added,
		  	   _cedula,
			   _observacion,
			   _poliza_coaseg
		  from cobsuspe
		 where cod_compania = a_compania
		   and year(fecha)  = a_periodo[1,4]
		   and month(fecha) = a_periodo[6,7]
		   and	actualizado  = 1
		 order by fecha,doc_suspenso

		let _no_recibo_otro = null;

		foreach	
			select no_recibo
			  into _no_recibo_otro
			  from cobredet
			 where doc_remesa = v_doc_suspenso
			   and tipo_mov   = 'E'
			 order by fecha	desc
			exit foreach;
		end foreach

		return	v_fecha,			
				v_doc_suspenso,	
				v_monto,			
				v_poliza,		
				v_asegurado, 	
				v_coaseguro, 	
				v_ramo,
			    v_compania_nombre,
				_no_recibo_otro,
				_user_added,
				_corredor,
				_cedula,
				_observacion,
				_poliza_coaseg
				with resume;
	end foreach
end if
end procedure;

