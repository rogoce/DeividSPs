-- Reporte de Vencimientos-- 
-- Creado    : 04/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 28/08/2001 - Autor: Lic. Marquelda Valdelamar (para incluir filtro de cliente y poliza)
-- Modificado: 07/09/2010 - Autor: Roman Gordon
--Modificacio: 05/03/2015 - Jaime Chevalier
-- Modificado: 02/05/2019 - HGIRON AdiciÃ³n de filtro de motivo de no renovaciÃ³n
-- SIS v.2.0 d_- DEIVID, S.A.

drop procedure sp_pr51a_1;
create procedure "informix".sp_pr51a_1(
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
a_cod_no_renov	    CHAR(255) DEFAULT "*")

returning	char(20),
			char(100),
			date,
			char(10),
			char(10),
			dec(16,2),
			char(50),
			dec(16,2),
			char(50),
			char(50),
			char(50),
			char(255),
			smallint,
			char(10),
			char(10),
			smallint,
			date,
			varchar(50),
			varchar(50),
			dec(16,2),
			smallint,
			char(3),
			char(50),
			char(50),
			char(3),CHAR(50);
			
define v_filtros			varchar(255);
define v_nombre_cliente		varchar(100);
define v_compania_nombre	varchar(50);
define _nombre_vendedor		varchar(50);
define v_nombre_agente		varchar(50);
define _nombre_subramo		varchar(50);
define v_nombre_grupo		varchar(50);
define v_nombre_ramo		varchar(50);
define _formapag			varchar(50);
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
define _cod_producto   	  char(5);
define _nombre_producto	  char(50);	



set isolation to dirty read;
-- nombre de la compania

let v_compania_nombre = sp_sis01(a_compania);
--drop table tmp_prod;
--set debug file to "sp_pr51c.trc";
--trace on;
let a_cod_vendedor = a_cod_vendedor;
let a_opcion_renovar = a_opcion_renovar;
--trace off;
LET _n_estatus_p = '';

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
		   '','','';
end if


let _tipo = '';
--let v_filtros = sp_pro51(

let v_filtros = sp_pro51_a_1(
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
		   cod_vendedor
	  into _no_documento,
		   _cod_contratante,
		   _vigencia_final,
		   _prima,
		   _cod_agente,
		   _saldo,
		   _cod_ramo,
		   _cod_grupo,
		   _cod_sucursal,
		   _cod_vendedor 
	  from tmp_prod
	 where seleccionado = 1
	 order by cod_grupo,cod_ramo,no_documento

	let _no_poliza = sp_sis21(_no_documento);
	let _cod_acreedor = null;

	--selecciona los nombres de ramos
	select nombre
	  into v_nombre_ramo
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
		   conoce_cliente
	  into v_nombre_cliente,
		   v_tel1,
		   v_tel2,
		   v_tel3,
		   v_celular,
		   v_conoce_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	--selecciona los nombres de los corredores
	select nombre
	  into v_nombre_agente
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
		   _nombre_subramo,_n_estatus_p, _nombre_producto with resume;
end foreach;
drop table tmp_prod;
end procedure 
                                                                         
