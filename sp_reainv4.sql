-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv4;
create procedure sp_reainv4()
returning char(10), char(20),char(7),dec(16,2),dec(16,2),date,smallint,smallint;
		  	

define _no_poliza char(10);
define _no_documento char(20);
define _cnt,_cnt2 integer;
define _suma_otr,_suma  dec(16,2);
define _tipo_cont,_tipo       smallint;
define _cod_cober_reas  char(3);
define _periodo         char(7);
define _vig_inic        date;
define _cnt_pol   		integer;            

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";
let _suma = 0;
foreach
	select no_poliza,
	       no_documento,
		   periodo,
		   vigencia_inic
	  into _no_poliza,
           _no_documento,
		   _periodo,
		   _vig_inic
      from emipomae
	 where actualizado = 1
	   and vigencia_inic between '01/07/2020' and '30/06/2021'
	   and ((cod_ramo = '001' and cod_subramo <> '006')
	   or (cod_ramo = '003' and cod_subramo <> '005'))
	   and suma_asegurada <= 500000
	 order by _no_poliza
    foreach
		select count(*)
		  into _cnt
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and t.tipo_contrato <> 1
		   
        if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
			let _cnt_pol = 0;
			
			select count(*)
			  into _cnt_pol
			  from camrea2
			 where no_poliza = _no_poliza;
			 
			if _cnt_pol is null THEN
				let _cnt_pol = 0;
			end if	
			
			if _cnt_pol = 0 then 
				insert into camrea2(
				no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
				values(_no_poliza,'',0,'',_periodo,_no_documento,1,today);
			end if	
--			return _no_poliza,_no_documento,_periodo,0,0,_vig_inic,0,1 with resume;
		end if
	end foreach
end foreach

foreach
	select no_poliza,
	       no_documento,
		   vigencia_inic,
		   periodo
	  into _no_poliza,
           _no_documento,
           _vig_inic,
		   _periodo		   
      from emipomae
	 where actualizado = 1
	   and vigencia_inic between '01/07/2020' and '30/06/2021'
	   and ((cod_ramo = '001' and cod_subramo <> '006')
	   or (cod_ramo = '003' and cod_subramo <> '005'))
	   and suma_asegurada > 500000
	 order by no_poliza
	
    foreach
		select sum(r.suma_asegurada),
		       r.cod_cober_reas
		  into _suma,
               _cod_cober_reas		  
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and t.tipo_contrato = 1
		 group by r.cod_cober_reas
        exit foreach;
    end foreach
	
	let _suma_otr = 0;
	--TIPO 2 INDICA POLIZAS CON SUMA ASEGURADA MAYOR A 500000 Y DEBEN TENER TOPADO EL CONTRATO DE RETENCION
	if _suma <= 499900 then
		foreach
			select distinct sum(r.suma_asegurada),
			       t.tipo_contrato
			  into _suma_otr,
			       _tipo_cont
			  from emifacon r, reacomae t
			 where r.cod_contrato = t.cod_contrato
			   and r.no_poliza = _no_poliza
			   and t.tipo_contrato <> 1
			 group by r.cod_cober_reas,t.tipo_contrato
			 order by t.tipo_contrato

		end foreach
		if _suma_otr <> 0 then
		
			select count(*)
			  into _cnt
			  from endedmae
			 where actualizado = 1
			   and no_poliza = _no_poliza
			   and no_endoso <> '00000'
			   and cod_endomov not in('024','025','002','003')
			   and suma_asegurada <> 0;
			   
			let _tipo = 2;
			if _cnt > 0 then
				--ESTE TIPO INDICA QUE LAS POLIZAS ESTAN EN INVESTIGACION PARA SABER COMO PROCEDER.
				let _tipo = 0;
			end if
			
			let _cnt_pol = 0;
			
			select count(*)
			  into _cnt_pol
			  from camrea2
			 where no_poliza = _no_poliza;
			 
			if _cnt_pol is null THEN
				let _cnt_pol = 0;
			end if	
			
			if _cnt_pol = 0 then 			
				insert into camrea2(
				no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
				values(_no_poliza,'',0,'',_periodo,_no_documento,_tipo,today);
			end if
			--return  _no_poliza,_no_documento,_periodo,_suma,_suma_otr,_vig_inic,_cnt,_tipo with resume;
		end if
    end if		
end foreach
end 
end procedure;