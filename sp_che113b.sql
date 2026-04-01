-- Reporte para las requisiciones de Reclamos

-- Creado    : 23/03/2010 - Autor: Amado Perez
-- Copia del sp_che67

drop procedure sp_che113b;

create procedure sp_che113b(a_fecha date, a_fecha2 date)
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   varchar(25),
		   smallint,
		   char(8),
		   char(8),
		   integer,
		   char(10),
		   char(20),
		   varchar(50),
		   char(10),
		   char(10),
		   char(10),
		   char(10),
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
define _reclamo			char(20);
define _no_cheque		integer;
define _cuenta          varchar(25);
define _numrecla        char(20);
define _cod_ramo        char(3);
define _cod_ruta        char(2);
define _ruta            varchar(50);
define _celular			char(10);	
define _celular2		char(10);
define _telefono1		char(10);
define _telefono2		char(10);
define _e_mail			char(50);

SET ISOLATION TO DIRTY READ;

foreach
select cod_banco,
       cod_chequera,
	   cod_ramo
  into _cod_banco,
	   _cod_chequera,
	   _cod_ramo
  from chqbanch
 where cod_ramo in ('016','019') 

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		no_cheque,
		cod_ruta
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque,
		_cod_ruta
   from	chqchmae
  where anulado         = 0
 --   and autorizado      = 1
	and pagado			= 1
	and origen_cheque   = '3'
	and fecha_impresion >= a_fecha 
	and fecha_impresion <= a_fecha2
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and en_firma        = 2
	
   select nombre
     into _ruta
	 from chqruta
	where cod_ruta = _cod_ruta;
	
   foreach
	select numrecla, transaccion, numrecla
	  into _reclamo, _transaccion, _numrecla
	  from chqchrec
	 where no_requis = _no_requis
	exit foreach;
   end foreach   
   
   if _reclamo[1,2] <> _cod_ramo[2,3] then
	continue foreach;
   end if

   foreach
   	select cuenta 
	  into _cuenta
	  from chqchcta
	 where no_requis = _no_requis
	   and cuenta[1,3] in ('122','123')

     exit foreach;    
   end foreach
   
	let _celular	= "";
	let _celular2	= "";
	let _telefono1	= "";
	let _telefono2	= "";
	let _e_mail		= "";
	
	select celular, 
	       fax, 
		   telefono1, 
		   telefono2, 
		   e_mail
	 into _celular,
		  _celular2,
		  _telefono1,
		  _telefono2,
		  _e_mail
     from cliclien 
	where cod_cliente = _cod_cliente;

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   trim(_cuenta),
		   _periodo_pago,
		   _firma1,
		   _firma2,
		   _no_cheque,
		   _transaccion,
           _numrecla,
           _ruta,
		   _celular,
		   _celular2,
		   _telefono1,
		   _telefono2,
		   _e_mail		   
		   with resume;
   
end foreach
end foreach
end procedure
