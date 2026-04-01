-- Procedimiento que muestra la ultima Distribucion de Reaseguro individual--
-- Creado:     27/01/2012 - Autor Roman Gordon
--Modificado   08/04/2016 -- Henry se adicino columnas de garantia(3)
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro356a;
create procedure "informix".sp_pro356a(a_no_poliza char(10), a_no_unidad char(5),a_cod_cober_reas char(3), a_cod_contrato char(5))
returning   char(10),			--1a_no_poliza,			 				
			char(5),			--2'00000',   		
			char(5),			--3a_no_unidad,   		
			char(3),			--4a_cod_cober_reas,  
			smallint,			--5_orden,   			
			char(5),			--6a_cod_contrato,   	
			char(3),			--7_cod_coasegur,   
   			dec(9,6),			--8_porc_partic_reas,
			dec(9,6),			--9_porc_comis_fac,  
			dec(5,2),			--10_porc_impuesto,   
			dec(16,2),			--11_suma_asegurada,  	
			dec(16,2),			--12_prima,   
			smallint,			--13_impreso,   
			date,				--14_fecha_impresion, 
			char(10),			--15_no_cesion
			integer,            --16_cant_garantia_pago
			char(3),            --17_cod_perfac
			date,               --18_fecha_primer_pago
			char(3);            --19_cod_coasegur2
			

define _no_cesion			char(10);
define _cod_coasegur		char(3);
define _prima		   		dec(16,2);
define _suma_asegurada		dec(16,2);
define _porc_partic_reas	dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto		dec(5,2);
define _orden				smallint;
define _no_cambio			smallint;
define _impreso				smallint;
define _fecha_impresion		date;
define _cant_garantia_pago  integer;
define _cod_perfac          char(3);
define _fecha_primer_pago   date;
define _no_endoso           char(10);
define _cod_coasegur2       char(3);

set isolation to dirty read;

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza		= a_no_poliza
   and no_unidad		= a_no_unidad
   and cod_cober_reas	= a_cod_cober_reas;
   
select max(e.no_endoso)
  into _no_endoso
  from emifafac e, endedmae t
 where e.no_poliza = t.no_poliza
   and e.no_endoso = t.no_endoso
   and  e.no_poliza	 = a_no_poliza
   and e.no_unidad	 = a_no_unidad
   and t.actualizado = 1;
   
if _no_endoso is null then
	let _no_endoso = '00000';
end if   

foreach
	select cod_coasegur,
		   orden,
		   porc_partic_reas,			   
		   porc_comis_fac,  
		   porc_impuesto
	  into _cod_coasegur,
		   _orden,
		   _porc_partic_reas,
		   _porc_comis_fac,
		   _porc_impuesto
	  from emireafa
	 where no_poliza		= a_no_poliza
	   and no_unidad		= a_no_unidad
	   and no_cambio		= _no_cambio
	   and cod_cober_reas	= a_cod_cober_reas
	   and cod_contrato		= a_cod_contrato

	select sum(a.suma_asegurada),
		   sum(a.prima)
	  into _suma_asegurada,
		   _prima
	  from emifafac a, endedmae	b
	 where a.no_poliza      = b.no_poliza
	   and a.no_endoso      = b.no_endoso
	   and b.actualizado    = 1
	   and a.no_poliza		= a_no_poliza
	   and a.no_unidad		= a_no_unidad
	   and a.cod_cober_reas	= a_cod_cober_reas
	   and a.cod_contrato	= a_cod_contrato
	   and a.cod_coasegur	= _cod_coasegur;

	select impreso,
		   fecha_impresion,
		   no_cesion,
		   cant_garantia_pago,
		   cod_perfac,
		   fecha_primer_pago,
		   cod_coasegur2
	  into _impreso,
	  	   _fecha_impresion,
	  	   _no_cesion,
		   _cant_garantia_pago,
		   _cod_perfac,
		   _fecha_primer_pago,
		   _cod_coasegur2
	  from emifafac
	 where no_poliza		= a_no_poliza
	   and no_endoso		= _no_endoso
	   and no_unidad		= a_no_unidad
	   and cod_cober_reas	= a_cod_cober_reas
	   and orden			= _orden
	   and cod_contrato		= a_cod_contrato
	   and cod_coasegur		= _cod_coasegur;

	return a_no_poliza,			 
		   _no_endoso,
		   a_no_unidad,   		
		   a_cod_cober_reas,  
		   _orden,   			
		   a_cod_contrato,   	
		   _cod_coasegur,   
		   _porc_partic_reas,
		   _porc_comis_fac,  
		   _porc_impuesto,   
		   _suma_asegurada,  
		   _prima,   
		   _impreso,   
		   _fecha_impresion, 
		   _no_cesion,
		   _cant_garantia_pago,
		   _cod_perfac,
		   _fecha_primer_pago,
           _cod_coasegur2		   
		   with resume;
end foreach
end procedure;