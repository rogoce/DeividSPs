-- Actualizacion Masiva polizas vigentes (Codificacion de Manzanas)

-- Creado: 29/10/2008 - Autor: Armando Moreno Montenegro

drop procedure sp_pro847;

create procedure "informix".sp_pro847(a_cod_manzana char(15), a_poliza char(20) default '*')
 returning  char(3),		--cobertura
			char(5),		--contrato
			decimal(16,2),	--suma
			decimal(16,2),	--prima
			char(50),		--no_documento
			char(50);		--no_documento

define _no_poliza		  char(10);
define v_prima1	      	  dec(16,2);
define _no_unidad		  char(5);
define _suma_asegurada    dec(16,2);
define _actualizado       smallint;
define v_desc_contrato    char(50);
define v_cod_contrato     char(5);
define v_cobertura		  char(3);
define _nombre_cob        char(50);


SET ISOLATION TO DIRTY READ;

let _suma_asegurada = 0;
let v_prima1        = 0;

 CREATE TEMP TABLE tp_contratos
           (cod_contrato     CHAR(5),
			desc_contrato    CHAR(50),
            cod_cobertura    CHAR(3),
			prima            DEC(16,2),
			suma             DEC(16,2)) WITH NO LOG;

if a_poliza = '*' then

FOREACH WITH HOLD

   select no_unidad,
          no_poliza,
		  suma_asegurada
     into _no_unidad,
		  _no_poliza,
		  _suma_asegurada
	 from emipouni
	where cod_manzana MATCHES a_cod_manzana
	order by no_poliza, no_unidad

   select actualizado
     into _actualizado
     from emipomae
    where no_poliza = _no_poliza;

   if _actualizado = 0 then
	continue foreach;
   end if	

	FOREACH
	    SELECT cod_cober_reas,
	    	   cod_contrato,
	    	   prima,
			   suma_asegurada
          INTO v_cobertura,
          	   v_cod_contrato,
          	   v_prima1,
			   _suma_asegurada
          FROM emifacon
         WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
           AND no_endoso = '00000'
           AND prima <> 0

		SELECT nombre
          INTO v_desc_contrato
          FROM reacomae
         WHERE cod_contrato = v_cod_contrato;

		INSERT INTO tp_contratos
              VALUES(v_cod_contrato,
					 v_desc_contrato,
                     v_cobertura,
                     v_prima1,
                     _suma_asegurada);

	END FOREACH

END FOREACH

foreach
	   select cod_cobertura,
	          cod_contrato,
			  suma,
			  prima,
			  desc_contrato
	     into v_cobertura,
			  v_cod_contrato,
			  _suma_asegurada,
			  v_prima1,
			  v_desc_contrato
		 from tp_contratos
		order by 1,2

         SELECT nombre
           INTO _nombre_cob
           FROM reacobre
          WHERE cod_cober_reas = v_cobertura;

	   RETURN v_cobertura, v_cod_contrato, _suma_asegurada, v_prima1, _nombre_cob, v_desc_contrato WITH RESUME;

end foreach


else

	let _no_poliza = sp_sis21(a_poliza);

{FOREACH WITH HOLD

   select sucursal_origen,
          no_documento,
		  actualizado,
		  vigencia_inic,
		  vigencia_final
     into _suc_origen,
	      _no_documento,
		  _actualizado,
		  _vig_ini,
		  _vig_fin
     from emipomae
    where no_poliza = _no_poliza

   if _actualizado = 0 then
	continue foreach;
   end if	

   SELECT descripcion
     INTO _n_suc_origen
     FROM insagen
    WHERE codigo_compania = "001"
      AND codigo_agencia  = _suc_origen;

	foreach
	   select no_unidad,
	          no_poliza,
			  suma_asegurada,
			  cod_asegurado,
			  tipo_incendio,
			  cod_manzana
	     into _no_unidad,
			  _no_poliza,
			  _suma_asegurada,
			  _contratante,
			  _tipo_incendio,
			  _cod_manzana
		 from emipouni
		where no_poliza = _no_poliza
		order by no_poliza, no_unidad

	   SELECT nombre
	     INTO v_asegurado
	     FROM cliclien
	    WHERE cod_cliente = _contratante;

	   SELECT referencia
	     INTO _referencia
	     FROM emiman05
	    WHERE cod_manzana = _cod_manzana;

	   RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,
	          _suc_origen,_n_suc_origen,_suma_asegurada,_tipo_incendio,_vig_ini,_vig_fin  WITH RESUME;

	end foreach

END FOREACH	 }

end if
DROP TABLE tp_contratos;
end procedure