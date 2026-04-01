-- Procedimiento que genera preliminar con polizas que tienen 16 dias sin pagos 
-- Creado    : 06/01/2016 -- Amado Perez
--execute procedure sp_rep12('01/01/2014',16,'*','*')

drop procedure sp_rep12;

create procedure "informix".sp_rep12(
a_fecha_actual	date,
a_dias_sin_pago	integer,
a_cod_agente	varchar(100) default '*',
a_cod_vendedor	varchar(100) default '*',
a_nueva_renov   char(1) default '*',
a_grupo      CHAR(255) DEFAULT '*')
returning varchar(20),
          varchar(100),
		  varchar(30),
		  varchar(30),
		  varchar(100),
		  varchar(100),
		  varchar(100),
		  date,
          date,
		  dec(10,2),
		  dec(10,2),
		  dec(10,2),  
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2),
		  varchar(20),
		  char(3),
		  varchar(100),
		  smallint,
		  varchar(50),
		  varchar(50),
		  smallint,
		  smallint,
		  varchar(50),
		  CHAR(255); 

-- Actualizar Polizas Nuevas
define _nombre_corredor		varchar(100);
define _nombre_acreedor		varchar(100);
define _nombre_cliente		varchar(100);
define _nombre_zona			varchar(100);
define _cod_agente			varchar(100);
define _error_desc			varchar(100);
define _nombre_forma_pag	varchar(30);
define _nombre_ramo			varchar(30);
define _estado				varchar(20);
define _no_documento		varchar(20);
define _cod_acreedor		varchar(10);
define _cod_pagador			varchar(10);
define _no_poliza			varchar(10);
define _periodo				char(7);
define _cod_vendedor		char(3);
define _cod_formapag		char(3);
define _cod_ramo			char(3);
define _tipo_vendedor		char(1);
define _nueva_renov			char(1);
define _tipo				char(1);
define _saldo_total			dec(10,2); 
define _prima_bruta			dec(10,2);
define _por_vencer			dec(10,2);   
define _corriente			dec(10,2); 
define _monto_180			dec(10,2); 
define _monto_150			dec(10,2); 
define _monto_120			dec(10,2); 
define _monto_90			dec(10,2); 
define _monto_60			dec(10,2); 
define _monto_30			dec(10,2); 
define _exigible			dec(10,2);
define _dias_anulacion		smallint; 
define _dias_sin_pago		smallint; 
define _error				integer;
define _cnt					integer;
define _fecha_anulacion		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_resta			date;
define _fecha_hoy			date;
define _cod_tipoprod		char(3);
define _leasing             smallint;
define _nombre_tipoprod     varchar(50);
define _fronting            smallint;

define _cod_grupo          CHAR(5);
define v_filtros           CHAR(255);
define _nombre_grupo       varchar(50);

set isolation to dirty read;

--set debug file to "sp_repo06.trc";
--trace on;

--let _fecha_resta = a_fecha_actual - a_dias_sin_pago units day;
let _cod_acreedor = "";
LET v_filtros = "";
let _dias_anulacion = 30;
let _fecha_hoy = current;

call sp_rep12b(a_fecha_actual,a_dias_sin_pago) returning _error, _error_desc;

--Filtro de grupo
IF a_grupo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- Incluir los Registros	
	  SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   
	   WHERE cod_grupo IN (SELECT codigo FROM tmp_codigos)
	    INTO temp grupo_tmp;  	   
	ELSE		        -- Excluir estos Registros
	  SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   
	   WHERE cod_grupo NOT IN (SELECT codigo FROM tmp_codigos)
	    INTO temp grupo_tmp;  
	END IF	
	DROP TABLE tmp_codigos;
else
      SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   	   
	    INTO temp grupo_tmp;  	
END IF

--Filtro de corredor
if a_cod_agente <> "*" then
	LET v_filtros = TRIM(v_filtros) || " Agente: " ||  TRIM(a_cod_agente);
	let _tipo = sp_sis04(a_cod_agente);  -- separa los valores del string en una tabla de codigos
end if

--Filtro de vendedor
if a_cod_vendedor <> "*" then
	LET v_filtros = TRIM(v_filtros) || " Vendedor: " ||  TRIM(a_cod_vendedor);
	let _tipo_vendedor = sp_sis04c(a_cod_vendedor);  -- separa los valores del string en una tabla de codigos
end if

