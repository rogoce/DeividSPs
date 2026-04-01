-- Reporte de Vencimientos
-- 
-- Creado    : 04/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 28/08/2001 - Autor: Lic. Marquelda Valdelamar (para incluir filtro de cliente y poliza)
-- Modificado: 07/09/2010 - Autor: Roman Gordon
--Modificacio: 05/03/2015 - Jaime Chevalier
-- Modificado: 02/05/2019 - HGIRON Adición de filtro de motivo de no renovación
-- Modificado: 12/11/2020 - HGIRON Adición clientes VIP
-- SIS v.2.0 d_- DEIVID, S.A.
--execute procedure sp_pr51a('001','001','2025-04','2025-04',"*","*","*","*","*","*",0,"*","*",0,"*","*","*","*",0)

drop procedure sp_pr51a;


create procedure "informix".sp_pr51a(
a_compania			char(3),
a_agencia			char(3),
a_periodo1			char(7),
a_periodo2			char(7),
a_sucursal			char(255) default "*",
a_ramo				char(255) default "*",
a_grupo				char(255) default "*",
a_usuario			char(255) default "*",
a_reaseguro			char(255) default "*",
a_agente			char(255) default "*",
a_saldo_cero		smallint,
a_cod_cliente		char(255) default "*",
a_no_documento		char(255) default "*",
a_opcion_renovar	smallint default 0,
a_tipo_prod			char(255) default "*",
a_cod_vendedor		char(255) default "*",
a_status_pool		char(255) default "*",
a_cod_no_renov	    CHAR(255) DEFAULT "*",
a_facultativo	    smallint  default 0)

returning	char(20)		as poliza,
			char(100)		as nombre_cliente,
			date			as vigencia_final,
			char(10)		as tel1,
			char(10)		as tel2,
			dec(16,2)		as prima,
			char(50)		as nombre_agente,
			dec(16,2)		as saldo,
			char(50)		as nombre_ramo,
			char(50)		as nombre_grupo,
			char(50)		as compania_nombre,
			char(255)		as filtros,
			smallint		as opcion_renovar,
			char(10)		as tel3,
			char(10)		as celular,
			smallint		as conoce_cliente,
			date			as fecha_ult_pago,
			varchar(50)		as formapag,
			varchar(50)		as acreedor,
			dec(16,2)		as porc_saldo,
			smallint		as estatus_pool,
			char(3)			as cod_vendedor,
			char(50)		as nombre_vendedor,
			char(50)		as nombre_subramo,
			char(3)			as n_estatus_p,
			varchar(50)		as n_norenov,  --_cod_no_re   --char(3), sd7937 JEPEREZ 28/09/2023 HG
			char(3)			as msg_vip,
			varchar(20)		as LoB,
			varchar(10)		as origen,
			varchar(100)	as email,
			CHAR(50)		as nombre_producto,
			varchar(16)		as suma_asegurada,
			char(2)			as facultativo,
			varchar(50)		as tipo_prod,
			varchar(255)	as notas_relevantes,
			varchar(255)	as notas_poliza;

define v_filtros			varchar(255);
define v_nombre_cliente		varchar(100);
define _email				varchar(100);
define v_compania_nombre	varchar(50);
define _nombre_vendedor		varchar(50);
define v_nombre_agente		varchar(50);
define _nombre_subramo		varchar(50);
define v_nombre_grupo		varchar(50);
define v_nombre_ramo		varchar(50);
define _formapag			varchar(50);
define _n_norenov			varchar(100);
define _LoB			varchar(20);
define _origen			varchar(10);
define _acreedor			varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define v_celular			char(10);
define v_tel1				char(10);
define v_tel2				char(10);
define v_tel3				char(10);
define _cod_acreedor		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_vendedor		char(3);
define _cod_formapag		char(3);
define _cod_sucursal		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define _porc_saldo			dec(16,2);
define _saldo				dec(16,2);
define _prima				dec(16,2);
define v_conoce_cliente		smallint;
define _estatus_pool		smallint;
define _dif_meses			smallint;
define _mes1				smallint;
define _mes2				smallint;
define _vigencia_final		date;
define _fecha_ult_pago		date;
define _n_estatus_p         char(3);
define _cod_no_renov        char(3);
define _cnt_vip             smallint;
define _msg_vip             char(3);
define _cod_producto   	  	char(5);
define _nombre_producto	  	char(50);	
define _suma_asegurada		varchar(16);
define _facultativo		    char(2);
define _cnt2			    smallint;
define _tipo_prod		    varchar(50);
define _climalare           varchar(50);
define _desc_mala_ref       varchar(250);
define _cod_mala_refe       char(3);
define _nota_poliza         varchar(255);
define _nota_poliza_sal     varchar(255);


