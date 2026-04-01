--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

--drop procedure sp_armando2;
create procedure "informix".sp_armando2()
returning	char(3),
			char(50),
			char(20),
			char(5),
			char(45),
			date,
			date;

define v_desc_ramo		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define _temp_poliza		char(10);
define v_contratante	char(10);
define v_codigo			char(10);
define _cod_acreedor	char(5);
define v_cod_grupo		char(5);
define _limite			char(5);
define v_cod_sucursal	char(3);
define _cod_tipoprod	char(3);
define v_cod_ramo		char(3);
define _tipo_prod		char(3);
define v_saber			char(2);
define _tipo			char(1);
define v_prima_suscrita	dec(16,2);
define v_suma_asegurada	dec(16,2);
define v_prima_bruta	dec(16,2);
define v_cant_polizas	integer;
define v_vigencia_final	date;
define v_vigencia_inic	date;
define _cod_coasegur    char(3);
define _porc_coas       dec(7,4);
define _no_unidad       char(5);
define _cod_manzana     char(15);
define v_filtros        char(255);

let v_cod_sucursal   = null;
let v_contratante    = null;
let _no_documento     = null;
let v_cod_grupo      = null;
let v_desc_ramo      = null;
let v_cod_ramo       = null;
let _tipo            = null;
let v_prima_suscrita = 0;
let v_cant_polizas   = 0;
let v_prima_bruta    = 0;

set isolation to dirty read;

--let v_filtros = sp_pro03('001','001','07/12/2015','001,003;');
foreach with hold
	select y.no_documento,
		   y.cod_ramo,
		   y.cod_contratante,
		   y.vigencia_inic,
		   y.vigencia_final,
		   y.cod_grupo,
		   y.suma_asegurada,
		   y.prima_suscrita,
		   y.prima_bruta,
		   y.cod_tipoprod,
		   y.no_poliza
	  into _no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_cod_grupo,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   v_prima_bruta,
		   _cod_tipoprod,
		   _temp_poliza
	  from temp_perfil y
	 where y.seleccionado = 1
	 order by y.cod_ramo,y.no_documento

	select a.nombre
	  into v_desc_ramo
	  from prdramo a
	 where a.cod_ramo  = v_cod_ramo;

	select nombre
	  into v_asegurado
	  from cliclien
	 where cod_cliente = v_contratante;

	foreach
		select no_unidad,
		       cod_manzana
		  into _no_unidad,
		       _cod_manzana
		  from emipouni
		 where no_poliza = _temp_poliza

		if _cod_manzana is null or _cod_manzana = "" then
			return	v_cod_ramo,
					v_desc_ramo,
					_no_documento,
					_no_unidad,
					v_asegurado,
					v_vigencia_inic,
					v_vigencia_final  with resume;
		end if
	end foreach	
end foreach
--drop table temp_perfil;
end procedure;