-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv;
create procedure sp_reainv()
returning char(10), char(20),smallint;
		  	

define _no_poliza char(10);
define _no_documento char(20);
define _cnt integer;

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";
foreach
	select no_poliza,
	       no_documento
	  into _no_poliza,
           _no_documento	  
      from emipomae
	 where actualizado = 1
	   and vigencia_inic >= '01/07/2021'
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
			return  _no_poliza,_no_documento,1 with resume;
		end if
	end foreach
end foreach
end 
end procedure;
