--Caso 14270   Pólizas con Cese de Coberturas
--Armando Moreno M. 10/07/2025

DROP procedure sp_cob434;
CREATE procedure sp_cob434(a_cia CHAR(3), a_codsucursal CHAR(255) DEFAULT "*", a_codgrupo CHAR(255) DEFAULT "*", a_codramo CHAR(255) DEFAULT "*",
                           a_periodo CHAR(7), a_periodo2 CHAR(7), a_codagente CHAR(255) DEFAULT "*", a_codvend CHAR(255) DEFAULT "*")
RETURNING char(20),                 
          char(5),                  
		  char(50),                 
		  char(3),                  
		  char(50),                 
		  char(50), --subramo       
		  char(10),                 
		  char(50),                 
		  char(5),                  
		  char(50), --n_producto    
		  date,
		  date,                     
		  char(3),                  
		  char(8),                  
		  char(50),                 
		  char(10),                 
		  dec(16,2),                
		  char(7),                  
		  char(25),                 
		  char(25),                 
		  char(50),                 
		  char(8),                  
		  char(50),                 
		  char(50),                 
		  dec(16,2),                
		  char(50),                 
		  decimal(16,2),            
		  decimal(16,2),            
		  char(50),                 
		  date,                      
		  char(25),                 
          varchar(255);             

define _periodo                                    char(7);
define _cod_ramo,_tipo_cliente,v_codsucursal,_cod_endomov,_cod_no_renov,_cod_subramo      char(3);
define _n_subramo,_n_ramo,_n_contratante,_n_grupo,_n_corredor,v_descr_cia char(50);
define _cod_grupo,_cod_agente,_cod_producto,v_codigo                      char(5);
define _suc_prom,_cod_vendedor,_cod_sucursal,_cod_formapag,_cod_cobrador                               char(3);
define _cod_contratante,_no_factura,_no_poliza,_no_endoso,_cod_asegurado char(10);
define _no_documento                               char(20);
define _tipo 									   char(1);
define _prima_sus,_prima_cese,_prima_bruta,_cobros,_saldo    dec(16,2);
define _vig_ini_p,_vig_fin_p,_fecha_emision,_fecha_susc_end        date;
define v_filtros                                   varchar(255);
define _tipo_agente,_tipo_poliza,_user_added           char(8);
define _n_producto,_n_asegurado,_nombre_vendedor,v_corredor,_forma_pago    char(50);
define _n_endomov,_n_no_renov,_zona_cobros,_user_added_desc         char(25);
define v_saber		     											CHAR(2);
define _cnt smallint;

--SET DEBUG FILE TO "sp_cob434";
--TRACE ON;


CREATE TEMP TABLE tmp_cese
                (no_documento     CHAR(20),
                 cod_grupo        CHAR(5),
				 n_grupo          char(50),
                 cod_ramo         CHAR(3),
				 n_ramo           char(50),
				 subramo          char(45),
                 cod_sucursal     CHAR(3),
                 cod_contratante  CHAR(10),
				 n_contratante    char(50),
				 cod_endomov      CHAR(3),
                 no_factura       CHAR(10),
                 prima_suscrita   DEC(16,2),
                 prima_bruta      DEC(16,2),
                 prima_cese       DEC(16,2),
				 no_poliza        CHAR(10),
				 no_endoso        CHAR(5),
				 vig_ini		  DATE,
				 vig_fin		  DATE,
				 cod_agente       CHAR(5),
                 seleccionado     SMALLINT DEFAULT 1,
                 cod_vendedor	  CHAR(3), 
                 nombre_vendedor  CHAR(50),       -- nombre vendedor				 
				 user_added       CHAR(10),
				 periodo          char(7),
				 cod_no_renov     char(3),
				 fecha_emision    date
				 );
   CREATE INDEX i_cancela1 ON tmp_cese(cod_grupo,cod_ramo,no_factura);
   CREATE INDEX i_cancela2 ON tmp_cese(cod_sucursal);
   CREATE INDEX i_cancela3 ON tmp_cese(cod_ramo);
   CREATE INDEX i_cancela4 ON tmp_cese(cod_grupo);


