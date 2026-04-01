-- Procedimiento que elimina el rechazo de las pólizas 
-- Creado    : 15/04/2015 - Autor: Román Gordón
-- Modificadi: 29/01/2016 - Autor: Román Gordón --Hacer que el proceso de anulación de pólizas renovadas tome en cuenta todos los endososos de la vigencia a anular. 
-- Modificadi: 07/03/2016 - Autor: Román Gordón --Se agregó el proceso de eliminar el endoso realizado en caso de error y permitir que continue con la siguiente póliza a anular.
-- SIS v.2.0 - d_cobr_sp_cob358_dw1 --llamado desde sis103 (Proceso Diario de Cobros) - DEIVID, S.A.

drop procedure sp_cob379;
create procedure sp_cob379(a_no_remesa char(10)
returning	integer			as Codigo_Error,
			varchar(100)	as Error_Desc;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_tarjeta			char(19);
define _no_cuenta			char(17);
define _no_poliza			char(10);
define _cod_formapag		char(3);
define _cod_chequera		char(3);
define _cnt_tarjeta			smallint;
define _cnt_cuenta			smallint;
define _tipo_forma			smallint;
define _error_isam			integer;
define _error				integer;

--set debug file to "sp_cob379.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

select cod_chequera
  into _cod_chequera
  from cobremae
 where no_remesa = a_no_remesa;

if _cod_chequera in ('029','031','030') then
	let _error_desc = 'La Remesa: '|| trim(a_no_remesa) || ' es una remesa Electrónica';
	return 0,_error_desc;
end if

foreach
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov in ('P')

	select no_documento,
		   cod_formapag
	  into _no_documento,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma not in (2,4) then
		continue foreach;
	end if

	if _tipo_forma = 2 then

		select no_tarjeta
		  into _no_tarjeta
		  from cobtacre
		 where no_documento = _no_documento;

		select count(*)
		  into _cnt_tarjeta
		  from cobtacre
		 where no_tarjeta = _no_tarjeta;

		if _cnt_tarjeta is null then
			continue foreach;
		end if
		
		if _cnt_tarjeta = 1 then
			update cobtahab
			   set rechazada = 0
			 where no_tarjeta = _no_tarjeta;
		end if

		update cobtacre
		   set rechazada = 0
		 where no_tarjeta = _no_tarjeta
		   and no_documento = _no_documento;
	elif _tipo_forma = 4 then
		select no_cuenta
		  into _no_cuenta
		  from cobcutas
		 where no_documento = _no_documento;

		select count(*)
		  into _cnt_cuenta
		  from cobcuhab
		 where no_cuenta = _no_cuenta;

		if _cnt_cuenta is null then
			continue foreach;
		end if
		
		if _cnt_cuenta = 1 then
			update cobcuhab
			   set rechazada = 0
			 where no_cuenta = _no_cuenta;
		end if

		update cobcutas
		   set rechazada = 0
		 where no_cuenta = _no_cuenta
		   and no_documento = _no_documento;
	end if
end foreach

return 0,'Actualización Exitosa';

end
end procedure;