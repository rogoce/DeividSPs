-- Reporte de Movimiento de Cheque y Efectivo
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob754;
create procedure sp_cob754(a_fecha1 date,a_fecha2 date,a_chequera char(255) default "*") 
returning char(50), char(3), date, decimal(16,2), decimal(16,2), decimal(16,2), decimal(16,2), decimal(16,2), decimal(16,2), char(255);

define _cod_chequera 	char(3);
define _fecha 			date;
define _no_remesa		char(10);

define _monto_chequeo	dec(16,2);
define _total_caja		dec(16,2);
define _total_pagos		dec(16,2);
define _importe			dec(16,2);
define _tipo_pago		smallint;
define _n_pago          char(15);
define _n_caja          char(50);
define v_filtros        char(255);
define _tipo            char(01);
define _monto_1			dec(16,2);
define _monto_2			dec(16,2);
define _monto_3			dec(16,2);
define _monto_4			dec(16,2);

set isolation to dirty read;

create temp table tmp_caja(
cod_chequera    char(3),
fecha			date,
efectivo        dec(16,2),
cheque          dec(16,2),
clave           dec(16,2),
tarjeta         dec(16,2),
seleccionado    smallint default 1,
primary key(cod_chequera, fecha)) with no log;

let _total_caja   = 0.00;
let _total_pagos  = 0.00;

foreach
 select cod_chequera,
        no_remesa,
		fecha,
        monto_chequeo
   into _cod_chequera,
        _no_remesa,
        _fecha,
        _monto_chequeo
   from cobremae
  where fecha        >= a_fecha1
    and fecha        <= a_fecha2
	and actualizado  = 1
--	and cod_chequera in --("017","019","021","014","028") --= _cod_chequera

	let _total_caja = _total_caja + _monto_chequeo;

	foreach
	 select tipo_pago,
			sum(importe)
	   into _tipo_pago,
			_importe
	   from cobrepag
	  where no_remesa = _no_remesa and tipo_pago in (1,2)
	  group by tipo_pago

		let _total_pagos = _total_pagos + _importe;

		let _monto_1 = 0;
		let _monto_2 = 0;
		let _monto_3 = 0;
		let _monto_4 = 0;

		if _tipo_pago = 1 then
		   let _monto_1 = _importe;
		elif _tipo_pago = 2 then
		   let _monto_2 = _importe;
		elif _tipo_pago = 3 then
		   let _monto_3 = _importe;
		elif _tipo_pago = 4 then
		   let _monto_4 = _importe;
		end if

		begin
		on exception in(-239)
			update tmp_caja
			   set efectivo = efectivo + _monto_1,
			       cheque   = cheque + _monto_2,
			       clave    = clave + _monto_3,
			       tarjeta  = tarjeta + _monto_4
			 where cod_chequera	= _cod_chequera
			   and fecha = _fecha; 

		end exception 	
			insert into tmp_caja (cod_chequera,fecha,efectivo,cheque,clave,tarjeta,seleccionado)
			values (_cod_chequera, _fecha, _monto_1, _monto_2, _monto_3, _monto_4, 1 );
		end

	end foreach

end foreach

-- Procesos Filtros
let v_filtros ="";

--Filtro por Chequera
if a_chequera <> "*" then
	let v_filtros = TRIM(v_filtros) ||"CAJA: "||TRIM(a_chequera);
	let _tipo = sp_sis04(a_chequera); -- Separa los valores del String

	if _tipo <> "E" then -- Incluir los Registros

	update tmp_caja
	   set seleccionado = 0
	 where seleccionado = 1
	   and cod_chequera not in(select codigo from tmp_codigos);
	else
	update tmp_caja
	   set seleccionado = 0
	 where seleccionado = 1
	   and cod_chequera in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if


foreach
	select cod_chequera,fecha,efectivo,cheque,clave,tarjeta
	  into _cod_chequera, _fecha, _monto_1, _monto_2, _monto_3, _monto_4
	  from tmp_caja
	 where seleccionado = 1
	 order by cod_chequera, fecha

	select nombre
	  into _n_caja
	  from chqchequ
	 where cod_chequera = _cod_chequera
	   and cod_banco = "146";

	return _n_caja,
		   _cod_chequera, 
		   _fecha, 
		   _monto_1, 
		   _monto_2, 
		   _monto_3, 
		   _monto_4,
		   _total_caja,
		   _total_pagos,
		   v_filtros
		   with resume;

end foreach

drop table tmp_caja;

--return 0, "Actualizacion Exitosa";

end procedure