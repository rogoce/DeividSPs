-- Procedimiento que Determina el Coaseguro y el Reaseguro por Transaccion
-- 
-- Creado    : 05/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis58_ajuste;		

create procedure "informix".sp_sis58_ajuste(a_no_tranrec char(10))
returning integer, char(250);

define _error_desc			char(50);
define _no_reclamo			char(10);
define _cod_contrato		char(5);
define _cod_cober_reas		char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _tipo_contrato		smallint;
define _orden				smallint;
define _error				integer;
define _cod_ramo            char(3);
define _no_poliza           char(10);

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Generar el Reaseguro de la Transaccion";
end exception

--delete from rectrref where no_tranrec = a_no_tranrec;
delete from rectrrea where no_tranrec = a_no_tranrec;

select no_reclamo
  into _no_reclamo
  from rectrmae
 where no_tranrec = a_no_tranrec;

set lock mode to wait 60;

select no_poliza
  into _no_poliza
  from recrcmae
 where no_reclamo = _no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

if _cod_ramo = '002' then

foreach
	select cod_cober_reas,
		   cod_contrato,
		   porc_partic_suma,
		   porc_partic_prima,
		   orden
	  into _cod_cober_reas,
		   _cod_contrato,
		   _porc_partic_suma,
		   _porc_partic_prima,
		   _orden
	  from rearucon  
	 where cod_ruta       = '00487'
	 order by orden asc
	
	select tipo_contrato
	  into _tipo_contrato
	  from reacomae
	 where cod_contrato = _cod_contrato;
	 
	insert into rectrrea(
		no_tranrec,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		tipo_contrato,
		cod_cober_reas)
	values(	a_no_tranrec,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima,
			_tipo_contrato,
			_cod_cober_reas);
end foreach	

end if  

if _cod_ramo = '023' then

foreach
	select cod_cober_reas,
		   cod_contrato,
		   porc_partic_suma,
		   porc_partic_prima,
		   orden
	  into _cod_cober_reas,
		   _cod_contrato,
		   _porc_partic_suma,
		   _porc_partic_prima,
		   _orden
	  from rearucon  
	 where cod_ruta       = '00538'
	 order by orden asc
	
	select tipo_contrato
	  into _tipo_contrato
	  from reacomae
	 where cod_contrato = _cod_contrato;
	 
	insert into rectrrea(
		no_tranrec,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		tipo_contrato,
		cod_cober_reas)
	values(	a_no_tranrec,
			_orden,
			_cod_contrato,
			_porc_partic_suma,
			_porc_partic_prima,
			_tipo_contrato,
			_cod_cober_reas);
end foreach	

end if  

{insert into rectrref(
no_tranrec,
orden,
cod_coasegur,
cod_contrato,
porc_partic_reas,
cod_cober_reas
)
select
a_no_tranrec,
orden,
cod_coasegur,
cod_contrato,
porc_partic_reas,
cod_cober_reas
from recreafa
where no_reclamo = _no_reclamo;	 }

update rectrrea set subir_bo = 1 where no_tranrec = a_no_tranrec;
update rectrcon set subir_bo = 1 where no_tranrec = a_no_tranrec;

-- Campo Subir_BO para el DWH

{call sp_sis96(2, _no_reclamo, a_no_tranrec) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if

-- Reaseguro de los Reclamos para los Asientos

call sp_rea008(3, a_no_tranrec) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if}

end

return 0, "Actualizacion Exitosa ...";
end procedure