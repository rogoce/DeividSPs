-- Reclasificacion de Cumulos por Ubicacion a Zonas Crestas
-- 
-- Creado    : 22/04/2013 - Autor: Armando Moreno
-- Modificado: 22/04/2013 - Autor: Armando Moreno
-- 
--
--DROP PROCEDURE sp_act_tipo_incendio;

CREATE PROCEDURE "informix".sp_act_tipo_incendio()
RETURNING   smallint;

DEFINE v_filtros           		CHAR(255);
DEFINE v_ubicacion         		CHAR(50);
DEFINE v_cnt_poliza        		INT; 
DEFINE v_suma_asegurada    		DEC(16,2);
DEFINE v_retencion         		DEC(16,2);
DEFINE v_excedente         		DEC(16,2);
DEFINE v_facultativo       		DEC(16,2);
DEFINE v_prima			   		DEC(16,2);
DEFINE v_compania_nombre   		CHAR(50);

DEFINE _no_poliza          		CHAR(10);
DEFINE _no_unidad, _no_endoso	CHAR(5);
DEFINE _cod_ubica          		CHAR(3);
DEFINE _suma     		   		DEC(16,2);
DEFINE _prima    		   		DEC(16,2);
DEFINE _suma_retencion     		DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   		DEC(16,2);
DEFINE _suma_excedente     		DEC(16,2);
DEFINE _porc_partic_suma   		DEC(9,6);
DEFINE _porcentaje		   		DEC(9,6);
DEFINE _tipo_contrato      		SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   		CHAR(5);
DEFINE _mes_contable      		CHAR(2);
DEFINE _ano_contable      		CHAR(4);
DEFINE _periodo           		CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;
define _tipo_incendio           smallint;
define _cod_tipoprod			char(3);
define _cod_subramo				char(3);
define _cod_contratante			char(10);
define _n_aseg                  char(50);
define _coas                    char(3);
define _n_subra,_n_ramo         char(30);
define _cod_ramo                char(3);
define _porc_partic_coas        decimal(7,4);
define _n_dist					char(50);
define _cod_provincia           char(2);
define _cod_distrito            char(3);
define _cod_manzana             char(15);
define _cod_barrio				char(4);
define _no_documento			char(20);
define _estatus_poliza			smallint;
define _actualizado  			smallint;
define _n_prov                  char(20);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

{   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  no_poliza        CHAR(10),
		  no_documento	   CHAR(20),
          cantidad         INT,
          suma_asegurada   DEC(16,2),
		  mal_porc         CHAR(5),
		  retencion        DEC(16,2),
		  cant_ret         INT,
          primer_excedente DEC(16,2),
		  cant_exe         INT,
          facultativo      DEC(16,2),
		  cant_fac         INT,
          prima_terremoto  DEC(16,2),
		  tipo_incendio    smallint,
          PRIMARY KEY (no_poliza))
          WITH NO LOG;
						 }
-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;


FOREACH
		 SELECT	no_poliza 
		   INTO _no_poliza 
		   FROM	emipomae
		  WHERE actualizado = 1
			and cod_ramo = '003'

	   foreach

        select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza


		 update emipouni
		    set tipo_incendio  = 2
		  where no_poliza      = _no_poliza
		    and no_unidad      = _no_unidad;

		 update endeduni
		    set tipo_incendio  = 2
		  where no_poliza      = _no_poliza
		    and no_unidad      = _no_unidad;


	   end foreach

END FOREACH

return 0;					 

END PROCEDURE;
