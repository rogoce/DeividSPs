-- Informe Para Demetrio Solo Vida Vigentes 

-- Creado    : 04/07/2007 - Autor: Rub‚n Arn ez

-- SIS v.2.0 - DEIVID, S.A.

 --DROP PROCEDURE sp_pro183;

create procedure sp_pro183(a_ano char(4))
returning 
		  CHAR(10),       -- 1  NUMERO DE POLIZA
          CHAR(20),	      -- 2  NUMERO DE DOCUMENTO
          CHAR(10),		  -- 3  NUMERO DE FACTURA 
		  CHAR(3),        -- 4  COD RAMO   
		  CHAR(3),		  -- 5  COD SUBRAMO
		  CHAR(3),		  -- 6  COD SUCURSAL
		  CHAR(05),	      -- 7  COD GRUPO
		  CHAR(3),   	  -- 8  cod tipo de producto
		  CHAR(10),		  -- 9  COD CONTRATANTE
		  CHAR(05),		  -- 10  COD AGENTE 
		  DECIMAL(16,2),  -- 11 PRIMAR SUSCRITA
		  DECIMAL(16,2),  -- 12 PRIMA RETENIDA
		  DATE,			  -- 13 VIGENCIA INCICIAL
		  DATE,			  -- 14 VIGENCIA FINAL
		  DATE,			  -- 15 fecha de suscripcion
		  CHAR(08),       -- 16 USUARIO
		  DECIMAL(16,2),  -- 17 SUMA ASEGURADA 
		  CHAR(50),	      -- 18 Nombre del Subramo
		  CHAR(50),       -- 19 Nombre del Subramo
          char(100);      -- 20 Nombre de Asegurado
		  
define _fecha			date;
define _nombre_ramo		char(50);
define _nombre_subramo  char(50);     
define v_filtros        char(255);
define _compania		char(3);
define v_status         char(1);
define v_cod_ramo		char(3);
define v_cod_subramo    char(3);

DEFINE _cod_ramo,_cod_subramo,_cod_sucursal,_cod_tipoprod  CHAR(3);
DEFINE _no_poliza,_no_factura    CHAR(10);
DEFINE _no_documento             CHAR(20);
DEFINE _cod_grupo                CHAR(05);
DEFINE _contratante              CHAR(10);
DEFINE _cod_agente               CHAR(05);
DEFINE _prima_suscrita,_prima_retenida,_suma_asegurada DECIMAL(16,2);
DEFINE _vigencia_inic,_vigencia_final,_fecha_suscrip   DATE;
DEFINE _filtros          CHAR(255);
DEFINE _porc_partic      DECIMAL(5,2);
DEFINE _tipo             CHAR(01);
DEFINE _usuario          CHAR(08);
DEFINE mes               SMALLINT;
DEFINE mes1              CHAR(02);
DEFINE ano               CHAR(04);
DEFINE periodo1          CHAR(07);
define _no_unidad		char(5);
define v_no_unidad		char(5);
define _cod_asegurado   char(10);
define _nombre_aseg		char(100);

DEFINE _fecha_emision, _fecha_cancelacion DATE;

SET ISOLATION TO DIRTY READ;

let _fecha = MDY(12,31,a_ano);

create temp table tmp_onlylife(
no_poliza         CHAR(10),		    --1
no_documento   	  CHAR(20),		    --2
no_factura     	  CHAR(10),		    --3
cod_ramo       	  CHAR(3),		    --4
cod_subramo    	  CHAR(3),		    --5
cod_sucursal   	  CHAR(3),		    --6
cod_grupo         CHAR(5),		    --7
cod_tipoprod      CHAR(3),		    --8
cod_contratante   CHAR(10),		    --9
cod_agente        CHAR(5),		    --10
prima_suscrita    DEC(16,2),	    --11
prima_retenida    DEC(16,2),	    --12
vigencia_inic     DATE,			    --13
vigencia_final    DATE,			    --14
fecha_suscripcion DATE,			    --15
usuario           CHAR(08),		    --16
suma_asegurada    DEC(16,2),	    --17
seleccionado      SMALLINT DEFAULT 1,--18
nombre_aseg		  char(100) 		--19
) with no log;

