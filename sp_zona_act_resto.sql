-- Reclasificacion de Cumulos por Ubicacion a Zonas Crestas
-- 
-- Creado    : 22/04/2013 - Autor: Armando Moreno
-- Modificado: 22/04/2013 - Autor: Armando Moreno
-- 
--
--DROP PROCEDURE sp_zona_act_resto;

CREATE PROCEDURE "informix".sp_zona_act_resto(a_zona CHAR(03), a_fecha DATE)
RETURNING   CHAR(35),  -- Ubicacion
            char(20),
			char(10),
			char(5),
			char(20),
			smallint;

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
		 SELECT	cod_ubica, 
		        no_unidad,
				no_poliza 
		   INTO _cod_ubica,
		        _no_unidad, 
				_no_poliza 
		   FROM	endcuend
		  WHERE cod_ubica = a_zona
		  order by no_poliza,no_unidad

        select cod_manzana
		  into _cod_manzana
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

        select no_documento,
		       estatus_poliza,
			   actualizado
		  into _no_documento,
		       _estatus_poliza,
			   _actualizado
		  from emipomae
		 where no_poliza = _no_poliza;

	   if _actualizado <> 1 then
			continue foreach;
	   end if

      { if _no_documento = '0108-00099-01' then
	   else
			continue foreach;
	   end if}

   		select cod_provincia,
		       cod_barrio
     	  into _cod_provincia,
		       _cod_barrio
          from emiman05
         where cod_manzana = _cod_manzana;

        select nombre
		  into _n_prov
		  from emiman01
		 where cod_provincia = _cod_provincia;

       if _cod_provincia in('01','04','09','06','07','02') then --Provincias oeste
				return 'PROVINCIAS OESTE',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

			 update emicupol
			    set cod_ubica      = '003'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

			 update endcuend
			    set cod_ubica      = '003'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

	   elif _cod_provincia = '05' then --Darien
			return 'DARIEN',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

	   elif _cod_provincia = '20' then --Intereses en el extranjero
			return 'EXTRANJERO',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

			 update emicupol
			    set cod_ubica      = '005'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

			 update endcuend
			    set cod_ubica      = '005'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

	   elif _cod_provincia = '08' then --Panama
			return 'PANAMA',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

			 update emicupol
			    set cod_ubica      = '001'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

			 update endcuend
			    set cod_ubica      = '001'
			  where no_poliza      = _no_poliza
			    and no_unidad      = _no_unidad
				and cod_ubica      = _cod_ubica;

       elif _cod_provincia = '03' then --Colon
			if _cod_barrio = '0103' then --Zona Libre
				return 'COLON ZONA LIBRE',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

				 update emicupol
				    set cod_ubica      = '006'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

				 update endcuend
				    set cod_ubica      = '006'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

			elif _cod_barrio = '4400' then --France Field
				return 'COLON ZONA LIBRE FRANCE FIELD',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

				 update emicupol
				    set cod_ubica      = '007'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

				 update endcuend
				    set cod_ubica      = '007'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

			else
				return 'RESTO PROVINCIA DE COLON',_n_prov,_no_poliza, _no_unidad,_no_documento,_estatus_poliza with resume;

				 update emicupol
				    set cod_ubica      = '002'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

				 update endcuend
				    set cod_ubica      = '002'
				  where no_poliza      = _no_poliza
				    and no_unidad      = _no_unidad
					and cod_ubica      = _cod_ubica;

			end if

	   end if

END FOREACH

END PROCEDURE;
