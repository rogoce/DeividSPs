-- Procedimiento que genera preliminar con polizas que tienen 16 dias sin pagos 
-- Creado    : 22/04/2015 -- Federico Coronado
--execute procedure sp_rep06('22/05/2016',16,'*','*','0001;')

drop procedure sp_rep06;
create procedure sp_rep06(
a_fecha_actual	date,
a_dias_sin_pago	integer,
a_cod_agente	varchar(100) default '*',
a_cod_vendedor	varchar(100) default '*',
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
		  varchar(20),
		  char(3),
		  varchar(100),
		  smallint,
		  varchar(50),
		  CHAR(255),
		  dec(16,2),
		  char(3),
		  varchar(50);

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

define _cod_grupo          CHAR(5);
define v_filtros           CHAR(255);
define _nombre_grupo       varchar(50);
define _cliente_vip        char(3);
define _nombre_subramo     varchar(50);
define _cod_subramo        char(3);


set isolation to dirty read;

--set debug file to "sp_repo06.trc";

--return '','','','','','','',null,null,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'','','',0,'','',0.00,'','';

--let _fecha_resta = a_fecha_actual - a_dias_sin_pago units day;
let _cod_acreedor = "";
LET v_filtros = "";
let _dias_anulacion = 50;
let _fecha_hoy = current;

call sp_cob356b(a_fecha_actual,a_dias_sin_pago) returning _error, _error_desc;
--trace on;
--Filtro de grupo
IF a_grupo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- Incluir los Registros	
	  SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   
	   WHERE TRIM(cod_grupo) IN (SELECT TRIM(codigo) FROM tmp_codigos)
	    INTO temp grupo_tmp;  	   
	ELSE		        -- Excluir estos Registros
	  SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   
	   WHERE TRIM(cod_grupo) NOT IN (SELECT TRIM(codigo) FROM tmp_codigos)
	    INTO temp grupo_tmp;  
	END IF	
	DROP TABLE tmp_codigos;
else
      SELECT cod_grupo,   
			 nombre  
		FROM cligrupo   	   
	    INTO temp grupo_tmp;  
END IF
--trace off;
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

let _error = _error;
let _error_desc = _error_desc;

foreach
	select no_documento, --first 1 
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
		   cod_grupo,
		   cod_subramo
	  into _cod_pagador,
		   _cod_ramo,
		   _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _nueva_renov,
		   _cod_grupo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;	 

	let _cnt = 0;
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

	let _cliente_vip = '';
	
    select count(*) into _cnt from clivip where cod_cliente = _cod_pagador;
	
	if _cnt is null then 
		let _cnt = 0;
	end if
	if _cnt > 0 then
		let _cliente_vip = 'VIP';
	end if
	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;
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

	select nombre
	  into _nombre_zona
	  from agtvende 
	 where cod_vendedor = _cod_vendedor;
	let _cod_acreedor   = "";
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
		   _nombre_grupo,
		   v_filtros,
		   _saldo_total,
		   _cliente_vip,
		   _nombre_subramo
		   with resume; 
end foreach

drop table if exists tmp_codigos;
drop table if exists tmp_codigos_zona;
drop table if exists grupo_tmp;
drop table if exists tmp_cascliente;
--drop table if exists tmp_caspoliza;
drop table if exists tmp_filtros;

end procedure;