foreach
	select no_documento,
		   dia_cobros1
	  into _no_documento,
		   _dias_sin_pago
	  from tmp_caspoliza
	 order by no_documento asc

	let _no_poliza = sp_sis21(_no_documento);

	select cod_pagador,
		   cod_ramo,
		   cod_formapag,
		   vigencia_inic,
		   vigencia_final,
		   prima_bruta,
		   nueva_renov,
		   cod_tipoprod,
		   cod_grupo,
		   leasing,
		   cod_grupo
	  into _cod_pagador,
		   _cod_ramo,
		   _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _nueva_renov,
		   _cod_tipoprod,
		   _cod_grupo,
		   _leasing,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	 let _cnt = 0;
	-- a_grupo 
	if a_grupo <> "*" then
		select count(*)
		  into _cnt
		  from grupo_tmp
		 where cod_grupo = _cod_grupo;
		if _cnt = 0 then
			continue foreach;		
		end if	 
	end if

	select nombre
	  into _nombre_grupo
	  from grupo_tmp
	 where cod_grupo = _cod_grupo;		 
	 
	let _fronting = sp_sis135(_no_poliza);	 

	--let _fecha_anulacion = _vigencia_inic + _dias_anulacion units day;

	if _nueva_renov = 'N' then
		let _estado = "Nuevas";
	else
		let _estado = "Renovadas";
	end if

	select nombre
	  into _nombre_forma_pag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;		
 
    select nombre
      into _nombre_tipoprod
      from emitipro
     where cod_tipoprod = _cod_tipoprod;

    select nombre
      into _nombre_grupo
      from cligrupo
     where cod_grupo = _cod_grupo;  

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre,
		   cod_vendedor
	  into _nombre_corredor,
		   _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;

	let _cnt = 0;

	-- cod_vendedor	
	if a_cod_vendedor <> "*" then
		if _tipo_vendedor <> "E" then -- Incluir los Registros vendedores
			select count(*)
			  into _cnt
			  from tmp_codigos_zona
			 where codigo = _cod_vendedor;
			if _cnt = 0 then
				continue foreach;
			end if
		else
			select count(*)
			  into _cnt
			  from tmp_codigos_zona
			 where codigo = _cod_vendedor;
			if _cnt >= 1 then
				continue foreach;
			end if
		end if
	end if
	
	let _cnt = 0;
	if a_cod_agente <> "*" then
		if _tipo <> "E" then -- Incluir los Registros agentes
			select count(*)
			  into _cnt
			  from tmp_codigos
			 where codigo = _cod_agente;
			if _cnt = 0 then
				continue foreach;
			end if
		else
			select count(*)
			  into _cnt
			  from tmp_codigos
			 where codigo = _cod_agente;
			if _cnt >= 1 then
				continue foreach;
			end if
		end if
	end if

	if a_nueva_renov <> "*" then
		if _nueva_renov <> a_nueva_renov then
			continue foreach;
		end if
	end if

	select nombre
	  into _nombre_zona
	  from agtvende 
	 where cod_vendedor = _cod_vendedor;

	let _cod_acreedor = "";	 
	 
	foreach
		select x.cod_acreedor
		  into _cod_acreedor
		  from emipoacr x, emipouni e
		 where x.no_poliza = e.no_poliza
		   and x.no_unidad = e.no_unidad
		   and e.no_poliza = _no_poliza
		 exit foreach;
	end foreach

	select nombre
	  into _nombre_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;

	call sp_sis39(_fecha_hoy) returning _periodo;

	call sp_cob245(
		 "001",
		 "001",	
		 _no_documento,
		 _periodo,
		 _fecha_hoy)
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo_total;

	return _no_documento,
		   _nombre_cliente,
		   _nombre_ramo,
		   _nombre_forma_pag,
		   _cod_agente,
		   _nombre_corredor,
		   _nombre_acreedor,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _saldo_total,
		   _por_vencer,  
		   _exigible,    
		   _corriente,   
		   _monto_30,    
		   _monto_60,    
		   _monto_90,
		   _estado,
		   _cod_vendedor,
		   _nombre_zona,
		   _dias_sin_pago,
     	   _nombre_tipoprod,
		   _nombre_grupo,
		   _leasing,
		   _fronting,
		   _nombre_grupo,
		   v_filtros
		   with resume; 
end foreach

drop table if exists tmp_codigos;
drop table if exists tmp_codigos_zona;	
drop table if exists grupo_tmp;
end procedure;