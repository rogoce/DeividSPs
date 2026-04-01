-- Reporte de polizas que cambia de prima por cambio de edad
-- creado   :02/08/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_rep11;

CREATE PROCEDURE "informix".sp_rep11(
a_compania      	CHAR(50),
a_no_documento  	varchar(20)  default "*",
a_codsucursal     	varchar(250) default "*",
a_codagente      	varchar(250) default  "*",
a_codsubramo       	varchar(250) default "*",
a_codgrupo         	varchar(250) default "*",
a_codasegurado     	varchar(250) default "*"

)RETURNING VARCHAR(20),      -- No_documento
		   VARCHAR(50),      -- Nombre del subramo
		   VARCHAR(50),      -- nombre_asegurado
		   VARCHAR(10),      -- cod_producto
		   VARCHAR(50),      -- nombre del producto
		   DATE,             -- vigencia inicial
		   DATE,             -- vigencia final
		   VARCHAR(50),      -- nombre corredor
		   DECIMAL(16,2),    -- prima_bruta
		   VARCHAR(50),      -- compañia nombre
		   VARCHAR(15),      -- estado
		   VARCHAR(3),       -- subramo
		   VARCHAR(250);     -- filtros
		   

		   			  		    
DEFINE _no_poliza  		  		CHAR(10);
DEFINE _no_documento            VARCHAR(20);
DEFINE _cod_agente              VARCHAR(5);
DEFINE _cod_asegurado           VARCHAR(10);
DEFINE _cod_ramo                VARCHAR(3);
DEFINE _cod_subramo             VARCHAR(3);
DEFINE _vigencia_inic           DATE;
DEFINE _vigencia_fin            DATE;
DEFINE _estado_poliza           SMALLINT;
DEFINE _nombre_subra            VARCHAR(50);
DEFINE _nombre_corredor         VARCHAR(50);
DEFINE _cod_producto            VARCHAR(10);
DEFINE _no_unidad               VARCHAR(10);
DEFINE v_compania_nombre        VARCHAR(30);
DEFINE _nombre_producto         VARCHAR(50);
DEFINE _nombre_asegurado        VARCHAR(50);
DEFINE _prima_bruta             DECIMAL(16,2);
define _estado                  VARCHAR(15);
define _cod_sucursal            VARCHAR(3);
define _cod_grupo               VARCHAR(10);
define _filtros                 varchar(250);
define _tipo                    char(1); 
define _colectiva               char(1); 


 CREATE TEMP TABLE tmp_polizas(
		no_documento        VARCHAR(20),
		no_poliza           CHAR(10),
        no_unidad           CHAR(5),		
		nombre_subra        VARCHAR(50),
		nombre_asegurado    VARCHAR(50),
		cod_producto        VARCHAR(10),
		nombre_producto     VARCHAR(50),
		vigencia_inic       DATE,
		vigencia_final      DATE,
		nombre_corredor     VARCHAR(50),
		prima               DEC(16,2),
		nombre_compania     VARCHAR(50),
		estado              VARCHAR(15),
		cod_subramo         VARCHAR(3),
		cod_agente          VARCHAR(10),
		cod_sucursal        VARCHAR(3),
		cod_grupo           varchar(10),
		cod_asegurado       varchar(10),
		seleccionado        SMALLINT default 1,
		primary key (no_poliza, no_unidad)
		) WITH NO LOG;     

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 
let _filtros = '';
--Ramo de Salud
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;
 
--set debug file to "sp_pro76cbk.trc";
--trace on;

FOREACH   
  SELECT no_documento,
         colectiva
    INTO _no_documento,
	     _colectiva
    FROM emipomae
   WHERE cod_ramo        = _cod_ramo 	 
	 AND actualizado     = 1
