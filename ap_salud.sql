-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE ap_salud;

CREATE PROCEDURE "informix".ap_salud()
returning char(20);

define _no_poliza	char(10);
define _no_unidad   char(5);
define _no_documento char(20);
define _recargo dec(16,2);
define _recargo_dep dec(16,2);
define _error integer;

SET ISOLATION TO DIRTY READ;

let _recargo = 0;
let _recargo_dep = 0;

foreach
	select no_poliza,
	       no_documento
	  into _no_poliza,
	       _no_documento
	  from emipomae
	 where cod_ramo  = '018'
	   and estatus_poliza = 1
	   and recargo = 0
	--   and no_documento = '1807-00095-01'
	   
	let _recargo = 0;
	let _recargo_dep = 0;
	      
	select sum(b.porc_recargo)
	  into _recargo
	  from emipouni a, emiunire b
	 where a.no_poliza = b.no_poliza
	   and a.no_unidad = b.no_unidad
	   and a.no_poliza = _no_poliza
	   and a.activo = 1;
		   
	select sum(c.por_recargo)
	  into _recargo_dep
	  from emipouni a, emidepen b, emiderec c
	 where a.no_poliza = b.no_poliza
	   and a.no_unidad = b.no_unidad
	   and b.no_poliza = c.no_poliza
	   and b.no_unidad = c.no_poliza
	   and a.no_poliza = _no_poliza
	   and a.activo = 1
	   and b.activo = 1;
	   
	   if _recargo is null then
		let _recargo = 0;
	   end if
	   
	   if _recargo_dep is null then
		let _recargo_dep = 0;
	   end if
	   
	   if _recargo + _recargo_dep > 0 then
	     foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1
			   
			let _error = sp_proe01(_no_poliza, _no_unidad, '001');   
			   
		 end foreach

		let _error = sp_proe03(_no_poliza, '001');   
		 
		 return _no_documento with resume;
	   end if

end foreach

foreach
	select no_poliza,
	       no_documento
	  into _no_poliza,
	       _no_documento
	  from emipomae
	 where cod_ramo  = '018'
	   and estatus_poliza = 1
	   and descuento = 0
	   
	let _recargo = 0;
	let _recargo_dep = 0;
	      
	select sum(b.porc_descuento)
	  into _recargo
	  from emipouni a, emiunide b
	 where a.no_poliza = b.no_poliza
	   and a.no_unidad = b.no_unidad
	   and a.no_poliza = _no_poliza
	   and a.activo = 1;
		   	   
	   if _recargo is null then
		let _recargo = 0;
	   end if
	   
	   if _recargo > 0 then
	     foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza
			   and activo = 1
			   
			let _error = sp_proe01(_no_poliza, _no_unidad, '001');   
			   
		 end foreach

		let _error = sp_proe03(_no_poliza, '001');   
		
		 return _no_documento with resume;
	   end if

end foreach

END PROCEDURE