LET v_filtros = "";
LET v_descr_cia = sp_sis01(a_cia);
foreach
	select p.cod_grupo,
		   y.nombre,
		   p.cod_ramo,
		   h.nombre,
		   p.cod_contratante,
		   c.nombre,
		   p.no_documento,
		   e.no_factura,
		   e.prima_suscrita,
		   p.prima_bruta,
		   e.periodo,
		   p.vigencia_inic,
		   p.vigencia_final,
		   e.vigencia_inic,
		   --decode(p.estatus_poliza,1,"Vigente",2,"Cancelada",3,"Vencida",4,"Anulada"),
		   g.cod_agente,
		   e.fecha_emision,
		   p.cod_sucursal,
		   e.cod_endomov,
		   e.prima_bruta,
		   e.no_poliza,
		   e.no_endoso,
		   e.user_added,
		   p.cod_subramo,
		   p.cod_no_renov
	  into _cod_grupo,
	       _n_grupo,
		   _cod_ramo,
		   _n_ramo,
		   _cod_contratante,
		   _n_contratante,
		   _no_documento,
		   _no_factura,
		   _prima_sus,
		   _prima_bruta,
		   _periodo,
		   _vig_ini_p,
		   _vig_fin_p,
		   _fecha_emision,
		   --_estaus_poliza,
		   _cod_agente,
		   _fecha_susc_end,
		   v_codsucursal,
		   _cod_endomov,
		   _prima_cese,
		   _no_poliza,
		   _no_endoso,
		   _user_added,
		   _cod_subramo,
		   _cod_no_renov
      from endedmae e, emipomae p, emipoagt g, cligrupo y, prdramo h, cliclien c
     where e.no_poliza = p.no_poliza
       and p.no_poliza = g.no_poliza
       and p.cod_grupo = y.cod_grupo
	   and p.cod_ramo  = h.cod_ramo
	   and p.cod_contratante = c.cod_cliente
	   and e.actualizado = 1
	   and p.actualizado = 1
	   and e.cod_endomov = '032'
	   and e.periodo between a_periodo And a_periodo2
	   
	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = v_codsucursal
	   and codigo_compania = a_cia;

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _suc_prom
	   and cod_ramo	   = _cod_ramo;
		
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;
	 
	select nombre
	  into _n_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	   

       INSERT INTO tmp_cese
       VALUES(
       _no_documento,
       _cod_grupo,
	   _n_grupo,
       _cod_ramo,
	   _n_ramo,
	   _n_subramo,
       v_codsucursal,
       _cod_contratante,
	   _n_contratante,
	   _cod_endomov,
       _no_factura,
       _prima_sus,
       _prima_bruta,
	   _prima_cese,
      _no_poliza,
	  _no_endoso,
	  _vig_ini_p,
	  _vig_fin_p,
	  _cod_agente,
      1,
	  _cod_vendedor,
      _nombre_vendedor,
	  _user_added,
	  _periodo,
	  _cod_no_renov,
	  _fecha_susc_end
      );
end foreach	  
-- Filtro de Agencia
      LET v_filtros = " ";
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      -- Filtro de Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      -- Filtro de Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cese
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
	  --Filtro de Agente
	IF a_codagente <> "*" THEN
		LET _tipo = sp_sis04(a_codagente);  -- Separa los Valores del String en una tabla de codigos
	   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_codagente);
		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE tmp_cese
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       	   LET v_saber = "";
		ELSE		        -- Excluir estos Registros
			UPDATE tmp_cese
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	           LET v_saber = " Ex";
		END IF
	    FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
		      INTO v_corredor,v_codigo
		      FROM agtagent,tmp_codigos
		     WHERE agtagent.cod_agente = codigo
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_corredor) || (v_saber);
	    END FOREACH
		DROP TABLE tmp_codigos;
	END IF
	IF a_codvend <> "*" THEN   -- Aplica Filtro de Zona 
		LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
		LET v_filtros = TRIM(v_filtros) ||" Zona :"; --||TRIM(a_codvend);
		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE tmp_cese
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = "";
		ELSE
			UPDATE tmp_cese
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = " Ex";
		END IF
	    FOREACH
			SELECT Distinct tmp_cese.nombre_vendedor,tmp_codigos.codigo
		      INTO _nombre_vendedor,v_codigo
		      FROM tmp_cese,tmp_codigos
		     WHERE tmp_cese.cod_vendedor = codigo
			 
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(_nombre_vendedor) || (v_saber);
	    END FOREACH		
		DROP TABLE tmp_codigos;
	END IF	
