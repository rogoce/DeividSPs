-- Reporte de polizas que cambia de prima por cambio de edad
-- creado   :02/08/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_rep09;

CREATE PROCEDURE "informix".sp_rep09(
a_compania      CHAR(50),
a_periodo       char(7),
a_no_documento  varchar(20)  default "*",
a_codsucursal     varchar(250) default "*",
a_codagente      varchar(250) default "*",
a_codsubramo       varchar(250) default "*",
a_codgrupo         varchar(250) default "*",
a_codasegurado     varchar(250) default "*"

)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(50),      -- nombre_depen
		   DATE,   	      -- Fecha aniversario
		   CHAR(50),      -- Nombre del Agente
		   DATE,           -- fecha
		   CHAR(50),      -- Nombre de la Compania
		   char(50),	  --subramo		  		         
		   DECIMAL(16,2), -- Nueva prima
		   decimal(16,2), -- prima nueva
		   decimal(16,2), --recargo
		   char(7),       --a_periodo
		   smallint;      --contador
		   			  		    
DEFINE _no_poliza  		  		CHAR(10);
DEFINE _cod_agente        		CHAR(5);
DEFINE _cod_ramo          		CHAR(3);
DEFINE _nombre_cliente    		CHAR(50);
DEFINE _nombre_corredor   		CHAR(50);
DEFINE _direccion1		  		CHAR(50);
DEFINE _direccion2        		CHAR(50);
DEFINE _no_documento      		CHAR(20);
DEFINE _cod_asegurado     		CHAR(10);
DEFINE _fecha_aniversario 		DATE;
DEFINE _vigencia_inic     		DATE;
DEFINE _fecha_ani         		DATE;
DEFINE _dia     		  		SMALLINT;
DEFINE _mes	        	  		SMALLINT;
DEFINE _ano		          		SMALLINT;
DEFINE _dia2    		  		SMALLINT;
DEFINE _mes2	    	  		SMALLINT;
DEFINE _ano2		      		SMALLINT;
DEFINE _ano3		      		SMALLINT;
DEFINE _ano4		      		SMALLINT;
DEFINE _edad              		SMALLINT;
DEFINE _prima             		DECIMAL(16,2);
DEFINE _vigencia_final    		DATE;   
DEFINE _fecha_cumpleanos  		DATE;
DEFINE _cod_producto      		CHAR(5);
DEFINE v_compania_nombre  		CHAR(50);
define _telefono1		  		char(10);
define _telefono2		  		char(10);
define _telefono3		  		char(10);
define _nombre_depen      		varchar(50);
define _cod_cliente_depen 		varchar(50);
define _no_unidad         		char(5);
define _cnt               		smallint;
define _activo                  smallint;
define _cant_dep                smallint;
define _fecha_aniversario_depen date;
 	
