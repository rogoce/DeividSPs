-- Procedimiento que Crea los Registros para los Auditores (Cobros)
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud01;

create procedure "informix".sp_aud01(
a_periodo1	char(7),
a_periodo2	char(7)
)

define _no_recibo	char(10);
define _tipo_mov	char(1);
define _desc_remesa	char(100);
define _monto		dec(16,2);
define _fecha		date;
define _desc_mov	char(20);
define _monto_desc	dec(16,2);

create temp table tmp_recibos(
	no_recibo	char(10),
	cod_cobrad	char(10),
	desc_mov	char(20),
	estado		char(10),
	desc_remesa	char(100),
	monto		dec(16,2),
	fecha		date
	) with no log;

set isolation to dirty read;

foreach
 select d.no_recibo, 
        d.tipo_mov, 
        d.desc_remesa, 
        d.monto, 
        d.fecha,
		d.monto_descontado
   into _no_recibo, 
        _tipo_mov, 
        _desc_remesa, 
        _monto, 
        _fecha,
		_monto_desc
   from cobredet d, cobremae m
  where d.actualizado = 1
    and d.periodo     >= a_periodo1
    and d.periodo     <= a_periodo2
	and d.renglon     <> 0
	and d.no_remesa   = m.no_remesa
--	and m.tipo_remesa in ("A", "M")
  order by d.fecha

	if _tipo_mov = "P" then
		let _desc_mov = "Pago de Prima";
	elif _tipo_mov = "N" then
		let _desc_mov = "Nota Credito";
	elif _tipo_mov = "M" then
		let _desc_mov = "Afectacion Catalogo";
		if _monto_desc <> 0.00 then
			let _monto = _monto * -1;
		end if
	elif _tipo_mov = "C" then
		let _desc_mov = "Comision Descontada";
	elif _tipo_mov = "D" then
		let _desc_mov = "Pago Deducible";
	elif _tipo_mov = "S" then
		let _desc_mov = "Pago Salvamento";
	elif _tipo_mov = "R" then
		let _desc_mov = "Pago Recupero";
	elif _tipo_mov = "E" then
		let _desc_mov = "Crear Prima Suspenso";
	elif _tipo_mov = "A" then
		let _desc_mov = "Aplicar Prima Suspenso";
	elif _tipo_mov = "B" then
		let _desc_mov = "Recibo Anulado";
	elif _tipo_mov = "T" then
		let _desc_mov = "Aplicar Reclamo";
	end if

	if _desc_remesa = " " then
		let _desc_remesa = _desc_mov;
	end if

	insert into tmp_recibos
	values (
	_no_recibo, 
	" ",
	_desc_mov,
	" ",
    _desc_remesa, 
    _monto, 
    _fecha
	);

end foreach

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure