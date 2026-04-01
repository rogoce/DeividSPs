--Proceso que carga las coberturas de las pólizas de coaseg. minoritario del Estado

drop procedure sp_pro552;

create procedure "informix".sp_pro552(
a_no_poliza 	char(10),
a_no_unidad		char(5)) 
returning	integer		as cod_error,
			varchar(255)	as error_desc;

define _error_desc		varchar(255);
define _desc_limite1	varchar(50);
define _desc_limite2	varchar(50);
define _cod_cliente		char(10);
define _cod_cobertura	char(5);
define _cod_producto	char(5);
define _prima_neta		dec(16,2);
define _actualizado		smallint;
define _orden			smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_hoy		date;

begin
on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception

select actualizado
  into _actualizado
  from emipomae
 where no_poliza = a_no_poliza;

if _actualizado is null then
	let _actualizado = 0;
end if

if _actualizado = 1 then
	return 0,'La Póliza ya fue emitida';
end if

delete from emipocob
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

select cod_producto,
	   prima_neta
  into _cod_producto,
	   _prima_neta
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

let _fecha_hoy = today;

foreach
	select cod_cobertura,
		   orden,
		   desc_limite1,
		   desc_limite2
	  into _cod_cobertura,
		   _orden,
		   _desc_limite1,
		   _desc_limite2
	  from prdcobpd
	 where cod_producto = _cod_producto
	   and cob_default = 1

	if _orden is null or _orden = 0 then
		select max(orden)
		  into _orden
		  from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad;

		if _orden is null then
			let _orden = 0;
		end if
		
		let _orden = _orden + 1;
	end if

	insert into emipocob (
			no_poliza,
			no_unidad,
			cod_cobertura,
			orden,
			tarifa,
			deducible,
			limite_1,
			limite_2,
			prima_anual,
			prima,
			descuento,
			recargo,
			prima_neta,
			date_added,
			date_changed,
			factor_vigencia,
			desc_limite1,
			desc_limite2)			
	values(	a_no_poliza,
			a_no_unidad,
			_cod_cobertura,
			_orden,
			0,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_fecha_hoy,
			_fecha_hoy,
			1,
			_desc_limite1,
			_desc_limite2);
end foreach

foreach
	select first 1 cod_cobertura
	  into _cod_cobertura
	  from emipocob
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
	 order by orden asc

	update emipocob
	   set prima_anual = _prima_neta,
		   prima_neta = _prima_neta,
		   prima = _prima_neta
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
	   and cod_cobertura = _cod_cobertura;
end foreach

end

return 0,'Actualización Exitosa';
end procedure;