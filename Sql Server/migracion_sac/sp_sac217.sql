-- Reporte de Primas Pendientes por Aplicar Historico a un periodo dado, empezo en abril del 2012
-- 
-- Creado    : 25/04/2012 - Autor: Armando Moreno
-- Modificado: 25/04/2012 - Autor: Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob16_dw1 - DEIVID, S.A.

--drop procedure sp_sac217;

create procedure "informix".sp_sac217(a_periodo  char(7)
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
			char(30);

define v_doc_suspenso    char(30); 
define v_fecha           date;     
define v_monto           dec(16,2);
define v_poliza          char(50); 
define v_asegurado       char(50); 
define v_coaseguro       char(50); 
define v_ramo            char(50); 
define v_compania_nombre char(50);
define _corredor		 char(50);
define _user_added		 char(8);
define _cedula			 char(30);
define _no_recibo_otro 	char(10);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01('001'); 

-- Seleccion de las Primas en Suspenso
let _corredor   = "";
let _user_added	= "";
let _cedula		= "";

FOREACH 
	 SELECT fecha,
			doc_suspenso,
			monto,
			poliza,
			asegurado,
			coaseguro,
			ramo,
			corredor,
			user_added,
			cedula
	   INTO	v_fecha,			
			v_doc_suspenso,	
			v_monto,			
			v_poliza,		
			v_asegurado, 	
			v_coaseguro, 	
			v_ramo,
			_corredor,
			_user_added,
			_cedula
	   FROM cobsuspeh
	  WHERE periodo = a_periodo
	  ORDER BY fecha

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

		RETURN	v_fecha,			
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
				_cedula
				WITH RESUME;	 		

END FOREACH

END PROCEDURE;

