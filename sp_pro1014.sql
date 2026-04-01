--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_pro1014;
create procedure "informix".sp_pro1014(
a_cia			char(3),
a_agencia		char(3),
a_fecha			date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "018;",
a_codgrupo		char(255)	default "*",
a_agente		char(255)	default "*",
a_usuario		char(255)	default "*",
a_cod_cliente	char(255)	default "*",
a_acreedor		char(255)	default "*",
a_no_documento	char(255)	default "*")

returning	char(20),		--_no_documento
			char(45),		--v_asegurado
			date,			--v_vigencia_inic
			date,			--v_vigencia_final
			dec(16,2),		--v_prima_suscrita
			char(50),		--v_descr_cia
			dec(16,2),		--v_prima_bruta
			varchar(50);
			

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
define _cod_asegurado_uni   char(10);
define v_asegurado_uni      varchar(50);
define v_fecha_nac_uni      date;
define _cod_agente          char(5);
define v_corredor           varchar(50);
define _nueva_renov         char(1);

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
let v_corredor = '';

set isolation to dirty read;

let v_descr_cia = sp_sis01(a_cia);

set isolation to dirty read;

foreach with hold
	select y.no_documento,
		   y.cod_ramo,
		   y.cod_contratante,
		   y.vigencia_inic,
		   y.vigencia_final,
		   y.prima_suscrita,
		   y.prima_bruta
	  into _no_documento,
		   v_cod_ramo,
		   v_contratante,
		   v_vigencia_inic,
		   v_vigencia_final,
		   v_prima_suscrita,
		   v_prima_bruta
	  from emipomae y
	 where y.actualizado = 1
	   and y.cod_ramo = "018"
	   and y.nueva_renov = 'N'
	   and vigencia_inic between '01/01/2015' and '31/12/2015'
	 order by y.no_documento
	 
	 let _no_poliza = sp_sis21(_no_documento);	

	select nombre,
	       fecha_aniversario
	  into v_asegurado,
		   v_fecha_nac
	  from cliclien
	 where cod_cliente = v_contratante;
	 
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		exit foreach;
	end foreach
	
	select nombre
	  into v_corredor
	  from agtagent
	 where cod_agente = _cod_agente;


	return	_no_documento,
			v_asegurado,
			v_vigencia_inic,
			v_vigencia_final,
			v_prima_suscrita,
			v_descr_cia,
			v_prima_bruta,
			v_corredor			with resume;
			
end foreach

end procedure;