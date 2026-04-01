drop procedure sp_pro51_a;
create procedure "informix".sp_pro51_a(
a_compania  	char(3), 
a_agencia   	char(3), 
a_periodo1  	char(7),
a_periodo2  	char(7),
a_sucursal  	char(255) default "*",
a_ramo      	char(255) default "*",
a_grupo     	char(255) default "*",
a_usuario   	char(255) default "*",
a_reaseguro 	char(255) default "*",
a_agente    	char(255) default "*",
a_saldo_cero    smallint,
a_cod_cliente   char(255) default "*",
a_no_documento  char(255) default "*",
a_opcion_renovar smallint default 0,
a_codtipoprod   char(255) default "*",
a_cod_vendedor  char(255) default "*",
a_cod_no_renov  char(255) default "*" )
returning	varchar(255);

define v_filtros		varchar(255);
define v_desc_agente	varchar(50);
define _no_documento	char(20);
define _cod_contratante	char(10);
define _no_poliza		char(10);
define _user_added		char(8);
define _periodo			char(7);
define _cod_agente		char(5);
define _cod_grupo		char(5);
define v_codigo			char(5);
define _sucursal_origen	char(3);
define _tipo_produccion	char(1);
define _cod_tipoprod	char(3);
define _cod_vendedor	char(3);
define _suc_prom		char(3);
define _cod_ramo		char(3);
define v_saber			char(3);
define _estatus			char(1);
define _tipo			char(1);
define _por_vencer_tot	dec(16,2);
define _prima_porc		dec(16,2);
define _porc_saldos		dec(16,2);
define _prima			dec(16,2);
define _saldo			dec(16,2);
define _mes1			smallint;
define _mes2			smallint;
define _ano1			smallint;
define _ano2			smallint;
define _vigencia_final	date;
define _fecha1			date;
define _fecha2			date;
DEFINE _cod_no_renov	CHAR(3);

let _porc_saldos = 10;
let _cod_no_renov = '';
-- descomponer los periodos en fechas
let _ano1 = a_periodo1[1,4];
let _mes1 = a_periodo1[6,7];

let _ano2 = a_periodo2[1,4];
let _mes2 = a_periodo2[6,7];

let _fecha1 = mdy(_mes1,1,_ano1);

if _mes2 = 12 then
   let _mes2 = 1;
   let _ano2 = _ano2 + 1;
else
   let _mes2 = _mes2 + 1;
end if
let _fecha2 = mdy(_mes2,1,_ano2);
let _fecha2 = _fecha2 - 1;

-- Tabla Temporal tmp_prod
create temp table tmp_prod(
sucursal_origen	char(3)   not null,
cod_grupo		char(5)   not null,
cod_agente		char(5)   not null,
user_added		char(8)   not null,
cod_ramo		char(3)   not null,
no_documento	char(20)  ,
cod_contratante	char(10)  not null,
vigencia_final	date   	  not null,
prima			dec(16,2),
saldo			dec(16,2),
tipo_produccion	char(3),
estatus			char(1),
cod_vendedor	char(3),	
seleccionado	smallint  default 1 not null,
cod_no_renov	CHAR(3) default '') with no log;
--no_poliza       CHAR(10)  NOT NULL

create index iend1_tmp_prod on tmp_prod(cod_ramo);
create index iend2_tmp_prod on tmp_prod(cod_grupo);
create index iend3_tmp_prod on tmp_prod(sucursal_origen);
create index iend4_tmp_prod on tmp_prod(tipo_produccion);
create index iend5_tmp_prod on tmp_prod(cod_agente);
create index iend6_tmp_prod on tmp_prod(user_added);

let _cod_agente = "*";
set isolation to dirty read;

--set debug file to "sp_pro51.trc";
--trace on;

