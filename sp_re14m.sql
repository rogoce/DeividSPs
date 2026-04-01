-- Siniestralidad por Grupo - Detalle Ramo - Poliza
-- 
-- Creado    : 30/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_sp_rec14m_dw13 - DEIVID, S.A.

drop procedure sp_rec14m;
create procedure "informix".sp_rec14m(
a_compania char(3),
a_agencia  char(3),
a_periodo1 char(7),
a_periodo2 char(7),
a_sucursal char(255) default '*',
a_ramo     char(255) default '*',
a_grupo    char(255) default '*',
a_agente   char(255) default '*',
a_cliente  char(255) default '*'
, a_poliza char(20)  default '*' 
, a_producto CHAR(255) DEFAULT '*', a_subramo CHAR(255) DEFAULT '*'
)
returning	char(20)		as poliza,				-- poliza
			char(100)		as asegurado,			-- asegurado	
			dec(16,2)		as prima_suscrita, 		-- prima suscrita
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
DEFINE _cod_subramo       CHAR(3); 
DEFINE v_desc_cliente     CHAR(100);
DEFINE v_desc_agente	  CHAR(50);
let v_desc_cliente = '';

set isolation to dirty read;

-- nombre de la compania
let  v_compania_nombre = sp_sis01(a_compania); 

-- procedimiento que carga la siniestralidad

--drop table tmp_siniest;
call sp_rec14(a_compania,a_agencia,a_periodo1,a_periodo2);

-- Procesos para Filtros
let v_filtros = "";

if a_sucursal <> "*" then

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  trim(a_sucursal);
	let _tipo = sp_sis04(a_sucursal);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_grupo <> "*" then

	let v_filtros = trim(v_filtros) || " Grupo: "; --||  TRIM(a_grupo);
	let _tipo = sp_sis04(a_grupo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros

		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in (select codigo from tmp_codigos);
	       let v_saber = "";

	else		        -- (e) excluir estos registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in (select codigo from tmp_codigos);
	       let v_saber = " Ex";
	end if
		select cligrupo.nombre,tmp_codigos.codigo
          into v_desc_grupo,v_codigo
          from cligrupo,tmp_codigos
         where cligrupo.cod_grupo = codigo;
         let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_grupo) || trim(v_saber);
	drop table tmp_codigos;

end if

if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: "; --||  TRIM(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);
	       let v_saber = "";
	else		        -- (e) excluir estos registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	       let v_saber = " Ex";
	end if
		foreach
			select prdramo.nombre,tmp_codigos.codigo
			  into v_desc_ramo,v_codigo
			  from prdramo,tmp_codigos
			 where prdramo.cod_ramo = codigo

			let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_ramo) || trim(v_saber);
		end foreach
	drop table tmp_codigos;

end if

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --|| TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_desc_agente,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF


if a_cliente <> "*" then

	let v_filtros = trim(v_filtros) || " Asegurado: " ||  trim(a_cliente);
	let _tipo = sp_sis04(a_cliente);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_cliente not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update tmp_siniest
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_cliente in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if


IF a_poliza <> "*" THEN
	LET v_filtros = TRIM(v_filtros)|| " Poliza: "|| TRIM(a_poliza);
	UPDATE tmp_siniest
	   SET seleccionado = 0
	 WHERE seleccionado = 1
	   AND doc_poliza NOT IN (a_poliza);       
END IF


IF a_producto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Producto: " ||  TRIM(a_producto);

	LET _tipo = sp_sis04(a_producto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		{SELECT prdprod.nombre,tmp_codigos.codigo
          INTO v_nombre_prod,v_codigo
          FROM prdprod,tmp_codigos
         WHERE prdprod.cod_producto = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_prod) || TRIM(v_saber);}
	DROP TABLE tmp_codigos;

END IF

IF a_subramo <> "*" THEN

    LET v_filtros = TRIM(v_filtros) || " Subramo: " ||  TRIM(a_subramo);

	LET _tipo = sp_sis04(a_subramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo NOT IN (SELECT codigo FROM tmp_codigos);
	       
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_siniest
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo IN (SELECT codigo FROM tmp_codigos);
	       
	END IF

	DROP TABLE tmp_codigos;

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
	 order by cod_cliente, doc_poliza, no_poliza

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
	if v_prima_suscrita = 0 then
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
		   v_prima_suscrita,
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