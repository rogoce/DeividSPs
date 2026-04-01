-- Procedure que reversa la distribución de reaseguro de las transacciones de auto al 100% Retención de forma masiva
-- Creado    : 31/01/2017 - Autor: Román Gordón
--execute procedure sp_rec271a('2018-08')

drop procedure sp_rec271a;
create procedure sp_rec271a(a_periodo char(8))
RETURNING	integer,
			varchar(100);

define _error_desc			varchar(100);
define _no_registro			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _rec_periodo			char(8);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _cnt_notrx			smallint;
define _cnt_reama			smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error_cod			integer;
define _notrx				integer;
define _vigencia_final		date;
define _vigencia_inic		date;

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

begin
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

select rec_periodo
  into _rec_periodo
  from parparam;

if a_periodo <> _rec_periodo then
	--return 1,'Este procedure solo se puede ejecutar para el periodo actual de Reclamos.';
end if

foreach
	select distinct r.no_reclamo--r.numrecla,a.*
	  into _no_reclamo
	  from recrcmae r, recreaco a, emipomae e,reacomae c
	 where r.no_poliza = e.no_poliza
	   and r.no_reclamo = a.no_reclamo
	   and c.cod_contrato = a.cod_contrato
	   and e.cod_ramo in ('002','020','023')
	   and c.tipo_contrato = 1
	   and a.porc_partic_prima <> 30
	   --and r.fecha_reclamo >= '01/01/2015'
	   and r.estatus_reclamo = 'A'

	select no_poliza,
		   no_unidad
	  into _no_poliza,
		   _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select vigencia_inic,
		   vigencia_final,
		   cod_ramo
	  into _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _vigencia_inic < '01/07/2015' then
		let _vigencia_inic = '01/07/2015';
	end if

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and _vigencia_inic between vig_inic and vig_final
	   and cod_ruta <> '00676'
	   and activo = 1;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _no_cambio is null then
		let _no_cambio = 0;
	end if

	let _no_cambio = _no_cambio + 1;
	
	delete from recreaco
	 where no_reclamo = _no_reclamo;

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   orden,
			   porc_partic_prima,
			   porc_partic_suma
		  into _cod_contrato,
			   _cod_cober_reas,
			   _orden,
			   _porc_partic_prima,
			   _porc_partic_suma
		  from rearucon
		 where cod_ruta = _cod_ruta

		select count(*)
		  into _cnt_reama
		  from emireama
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		   and cod_cober_reas = _cod_cober_reas;

		if _cnt_reama is null then
			let _cnt_reama = 0;
		end if

		if _cnt_reama = 0 then
			insert into emireama(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					vigencia_inic,
					vigencia_final)
			values(	_no_poliza,
					_no_unidad,
					_no_cambio,
					_cod_cober_reas,
					_vigencia_inic,
					_vigencia_final);
		end if

		insert into emireaco(
				no_poliza,
				no_unidad,
				no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima)				
		values(	_no_poliza,
				_no_unidad,
				_no_cambio,
				_cod_cober_reas,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima);

		insert into recreaco(
				no_reclamo,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima,
				cod_cober_reas,
				subir_bo)
		values(	_no_reclamo,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima,
				_cod_cober_reas,
				1);		
	end foreach
end foreach

return 0, "Actualizacion Exitosa";

end
end procedure;