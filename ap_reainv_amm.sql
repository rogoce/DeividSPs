-- Procedimiento que carga la tabla camrea con registros para realizar cambios referente a reaseguro.
-- 
-- Creado    : 21/11/2022 - Autor: Armando Moreno Montenegro
--
drop procedure ap_reainv_amm;
create procedure ap_reainv_amm()
returning char(10), char(20),char(4);
		  	

define _no_poliza    char(10);
define _no_documento char(20);
define _cnt 		 integer;
define _serie 		 char(4);
define _no_unidad    char(5);
define _no_poliza2   char(10);

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";

--NOTA: SE DEBE REVISAR EL PROCEDIMIENTO SP_1REAINV_AMM PARA BUSCAR RASTROS DE REGISTROS EN EMIREACO CON ESOS CONTRATOS Y CAMBIARLOS.

foreach
	select distinct emi.no_poliza, emi.no_documento, emi.serie, rea.no_unidad
	  into _no_poliza, _no_documento, _serie, _no_unidad
	  from emipomae emi
	inner join endedmae fac on fac.no_poliza = emi.no_poliza
	inner join emifacon rea on rea.no_poliza  = fac.no_poliza and rea.no_endoso = fac.no_endoso
	inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
	where emi.cod_ramo in ('002','020','023')
	   and fac.periodo >= '2024-05'
	   and fac.actualizado = 1
	   and rea.porc_partic_prima <> 5
	union all	 
	select distinct emi.no_poliza, emi.no_documento, emi.serie, rea.no_unidad
	  from emipomae emi
	inner join endedmae fac on fac.no_poliza = emi.no_poliza
	inner join emifacon rea on rea.no_poliza  = fac.no_poliza and rea.no_endoso = fac.no_endoso
	inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 5
	where emi.cod_ramo in ('002','020','023')
	   and fac.periodo >= '2024-05'
	   and fac.actualizado = 1
	   and rea.porc_partic_prima <> 95
	order by 1
	
	--NOTA: SE DEBE REVISAR EL PROCEDIMIENTO SP_1REAINV_AMM PARA BUSCAR RASTROS DE REGISTROS EN EMIREACO CON ESOS CONTRATOS Y CAMBIARLOS.

{	foreach
		select no_poliza,
			   no_documento,
			   serie
		  into _no_poliza,
			   _no_documento,
			   _serie		   
		  from emipomae
		 where no_poliza = _no_poliza2

		foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza}
			 
			return  _no_poliza,_no_documento,_serie with resume;
			
			select count(*)
			  into _cnt
			  from camrea
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			 
			if _cnt is null THEN
				let _cnt = 0;
			end if	
			
			if _cnt = 0 then 
				insert into camrea(
				no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
				values(_no_poliza,_no_unidad,0,'',_serie,_no_documento,1,today);
			end if
	--	end foreach

--	end foreach
end foreach
end 
end procedure;
