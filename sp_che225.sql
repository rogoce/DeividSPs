-- Reporte para las requisiciones de Reclamos de Salud por imprimir

-- Creado    : 12/07/2006 - Autor: Armando Moreno

drop procedure sp_che225;
create procedure sp_che225()
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   char(1),
		   char(50),
		   date,
		   integer,
		   integer,
		   integer,
		   integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _fecha_hoy       date;
define _fecha_captura   date;
define _dias		    integer;
define _dias30 			integer;
define _dias60 			integer;
define _dias90			integer;
define _diasmas90		integer;
define _per_pago_char   char(1);

SET ISOLATION TO DIRTY READ;

let _fecha_hoy = current;

foreach
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018'

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		fecha_captura
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_fecha_captura
   from	chqchmae
  where anulado       = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma      = 2
--	and autorizado    = 1
	and pagado        = 0
	and tipo_requis   = 'C'


 foreach
	select cod_tipopago
	  into _cod_tipopago
	  from rectrmae
	 where no_requis   = _no_requis
	   and actualizado = 1
	exit foreach;
 end foreach
   
 select nombre
   into _nom_tipopago
   from rectipag
  where cod_tipopago = _cod_tipopago;
  
  let _dias = _fecha_hoy - _fecha_captura;
	  let _dias30 = 0;
	  let _dias60 = 0;
	  let _dias90 = 0;
	  let _diasmas90 = 0;
	if _dias >= 0 And _dias <= 30 then
			let _dias30 = _dias;
	elif _dias >= 31 And _dias <= 60 then
			let _dias60 = _dias;
	elif _dias >= 61 And _dias <= 90 then
			let _dias90 = _dias;
	elif _dias >= 91 then
			let _diasmas90 = _dias;
	end if

		if _periodo_pago = 0 then
			let _per_pago_char = 'D';
		elif _periodo_pago = 1 then
			let _per_pago_char = 'S';
		else
			let _per_pago_char = 'M';
		end if

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _per_pago_char,
		   _nom_tipopago,
		   _fecha_captura,
		   _dias30,
		   _dias60,
		   _dias90,
		   _diasmas90
		   with resume;

end foreach
end foreach
end procedure
