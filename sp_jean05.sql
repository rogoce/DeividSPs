-- Data de corredores
--

   DROP procedure sp_jean05;
   CREATE procedure sp_jean05()
   RETURNING char(5),CHAR(50),varchar(22),CHAR(10),char(10),char(10);
   
    DEFINE _cod_agente,_cod_agente_a      CHAR(5);
	define _cod_contratante char(10);
    DEFINE _n_agente_a,_n_agente   	CHAR(50);
	define _vi,_vf,_fecha_emision		    date;
	define _licencia,_licencia_a	CHAR(15);
	define _estatus_lic             VARCHAR(22);
	define _pp_lic_vida,_pp_lic_general,_pp_lic_fianza             CHAR(10);
	define _saber smallint;
	       
	
{foreach
	select cod_agente,
	       nombre,
		   no_licencia,
		   agente_agrupado
	  into _cod_agente,
	       _n_agente,
		   _licencia,
		   _cod_agente_a
	  from agtagent
	 where cod_agente <> agente_agrupado
	
	select nombre,
	       no_licencia
	  into _n_agente_a,
		   _licencia_a
	  from agtagent
	 where cod_agente = _cod_agente_a;

	return _cod_agente,_n_agente,_licencia,_cod_agente_a,_n_agente_a,_licencia_a with resume;

end foreach}

let _pp_lic_vida    = "";
let _pp_lic_general = "";
let _pp_lic_fianza  = "";

foreach
	select cod_agente,
	       nombre,
		   trim(pp_lic_vida),
		   trim(pp_lic_general),
		   trim(pp_lic_fianza),
		   decode(estatus_licencia,'A','Activa','P','Suspension Permanente','T','Suspension Temporal','X','Susp. Superintendencia')
	  into _cod_agente,
	       _n_agente,
		   _pp_lic_vida,		  
		   _pp_lic_general,
		   _pp_lic_fianza,
		   _estatus_lic
	  from agtagent
	 
	if _pp_lic_vida is null and _pp_lic_general is null and _pp_lic_fianza is null then
		continue foreach;
	end if
    if trim(_pp_lic_vida) = "" and trim(_pp_lic_general) = "" and trim(_pp_lic_fianza) = "" then
		continue foreach;
	end if

	return _cod_agente,_n_agente,_estatus_lic,_pp_lic_vida,_pp_lic_fianza,_pp_lic_general with resume;

end foreach
END PROCEDURE;
