-- Carta de Cambio de Tarifa 2006-2007 

-- Creado: 07/08/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro170_dw1 - DEIVID, S.A.
-- SIS v.2.0 - d_prod_sp_pro76_crit - DEIVID, S.A.

drop procedure sp_pro506;
create procedure sp_pro506(a_periodo char(7), a_codagente CHAR(255) DEFAULT "*") 
returning char(3),
		  varchar(50),
          dec(16,2),
          dec(16,2),
          char(255);


define _no_documento     char(20);
define _cod_producto     char(5);
define _cod_producto_n   char(5);
define _prima            dec(16,2);
define _prima_nueva      dec(16,2);
define _vigencia_inic    date;
define _vigencia_final   date;
define _cod_agente       char(5);
define _nombre_agente    varchar(50);
define _cod_asegurado    char(10);
define _nombre_asegurado varchar(100);
define _no_poliza        char(10);
define _nombre_producto, _nombre_producto_n  varchar(50);
define v_filtros         char(255);
define _tipo             char(1);
define _cod_subramo      char(3);

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
	cod_producto_n   char(5),
	cod_subramo      char(3),
    seleccionado     SMALLINT DEFAULT 1 NOT NULL) WITH NO LOG;


set isolation to dirty read;


--set debug file to "sp_pro506.trc";
--trace on;

foreach
	SELECT no_documento,   
	       cod_producto,   
	       prima,
		   cod_subramo
	  INTO _no_documento,
	       _cod_producto,
	       _prima,
	       _cod_subramo   
	  FROM emicartasal  
	 WHERE periodo = a_periodo
	   AND cod_subramo in ('007','009','013','016')  
  ORDER BY no_documento ASC
	
    LET _no_poliza   = sp_sis21(_no_documento);
    call sp_pro503b(_no_documento) returning _cod_producto_n, _prima_nueva;

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
		   _cod_producto_n, 
		   _cod_subramo,
		   1);

end foreach

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
	select cod_subramo,
		   sum(prima),           
		   sum(prima_nueva)     
	  into _cod_subramo,
		   _prima,           
		   _prima_nueva     
	  from temp_carta
	 where seleccionado = 1	
  group by 1				   

	select nombre
	  into _nombre_producto
	  from prdsubra
	 where cod_ramo = '018'
	   and cod_subramo = _cod_subramo;

    return _cod_subramo,
		   _nombre_producto,    
		   _prima,           
		   _prima_nueva,
		   v_filtros with resume;   

end foreach

DROP TABLE temp_carta;

end procedure