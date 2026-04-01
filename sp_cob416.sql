-- 3:Txt de Cobros por Campana VOCEM
-- Creado    : 26/07/2018- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob416;

create procedure sp_cob416(a_fecha date)
returning VARCHAR(20)	as	no_documento,
		  VARCHAR(10)	as	fecha,
		  VARCHAR(16)	as	montos,
		  VARCHAR(3)    as  cod_ramo,
		  VARCHAR(50)   as  desc_ramo;		  

define _no_documento    char(20); 
define _fecha		    date;
define _montos			dec(16,2);
define _cnt             smallint;
define _cod_ramo		char(3);
define _desc_ramo		char(50);  

--set debug file to "sp_cob416.trc";
--trace on;

set isolation to dirty read;

select count(*)
  into _cnt
  from caspoliza
 where cod_campana = '01656'; 

if _cnt > 0 then
	foreach
		select a.no_documento, b.fecha, sum(b.monto)
		  into _no_documento, _fecha, _montos
		  from caspoliza a, cobredet b
		 where a.cod_campana = '01656'  -- Campaña VOCEM   		
		   and b.doc_remesa = a.no_documento
		   and b.tipo_mov in ('P','N')
		   and b.actualizado = 1
		   and b.fecha >= a_fecha
		 group by 1, 2	
		 order by 1, 2			
		 
		 select cod_ramo 
		   into _cod_ramo
		   from emipoliza 
		  where no_documento = _no_documento;
			 
		 select nombre
		   into _desc_ramo	
		   from prdramo
		  where cod_ramo = _cod_ramo;	 		 
		 
		return _no_documento,
				_fecha,
				_montos,
				_cod_ramo,
				_desc_ramo
				with resume;		
	end foreach
else
		return ' ',' ',' ',' ',' ' with resume;		
end if

end procedure;