set isolation to dirty read;
-- nombre de la compania
let _cod_no_renov = '';
let _n_norenov  = '';
let _nombre_producto = '';
let _facultativo = '';
let _tipo_prod = '';
let _cnt2 = 0.00;
let v_compania_nombre = sp_sis01(a_compania);
--drop table tmp_prod;
--set debug file to "sp_pr51c.trc";
--trace on;
let a_cod_vendedor = a_cod_vendedor;
let a_opcion_renovar = a_opcion_renovar;
--trace off;
LET _n_estatus_p = '';
let _cnt_vip = 0;
let _msg_vip = '';

let _mes1 = a_periodo1[6,7];
let _mes2 = a_periodo2[6,7];

let _dif_meses	= _mes2 - _mes1 + 1;

if _dif_meses < 0 then
	let _dif_meses = _dif_meses + 12;
end if

if _dif_meses > 3 then
	return '',
		   '',
		   '01/01/1900',
		   '',
		   '',
		   0.00,
		   '',
		   0.00,
		   '',
		   '',
		   '',
		   '',
		   0,
		   '',
		   '',
		   0,
		   '01/01/1900',
		   '',
		   '',
		   0.00,
		   0,
		   '',
		   '',
		   '','','','','','','','','','','','','';
end if


let _tipo = '';
--let v_filtros = sp_pro51(

drop table if exists tmp_prod;

let v_filtros = sp_pro51_a(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo,
a_usuario,
a_reaseguro,
a_agente,
a_saldo_cero,
a_cod_cliente,
a_no_documento,
a_opcion_renovar,
a_tipo_prod,
a_cod_vendedor,a_cod_no_renov);

if a_status_pool <> "*" then
	let v_filtros = trim(v_filtros) || " Estado del Pool: " ||  trim(a_status_pool);
	let _tipo = sp_sis04(a_status_pool);  -- separa los valores del string en una tabla de codigos
end if

if a_facultativo = 1 then --Incluido

	let v_filtros = " Facultativo Incluido;";

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	   and facultativo =  "NO";
	   
elif a_facultativo = 2 then -- Excluido

   	let v_filtros = " Facultativo Excluido;";

	update tmp_prod
	   set seleccionado = 0
	 where seleccionado = 1
	    and facultativo =  "SI";
else --todos
   	let v_filtros = trim(v_filtros) || " " ||" Todos los Facultativos;";
end if

if a_tipo_prod <> "*" then
	let v_filtros = trim(v_filtros) || "Tipo Produccion "|| trim(a_tipo_prod);
	let _tipo = sp_sis04(a_tipo_prod); -- separa los valores del string

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

--Recorre la tabla temporal y asigna valores a variables de salida

foreach with hold
	select no_documento,
		   cod_contratante,
		   vigencia_final,
		   prima,
		   cod_agente,
		   saldo,
		   cod_ramo,
		   cod_grupo,
		   sucursal_origen,
		   cod_vendedor,
		   cod_no_renov,
		   suma_asegurada,
			facultativo,
			tipo_prod_name
	  into _no_documento,
		   _cod_contratante,
		   _vigencia_final,
		   _prima,
		   _cod_agente,
		   _saldo,
		   _cod_ramo,
		   _cod_grupo,
		   _cod_sucursal,
		   _cod_vendedor,
           _cod_no_renov,
		   _suma_asegurada,
			_facultativo,
			_tipo_prod
	  from tmp_prod
	 where seleccionado = 1
	 order by cod_grupo,cod_ramo,no_documento

	let _no_poliza = sp_sis21(_no_documento);
	let _cod_acreedor = null;

	--selecciona los nombres de ramos
	select nombre,
		    case when cod_area = 0 then 'PATRIMONIALES'
				  when cod_area = 1 then 'AUTO'
				  when cod_area = 2 then 'PERSONAS'
			end
	  into v_nombre_ramo,
			_LoB
	  from prdramo
	 where cod_ramo = _cod_ramo;

	--selecciona los nombres de los grupos
	select nombre
	  into v_nombre_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	--selecciona los nombres de clientes
	select nombre,
		   telefono1,
		   telefono2,
		   telefono3,
		   celular,
		   conoce_cliente,
		   e_mail,
		   desc_mala_ref,
		   cod_mala_refe
	  into v_nombre_cliente,
		   v_tel1,
		   v_tel2,
		   v_tel3,
		   v_celular,
		   v_conoce_cliente,
		   _email,
		   _desc_mala_ref,
		   _cod_mala_refe
	  from cliclien
	 where cod_cliente = _cod_contratante;

	--selecciona los nombres de los corredores
	select nombre,
			case when tipo_agente = 'O' then 'DIRECTO' else 'BROKER' end
	  into v_nombre_agente,
			_origen
     from agtagent
	 where cod_agente = _cod_agente;

	--selecciona el fecha de ultimo pago, la forma de pago y acreedor
	select fecha_ult_pago,
		   cod_formapag
	  into _fecha_ult_pago,
		   _cod_formapag
	  from emipomae
	 where	no_poliza =_no_poliza;

	select nombre
	  into	_formapag
	  from cobforpa
	 where	cod_formapag = _cod_formapag;

	--selecciona el acreedor
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza
		 order by no_unidad asc
		exit foreach;
	end foreach

	let _acreedor = "";
	if _cod_acreedor is not null then
		select nombre
		  into _acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;
	end if

	--busco el subramo de la poliza
	select cod_subramo
	  into _cod_subramo
	from emipomae
	where no_poliza = _no_poliza;

	select nombre
	  into _nombre_subramo
	  from prdsubra
     where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;

	--calculo para porcentaje de la prima bruta
	let _porc_saldo = _prima;
	let _porc_saldo = _porc_saldo * 0.10;


	--saber en que pool esta
	let _estatus_pool = null;

	select estatus
	  into	_estatus_pool
	  from emirepo
	 where	no_poliza = _no_poliza;

	if _estatus_pool is null then
		select estatus
		  into	_estatus_pool
		  from emirepol
		 where	no_poliza = _no_poliza;
	end if

	if _estatus_pool in(1,2,3,4,5,9) then
	else
		let _estatus_pool = 0;
	end if
    if _estatus_pool in(1) then
		let _n_estatus_p = 'AUT';
	elif _estatus_pool in(2) then
		let _n_estatus_p = 'TEC';
	elif _estatus_pool in(3) then
		let _n_estatus_p = 'FID';
	elif _estatus_pool in(4) then
		let _n_estatus_p = 'MAN';
	elif _estatus_pool in(5,9) then
		let _n_estatus_p = 'IMP';
	else
		let _n_estatus_p = 'MAN';
	end if
	if a_status_pool <> '*' then
		if _tipo <> "E" then -- incluir los registros
			if _estatus_pool not in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		else		        -- (e) excluir estos registros
			if _estatus_pool in (select codigo from tmp_codigos) then
				continue foreach;
			end if
		end if
	end if

	--zona del vendedor de la poliza .. henry 21/11/2011 solicitud de isis venavides
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where activo = 1
	   and cod_vendedor = _cod_vendedor;

	select count(*)
	  into _cnt_vip
	  from clivip
	 where cod_cliente = _cod_contratante;

	if _cnt_vip is null then
		let _cnt_vip = 0;
	end if

	if _cnt_vip > 0 then
		let _msg_vip = 'VIP';
	else
	    let _msg_vip = '   ';
	end if
	
	--selecciona el primer producto de la unidada activa
	foreach
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza  = _no_poliza	  
		  and activo   = 1
		 order by no_unidad asc
		 
		select nombre
		  into _nombre_producto
		  from prdprod 
		 where cod_producto = _cod_producto;
		 
		exit foreach;
	end foreach	
	
  SELECT trim(nombre)||" - "||trim(cod_no_renov)
    into _n_norenov
    FROM eminoren   
	where cod_no_renov = _cod_no_renov;	

	-- Notas relevantes
	select nombre
	  into _climalare
	  from climalare
	 where cod_mala_refe = _cod_mala_refe;

	if _climalare is null then	
		let _climalare = "";
	end if

	if _desc_mala_ref is null then	
		let _desc_mala_ref = "";
	end if
	
	-- Notas Poliza
	let _nota_poliza_sal = "";
	let _nota_poliza = "";
	foreach 
		select trim(descripcion)
		  into _nota_poliza
		  from eminotas
		 where no_documento = _no_documento
		   and procesado = 0

		if _nota_poliza is null then
			let _nota_poliza = "";
		end if
		
		let _nota_poliza = REPLACE(_nota_poliza,"|","");
		   
		if length(trim(_nota_poliza_sal)  || " " || trim(_nota_poliza)) > 255 then
			exit foreach;
		end if
				
		let _nota_poliza_sal = trim(trim(_nota_poliza_sal) || " " || trim(_nota_poliza));
    end foreach
	
	let _nota_poliza_sal = REPLACE(_nota_poliza_sal,"|","");
	
	return _no_documento,
		   v_nombre_cliente,
		   _vigencia_final,
		   v_tel1,
		   v_tel2,
		   _prima,
		   v_nombre_agente,
		   _saldo,
		   v_nombre_ramo,
		   v_nombre_grupo,
		   v_compania_nombre,
		   v_filtros,
		   a_opcion_renovar,
		   v_tel3,
		   v_celular,
		   v_conoce_cliente,
		   _fecha_ult_pago,
		   _formapag,
		   _acreedor,
		   _porc_saldo,
		   _estatus_pool,
		   _cod_vendedor,
		   _nombre_vendedor,
		   _nombre_subramo,
		   _n_estatus_p,
		   _n_norenov,  --_cod_no_renov,
		   _msg_vip,
		   _LoB,
		   _origen,
		   _email,
		   _nombre_producto,
		   _suma_asegurada,
		   _facultativo,
		   _tipo_prod,
		   trim(trim(_climalare) || " " || trim(_desc_mala_ref)),
		   _nota_poliza_sal  with resume;
end foreach;
drop table tmp_prod;
end procedure


                                                                                                                                                                                      