foreach
	select no_documento,               
		   cod_grupo,                  
		   n_grupo,                    
		   cod_ramo,                   
		   n_ramo,                     
		   subramo,                    
		   cod_sucursal,               
		   cod_contratante,            
		   n_contratante,              
		   cod_endomov,                
		   no_factura,                 
		   prima_suscrita,             
		   prima_bruta,                
		   prima_cese,                 
		   no_poliza,                  
		   no_endoso,                  
		   vig_ini,                    
		   vig_fin,                    
		   cod_agente,                 
		   cod_vendedor,               
		   nombre_vendedor,            
		   user_added,                 
		   periodo,                    
		   cod_no_renov,               
		   fecha_emision
	  into _no_documento,
           _cod_grupo,
		   _n_grupo,
		   _cod_ramo,
		   _n_ramo,
		   _n_subramo,
		   _cod_sucursal,
		   _cod_contratante,
		   _n_contratante,
		   _cod_endomov,
		   _no_factura,
		   _prima_sus,
		   _prima_bruta,
		   _prima_cese,
		   _no_poliza,
		   _no_endoso,
		   _vig_ini_p,
		   _vig_fin_p,
		   _cod_agente,
		   _cod_vendedor,
		   _nombre_vendedor,
		   _user_added,
		   _periodo,
		   _cod_no_renov,
		   _fecha_susc_end
	  from tmp_cese
     where seleccionado = 1

	--Producto
	foreach
		select cod_producto,cod_cliente
		  into _cod_producto,_cod_asegurado
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
			
		exit foreach;
	end foreach

	select cod_formapag
	  into _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
	  into _n_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	select nombre
	  into _forma_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	
	-- Tipo Cliente
	select count(*)
	  into _cnt
	  from clivip
	 where cod_cliente = _cod_contratante;
		
	if _cnt is null THEN
		let _cnt = 0;
	end if
	if _cnt > 0 then 	--es VIP
		let _tipo_cliente = "VIP";
	ELSE
		let _tipo_cliente = "";
	end if

	--Asegurado
    SELECT nombre
      INTO _n_asegurado
      FROM cliclien
     WHERE cod_cliente = _cod_asegurado;
		  
	select cod_subramo,
	       decode(nueva_renov,"N","NUEVA","R","RENOVADA"),
		   cod_formapag
	  into _cod_subramo,
	       _tipo_poliza,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
	  into _n_endomov
	  from endtimov
	 where cod_endomov = _cod_endomov;
	 
	select nombre
	  into _n_no_renov
	  from eminoren
	 where cod_no_renov = _cod_no_renov;
	 
	select decode(tipo_agente,"A","Agente","O","Oficina","E","Especial"),
	       cod_cobrador,
		   nombre
	  into _tipo_agente,
	       _cod_cobrador,
		   _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente; 

	select nombre into _zona_cobros from cobcobra
	where cod_cobrador = _cod_cobrador;
	
	select trim(upper(descripcion))
      into _user_added_desc 
      from insuser 
	 where usuario = _user_added;

	
	let _saldo = 0;
	let _saldo = sp_cob174(_no_documento);

	return _no_documento,
	       _cod_grupo,
		   _n_grupo,
		   _cod_ramo,
		   _n_ramo,
		   _n_subramo,
		   _cod_contratante,
		   _n_contratante,
		   _cod_producto,
		   _n_producto,
	       _vig_ini_p,
		   _vig_fin_p,
		   _tipo_cliente,
		   _tipo_poliza,
		   _n_asegurado,
		   _no_factura,
		   _prima_sus,
		   _periodo,
		   _n_endomov,
		   _n_no_renov,
		   _n_corredor,
		   _tipo_agente,
		   _nombre_vendedor,
		   _forma_pago,
		   _prima_bruta,
		   _zona_cobros,
		   _prima_cese,
		   _saldo,
		   v_descr_cia,
		   _fecha_susc_end,
		   _user_added_desc,
		   v_filtros 
		   with resume;
	
end foreach
drop table tmp_cese;
END PROCEDURE;