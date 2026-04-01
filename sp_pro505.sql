-- Carta de Cambio de Tarifa 2006-2007 

-- Creado: 07/08/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro170_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_prod_sp_pro76_crit - DEIVID, S.A.

drop procedure sp_pro505;
create procedure sp_pro505(a_periodo char(7), a_codagente CHAR(255) DEFAULT "*") 
returning char(20),
          date,
		  date,
          char(10),
          varchar(100),
          char(5),
		  varchar(50),
          dec(16,2),
          dec(16,2),
          char(5),
          varchar(50),
          char(255);

define _no_documento     char(20);
define _cod_producto     char(5);
define _prima            dec(16,2);
define _prima_nueva      dec(16,2);
define _vigencia_inic    date;
define _vigencia_final   date;
define _cod_agente       char(5);
define _nombre_agente    varchar(50);
define _cod_asegurado    char(10);
define _nombre_asegurado varchar(100);
define _no_poliza        char(10);
define _nombre_producto  varchar(50);
define v_filtros         char(255);
define _tipo             char(1);
DEFINE _porc_impuesto    DEC(5,2);
define _prima_new        dec(16,2);
define _prima_old        dec(16,2);

CREATE TEMP TABLE temp_carta
   (no_documento     char(20),
    cod_producto     char(5),
    prima            dec(16,2),
    prima_nueva      dec(16,2),
    vigencia_inic    date,
    vigencia_final   date,
    cod_agente       char(5),
	nombre_agente    varchar(50),
    cod_asegurado    char(10),
    nombre_asegurado varchar(100),
    nombre_producto  varchar(50),
    seleccionado     SMALLINT DEFAULT 1 NOT NULL) WITH NO LOG;

set isolation to dirty read;


--set debug file to "sp_pro170.trc";
--trace on;

if a_periodo >= '2012' then

foreach
	SELECT no_documento,   
	       cod_producto_ant,   
	       prima,
		   prima_ant
	  INTO _no_documento,
	       _cod_producto,
	       _prima_new,
	       _prima_old 
	  FROM emicartasal2  
	 WHERE periodo = a_periodo
	   AND cod_subramo in ('008','018')  
	   AND cod_grupo <> '01007' -- Grupo Apavimed
  ORDER BY no_documento ASC
	
    LET _no_poliza   = sp_sis21(_no_documento);
--    LET _prima_nueva = sp_pro503(_no_documento, a_periodo);	  --cambiar este procedure por el sp_pro503a

	SELECT vigencia_inic,
		   vigencia_final
	  INTO _vigencia_inic,
		   _vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT cod_asegurado
	  INTO _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nombre_producto
	  from prdprod
	 where cod_producto = _cod_producto;

    insert into temp_carta
    values(_no_documento,    
		   _cod_producto,
		   _prima_old,  
		   _prima_new,  
		   _vigencia_inic,   
		   _vigencia_final,  
		   _cod_agente,      
		   _nombre_agente,
		   _cod_asegurado,   
		   _nombre_asegurado,
		   _nombre_producto, 
		   1);

end foreach

else

foreach
	SELECT no_documento,   
	       cod_producto,   
	       prima
	  INTO _no_documento,
	       _cod_producto,
	       _prima   
	  FROM emicartasal  
	 WHERE periodo = a_periodo
	   AND cod_subramo in ('008','018')  
	   AND cod_grupo <> '01007' -- Grupo Apavimed
  ORDER BY no_documento ASC
	
    LET _no_poliza   = sp_sis21(_no_documento);
    LET _prima_nueva = sp_pro503(_no_documento, a_periodo);

	SELECT vigencia_inic,
		   vigencia_final
	  INTO _vigencia_inic,
		   _vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT cod_asegurado
	  INTO _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = _no_poliza;

    SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nombre_producto
	  from prdprod
	 where cod_producto = _cod_producto;

    insert into temp_carta
    values(_no_documento,    
		   _cod_producto,
		   _prima,           
		   _prima_nueva,     
		   _vigencia_inic,   
		   _vigencia_final,  
		   _cod_agente,      
		   _nombre_agente,
		   _cod_asegurado,   
		   _nombre_asegurado,
		   _nombre_producto, 
		   1);

end foreach
end if

-- Procesos v_filtros
LET v_filtros ="";

IF a_codagente <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Corredor "||TRIM(a_codagente);
 LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

 IF _tipo <> "E" THEN -- Incluir los Registros

    UPDATE temp_carta
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
 ELSE
    UPDATE temp_carta
           SET seleccionado = 0
         WHERE seleccionado = 1
           AND cod_agente IN(SELECT codigo FROM tmp_codigos);
 END IF
 DROP TABLE tmp_codigos;
END IF

foreach
	select no_documento,     
		   cod_producto,    
		   prima,           
		   prima_nueva,     
		   vigencia_inic,   
		   vigencia_final,  
		   cod_agente,      
		   nombre_agente,   
		   cod_asegurado,   
		   nombre_asegurado,
		   nombre_producto 
	  into _no_documento,    
		   _cod_producto,
		   _prima,           
		   _prima_nueva,     
		   _vigencia_inic,   
		   _vigencia_final,  
		   _cod_agente,      
           _nombre_agente,
           _cod_asegurado,   
		   _nombre_asegurado,
		   _nombre_producto 
	  from temp_carta
	 where seleccionado = 1					   

    return _no_documento,    
		   _vigencia_inic,   
		   _vigencia_final,  
		   _cod_asegurado,   
		   _nombre_asegurado,
		   _cod_producto,
		   _nombre_producto,    
		   _prima,           
		   _prima_nueva,     
		   _cod_agente,      
		   _nombre_agente,
		   v_filtros with resume;   

end foreach

DROP TABLE temp_carta;

end procedure