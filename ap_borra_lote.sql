-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_borra_lote;		
create procedure ap_borra_lote()
returning integer,char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _no_poliza       char(10);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _no_poliza;
end exception


--set debug file to "ap_borra_lote.trc";
--trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

let _no_poliza = null;

foreach with hold
{	select  a.no_poliza_r 
      into _no_poliza
      from deivid_tmp:renov_recar a
     where a.procesado = 1}	

 {   select  no_poliza_r 
      into _no_poliza
      from deivid_tmp:renov_recar
     where no_documento in (
	select a.no_documento
         from emipomae a, emipouni b, emiauto c, emivehic d
	where a.no_poliza = b.no_poliza
	  and b.no_poliza = c.no_poliza
	  and b.no_unidad = c.no_unidad
	  and c.no_motor = d.no_motor
	  and b.cod_producto in ('07755','03812','03811','02283','03810','07754','02282','07215','08278')
	  and a.vigencia_final >= '01-10-2024'
	  and a.vigencia_final <= '31-10-2024'
	  and a.nueva_renov = 'N'
	  and d.ano_auto >= 2023
	  and a.no_documento[1,4] = '0223') 
	  and procesado = 1
}
{	select  a.no_poliza_r 
      into _no_poliza
      from deivid_tmp:renov_recar a, emipomae b, emipouni c
     where a.no_poliza_r = b.no_poliza
     and  b.no_poliza = c.no_poliza	 
    and a.no_unidad = c.no_unidad
     and a.procesado = 1	
	 and c.cod_producto in ('00313','07159')
}	 
 select  no_poliza 
   into _no_poliza
   from emipomae 
  where no_documento in ('0124-03666-01')
    and actualizado = 0 
	
 call sp_sis61b(_no_poliza) returning _error, _error_desc;
 
 return _error, _error_desc with resume;
 
 {update deivid_tmp:renov_recar 
    set procesado = 0
  where no_poliza_r = _no_poliza;
}
end foreach
end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	
return _error, _error_desc;
end procedure;
