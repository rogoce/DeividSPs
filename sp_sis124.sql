-- Procedimiento que trae información de los reclamos de la poliza reemplazada de la acumulación de deducibles y vitalicio 
-- 
-- Creado    : 30/06/2016 - Autor: Amado Perez Mendoza 

-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sis124;

create procedure sp_sis124(a_no_poliza char(10), a_no_doc char(20))
returning integer,
          char(50);

define _no_documento	 char(20);
define _reemplaza_poliza char(20);
define _error			 integer;
define _error_isam		 integer;
define _error_desc		 char(50);

set isolation to dirty read; 

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
 
-- Seleccion de Registros

let _no_documento = a_no_doc;

	select reemplaza_poliza
	  into _reemplaza_poliza
	  from emipomae
	 where no_poliza = a_no_poliza;

	delete from recacuan where no_documento = _no_documento; 
	delete from recacusu where no_documento = _no_documento; 
	delete from recacuvi where no_documento = _no_documento; 

	insert into recacuan (
		no_documento,
		ano,
		cod_cliente,
		monto_deducible,
		monto_coaseguro,
		no_unidad,
		monto_coaseguro2)
		select _no_documento,
			   ano,
			   cod_cliente,
			   monto_deducible,
			   monto_coaseguro,
			   no_unidad,
			   monto_coaseguro2
		  from recacuan 
		 where no_documento = _reemplaza_poliza;

	insert into recacusu (
		no_documento,
		ano,
		cod_cliente,
		cod_cobertura,
		monto,
		no_unidad)
		select _no_documento,
			   ano,
		       cod_cliente,
		       cod_cobertura,
		       monto,
		       no_unidad
		  from recacusu 
		 where no_documento = _reemplaza_poliza;

	insert into recacuvi (
		no_documento,
		cod_cliente,
		cod_cobertura,
		monto,
		no_unidad)
		select _no_documento,
			   cod_cliente,
			   cod_cobertura,
			   monto,
			   no_unidad
		  from recacuvi 
		 where no_documento = _reemplaza_poliza;
		 
end 

return 0, "Actualizacion Exitosa";

end procedure