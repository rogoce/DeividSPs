-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv11;
create procedure sp_reainv11()
returning char(10), char(20),dec(16,2),dec(16,2),date,smallint;
		  	

define _no_poliza char(10);
define _no_documento char(20);
define _cnt,_cnt2 integer;
define _suma_otr,_suma  dec(16,2);
define _tipo_cont,_tipo       smallint;
define _cod_cober_reas  char(3);
define _periodo         char(7);
define _vig_inic        date;

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";
let _suma = 0;
{foreach
	select distinct emi.no_poliza,emi.no_documento,emi.vigencia_inic,emi.periodo
	  into _no_poliza,_no_documento,_vig_inic,_periodo
	  from camrea cam
	 right join emipomae emi on emi.no_poliza = cam.no_poliza
	 inner join emipouni uni on uni.no_poliza = emi.no_poliza --and uni.suma_asegurada > 500000
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 inner join emifacon rea on rea.no_poliza = uni.no_poliza and rea.no_unidad = uni.no_unidad and rea.cod_contrato = '00712' and rea.suma_asegurada < 499900 and rea.porc_partic_prima < 100
	 where emi.cod_ramo in ('001','003')
	   and emi.actualizado = 1
	   and emi.vigencia_inic >= '01/07/2021'
	   and emi.estatus_poliza = 1
	   and cam.no_poliza is null
	   and sub.nombre not like 'ZONA%'
   
	insert into camrea(
	no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo)
	values(_no_poliza,'',0,'',_periodo,_no_documento,3);

end foreach}
foreach
	select no_poliza
	  into _no_poliza
	  from camrea
	 where tipo = 3 
  
	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza = _no_poliza
	   and no_endoso <> '00000'
	   and cod_endomov not in('024','025','002','003')
	   and suma_asegurada <> 0;

	return _no_poliza, '',0,0,'01/01/1900',_cnt;
end foreach
end 
end procedure;