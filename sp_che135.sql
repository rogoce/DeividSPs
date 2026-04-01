-- Reporte para las requisiciones de Cheques Impresas por banco y chequera

-- Creado    : 30/07/2012 - Autor: Armando Moreno M.

--drop procedure sp_che135;

create procedure sp_che135(a_fecha date, a_fecha2 date, a_cod_banco char(3), a_cod_chequera char(3))
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(8),
		   char(8),
		   integer,
		   date,
		   datetime hour to fraction(5),
		   char(8),
		   char(50),
		   char(50);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _no_cheque		integer;
define _anulado_por     char(8);
define _fecha_anulado   date;
define _hora_anulado    datetime hour to fraction(5);
define _n_banco         char(50);
define _n_chequera      char(50);
define _en_firma        smallint;
define _en_firma_o      smallint;

SET ISOLATION TO DIRTY READ;


select nombre
  into _n_banco
  from chqbanco
  where cod_banco = a_cod_banco;

select nombre
  into _n_chequera
  from chqchequ
 where cod_banco    = a_cod_banco
   and cod_chequera = a_cod_chequera;

let _en_firma   = 2;
let _en_firma_o = 0;

if a_cod_banco = '001' and a_cod_chequera = '006' then
   let _en_firma   = 2;
   let _en_firma_o = 2;
end if

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		no_cheque,
		fecha_anulado,
		hora_anulado,
		anulado_por
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque,
		_fecha_anulado,
		_hora_anulado,
		_anulado_por
   from	chqchmae
  where anulado         = 0
    and autorizado      = 1
	and cod_banco       = a_cod_banco
	and cod_chequera    = a_cod_chequera
	and pagado			= 1
	and en_firma        in(_en_firma, _en_firma_o)
	and fecha_impresion between a_fecha and a_fecha2

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _firma1,
		   _firma2,
		   _no_cheque,
		   _fecha_anulado,
		   _hora_anulado,
		   _anulado_por,
		   _n_banco,
		   _n_chequera
		   with resume;
   
end foreach

end procedure