--	 and colectiva       = "I"
	 and estatus_poliza  in(1,3)
	 
     let _no_poliza = sp_sis21(_no_documento);

	select cod_subramo,
		   cod_sucursal,
		   cod_grupo,
           prima_bruta,
           vigencia_inic,
           vigencia_final,
           estatus_poliza 
     INTO _cod_subramo,
		  _cod_sucursal,
		  _cod_grupo,
		  _prima_bruta,
	      _vigencia_inic,
		  _vigencia_fin,
		  _estado_poliza
      from emipomae
     where no_poliza = _no_poliza;

    if _estado_poliza not in (1,3) then
		continue foreach;
	end if
	 
	--Seleccion del subramo
	select nombre
	  into _nombre_subra
	  from prdsubra
	 where cod_subramo = _cod_subramo
	  and cod_ramo =  _cod_ramo;

	-- estado de la polizas
	if _estado_poliza = 1 then
		let _estado = "Vigente";
	elif _estado_poliza = 3 then
		let _estado = "Vencida";
	end if
	
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
				no_unidad
		   INTO	_cod_asegurado,
				_cod_producto,
				_no_unidad
		   FROM emipouni
		  WHERE no_poliza = _no_poliza
		   AND  activo    = 1
		   
		   SELECT nombre
		     into _nombre_asegurado
			 from cliclien
		    where cod_cliente = _cod_asegurado;
		   
		   select nombre
		     into _nombre_producto
			 from prdprod
			where cod_producto = _cod_producto;
			 
			begin 
			on exception in(-239)
			end exception
			
			INSERT INTO tmp_polizas(
									no_documento, 
                                    no_poliza,
                                    no_unidad,									
									nombre_subra,       
									nombre_asegurado,   
									cod_producto,       
									nombre_producto,    
									vigencia_inic,      
									vigencia_final,     
									nombre_corredor,    
									prima,              
									nombre_compania,    
									estado,             
									cod_subramo,
									cod_agente,        
									cod_sucursal,      
									cod_grupo,         
									cod_asegurado)
									VALUES(
									_no_documento,   
                                    _no_poliza,
                                    _no_unidad,									
									_nombre_subra,         
									_nombre_asegurado,     
									_cod_producto,         
									_nombre_producto,      
									_vigencia_inic,      	
									_vigencia_fin,         
									_nombre_corredor,
									_prima_bruta,          
									v_compania_nombre,     
									_estado,	
									_cod_subramo,
									_cod_agente,
									_cod_sucursal,
									_cod_grupo,
									_cod_asegurado							
									); 
			end			
        if _colectiva = 'C' then			
			exit foreach;
		end if
	end foreach
end foreach

--filtros
--Filtro por Sucursal
if a_codsucursal <> "*" then
	let _filtros = TRIM(_filtros) ||"Sucursal: "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por grupo
if a_codgrupo <> "*" then
	let _filtros = trim(_filtros) ||"Grupos: "||trim(a_codgrupo);
	let _tipo = sp_sis04(a_codgrupo); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo not in(select codigo from tmp_codigos);
	else
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_grupo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por agente
if a_codagente <> "*" then
	let _filtros = trim(_filtros) || "Agente: "||trim(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	else
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por subramo
if a_codsubramo <> "*" then
	let _filtros = trim(_filtros) || "Subramos: "||trim(a_codsubramo);
	let _tipo = sp_sis04(a_codsubramo); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in(select codigo from tmp_codigos);
	else
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por Asegurado
if a_codasegurado <> "*" then
	let _filtros = trim(_filtros) || "Asegurado: "||trim(a_codasegurado);
	let _tipo = sp_sis04(a_codasegurado); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_asegurado not in(select codigo from tmp_codigos);
	else
		update tmp_polizas
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_asegurado in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if


--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET _filtros = TRIM(_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE tmp_polizas
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--fin de filtros


FOREACH
	select no_documento,       
		   nombre_subra,       
		   nombre_asegurado,   
		   cod_producto,       
		   nombre_producto,    
		   vigencia_inic,      
		   vigencia_final,     
		   nombre_corredor,    
		   prima,              
		   nombre_compania,    
		   estado,             
		   cod_subramo    
      into _no_documento,         
	       _nombre_subra,         
	       _nombre_asegurado,     
	       _cod_producto,         
	       _nombre_producto,      
	       _vigencia_inic,      	
	       _vigencia_fin,         
	       _nombre_corredor,
	       _prima_bruta,          
	       v_compania_nombre,     
	       _estado,
	       _cod_subramo
	from tmp_polizas
   where seleccionado = 1
			RETURN 
			_no_documento,          -- No_documento
			_nombre_subra,          -- Nombre del subramo
			_nombre_asegurado,      -- nombre_asegurado
			_cod_producto,          --cod_producto
			_nombre_producto,       --nombre del producto
			_vigencia_inic,      	--vigencia inicial
			_vigencia_fin,         	--vigencia final
			_nombre_corredor,       --nombre corredor
			_prima_bruta,           --prima_bruta
			v_compania_nombre,      --compañia nombre
			_estado,
			_cod_subramo,
			_filtros
			WITH RESUME;
end foreach
DROP TABLE tmp_polizas;
END PROCEDURE;