-- Pólizas vigentes y con endoso de Cancelación
-- Creado    : 20/03/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob355b;
create procedure sp_cob355b(a_periodo_desde char(7),a_periodo_hasta char(7))
returning	varchar(20)	as Poliza, --_no_documento
			varchar(50)	as Ramo,
			date		as Vigencia_Inicial,
			date		as Vigencia_Final,
			dec(16,2)	as Prima_Suscrita,
			date		as Fecha_Renovacion,
			date		as Fecha_Cancelacion;

define _nom_ramo		varchar(50);
define _no_documento	varchar(20);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _prima_suscrita	dec(16,2);
define _cnt_cancelada	smallint; 
define _cnt_canc		smallint; 
define _cnt_rehab		smallint; 
define _fecha_impresion	date;
define _vigencia_final	date;
define _vigencia_inic	date;
define _vigencia_canc	date;
define _fecha_desde		date;
define _fecha_hasta		date;

set isolation to dirty read;

let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

foreach
	select no_poliza,
		   no_documento,
		   cod_ramo,
		   vigencia_inic,
		   vigencia_final,
		   prima_suscrita,
		   fecha_impresion
	  into _no_poliza,
		   _no_documento,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_suscrita,
		   _fecha_impresion
	  from emipomae
	 where periodo >= a_periodo_desde
	   and periodo <= a_periodo_hasta
	   and nueva_renov = 'R'
	   and estatus_poliza = 1
	   and actualizado = 1

	let _cnt_cancelada = 0;

	select count(*)
	  into _cnt_cancelada
	  from emipomae
	 where no_documento = _no_documento
	   and estatus_poliza = 2
	   and actualizado = 1;

	if _cnt_cancelada is null then
		let _cnt_cancelada = 0;
	end if
	
	select count(*)
	  into _cnt_canc
	  from endedmae
	 where no_documento = _no_documento
	   and cod_endomov = '002'
	   and actualizado = 1;

	if _cnt_canc is null then
		let _cnt_canc = 0;
	end if

	select count(*)
	  into _cnt_rehab
	  from endedmae
	 where no_documento = _no_documento
	   and cod_endomov = '003'
	   and actualizado = 1;

	if _cnt_rehab is null then
		let _cnt_rehab = 0;
	end if

	if _cnt_cancelada = 0 then
		continue foreach;
	elif _cnt_canc = _cnt_rehab then
		continue foreach;
	end if
	
	select max(fecha_impresion)
	  into _vigencia_canc
	  from endedmae
	 where no_documento = _no_documento
	   and cod_endomov = '002'
	   and actualizado = 1;

	if _vigencia_canc > _fecha_impresion then
		continue foreach;
	end if

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return	_no_documento,
			_nom_ramo,
			_vigencia_inic,
			_vigencia_final,
			_prima_suscrita,
			_fecha_impresion,
			_vigencia_canc with resume;
end foreach
end procedure;