if a_opcion_renovar	= 2 then --todas las polizas
	-- informacion de poliza
	foreach with hold
		select no_poliza,
			   sucursal_origen, 
			   cod_grupo, 
			   cod_tipoprod, 
			   cod_ramo, 
			   user_added,
			   no_documento, 
			   cod_contratante, 
			   vigencia_final, 
			   prima_bruta,
			   cod_no_renov
		  into _no_poliza, 
		  	   _sucursal_origen, 
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _prima,
			   _cod_no_renov
		  from emipomae
		 where vigencia_final >= _fecha1 
		   and vigencia_final <= _fecha2
		   and actualizado = 1
		   and no_renovar  = 0
	       and incobrable  = 0
		   and abierta     = 0
		   and estatus_poliza in (1,3)

	    {select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;}

		foreach with hold
		    select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 exit foreach;
		end foreach

		--Buscar el saldo de la poliza
		call sp_cob85(a_compania,a_agencia,_no_documento) returning _saldo;

		let _prima_porc = _prima * _porc_saldos / 100;
	   	
		if _saldo > 0 then
			if _saldo > _prima_porc then
				let _estatus = "0";		
			else
				let _estatus = "1";
			end if
		else
			let _estatus = "1";
		end if

		select sucursal_promotoria
		  into _suc_prom
		  from insagen
		 where codigo_agencia  = _sucursal_origen 
		   and codigo_compania = '001';


		--	Zona del vendedor de la Poliza .. Henry 21/11/2011 solicitud de Isis Venavides
		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_prom --_sucursal_origen
		   and cod_ramo    = _cod_ramo;
		   
			IF _cod_no_renov IS NULL THEN
				LET _cod_no_renov = '';
			END IF			   

		-- Insercion / Actualizacion a la tabla temporal tmp_prod

		insert into tmp_prod(
				sucursal_origen,
				cod_grupo,
				cod_agente,
				user_added,
				cod_ramo,
				no_documento,
				cod_contratante,
				vigencia_final,	 
				prima,
				saldo,
				tipo_produccion,
				estatus,
				cod_vendedor,
				seleccionado,
		        cod_no_renov)
		values(	_sucursal_origen,
				_cod_grupo,
				_cod_agente,
				_user_added,
				_cod_ramo,
				_no_documento,
				_cod_contratante,
				_vigencia_final,
				_prima,
				_saldo,
				_cod_tipoprod,
				_estatus,
				_cod_vendedor,
				1,
		        _cod_no_renov);		
				let _cod_no_renov = '';
	end foreach;
else	   --0 = EXCL REN.         1 = SOLO REN.

	foreach with hold			-- informacion de poliza
		select no_poliza, 
			   sucursal_origen, 
			   cod_grupo, 
			   cod_tipoprod, 
			   cod_ramo, 
			   user_added,
			   no_documento, 
			   cod_contratante, 
			   vigencia_final, 
			   prima_bruta,
			   cod_no_renov
		  into _no_poliza, 
		  	   _sucursal_origen, 
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _prima,
			   _cod_no_renov
		  from emipomae
		 where vigencia_final >= _fecha1 
		   and vigencia_final <= _fecha2
		   and actualizado = 1
		   and renovada    = a_opcion_renovar
		   and no_renovar  = 0
	       and incobrable  = 0
		   and abierta     = 0
		   and estatus_poliza in (1,3)

	    {select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;}

		foreach with hold
		    select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 exit foreach;
		end foreach

		--buscar el saldo de la poliza
		call sp_cob85(a_compania,a_agencia,_no_documento) returning _saldo;

		--si el saldo es 10% mayor que la prima bruta entonces se excluye del inf.	
		let _prima_porc = _prima * _porc_saldos / 100;
	   	
		if _saldo > 0 then
			if _saldo > _prima_porc then
				let _estatus = "0";		
			else
				let _estatus = "1";
			end if
		else
			let _estatus = "1";
		end if

		select sucursal_promotoria
		  into _suc_prom
		  from insagen
		 where codigo_agencia  = _sucursal_origen 
		   and codigo_compania = '001';

		--Zona del vendedor de la Poliza .. Henry 21/11/2011 solicitud de Isis Venavides
		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_prom --_sucursal_origen
		   and cod_ramo    = _cod_ramo;
		   
			IF _cod_no_renov IS NULL THEN
				LET _cod_no_renov = '';
			END IF			   		   

		-- Insercion / Actualizacion a la tabla temporal tmp_prod
		insert into tmp_prod(
				sucursal_origen,
				cod_grupo,
				cod_agente,
				user_added,
				cod_ramo,
				no_documento,
				cod_contratante,
				vigencia_final,	 
				prima,
				saldo,
				tipo_produccion,
				estatus,
				cod_vendedor,
				seleccionado,
                cod_no_renov)
		values(	_sucursal_origen,
				_cod_grupo,
				_cod_agente,
				_user_added,
				_cod_ramo,
				_no_documento,
				_cod_contratante,
				_vigencia_final,
				_prima,
				_saldo,
				_cod_tipoprod,
				_estatus,
				_cod_vendedor,
				1,
		        _cod_no_renov);		
				let _cod_no_renov = '';
	end foreach;
end if