LET _cod_ramo       = "018";
LET _cod_sucursal   = NULL;
LET _cod_subramo    = NULL;
LET _cod_grupo      = NULL;
LET _cod_tipoprod   = NULL;
LET _cod_agente     = NULL;
LET _prima_suscrita = 0;
LET _prima_retenida = 0;
LET _filtros        = " ";
LET _tipo           = NULL;
LET _no_documento   = NULL;
LET _no_factura     = NULL;
LET _no_poliza      = NULL;

-- Polizas Vigentes al 2007	solo de Vida
call sp_pro03("001", "001", _fecha, "*") RETURNING v_filtros;
   foreach 
 		   SELECT no_poliza,
          		  no_documento,
          		  no_factura,
          		  cod_sucursal,
                  cod_ramo,
                  cod_subramo,
				  cod_grupo,
                  cod_tipoprod,
                  cod_contratante,
				  cod_agente
                  prima_suscrita,
                  prima_retenida,
                  vigencia_inic,
                  vigencia_final,
                  fecha_suscripcion,
                  usuario,
                  suma_asegurada
             INTO _no_poliza,
             	  _no_documento,
             	  _no_factura,
             	  _cod_sucursal,
				  _cod_ramo,
                  _cod_subramo,
				  _cod_grupo,
                  _cod_tipoprod,
                  _contratante,
                  _prima_suscrita,
                  _prima_retenida,
                  _vigencia_inic,
                  _vigencia_final,
                  _fecha_suscrip,
                  _usuario,
                  _suma_asegurada
		   	from  temp_perfil 
		   	where cod_ramo =_cod_ramo

		    select nombre
			  into _nombre_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;
			 	
			select nombre
			  into _nombre_subramo
			  from prdsubra
			 where cod_ramo    = _cod_ramo
			   and cod_subramo = _cod_subramo;

	   foreach
			 select no_unidad,
			        cod_asegurado
			   into v_no_unidad,
					_cod_asegurado
		       from emipouni
		      where no_poliza   = _no_poliza

				select nombre
        	      into _nombre_aseg
        		  from cliclien 
       			 where cod_cliente = _cod_asegurado;
			   	
		
			INSERT INTO tmp_onlylife(
		           no_poliza,
          	       no_documento,
          	       no_factura,
          	       cod_ramo,
                   cod_subramo,
			       cod_sucursal,
                   cod_grupo,
                   cod_tipoprod,
                   cod_contratante,
				   cod_agente,
                   prima_suscrita,
                   prima_retenida,
                   vigencia_inic,
                   vigencia_final,
                   fecha_suscripcion,
                   usuario,
                   suma_asegurada,
				   nombre_aseg
                   )
             VALUES(_no_poliza,
                   _no_documento,
                   _no_factura,
                   _cod_ramo,
                   _cod_subramo,
                   _cod_sucursal,
                   _cod_grupo,
                   _cod_tipoprod,
                   _contratante,
                   _cod_agente,
                   _prima_suscrita,
                   _prima_retenida,
                   _vigencia_inic,
                   _vigencia_final,
                   _fecha_suscrip,
                   _usuario,
                   _suma_asegurada,
				   _nombre_aseg
                   );
		   return 
		   _no_poliza,          
           _no_documento,		
           _no_factura,			
           _cod_ramo,			
           _cod_subramo,		
           _cod_sucursal,		
           _cod_grupo,			
           _cod_tipoprod,		
           _contratante,		
           _cod_agente,			
           _prima_suscrita,		
           _prima_retenida,		
           _vigencia_inic,		
           _vigencia_final,		
           _fecha_suscrip,		
           _usuario, 			
           _suma_asegurada,		
		   _nombre_subramo,		
		   _nombre_ramo,
		   _nombre_aseg		
		   with resume;
   
   	end foreach
   end foreach
drop table temp_perfil;
drop table tmp_onlylife;
end procedure;