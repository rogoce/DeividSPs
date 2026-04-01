-- Reporte para las requisiciones de Cheques Impresas por banco y chequera

-- Creado    : 30/07/2012 - Autor: Armando Moreno M.

--drop procedure sp_che_info;

create procedure sp_che_info(a_fecha date, a_fecha2 date, a_cod_banco char(3), a_cod_chequera char(3))
returning  char(10),
		   integer,
		   char(25),
		   char(100),
		   date,
		   dec(16,2),
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
define _fecha_impresion  date;
define _origen           char(1);
define _n_origen         char(25);
define _flag             smallint;
define _no_doc			 char(2);

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
		anulado_por,
		fecha_impresion,
		origen_cheque
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
		_anulado_por,
		_fecha_impresion,
		_origen
   from	chqchmae
  where anulado         = 0
    and autorizado      = 1
	and cod_banco       = a_cod_banco
	and cod_chequera    = a_cod_chequera
	and pagado			= 1
	--and cod_sucursal    = '003'
	and origen_cheque     = '6'
	and fecha_impresion between a_fecha and a_fecha2

	let _flag = 0;
	foreach
		select no_documento[1,2]
		  into _no_doc
		  from chqchpol
		 where no_requis = _no_requis
		 
		if _no_doc in('02','23','20','08') then
			let _flag = 1;
			exit foreach;
		end if
	end foreach	 
	if _flag = 1 then
		continue foreach;
	end if
	if _origen = '1' then
		let _n_origen = 'CONTABILIDAD';
	elif _origen = '2' then
		let _n_origen = 'CORREDOR';
	elif _origen = '3' then
		let _n_origen = 'RECLAMOS';
	elif _origen = '4' then
		let _n_origen = 'REASEGURO';
	elif _origen = '5' then
		let _n_origen = 'COASEGURO';
	elif _origen = '6' then
		let _n_origen = 'COBROS';
	elif _origen = '7' then
		let _n_origen = 'HONORARIOS';
	elif _origen = '8' then
		let _n_origen = 'BONI. COBRANZA';
	elif _origen = 'A' then
		let _n_origen = 'HONORARIOS';
	elif _origen = 'B' then
		let _n_origen = 'SERV. BASICOS';
	elif _origen = 'C' then
		let _n_origen = 'ALQUILERES';	
	elif _origen = '9' then
		let _n_origen = 'ICENTIVO FIDELIDAD';		
	elif _origen = 'D' then
		let _n_origen = 'BONI. RENTABILIDAD';
	elif _origen = 'E' then
		let _n_origen = 'BONI. RECLUTAMIENTO';
	elif _origen = 'P' then
		let _n_origen = 'PLANILLA';
	elif _origen = 'G' then
		let _n_origen = 'GASTOS ADM.';
	elif _origen = 'S' then
		let _n_origen = 'DEV. PRIMA SUSPENSO';
	elif _origen = 'K' then
		let _n_origen = 'DEV. POLIZA CANCELADA';
	elif _origen = 'F' then
		let _n_origen = 'BONI. 1% WEB';
	end if	

	return _no_requis,
		   _no_cheque,
		   _n_origen,
		   _a_nombre_de,
		   _fecha_impresion,
		   _monto,
		   _n_banco,
		   _n_chequera
		   with resume;
   
end foreach

end procedure