DEFINE _producto_nuevo, _cod_producto_new CHAR(5);
DEFINE v_fecha_ini              date;
DEFINE v_fecha_fin              date;
DEFINE _vigencia_fin       		DATE;   
define _prima_depen             DECIMAL(16,2);
define _edad_depen              SMALLINT; 
define ls_impuesto              DECIMAL(16,2);
define _prima_bruta             DECIMAL(16,2);
define _prima_bruta_dep         DECIMAL(16,2);
define _prima_total             decimal(16,2);
define _prima_endoso             decimal(16,2);
define _prima_total_depen       decimal(16,2);
define _factor_vigencia         decimal(16,2);
define ld_recargo               decimal(16,2);
define ld_recargo_dep           decimal(16,2);
define ld_recargo_d             decimal(16,2);
define _prima_rec               decimal(16,2);
DEFINE ld_porc_recargo          decimal(16,2);
define _edad_desde              integer;
define _meses                   integer;
define _prima_depen_r           decimal(16,2);
define ls_cod_recargo           decimal(16,2);
define _prima_actual            decimal(16,2);
define _cod_sucursal            char(3);
define _cod_subramo             char(3);
define _cod_grupo               char(10);
define a_fecha                  date;
define _filtros			        char(255);
define _tipo			        char(1);
define _nombre_subra            varchar(50);
define _inserta                 smallint;
define _prima_actual_depen      decimal(16,2);
define _rpt                     smallint;
define _count                   smallint;
define _periodo_original        char(7);
define _prima_original          decimal(16,2);
define _cnt_ducruet             smallint;
define _c_ano                   integer;
define _tope_ano                integer;
define i_periodo                varchar(7);
define _max_periodo             varchar(7);
define _cnt_unidad              smallint;


      CREATE TEMP TABLE tmp_carta(
		no_documento        CHAR(20),    
		nombre_cliente      CHAR(50),  
		direccion1        	CHAR(50),
		direccion2         	CHAR(50),
		fecha_ani		 	date,
		nombre_corredor     CHAR(50),
		prima    	        DEC(16,2),
		fecha               date,  	
		edad                smallint,
		compania_nombre     char(50),
		telefono1           char(10),
		telefono2           char(10),
		telefono3           char(10),
		nombre_depen        varchar(50) default null,
		recargo             decimal(16,2),
		seleccionado        smallint default 1,
		periodo             varchar(7),
		cambio              smallint,
		cod_sucursal        char(3),
		cod_agente          varchar(10),
		cod_subramo         char(3),
		cod_grupo           varchar(10),
		cod_asegurado       varchar(10),
		nombre_subramo      varchar(50),
		prima_actual        decimal(16,2)
		) WITH NO LOG; 
		
	CREATE TEMP TABLE tmp_periodo(
	periodo             varchar(7)
	) WITH NO LOG;
SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 
let _nombre_depen = ' ';
let _prima        = 0.00;
let _edad = 0;
let _fecha_ani = '';
let _activo = 1;
let a_fecha = current;
let _filtros = '';
let _prima_original = 0;

let _prima_depen_r = '';
let ld_recargo = 0;

let _c_ano 		= a_periodo[1,4];
let _tope_ano 	= year(a_fecha);

if _c_ano > _tope_ano then
	let _tope_ano = _c_ano;
end if

WHILE _c_ano <= _tope_ano
	let i_periodo = _c_ano ||"-"||a_periodo[6,7];
	insert into tmp_periodo (periodo) values(i_periodo);
	LET _c_ano = _c_ano + 1;
END WHILE;

--set debug file to "sp_rep09.trc";
--trace on;
/*if a_periodo[1,4] < year(a_fecha)then
	let a_periodo 	= year(a_fecha) || "-" || a_periodo[6,7];
end if
*/
--let _periodo_original = a_periodo;

--Ramo de Salud
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

