-- Actualizacion Masiva polizas vigentes (Codificacion de Manzanas)

-- Creado: 08/10/2008 - Autor: Armando Moreno Montenegro

drop procedure sp_pro844;

create procedure "informix".sp_pro844()
 returning  char(10),		--no_poliza
			char(5),		--no_unidad
			char(20),		--no_documento
			char(100),  	--asegurado
			char(15),		--cod_manzana
			char(50),		--referencia
			char(3),		--sucursal_origen
			char(30),   	--nombre suc origen
			decimal(16,2),	--suma asegurada
			integer;

define _no_poliza		  char(10);
define _contratante	      char(10);
define _no_unidad		  char(5);
define _fecha       	  date;
define v_asegurado		  char(100);
define _no_documento      char(20);
define v_filtros          char(255);
define _cod_manzana		  char(15);
define _suc_origen		  char(3);
define _n_suc_origen	  char(30);
define _referencia        char(50);
define _suma_asegurada    dec(16,2);
define _tipo_inc          integer;

SET ISOLATION TO DIRTY READ;

let _fecha = CURRENT;
let _suma_asegurada = 0;

CALL sp_pro03("001","001",_fecha,"001,003;") RETURNING v_filtros;

    FOREACH WITH HOLD

       SELECT y.no_documento,
              y.cod_contratante,
			  y.no_poliza
         INTO _no_documento,
              _contratante,
              _no_poliza
         FROM temp_perfil y
        WHERE y.seleccionado = 1
     ORDER BY y.cod_ramo,y.no_documento

       SELECT nombre
         INTO v_asegurado
         FROM cliclien
        WHERE cod_cliente = _contratante;

       SELECT sucursal_origen
         INTO _suc_origen
         FROM emipomae
        WHERE no_poliza = _no_poliza;

       SELECT descripcion
         INTO _n_suc_origen
         FROM insagen
        WHERE codigo_compania = "001"
          AND codigo_agencia  = _suc_origen;
	   
		foreach
		   select no_unidad,
		          cod_manzana,
				  suma_asegurada,
				  tipo_incendio
		     into _no_unidad,
				  _cod_manzana,
				  _suma_asegurada,
				  _tipo_inc
			 from emipouni
			where no_poliza = _no_poliza
		 order by no_unidad

		   if _cod_manzana is not null then
		       SELECT referencia
		         INTO _referencia
		         FROM emiman05
		        WHERE cod_manzana = _cod_manzana;
		   else
			let _referencia = "";
		   end if

	       RETURN _no_poliza, _no_unidad, _no_documento, v_asegurado, _cod_manzana,_referencia,_suc_origen,_n_suc_origen,_suma_asegurada,_tipo_inc  WITH RESUME;

		end foreach

    END FOREACH

DROP TABLE temp_perfil;

end procedure