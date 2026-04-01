-- Siniestralidad por Grupo - Detalle Ramo - Poliza
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14m_dw13 - DEIVID, S.A.

drop procedure sp_rec279a;
create procedure "informix".sp_rec279a(
a_poliza char(20))
returning	char(20)		as poliza,				-- poliza
			char(100)		as asegurado,			-- asegurado	
			dec(16,2)		as prima_devengada, 	-- prima devengada
			dec(16,2)		as incurrido_bruto,		-- incurrido bruto
			dec(16,2)		as porc_siniestralidad,	-- % siniestralidad 
			dec(16,2)		as prima_pagada,	 	-- prima pagada
			dec(16,2)		as siniestros_pagados, 	-- sinestros pagados
			dec(16,2)		as porc_pag_cob,	 	-- % pagado/cobrado
			varchar(50)		as ramo,			   	-- ramo
			varchar(50)		as grupo,			   	-- grupo
			varchar(50)		as compania,		    -- compania
			date			as vigencia_inic,		-- vigencia inicial
			date			as vigencia_final,		-- vigencia final
			varchar(255)	as filtros;			    -- filtros

define v_filtros			varchar(255);
define v_asegurado			varchar(100);     
define v_compania_nombre	varchar(50);     
define v_grupo_nombre		varchar(50);     
define v_ramo_nombre		varchar(50);     
define v_desc_grupo			varchar(50);     
define v_desc_ramo			varchar(50);     
define v_doc_poliza			char(20);
define _cod_cliente			char(10);	
define _no_poliza			char(10);
define v_codigo				char(10);
define _cod_grupo			char(5);      
define _cod_ramo			char(3);      
define v_saber				char(2);
define _tipo				char(1);
define v_prima_suscrita		dec(16,2);
define v_incurrido_bruto	dec(16,2);
define v_porc_siniest		dec(16,2);
define v_siniestro_pagado	dec(16,2);
define v_prima_pagada		dec(16,2);
define v_porc_pagado		dec(16,2);
define v_vigencia_inic		date;
define v_vigencia_final		date;
DEFINE _cod_subramo         CHAR(3); 
DEFINE v_desc_cliente       CHAR(100);
DEFINE v_desc_agente	    CHAR(50);
define _prima_devengada     dec(16,2);
define _fecha_proceso       date;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

let v_desc_cliente = '';

set isolation to dirty read;

-- nombre de la compania
let  v_compania_nombre = sp_sis01('001'); 

-- procedimiento que carga la siniestralidad

--drop table tmp_siniest;
call sp_rec279(a_poliza);

-- Procesos para Filtros
let v_filtros = "";

IF a_poliza <> "*" THEN
	LET v_filtros = TRIM(v_filtros)|| " Poliza: "|| TRIM(a_poliza);
	UPDATE tmp_siniest
	   SET seleccionado = 0
	 WHERE seleccionado = 1
	   AND doc_poliza NOT IN (a_poliza);       
END IF


-- seleccion de registros

foreach
	select no_poliza,
		   doc_poliza,
		   cod_ramo,
		   cod_grupo,
		   prima_suscrita,
		   incurrido_bruto,
		   siniestro_pagado,
		   prima_pagada,
		   cod_cliente
	  into _no_poliza,
		   v_doc_poliza,
		   _cod_ramo,
		   _cod_grupo,
		   v_prima_suscrita,
		   v_incurrido_bruto,
		   v_siniestro_pagado,
		   v_prima_pagada,
		   _cod_cliente
	  from tmp_siniest
	 where seleccionado = 1
	 order by cod_cliente, doc_poliza

	select vigencia_inic,
		   vigencia_final	
	  into v_vigencia_inic,
		   v_vigencia_final	
	  from emipomae 
	 where no_poliza = _no_poliza;
	
	select nombre
	  into v_asegurado
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into v_grupo_nombre
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	-- porcentaje de siniestralidad
{	if v_prima_suscrita = 0 then
		if v_incurrido_bruto = 0 then
			let v_porc_siniest = 0;
		else
			let v_porc_siniest = 100;
		end if
	else
	    if v_incurrido_bruto < 0 then
			let v_porc_siniest = 0;
		else
	   		let	v_porc_siniest = (v_incurrido_bruto / v_prima_suscrita)*100;
		end if
	end if
}
	-- Calculo de la Prima Devengada
	select date(fecha_proceso)
      into _fecha_proceso
	  from emicartasal2
	 where no_documento = a_poliza;
	 
	let v_filtros = trim(v_filtros) || " Fecha del Proceso:" || _fecha_proceso;
	 
	call sp_dev03(a_poliza, _fecha_proceso) returning _error, _error_desc;

	select sum(prima_devengada)
	  into _prima_devengada
	  from tmp_prima_devengada;
	  
	drop table tmp_prima_devengada;

	-- porcentaje de siniestralidad
	if _prima_devengada = 0 then
		if v_incurrido_bruto = 0 then
			let v_porc_siniest = 0;
		else
			let v_porc_siniest = 100;
		end if
	else
	    if v_incurrido_bruto < 0 then
			let v_porc_siniest = 0;
		else
	   		let	v_porc_siniest = (v_incurrido_bruto / _prima_devengada)*100;
		end if
	end if
	
	-- porcentaje de pagado
	if v_prima_pagada = 0 then
		if v_siniestro_pagado = 0 then
			let v_porc_pagado = 0;
		else
			let v_porc_pagado = 100;
		end if
	else
	    if v_siniestro_pagado < 0 then
			let v_porc_pagado = 0;
		else
		 	let	v_porc_pagado = (v_siniestro_pagado / v_prima_pagada)*100;
		end if
	end if

	return v_doc_poliza,
		   v_asegurado,
		   _prima_devengada,
		   v_incurrido_bruto,
		   v_porc_siniest,
		   v_prima_pagada,
		   v_siniestro_pagado,
		   v_porc_pagado,
		   v_ramo_nombre,
		   v_grupo_nombre,
	       v_compania_nombre,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_filtros
		   with resume;
end foreach

drop table tmp_siniest;
end procedure;