foreach
	select periodo
	  into a_periodo
	  from tmp_periodo

	let _periodo_original = a_periodo;

	FOREACH    
	  SELECT no_poliza,
			 vigencia_inic,
			 no_documento,
			 vigencia_final,
			 factor_vigencia,
			 cod_perpago,
			 cod_sucursal,
			 cod_subramo,
			 cod_grupo
		INTO _no_poliza,
			 _vigencia_inic,
			 _no_documento,
			 _vigencia_fin,
			 _factor_vigencia,
			 ls_cod_recargo,
			 _cod_sucursal,
			 _cod_subramo,
			 _cod_grupo
		FROM emipomae
	   WHERE cod_ramo        = _cod_ramo 	 
		 AND vigencia_final  >= a_fecha
		 AND month(vigencia_inic) = a_periodo[6,7]
		 AND year(vigencia_inic) < a_periodo[1,4]	   
		 AND actualizado     = 1
		-- and colectiva       = "I"
		 and estatus_poliza   = 1
		 --and no_documento = '1806-00318-01'

		select count(*)
		  into _cnt_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   AND activo    = 1;
		
		if _cnt_unidad > 1 then
			continue foreach;
		end if

		if _cod_subramo = '012' then
			continue foreach;
		end if

		let _cnt_ducruet = 0;
		let _nombre_depen = ' ';
		
		select count(*) 
		  into _cnt_ducruet
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in ('00815','00035','02154') ;	
		 
		 SELECT meses
		   INTO _meses
		   FROM cobperpa
		  WHERE cod_perpago = ls_cod_recargo;
		  
		--Seleccion del subramo
		select nombre
		  into _nombre_subra
		  from prdsubra
		 where cod_subramo = _cod_subramo
		  and cod_ramo =  _cod_ramo;

		-- Agente de la Poliza
		FOREACH
		 SELECT cod_agente
		 INTO   _cod_agente
		 FROM   emipoagt
		 WHERE  no_poliza = _no_poliza
			 
		 SELECT nombre
		   INTO _nombre_corredor
		   FROM agtagent
		  WHERE cod_agente = _cod_agente;
		 EXIT FOREACH;
		END FOREACH

		--Seleccion de los Asegurados
		FOREACH
			 SELECT cod_asegurado,
					cod_producto,
					no_unidad,
					prima_asegurado
			   INTO	_cod_asegurado,
					_cod_producto,
					_no_unidad,
					_prima_actual
			   FROM emipouni
			  WHERE no_poliza = _no_poliza
			   AND  activo    = 1

			 select sum(prima)
			   into _prima_actual_depen
			   from emidepen
			  where no_poliza 	= _no_poliza
				and no_unidad 	= _no_unidad
					and activo 	= 1
					and calcula_prima = 1;
				if _prima_actual_depen is null then
					let _prima_actual_depen = 0.00;
				end if
				
			--evaluar prima actual
				let _prima_actual  = _prima_actual - _prima_actual_depen;	
				CALL sp_proe22(_no_poliza, _no_unidad, _prima_actual) RETURNING ld_recargo;
				CALL sp_proe53(_no_poliza, _no_poliza) RETURNING ld_recargo_dep;
				let _prima_actual = _prima_actual + ld_recargo + ld_recargo_dep;
				let _prima_actual = _prima_actual + _prima_actual_depen;
				let _prima_actual = _prima_actual + (_prima_actual * 5 / 100);
				  
			--Datos del Asegurado
			   SELECT nombre, 
					  direccion_1, 
					  direccion_2,
					  fecha_aniversario,
					  telefono1,
					  telefono2,
					  celular
				INTO _nombre_cliente,
					 _direccion1,
					 _direccion2,
					 _fecha_aniversario,
					  _telefono1,
					  _telefono2,
					  _telefono3
				FROM cliclien 
			   WHERE cod_cliente = _cod_asegurado;
			   
		let _edad = 0;
		let _edad_depen = 0;
		let _activo = 1;
		let _inserta = 0;
		
		-- Vigencia inicial y Final
		LET _dia2      		= DAY(_vigencia_inic);
		LET _mes2           = MONTH(_vigencia_inic);
		LET _ano2      		= _periodo_original[1,4];
		LET _vigencia_final = mdy(_mes2,_dia2,_ano2);

		IF _vigencia_fin <= _vigencia_final THEN
			LET _fecha_ani = _vigencia_final;
		ELSE
			LET _ano3      = _periodo_original[1,4];
			LET _fecha_ani = mdy(_mes2,_dia2,_ano3);
		END IF

		let _cod_producto_new = null;
		
	{	if _cnt_ducruet > 0 then
			select producto_nuevo
			  into _cod_producto_new
			  from prdnewpro2
			 where cod_producto = _cod_producto
				and _fecha_ani >= desde
				and _fecha_ani < hasta
				and activo = 1;
		else
			select producto_nuevo
			  into _cod_producto_new
			  from prdnewpro
			 where cod_producto = _cod_producto
				and _fecha_ani >= desde
				and _fecha_ani < hasta
				and activo = 1;
		end if
	}
	/*    SELECT cod_producto
		  INTO _cod_producto_new
		  FROM emicartasal2
		 WHERE no_documento = _no_documento;
	*/
	--	select producto_nuevo
	--	  into _cod_producto_new
	--	  from prdnewpro
	--	 where cod_producto = _cod_producto
	--	   and activo = 1;
			
		if _cod_producto_new is not null then
			let _cod_producto = _cod_producto_new;
		end if

		LET _edad = sp_sis78(_fecha_aniversario, _fecha_ani); 
		
		if _edad < 0 then
			let _edad = 0;
		end if
		
		SELECT prima
		  INTO _prima
		  FROM prdtaeda
		 WHERE cod_producto = _cod_producto
		   AND edad_desde   <= _edad
		   AND edad_hasta   >= _edad;
		   
		foreach
			SELECT edad_desde
			  into _edad_desde
			  FROM prdtaeda
			 WHERE cod_producto = _cod_producto
			   and edad_desde > 0
		  order by edad_desde
			  
		--inicio
			IF _edad = _edad_desde THEN            
				let _nombre_depen = _nombre_cliente;
				-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)
				if _vigencia_fin <= "31/08/2006" then
					select producto_nuevo
					  into _producto_nuevo
					  from prdnewpro
					 where cod_producto = _cod_producto;
					 
					-- Tarifas Nuevas
					if _producto_nuevo is not null then
						let _cod_producto = _producto_nuevo;
					end if
				end if
				SELECT prima
				  INTO _prima
				  FROM prdtaeda
				 WHERE cod_producto = _cod_producto
				   AND edad_desde   <= _edad
				   AND edad_hasta   >= _edad;

					let _prima_rec = _prima;
					CALL sp_proe22(_no_poliza, _no_unidad, _prima_rec) RETURNING ld_recargo;
												INSERT INTO tmp_carta(
									  no_documento,    
									  nombre_cliente, 
									  direccion1,      
									  direccion2,      
									  fecha_ani,		
									  nombre_corredor, 
									  prima,    	    
									  fecha,           
									  edad,           
									  compania_nombre, 
									  telefono1,       
									  telefono2,       
									  telefono3,       
									  nombre_depen,
									  recargo,
									  periodo,
									  cambio,
									  cod_sucursal,
									  cod_subramo,
									  cod_grupo,
									  cod_agente,
									  cod_asegurado,
									  nombre_subramo,
									  prima_actual)
									  VALUES(  
									  _no_documento,
									  _nombre_cliente,
									  _direccion1,
									  _direccion2,
									  _fecha_ani,
									  _nombre_corredor,
									  _prima,
									  a_fecha,
									  _edad,
									  v_compania_nombre,
									  _telefono1,
									  _telefono2,
									  _telefono3,
									  _nombre_depen,
									  ld_recargo,
									  a_periodo,
									  1,
									  _cod_sucursal,
									  _cod_subramo,
									  _cod_grupo,
									  _cod_agente,
									  _cod_asegurado,
									  _nombre_subra,
									  _prima_actual
									  );
				let _activo = 0;	
				let ld_recargo = 0;	
				let _prima     	= 0;			
			end if
		--fin 
		end foreach
			
			-- como no entro en el cambio de tarifa verificamos si la prima original tiene recargo
		if _activo = 1 then
			let _prima_rec = _prima;
			CALL sp_proe22(_no_poliza, _no_unidad, _prima_rec) RETURNING ld_recargo;
			--let _prima = _prima_rec + ld_recargo;
			
			INSERT INTO tmp_carta(
					  no_documento,    
					  nombre_cliente, 
					  direccion1,      
					  direccion2,      
					  fecha_ani,		
					  nombre_corredor, 
					  prima,    	    
					  fecha,           
					  edad,           
					  compania_nombre, 
					  telefono1,       
					  telefono2,       
					  telefono3,       
					  nombre_depen,
					  recargo,
					  periodo,
					  cambio,
					  cod_sucursal,
					  cod_subramo,
					  cod_grupo,
					  cod_agente,
					  cod_asegurado,
					  nombre_subramo,
					  prima_actual)
					  VALUES(  
					  _no_documento,
					  _nombre_cliente,
					  _direccion1,
					  _direccion2,
					  _fecha_ani,
					  _nombre_corredor,
					  _prima,
					  a_fecha,
					  _edad,
					  v_compania_nombre,
					  _telefono1,
					  _telefono2,
					  _telefono3,
					  '',
					  ld_recargo,
					  a_periodo,
					  0,
					  _cod_sucursal,
					  _cod_subramo,
					  _cod_grupo,
					  _cod_agente,
					  _cod_asegurado,
					  _nombre_subra,
					  _prima_actual);
		end if

		--Dependientes	
		foreach
			select cod_cliente,
				   prima
			  into _cod_cliente_depen,
				   _prima_depen
			  from emidepen
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and activo    = 1
			   and calcula_prima = 1	
			let _activo = 1;		   
			--Datos del Asegurado
		   SELECT nombre, 
				  fecha_aniversario
			 INTO _nombre_depen,
				  _fecha_aniversario_depen
			 FROM cliclien 
			WHERE cod_cliente = _cod_cliente_depen;

			LET _edad = sp_sis78(_fecha_aniversario_depen, _fecha_ani); 
			
			if _edad < 0 then
				let _edad = 0;
			end if
			
			SELECT prima
			  INTO _prima_depen
			  FROM prdtaeda
			 WHERE cod_producto = _cod_producto
			   AND edad_desde   <= _edad
			   AND edad_hasta   >= _edad;

			let _prima_total 	= _prima_depen;
		
			SELECT por_recargo
			  INTO ld_porc_recargo
			  FROM emiderec
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad
			   AND cod_cliente = _cod_cliente_depen;

			IF ld_porc_recargo IS NULL THEN
				LET ld_porc_recargo = 0.00;
			END IF
					
		   SELECT sum(prima_endoso)
			 INTO _prima_endoso
			 FROM prdcobpd
			WHERE cod_producto = _cod_producto;
	 
			IF _prima_endoso IS NULL THEN
				LET _prima_endoso = 0.00;
			END IF

			foreach
				SELECT edad_desde
				  into _edad_desde
				  FROM prdtaeda
				 WHERE cod_producto = _cod_producto
				   and edad_desde > 0
			  order by edad_desde

	-- inicio	  
				IF _edad = _edad_desde THEN 
					LET _prima_depen_r = _prima_depen /*- _prima_endoso*/;
					LET _prima_depen_r = _prima_depen_r * _meses;
					LET ld_recargo_d = _prima_depen_r * ld_porc_recargo / 100;
					IF ld_recargo_d IS NULL THEN
						LET ld_recargo_d = 0.00;
					END IF
						
						INSERT INTO tmp_carta(
												no_documento,    
												nombre_cliente,  
												direccion1,      
												direccion2,      
												fecha_ani,		
												nombre_corredor, 
												prima,    	    
												fecha,           
												edad,            
												compania_nombre, 
												telefono1,       
												telefono2,       
												telefono3,       
												nombre_depen,
												recargo,
												periodo,
												cambio,
												cod_sucursal,
												cod_subramo,
												cod_grupo,
												cod_agente,
												cod_asegurado,
												nombre_subramo,
												prima_actual)
												VALUES(  
												_no_documento,
												_nombre_cliente,
												_direccion1,
												_direccion2,
												_fecha_ani,
												_nombre_corredor,
												_prima_total,
												a_fecha,
												_edad,
												v_compania_nombre,
												_telefono1,
												_telefono2,
												_telefono3,
												_nombre_depen,
												ld_recargo_d,
												a_periodo,
												1,
												_cod_sucursal,
												_cod_subramo,
												_cod_grupo,
												_cod_agente,
												_cod_asegurado,
												_nombre_subra,
												_prima_actual);
					let _activo = 0;
				end if
	-- fin  
			end foreach

				if _activo = 1 then	
				
					LET _prima_depen_r = _prima_depen /*- _prima_endoso*/;
					LET _prima_depen_r = _prima_depen_r * _meses;
					LET ld_recargo_d = _prima_depen_r * ld_porc_recargo / 100;
					IF ld_recargo_d IS NULL THEN
						LET ld_recargo_d = 0.00;
					END IF
					LET ld_recargo = ld_recargo + ld_recargo_d;
					INSERT INTO tmp_carta(
						no_documento,    
						nombre_cliente,  
						direccion1,      
						direccion2,      
						fecha_ani,		
						nombre_corredor, 
						prima,    	    
						fecha,           
						edad,            
						compania_nombre, 
						telefono1,       
						telefono2,       
						telefono3,       
						recargo,
						periodo,
						cambio,
						cod_sucursal,
						cod_subramo,
						cod_grupo,
						cod_agente,
						cod_asegurado,
						nombre_subramo,
						prima_actual)
						VALUES(  
						_no_documento,
						_nombre_cliente,
						_direccion1,
						_direccion2,
						_fecha_ani,
						_nombre_corredor,
						_prima_total,
						a_fecha,
						ld_porc_recargo,
						v_compania_nombre,
						_telefono1,
						_telefono2,
						_telefono3,
						ld_recargo,
						a_periodo,
						0,
						_cod_sucursal,
						_cod_subramo,
						_cod_grupo,
						_cod_agente,
						_cod_asegurado,
						_nombre_subra,
						_prima_actual
						);
				end if
			let _prima_total = 0;
			let ld_recargo   = 0;
		end foreach;
		END FOREACH;
	END FOREACH;