-- Procesos para Filtros
let v_filtros = "";

if a_saldo_cero = 1 then --solo saldo = 0

	let v_filtros = " saldo cero y cred.;";

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and estatus <> "1";
elif a_saldo_cero = 0 then --con saldo

   	let v_filtros = " con saldo;";

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and estatus <> "0";
else --todo
   	let v_filtros = " Todas las polizas;";
end if

if a_ramo <> "*" then

	let v_filtros = trim(v_filtros) || " Ramo: " ||  TRIM(a_ramo);
	let _tipo = sp_sis04(a_ramo);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" THEN -- (I) Incluir los Registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_ramo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

IF a_cod_no_renov = "*" THEN  -- HGIRON: CASO: 31300 USER: JEPEREZ 02/05/2019
elif a_cod_no_renov = "*E" THEN

	UPDATE tmp_prod
	   SET seleccionado = 0
	 WHERE seleccionado = 1
	   AND cod_no_renov <> '';
	   
	LET v_filtros = TRIM(v_filtros) || " Motivo NR: " ||  TRIM(a_cod_no_renov);	   

else

	LET v_filtros = TRIM(v_filtros) || " Motivo NR: " ||  TRIM(a_cod_no_renov);

	LET _tipo = sp_sis04(a_cod_no_renov);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_no_renov NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_no_renov IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

if a_grupo <> "*" then

	let v_filtros = trim(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	let _tipo = sp_sis04(a_grupo);  -- separa lls valores del string en una tabla de codigos

	if _tipo <> "E" then -- (i) incluir los registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_usuario <> "*" then

	let v_filtros = trim(v_filtros) || " Usuario: " ||  trim(a_usuario);
	let _tipo = sp_sis04(a_usuario);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and user_added not in (select codigo from tmp_codigos);
	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and user_added in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if


if a_sucursal <> "*" then

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	let _tipo = sp_sis04(a_sucursal);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and sucursal_origen not in (select codigo from tmp_codigos);

	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and sucursal_origen in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_reaseguro <> "*" then

	let _tipo = sp_sis04(a_reaseguro);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

        let v_filtros = trim(v_filtros) || " Reaseguro Asumido: Solamente ";

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion not in (select codigo from tmp_codigos);

	else		        -- (e) excllir estos registros
        let v_filtros = trim(v_filtros) || " Reaseguro Asumido: Excluido ";

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_cod_cliente <> "*" then

	let v_filtros = trim(v_filtros) || " Cliente: " ||  trim(a_cod_cliente);
	let _tipo = sp_sis04(a_cod_cliente);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante not in (select codigo from tmp_codigos);

	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_contratante in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

if a_cod_vendedor <> "*" then

	let v_filtros = trim(v_filtros) || " Zona : " ||  trim(a_cod_vendedor);
	let _tipo = sp_sis04(a_cod_vendedor);  -- separa los valores del string en una tabla de codigos

	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_vendedor not in (select codigo from tmp_codigos);

	else		        -- (e) excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_vendedor in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if


if a_codtipoprod <> "*" then
	let v_filtros = trim(v_filtros) || "Tipo Produccion "|| trim(a_codtipoprod);
	let _tipo = sp_sis04(a_codtipoprod); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion not in(select codigo from tmp_codigos);
	else
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and tipo_produccion in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--Filtro de Poliza
IF a_no_documento <> "*" and a_no_documento <> "" then
	let v_filtros = trim(v_filtros) ||"Documento: "|| trim(a_no_documento);

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and no_documento <> a_no_documento;
end if
--



if a_agente <> "*" then

	let _tipo = sp_sis04(a_agente);  -- separa los valores del string en una tabla de codigos
   	let v_filtros = trim(v_filtros) || " Corredor: "; -- ||  TRIM(a_agente);


	if _tipo <> "E" then -- incluir los registros

		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in (select codigo from tmp_codigos);
	       let v_saber = "";
	else		        -- excluir estos registros
		update tmp_prod
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in (select codigo from tmp_codigos);
	       let v_saber = " Ex";
	end if

	foreach
		select agtagent.nombre,tmp_codigos.codigo
          into v_desc_agente,v_codigo
          from agtagent,tmp_codigos
         where agtagent.cod_agente = codigo
         let v_filtros = trim(v_filtros) || " " || trim(v_codigo) || " " || trim(v_desc_agente) || " " || trim(v_saber);
	end foreach

	drop table tmp_codigos;
end if






return v_filtros;
end procedure 
                                                                       
