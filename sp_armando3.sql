--POLIZAS VIGENTES POR RAMO
--Creado : 08/10/2000 - Autor: Yinia Zamora
--Modificado: 16/08/2001 -Autor: Marquelda Valdelamar (inclusion de filtro de cliente)
--Modificado: 05/09/2001 -Autor: Marquelda Valdelamarinclusion de filtro de poliza
--SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

drop procedure sp_armando3;
create procedure sp_armando3()
returning date;
--char(20),char(3),char(3),char(5);

define v_desc_ramo		char(50);
define v_asegurado		char(45);
define v_desc_grupo		char(40);
define _no_documento	char(20);
define _temp_poliza		char(10);
define v_contratante	char(10);
define _no_poliza			char(10);
define _cod_acreedor	char(5);
define v_cod_grupo		char(5);
define _limite			char(5);
define v_cod_sucursal	char(3);
define _cod_tipoprod	char(3);
define _cod_forma		char(3);
define _cod_cobrador		char(3);
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
define _cod_agente     char(5);
define v_filtros        char(255);
define _dos_anos date;


let _no_documento     = null;


set isolation to dirty read;

let _dos_anos = current - 2 units year;
 
 return _dos_anos;
 
--let v_filtros = sp_pro03('001','001','07/12/2015','001,003;');
foreach with hold
	select distinct no_documento
	  into _no_documento
	  from emipomae
where no_documento in(
'0117-00039-01',
'0117-00041-01',
'0118-00233-01',
'0119-00089-01',
'0119-00229-01',
'0119-00232-01',
'0119-00253-01',
'0120-00110-01',
'0120-00201-01',
'0120-00441-01',
'0120-00448-01',
'0121-00091-01',
'0121-00219-01',
'0121-00220-01',
'0121-00233-01',
'0121-00260-01',
'0121-00268-01',
'0121-00269-01',
'0121-00281-01',
'0121-00561-01',
'0215-00228-12',
'0215-00381-12',
'0217-01393-01',
'0217-02464-01',
'0218-00380-01',
'0218-00433-09',
'0218-01808-01',
'0218-02240-09',
'0218-02292-01',
'0218-03171-09',
'0218-03501-09',
'0218-04071-09',
'0218-04507-09',
'0218-05256-09',
'0219-00425-09',
'0219-00431-09',
'0219-01258-01',
'0219-02042-09',
'0219-02191-09',
'0219-02588-09',
'0219-02668-09',
'0219-03501-09',
'0219-05136-09',
'0220-01141-01',
'0220-01681-01',
'0221-00010-01',
'0221-00379-09',
'0221-00683-09',
'0221-00700-09',
'0221-00982-09',
'0221-01035-01',
'0221-01448-09',
'0221-01550-01',
'0221-01815-01',
'0221-01832-01',
'0221-01954-09',
'0221-01984-09',
'0221-02051-09',
'0221-02585-09',
'0221-02732-09',
'0221-03134-09',
'0316-00061-01',
'0317-00010-01',
'0317-00101-01',
'0318-00101-01',
'0319-00079-01',
'0319-00084-01',
'0321-00017-01',
'0321-00188-01',
'0322-01749-01',
'0620-00082-01',
'0620-00083-01',
'0620-00254-01',
'0620-00255-01',
'0921-01425-01',
'1806-00840-01',
'1807-00582-01',
'1809-00908-01',
'1812-00083-01',
'1812-00097-01',
'1820-00006-01',
'2220-00010-01',
'2220-00024-01',
'2316-00030-01',
'2318-00091-01',
'2319-00003-01',
'2319-00005-01',
'2319-00070-01',
'2319-00071-01',
'2319-00076-01',
'2320-00015-01',
'2320-00056-01',
'2321-00034-01',
'2321-00043-01',
'2321-00044-01',
'2321-00045-01',
'2322-00025-01')
and actualizado = 1

let _no_poliza = sp_sis21(_no_documento);

select cod_formapag
  into _cod_forma
  from emipomae
 where no_poliza = _no_poliza;
 
 let _dos_anos = current - 2 units year;
 
 return _dos_anos;
 
 foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach
 
 select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;
 
 --if _cod_forma = '006' then
 
	--return _no_documento,_cod_forma,_cod_cobrador,_cod_agente with resume;
 --end if	
end foreach
end procedure;