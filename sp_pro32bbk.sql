--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

--drop procedure sp_pro32bbk;
create procedure "informix".sp_pro32bbk(
a_cia			char(3),
a_agencia		char(3),
a_fecha			date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_agente		char(255)	default "*",
a_usuario		char(255)	default "*",
a_cod_cliente	char(255)	default "*",
a_acreedor		char(255)	default "*",
a_no_documento	char(255)	default "*")

returning	char(10);

define _nom_parentesco		varchar(50);
define _nom_forma_pag		varchar(50);
define _cedula_depen		varchar(30);
define v_filtros			char(255);
define v_desc_agente		char(50);
define v_descr_cia			char(50);
define _des_sub_ramo		char(50);
define v_desc_ramo			char(50);
define v_asegurado			char(45);
define _nom_depen			char(45);
define v_desc_grupo			char(40);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define v_contratante		char(10);
define _temp_poliza			char(10);
define _no_poliza			char(10);
define v_codigo				char(10);
define _cod_acreedor		char(5);
define v_cod_grupo			char(5);
define _no_unidad			char(5);
define _limite				char(5);
define _cod_parentesco		char(3);
define _cod_subramo         char(3);
define v_cod_sucursal		char(3);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define v_cod_ramo			char(3);
define _tipo_prod			char(3);
define v_saber				char(2);
define _tipo				char(1);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_bruta		dec(16,2);
define v_cant_polizas		integer;
define _flag_depen			smallint;
define _cnt_depen			smallint;
define _ramo_sis			smallint;
define _fecha_aniv_depen	date;
define v_vigencia_final		date;
define v_vigencia_inic		date;
define v_fecha_nac          date;
define _cod_asegurado_uni,_cod_producto   char(10);
define v_asegurado_uni      varchar(50);
define v_fecha_nac_uni      date;

--set debug file to "sp_pro32b.trc";
--trace on;

let v_cod_sucursal = null;
let v_contratante = null;
let _no_documento = null;
let v_cod_grupo = null;
let v_desc_ramo = null;
let v_descr_cia = null;
let v_cod_ramo = null;
let _tipo = null;
let v_prima_suscrita = 0;
let v_cant_polizas = 0;
let v_prima_bruta = 0;
let _flag_depen = 0;
let _nom_forma_pag = '';
let _des_sub_ramo = '';
let v_fecha_nac = '';
let v_asegurado_uni = '';
let v_fecha_nac_uni = '';

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);
call sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) returning v_filtros;

set isolation to dirty read;

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
		   _no_poliza
	  from temp_perfil y
	 where y.seleccionado = 1
	   and y.cod_ramo = '018'
	 order by y.cod_ramo,y.no_documento

		select cod_subramo
		  into _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _cod_subramo in('008','007','017','009','016','018') then
		else
			continue foreach;
		end if
		
		 select nombre
		   into _des_sub_ramo
		   from prdsubra 
		  where cod_ramo = v_cod_ramo
		    and cod_subramo = _cod_subramo;
		 
		foreach
			select distinct cod_producto
			  into _cod_producto
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1
			 
					
			return _cod_producto with resume;
		end foreach
end foreach
drop table temp_perfil;
end procedure;