--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

--drop procedure sp_pro32bbk1;
create procedure sp_pro32bbk1()
returning	char(3),char(10),varchar(50),char(5),varchar(50);


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
define _cod_cobertura       char(5);
define v_asegurado_uni      varchar(50);
define _n_prod,_n_cobertura              varchar(50);
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
let _n_cobertura = '';
let v_fecha_nac = '';
let v_asegurado_uni = '';
let v_fecha_nac_uni = '';

set isolation to dirty read;

set isolation to dirty read;

foreach with hold
select cod_producto,nombre,cod_subramo
  into _cod_producto,_n_prod,_cod_subramo
  from prdprod
 where cod_ramo = '018' 
   and cod_producto in('04430',
'04419',
'04432',
'04421',
'04425',
'04720',
'04406',
'04409',
'04410',
'04452',
'04426',
'04728',
'04724',
'04423',
'04722',
'04414',
'04708',
'04428',
'04729',
'04459',
'04424',
'04732',
'04734',
'04719',
'04463',
'04413',
'04422',
'04448',
'04412',
'04716',
'04472',
'04434',
'04744',
'04474',
'01821',
'03181',
'04433',
'03150',
'04740',
'04742',
'04752',
'04730',
'04418',
'04408',
'04435',
'04429',
'04726',
'04712',
'01909',
'04465',
'04457',
'03163',
'01914',
'04416',
'01946',
'04431',
'00832',
'04721',
'04718',
'04711',
'04456',
'04420',
'02269',
'04427',
'03153',
'04415',
'04710',
'04411',
'04407',
'04725',
'04736',
'04714',
'03650',
'04741',
'04462',
'04477',
'04723',
'03156',
'04748',
'04709',
'04468',
'04717',
'02273',
'03165',
'04727',
'03188',
'04417',
'03520',
'04715',
'04398',
'03139',
'03162',
'03771',
'04395',
'03146',
'04397',
'05231',
'05172',
'04402',
'04396',
'05154',
'04400',
'05234',
'05233',
'04399',
'05232')
order by cod_subramo

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from prdcobpd
		 where cod_producto = _cod_producto
		 
		select nombre
		  into _n_cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;
		 
		return _cod_subramo,_cod_producto,_n_prod,_cod_cobertura,_n_cobertura with resume;
		 
	end foreach	 
		 
end foreach
end procedure;