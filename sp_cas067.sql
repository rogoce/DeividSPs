-- Actualizacion de Registros Segun el Tipo de Gestion
-- Creado    : 02/12/2015 - Autor: Román Gordón

drop procedure sp_cas067;

create procedure sp_cas067()
returning 	integer			as flag,
			varchar(100)	as error_desc;

define _error_desc		varchar(100);
define _no_documento	char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _valor_holgura	dec(16,2);
define _monto_pen		dec(16,2);
define _estatus_poliza	smallint;
define _cnt_caspoliza	smallint;
define _desmarcar		smallint;
define _pagada			smallint;
define _error			integer;

--set debug file to "sp_cas067.trc";
--trace on;

drop table if exists tmp_anulidad;
select cod_campana
  from cascampana
 where tipo_campana = 3
   and estatus = 2
  into temp tmp_anulidad;

begin
set isolation to dirty read;

foreach
	select no_documento
	  into _no_documento
	  from caspoliza
	 where cod_campana in (select cod_campana from tmp_anulidad)

	let _no_poliza = sp_sis21(_no_documento);
	let _desmarcar = 0;

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza not in (1,4) then
		let _desmarcar = 1;
	end if

	select pagada,
		   monto_pen
	  into _pagada,
		   _monto_pen
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = 1;

	if _pagada = 1 then
		let _desmarcar = 1;
	else
		select valor_parametro
		  into _valor_holgura
		  from inspaag
		 where codigo_parametro = 'nuli_holgura_pago';

		if _monto_pen <= _valor_holgura then
			let _desmarcar = 1;
		end if
	end if
	
	if _desmarcar = 1 then
		foreach
			select cod_cliente
			  into _cod_cliente
			  from caspoliza
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		if _cod_cliente is null then
			let _cod_cliente = '';
		end if

		select count(*)
		  into _cnt_caspoliza
		  from caspoliza
		 where cod_campana in (select cod_campana from tmp_anulidad)
		   and cod_cliente = _cod_cliente
		   and no_documento <> _no_documento;

		if _cnt_caspoliza is null then
			let _cnt_caspoliza = 0;
		end if

		if _cnt_caspoliza > 0 then
			delete from caspoliza
			 where cod_cliente = _cod_cliente
			   and no_documento = _no_documento
			   and cod_campana in (select cod_campana from tmp_anulidad);
		else
			delete from caspoliza
			 where cod_cliente = _cod_cliente
			   and no_documento = _no_documento
			   and cod_campana in (select cod_campana from tmp_anulidad);

			delete from cascliente
			 where cod_cliente = _cod_cliente
			   and cod_campana in (select cod_campana from tmp_anulidad);
		end if
	end if
end foreach

drop table if exists tmp_anulidad;
return 0,'Depuración Exitosa';

end
end procedure;
