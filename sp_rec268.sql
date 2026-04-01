-- Requisiciones Pendientes de Pagar 

--drop procedure sp_rec268;

create procedure sp_rec268(a_cod_cliente char(10)
) returning date,
			char(10),
			char(100),
			dec(16,2);

define _no_requis		char(10);
define _fecha_captura	date;
define _nombre			char(100);
define _monto			dec(16,2);
define _numrecla        char(20);
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _ramo_sis        smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _descripcion		char(100);
define _cod_banco_r     char(3);
define _cod_chequera_r  char(3);
define _transaccion     char(10);
define _no_tranrec      char(10);
define _cant            smallint;
define _en_firma     	smallint;
define _tipo_requis     char(1);
define _ramo            char(2);

SET ISOLATION TO DIRTY READ;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;
 
foreach
 select	no_requis,
		fecha_captura,
		monto,
		cod_banco,
		cod_chequera,
		en_firma,
		tipo_requis
   into	_no_requis,
		_fecha_captura,
		_monto,
		_cod_banco_r,
		_cod_chequera_r,
		_en_firma,
		_tipo_requis
   from	chqchmae
  where cod_cliente   = a_cod_cliente
	and pagado        = 0
	and anulado       = 0
	and origen_cheque = "3"
	and en_firma	  in (0, 4, 5)
	and monto         <> 0
 order by 1 desc

 let _cant = 0;

 select count(*)	  
   into _cant
   from chqchrec
  where no_requis = _no_requis;

 if _cant = 0 then
	continue foreach;
 end if

 return _fecha_captura,
        _no_requis,
  	    _nombre,
		_monto;

 exit foreach;

end foreach

end procedure
