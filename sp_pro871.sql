--POLIZAS VIGENTES COLECTIVO DE VIDA
--Creado : 30/07/2025 Autor: Armando Moreno M.
--execute procedure sp_pro32f('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_pro871;
create procedure sp_pro871(a_cia char(3), a_agencia	char(3), a_fecha date, a_codramo char(255) default "*",
                           a_agente	char(255) default "*", a_no_documento char(255) default "*", a_codvend char(255)	default "*")

returning	char(3)  as v_cod_ramo,
			char(50) as v_desc_ramo,
			char(20) as no_documento,
			char(10) as cod_asegurado,
			char(50) as v_asegurado,
            char(2)  as tiene_dep,
			char(5)  as no_unidad,
			char(5)  as cod_corredor,
			char(50)  as _n_corredor,
			char(255) as v_filtros;

define v_filtros		char(255);
define v_desc_agente	char(50);
define v_descr_cia,v_desc_vendedor		char(50);
define v_desc_ramo,_n_corredor		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define _temp_poliza		char(10);
define _cod_asegurado	char(10);
define v_codigo			char(10);
define _no_unidad    	char(5);
define _cod_agente		char(5);
define _limite			char(5);
define v_cod_sucursal	char(3);
define _cod_tipoprod	char(3);
define v_cod_ramo		char(3);
define _tipo_prod		char(3);
define v_saber			char(2);
define _tipo			char(1);
define _cod_contratante char(10);
define v_prima_suscrita	dec(16,2);
define v_suma_asegurada	dec(16,2);
define v_prima_bruta	dec(16,2);
define v_cant_polizas	integer;
define v_vigencia_final	date;
define v_vigencia_inic	date;
define _cod_coasegur    char(3);
define _tiene_dep       char(2);
define _porc_coas       dec(7,4);
define _cnt             integer;
DEFINE _suc_prom        	    CHAR(3);
DEFINE _cod_vendedor		    CHAR(3);
DEFINE _nombre_vendedor	    	CHAR(50);

let _no_documento     = null;
let v_desc_ramo      = null;
let v_saber = '';

set isolation to dirty read;

--let _cod_coasegur = sp_sis02(a_cia,a_agencia);

---call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;
call sp_pro03ii(a_cia,a_agencia,a_fecha,a_codramo,a_codvend) returning v_filtros;  -- Filtro de Zona DALBA  

if a_agente <> "*" then
	let v_filtros = trim(v_filtros) ||"Corredor: "; --||trim(a_agente);
	let _tipo = sp_sis04(a_agente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	
		let v_saber = "";
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);

		let v_saber = " Ex";
	end if

	foreach
		select a.nombre,
			   t.codigo
		  into v_desc_agente,
			   v_codigo
		  from agtagent a,tmp_codigos t
		 where a.cod_agente = t.codigo
		 
		let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_agente) || trim(v_saber);
	end foreach
	drop table tmp_codigos;
end if

--filtro de poliza
if a_no_documento <> "*" and a_no_documento <> "" then
	let v_filtros = trim(v_filtros) ||"Documento: "||trim(a_no_documento);

	update temp_perfil
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_documento <> a_no_documento;
end if

IF a_codvend <> "*" THEN   -- Aplica Filtro de Zona 
	LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
	LET v_filtros = TRIM(v_filtros) ||" Zona :"; --||TRIM(a_codvend);

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
		   LET v_saber = "";
	ELSE
		UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
		   LET v_saber = " Ex";
	END IF
	
	FOREACH
		SELECT distinct temp_perfil.nombre_vendedor,tmp_codigos.codigo
		  INTO _nombre_vendedor,v_codigo
		  FROM temp_perfil,tmp_codigos
		 WHERE temp_perfil.cod_vendedor = codigo
		 
		 LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(_nombre_vendedor) || (v_saber);
	END FOREACH		

	DROP TABLE tmp_codigos;
END IF	

set isolation to dirty read;

select nombre
  into v_desc_ramo
  from prdramo
 where cod_ramo  = '016';
 
foreach
	select no_documento,
		   cod_ramo,
		   no_poliza,
		   cod_agente
	  into _no_documento,
		   v_cod_ramo,
		   _temp_poliza,
		   _cod_agente
	  from temp_perfil
	 where seleccionado = 1
	 order by no_documento
	 
	select nombre
	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente; 
	 
		foreach
			select no_unidad,
			       cod_asegurado
			  into _no_unidad,
			       _cod_asegurado
			  from emipouni
			 where no_poliza = _temp_poliza
			   and activo = 1
				  
			select count(*)
			  into _cnt
			  from emibenef
			 where no_poliza   = _temp_poliza
               and no_unidad   = _no_unidad;
			   
			if _cnt is null then
				let _cnt = 0;
			end if
			
			if _cnt > 0 then
				let _tiene_dep = "SI";
			else
				let _tiene_dep = "NO";
			end if
			
			select nombre
			  into v_asegurado
			  from cliclien
			 where cod_cliente = _cod_asegurado;

			return v_cod_ramo,v_desc_ramo,_no_documento,_cod_asegurado,v_asegurado,_tiene_dep,_no_unidad,_cod_agente,
                   _n_corredor,v_filtros with resume;

		end foreach
end foreach

--drop table temp_perfil;
end procedure;