end foreach


select max(periodo)
  into _max_periodo
  from tmp_carta;

update tmp_carta 
   set prima = 0,
       recargo = 0
where periodo <> _max_periodo;	  

let _nombre_depen = '';



--filtros
--Filtro por Sucursal
if a_codsucursal <> "*" then
	let _filtros = TRIM(_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por grupo
if a_codgrupo <> "*" then
	let _filtros = trim(_filtros) ||"Grupo "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in(select codigo from tmp_codigos);
	else
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por agente
if a_codagente <> "*" then
	let _filtros = trim(_filtros) || "Agente "||trim(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	else
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por subramo
if a_codsubramo <> "*" then
	let _filtros = trim(_filtros) || "Cliente "||trim(a_codsubramo);
	let _tipo = sp_sis04(a_codsubramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por Asegurado
if a_codasegurado <> "*" then
	let _filtros = trim(_filtros) || "Asegurado "||trim(a_codasegurado);
	let _tipo = sp_sis04(a_codasegurado); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_asegurado not in(select codigo from tmp_codigos);
	else
		update tmp_carta
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_asegurado in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if


--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET _filtros = TRIM(_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE tmp_carta
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--fin de filtros

foreach
		select no_documento
		  into _no_documento
		  from tmp_carta
		 where nombre_depen <> ''
		   and seleccionado = 1 
		   and cambio = 1
	  group by 1
	  order by 1
	  
	  let _rpt = 1;
	  let _count = 1;
	  
	foreach	 
		select no_documento,
			   nombre_cliente,
			   nombre_depen,
			   fecha_ani,
			   nombre_corredor,
			   fecha,
			   compania_nombre,  
			   nombre_subramo, 
			   prima_actual
		 into  _no_documento,
			   _nombre_cliente,
			   _nombre_depen,
			   _fecha_ani,
			   _nombre_corredor,
			   a_fecha,
			   v_compania_nombre,
			   _nombre_subra,
			   _prima_actual
		 from tmp_carta
		where no_documento = _no_documento
          and nombre_depen <> ''		
	 group by 1,2,3,4,5,6,7,8,9
     order by nombre_depen desc	
	 
		select sum(prima), 
		       sum(recargo)
		  into _prima_bruta,
			   ld_recargo
		  from tmp_carta
         where no_documento = _no_documento;
		 
		 if _rpt > 1 then
			let ld_recargo	  = 0;
			let _prima_bruta  = 0;
			let _prima_actual = 0;
			let _count = 0;
		 end if
		 
		 let _rpt = _rpt + 1;
		
			RETURN 
			_no_documento,
			_nombre_cliente,
			_nombre_depen,
			_fecha_ani,
			trim(_nombre_corredor),
			a_fecha,
			v_compania_nombre,
			_nombre_subra,
			_prima_actual,
			_prima_bruta,
			ld_recargo,
			_periodo_original,
			_count
			WITH RESUME;
	end foreach
end foreach

DROP TABLE tmp_carta;
END PROCEDURE;