-- Verificador requisiciones de Reclamos de Salud

drop procedure sp_verif_requis;

create procedure sp_verif_requis()
returning char(100),
          char(10),
          char(10),
          char(7),
          char(10),
          char(10),
          date,
          smallint,
          char(100),
          char(100),
          char(8),
          char(8);

define _no_requis	  	char(10);
define _cod_tipopago  	char(3);
define _periodo_pago  	smallint;
define _cod_banco     	char(3);
define _cod_chequera  	char(3);
define _cnt           	integer;
define _nombre        	char(100);
define _cod_cliente   	char(10);
define _cod_cliente_ch	 char(10);
define _fecha_paso_firma datetime year to fraction(5);
define _anulado       	integer;
define _periodo       	char(7);
define _fecha_impresion date;
define _pagado        	integer;
define _transaccion   	char(10);
define _n_cliente_chq 	char(100);
define _n_cliente_trx 	char(100);
define _n_cliente_des 	char(100);
define _user_trx		char(8);
define _user_chk		char(8);
	
SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

{foreach
  	 select	no_requis,
			periodo_pago,
			a_nombre_de,
			cod_cliente,
			fecha_paso_firma
	   into	_no_requis,
			_periodo_pago,
			_nombre,
			_cod_cliente,
			_fecha_paso_firma
	   from	chqchmae
	  where autorizado    = 1
		and origen_cheque = "3"
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and date(fecha_paso_firma) >= a_fecha
		and periodo_pago     = 0

	  select periodo_pago
	    into _periodo_pago
	    from cliclien
	   where cod_cliente = _cod_cliente; 	



	  if _periodo_pago = 1 then

	    {update chqchmae
		   set periodo_pago = _periodo_pago
		 where no_requis    = _no_requis; 

	  	return _no_requis,_nombre,_cod_cliente,_fecha_paso_firma with resume;
	  end if

end foreach	

{foreach
	select cod_cliente,
	       no_requis
	  into _cod_cliente,
	       _no_requis
	  from rectrmae
	 where fecha          = a_fecha
	   and actualizado    = 1
	   and numrecla[1,2]  = "18"
	   and generar_cheque = 1
	   and cod_tipotran   = "004"	 --pago
	   and periodo        = "2008-02"
	   and no_requis is not null
	   and cod_tipopago   = "001"	 --proveedor

	  select periodo_pago
	    into _periodo_pago
	    from cliclien
	   where cod_cliente = _cod_cliente;
	    	
	 { select periodo_pago
	    into _periodo_pago
	    from chqchmae
	   where no_requis = _no_requis; 

	  if _periodo_pago = 0 then
			return _no_requis,"",_cod_cliente,null with resume;
	  end if 


end foreach	}

foreach
	select cod_cliente,
	       no_requis,
		   periodo,
		   transaccion,
		   user_added
	  into _cod_cliente,
	       _no_requis,
		   _periodo,
		   _transaccion,
		   _user_trx
	  from rectrmae
	 where actualizado    = 1
	   and numrecla[1,2]  = "18"
	   and generar_cheque = 1
	   and cod_tipotran   = "004"	 --pago
	   and periodo        > "2008-08"
	   and no_requis      is not null
	   and transaccion not in('01-1349258','01-1349264')

	  select nombre
	    into _n_cliente_trx
	    from cliclien
	   where cod_cliente = _cod_cliente;

	  select cod_cliente,
	         anulado,
			 fecha_impresion,
			 pagado,
			 a_nombre_de,
			 autorizado_por
	    into _cod_cliente_ch,
		     _anulado,
			 _fecha_impresion,
			 _pagado,
			 _n_cliente_des,
			 _user_chk
	    from chqchmae
	   where no_requis = _no_requis;

	  select nombre
	    into _n_cliente_chq
	    from cliclien
	   where cod_cliente = _cod_cliente_ch;

--	  if _anulado = 1 then
--		continue foreach;
--	  end if

	  if _cod_cliente_ch is null or _cod_cliente_ch = "" then
	  	let _n_cliente_chq = "";
	  end if
	  	
	  if _cod_cliente <> _cod_cliente_ch then

			return _n_cliente_trx,
				   _transaccion,
				   _no_requis,
				   _periodo,
				   _cod_cliente,
				   _cod_cliente_ch,
				   _fecha_impresion,
				   _pagado,
				   _n_cliente_chq, 
				   _n_cliente_des,
				   _user_trx,
				   _user_chk
				   with resume;

	  end if 

end foreach

RETURN "0","","","","","","01/01/1900",0,"", "", "", "" WITH RESUME;

end procedure
