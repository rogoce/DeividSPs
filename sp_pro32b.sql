--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_pro32b;
create procedure "informix".sp_pro32b(
a_cia			char(3),
a_agencia		char(3),
a_fecha			date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_agente		char(255)	default "*",
a_usuario		char(255)	default "*",
a_cod_cliente	char(255)	default "*",
a_acreedor		char(255)	default "*",
a_no_documento	char(255)	default "*",
a_cod_no_renov  char(255)     default "*")

returning	char(3),		--v_cod_ramo
			char(50),		--v_desc_ramo
			char(20),		--_no_documento
			char(45),		--v_asegurado
			date,			--v_vigencia_inic
			date,			--v_vigencia_final
			char(40),		--v_desc_grupo
			dec(16,2),		--v_suma_asegurada
			dec(16,2),		--v_prima_suscrita
			char(255),		--v_filtros
			char(50),		--v_descr_cia
			dec(16,2),		--v_prima_bruta
			char(3),		--_tipo_prod
			char(50),		--_nom_depen
			varchar(30),	--_cedula_depen
			date,			--_fecha_aniv_depen
			varchar(50),	--_nom_forma_pag
			varchar(50),    --des_subramo
			date,           --v_fecha_nac
			varchar(50),    --v_asegurado_uni
			varchar(30),    --v_cedula_aseg
			date,           --v_fecha_nac_uni
			char(10),		--v_celular
			char(10),		--v_celular2
			varchar(50),	--v_email
			varchar(255),	--v_corredor
			char(10);		--estatus_poliza


define _nom_parentesco		varchar(50);
define _nom_forma_pag		varchar(50);
define _cedula_depen		varchar(30);
define v_filtros			char(255);
define v_desc_agente		char(50);
define v_descr_cia			char(50);
define _des_sub_ramo		char(50);
define v_desc_ramo			char(50);
define v_asegurado			char(45);
define _nom_depen			char(45);
define v_desc_grupo			char(40);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define v_contratante		char(10);
define _temp_poliza			char(10);
define _no_poliza			char(10);
define v_codigo				char(10);
define _cod_acreedor		char(5);
define v_cod_grupo			char(5);
define _no_unidad			char(5);
define _limite				char(5);
define _cod_parentesco		char(3);
define _cod_subramo         char(3);
define v_cod_sucursal		char(3);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define v_cod_ramo			char(3);
define _tipo_prod			char(3);
define v_saber				char(2);
define _tipo				char(1);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_bruta		dec(16,2);
define v_cant_polizas		integer;
define _flag_depen			smallint;
define _cnt_depen			smallint;
define _ramo_sis			smallint;
define _fecha_aniv_depen	date;
define v_vigencia_final		date;
define v_vigencia_inic		date;
define v_fecha_nac          date;
define _cod_asegurado_uni   char(10);
define v_asegurado_uni      varchar(50);
define v_fecha_nac_uni      date;
define _estatus_poliza      smallint;
define _cod_no_renov        char(3);
define v_celular			char(10);
define v_celular2			char(10);
define v_email				varchar(50);
define v_corredor           varchar(255);
define _corredor			varchar(50);
define _cnt_corredor		smallint;
define _cod_agente			char(10);
define v_cedula_aseg		varchar(30);

--set debug file to "sp_pro32b.trc";
--trace on;

let v_cod_sucursal = null;
let v_contratante = null;
let _no_documento = null;
let v_cod_grupo = null;
let v_desc_ramo = null;
let v_descr_cia = null;
let v_cod_ramo = null;
let _tipo = null;
let v_prima_suscrita = 0;
let v_cant_polizas = 0;
let v_prima_bruta = 0;
let _flag_depen = 0;
let _nom_forma_pag = '';
let _des_sub_ramo = '';
let v_fecha_nac = '';
let v_asegurado_uni = '';
let v_fecha_nac_uni = '';

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
call sp_pro03k(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;

if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_codgrupo <> "*" then
	let v_filtros = trim(v_filtros) ||"Grupo "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

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
		 where a.cod_agente = codigo
		 
		let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_agente) || trim(v_saber);
	end foreach
	drop table tmp_codigos;
end if

if a_usuario <> "*" then
	let v_filtros = trim(v_filtros) ||"Corredor: "||trim(a_usuario);
	let _tipo = sp_sis04(a_usuario); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and usuario not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and usuario in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

if a_cod_cliente <> "*" then
	let v_filtros = trim(v_filtros) ||"Cliente: "||trim(a_cod_cliente);
	let _tipo = sp_sis04(a_cod_cliente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante in(select codigo from tmp_codigos);
	end if
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

if a_acreedor <> "*" then

	create temp table tmp_acree
	(cod_acreedor	char(5),
	no_poliza		char(10),
	limite			dec(16,2),
	seleccionado	smallint default 1) with no log;

	foreach
		select no_poliza 
		  into _temp_poliza
		  from temp_perfil
		 where seleccionado = 1
		 
		foreach
			select cod_acreedor,
				   limite
			  into _cod_acreedor,
				   _limite
			  from emipoacr
			 where no_poliza = _temp_poliza

			insert into tmp_acree
			values(	_cod_acreedor,
					_temp_poliza,
					_limite,
					1);
		end foreach
	end foreach

	let v_filtros = trim(v_filtros) ||"Acreedor: "||trim(a_acreedor);
	let _tipo = sp_sis04(a_acreedor); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update tmp_acree
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_acreedor not in(select codigo from tmp_codigos);
	else
		update tmp_acree
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_acreedor in(select codigo from tmp_codigos);
	end if

	update temp_perfil
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_poliza not in(select no_poliza from tmp_acree where seleccionado = 1);

	drop table tmp_codigos;
	drop table tmp_acree;
end if

if a_cod_no_renov <> "*" then

	create temp table tmp_cod_no_renov
	(no_poliza		char(10),
	cod_no_renov    char(3),
	seleccionado	smallint default 1) with no log;

	foreach
		select no_poliza 
		  into _temp_poliza
		  from temp_perfil
		 where seleccionado = 1
		 
		foreach
			select estatus_poliza,
				   cod_no_renov
			  into _estatus_poliza,
				   _cod_no_renov
			  from emipomae
			 where no_poliza = _temp_poliza
			 
			if  _cod_no_renov is null then
				continue foreach;
			end if
            
			if _estatus_poliza = 3 then
				insert into tmp_cod_no_renov
				values(	_temp_poliza,
						_cod_no_renov,
						1);
			end if
		end foreach
	end foreach

	let v_filtros = trim(v_filtros) ||"No Renovacion: "||trim(a_cod_no_renov);
	let _tipo = sp_sis04(a_cod_no_renov); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update tmp_cod_no_renov
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_no_renov not in(select codigo from tmp_codigos);
	else
		update tmp_cod_no_renov
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_no_renov in(select codigo from tmp_codigos);
	end if

	update temp_perfil
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_poliza not in(select no_poliza from tmp_cod_no_renov where seleccionado = 1);

	drop table tmp_codigos;
	drop table tmp_cod_no_renov;
end if

set isolation to dirty read;

foreach with hold
	select y.no_documento,
		   y.cod_ramo,
		   y.cod_contratante,
		   y.vigencia_inic,
		   y.vigencia_final,
		   y.cod_grupo,
		   y.suma_asegurada,
		   y.prima_suscrita,
		   y.prima_bruta,
		   y.cod_tipoprod
	  into _no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_cod_grupo,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   v_prima_bruta,
		   _cod_tipoprod
	  from temp_perfil y
	 where y.seleccionado = 1
	 order by y.cod_ramo,y.no_documento

	select nombre,
		   ramo_sis
	  into v_desc_ramo,
		   _ramo_sis
	  from prdramo
	 where cod_ramo  = v_cod_ramo;

	select nombre,
	       fecha_aniversario
	  into v_asegurado,
		   v_fecha_nac
	  from cliclien
	 where cod_cliente = v_contratante;

	select nombre
	  into v_desc_grupo
	  from cligrupo
	 where cod_grupo = v_cod_grupo;

	let _tipo_prod = '';
	if _cod_tipoprod = '001' then
		let _tipo_prod = 'MAY';
	elif _cod_tipoprod = '002' then
		let _tipo_prod = 'MIN';
	end if
	
	call sp_sis21(_no_documento) returning _no_poliza;
	
	let _cod_no_renov = null;
	let v_email = null;
	let v_celular = null;
	let v_celular2 = null;
	
	select cod_subramo,
	       estatus_poliza
	  into _cod_subramo,
	       _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;
	 
--	if _estatus_poliza in (2,4) then
--		continue foreach;
--    end if	
		 		 
	select nombre
	  into _des_sub_ramo
	  from prdsubra 
	 where cod_ramo = v_cod_ramo
	   and cod_subramo = _cod_subramo;
	
	let _cnt_corredor = 0;
	   
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		select nombre
		  into _corredor
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		let _cnt_corredor = _cnt_corredor + 1;  
		
		if _cnt_corredor = 1 then
			let v_corredor = trim(_corredor);
		else
			let v_corredor = trim(v_corredor) ||"/"|| trim(_corredor);
		end if
    end foreach	
		 
	if _ramo_sis = 5 then
		let _flag_depen = 0;

		select cod_formapag
		  into _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nom_forma_pag
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		foreach
			select no_unidad,
				   cod_asegurado
			  into _no_unidad,
				   _cod_asegurado_uni
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1
			 
			select nombre,
				   fecha_aniversario,
				   celular,
				   fax,
				   e_mail,
				   cedula
	          into v_asegurado_uni,
		           v_fecha_nac_uni,
				   v_celular,
				   v_celular2,
				   v_email,
				   v_cedula_aseg
	          from cliclien
	         where cod_cliente = _cod_asegurado_uni;

			let _cnt_depen = 0;

			select count(*)
			  into _cnt_depen
			  from emidepen
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and activo = 1;

			if _cnt_depen is null then
				let _cnt_depen = 0;
			end if

			let _nom_parentesco = '';
			let _nom_depen = '';

			If _cnt_depen > 0 Then
				foreach
					select cod_cliente,
						   cod_parentesco
					  into _cod_dependiente,
						   _cod_parentesco
					  from emidepen
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					   and activo = 1
					
					{select nombre
					  into _nom_parentesco
					  from emiparen
					 where cod_parentesco = _cod_parentesco;}

					select nombre,
						   cedula,
						   fecha_aniversario
					  into _nom_depen,
						   _cedula_depen,
						   _fecha_aniv_depen
					  from cliclien
					 where cod_cliente = _cod_dependiente;
					 
					let _flag_depen = 1;
					
					return	v_cod_ramo,
							v_desc_ramo,
							_no_documento,
							v_asegurado,
							v_vigencia_inic,
							v_vigencia_final,
							v_desc_grupo,
							v_suma_asegurada,
							v_prima_suscrita,
							v_filtros,
							v_descr_cia,
							v_prima_bruta,
							_tipo_prod,
							_nom_depen,
							_cedula_depen,
							_fecha_aniv_depen,
							_nom_forma_pag,
							_des_sub_ramo,
							v_fecha_nac,
							v_asegurado_uni,
							v_cedula_aseg,
							v_fecha_nac_uni,
							v_celular,
							v_celular2, 
							v_email,
							v_corredor,
							(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end)  with resume;
				end foreach
			Else
			--if _flag_depen = 0 then
			return	v_cod_ramo,
					v_desc_ramo,
					_no_documento,
					v_asegurado,
					v_vigencia_inic,
					v_vigencia_final,
					v_desc_grupo,
					v_suma_asegurada,
					v_prima_suscrita,
					v_filtros,
					v_descr_cia,
					v_prima_bruta,
					_tipo_prod,
					'',
					'',
					'01/01/1900',
					_nom_forma_pag,
                    _des_sub_ramo,
					v_fecha_nac,
					v_asegurado_uni,
					v_cedula_aseg,
					v_fecha_nac_uni,
					v_celular,
					v_celular2, 
					v_email,
					v_corredor,
					(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end) with resume;
			end if
			
		end foreach
		
		{if _flag_depen = 0 then
			return	v_cod_ramo,
					v_desc_ramo,
					_no_documento,
					v_asegurado,
					v_vigencia_inic,
					v_vigencia_final,
					v_desc_grupo,
					v_suma_asegurada,
					v_prima_suscrita,
					v_filtros,
					v_descr_cia,
					v_prima_bruta,
					_tipo_prod,
					'',
					'',
					'01/01/1900',
					_nom_forma_pag,
                    _des_sub_ramo,
					v_fecha_nac,
					v_asegurado_uni,
					v_fecha_nac_uni with resume;
		end if}
	else
		return	v_cod_ramo,
				v_desc_ramo,
				_no_documento,
				v_asegurado,
				v_vigencia_inic,
				v_vigencia_final,
				v_desc_grupo,
				v_suma_asegurada,
				v_prima_suscrita,
				v_filtros,
				v_descr_cia,
				v_prima_bruta,
				_tipo_prod,
				'',
				'',
				'01/01/1900',
				_nom_forma_pag,
				_des_sub_ramo,
				v_fecha_nac,						
				v_asegurado_uni,
				v_cedula_aseg,
			    v_fecha_nac_uni,
				v_celular,
				v_celular2, 
				v_email,
				v_corredor,
				(case when _estatus_poliza = 1 then "VIGENTE" else (case when _estatus_poliza = 2 then "CANCELADA" else (case when _estatus_poliza = 3 then "VENCIDA" else "ANULADA" end) end)end) with resume;
	end if
end foreach
drop table temp_perfil;
end procedure;