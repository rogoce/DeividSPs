-- Procedimiento que elimina linea en blanco de la Descripcion de la Transaccion

-- Creado    : 11/05/2004 - Autor: Armando Moreno M.
-- Modificado: 11/05/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

drop PROCEDURE sp_rec737;

CREATE PROCEDURE "informix".sp_rec737()
RETURNING char(20) as reclamo,char(10) as transaccion,varchar(50) as tipo_pago,varchar(100) as a_nombre_de,dec(16,2) as monto,char(8) as usuario,char(2) as pagado, char(10) as requisicion, char(3) as cod_ramo, varchar(50) as ramo;

define _no_factura   char(10);
define _cod_tipotran char(3);
define _cod_cpt      char(10);
define _monto        dec(16,2);
define _cant         smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);
define _numrecla     char(20);
define _no_tranrec   char(10);
define _monto2        dec(16,2);
define _user_added   char(8);
define _cod_cliente  char(10);
define _cod_tipopago char(3);
define _nombre       varchar(100);
define _cod_cliente2  char(10);
define _pago          varchar(50);
define _pagado        smallint;
define _requisicion   char(10);
define _pagado_s      char(2);
define _cod_ramo      char(3);
define _ramo          varchar(50);
define _no_poliza     char(10);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE pago_dup (
	numrecla    CHAR(20), 
	transaccion CHAR(10), 
	pago        VARCHAR(50), 
	nombre      VARCHAR(100), 
	monto2      DEC(16,2), 
	user_added  CHAR(8), 
	pagado      SMALLINT, 
	requisicion CHAR(10),
	cod_ramo    CHAR(3),
	PRIMARY KEY (transaccion, requisicion));

let _no_factura = null;
let _cant = 0;

foreach
	select no_reclamo,
	       numrecla,
		   no_poliza
	  into _no_reclamo,
	       _numrecla,
		   _no_poliza
	  from recrcmae
	 where actualizado = 1
	   and fecha_reclamo >= '01/01/2017'
	--   and fecha_reclamo <= '31/12/2016'
	   
	 select cod_ramo
	   into _cod_ramo
	   from emipomae
	  where no_poliza = _no_poliza;
	  
 let _cant = 0;
 foreach
	select no_tranrec,
	       no_factura,
		   cod_tipotran,
		   cod_cpt,
		   monto,
		   cod_cliente
	  into _no_tranrec,
	       _no_factura,
		   _cod_tipotran,
		   _cod_cpt,
		   _monto,
		   _cod_cliente
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = '004'
	   and actualizado = 1
	   and anular_nt is null
	 --  and monto > 0
	 --  and pagado = 1
	   
    let _cant = 0;
	let _monto2 = 0.00;
	 
	if _no_factura is not null and trim(_no_factura) <> "" and _cod_tipotran = "004" and _numrecla[1,2] = '18' then
		SELECT count(*)
		  INTO _cant
		  FROM rectrmae
		 WHERE no_tranrec <> _no_tranrec
		   and no_reclamo = _no_reclamo
		   and no_factura = _no_factura
		   and actualizado = 1
		   and cod_tipotran = _cod_tipotran
		   and anular_nt is null
		   and cod_cpt = _cod_cpt
		   and monto = _monto;
		--   and pagado = 1;
	end if
    if _cod_tipotran = "004" and _numrecla[1,2] = '16' then
		SELECT count(*)
		  INTO _cant
		  FROM rectrmae
		 WHERE no_tranrec <> _no_tranrec
		   and no_reclamo = _no_reclamo
		   and cod_cliente = _cod_cliente
		   and actualizado = 1
		   and cod_tipotran = _cod_tipotran
		   and anular_nt is null
		   and monto = _monto;
		--   and pagado = 1;
	end if	
	
    if _cod_tipotran = "004" and _numrecla[1,2] not in ('18','16') then
		SELECT count(*)
		  INTO _cant
		  FROM rectrmae
		 WHERE no_tranrec <> _no_tranrec
		   and no_reclamo = _no_reclamo
		   and actualizado = 1
		   and cod_tipotran = _cod_tipotran
		   and anular_nt is null
		   and monto = _monto;
		--   and pagado = 1;
	end if	

	if _cant > 0 and _numrecla[1,2] = '18' then
		foreach
			select transaccion, 
			       monto,
				   user_added,
				   cod_tipopago,
				   cod_cliente,
				   pagado,
				   no_requis
			  into _transaccion,
			       _monto2,
				   _user_added,
				   _cod_tipopago,
				   _cod_cliente2,
				   _pagado,
				   _requisicion
			  from rectrmae
			 where no_tranrec <> _no_tranrec
			   and no_reclamo = _no_reclamo
			   and no_factura = _no_factura
			   and actualizado = 1
			   and cod_tipotran = _cod_tipotran
			   and anular_nt is null
			   and cod_cpt = _cod_cpt
			   and monto = _monto
			  -- and pagado = 1
			   
	        if _requisicion is null then
				let _requisicion = "";
			end if
			
			select nombre
			  into _pago
			  from rectipag
			 where cod_tipopago = _cod_tipopago;
			 
			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente2;
			 
			 BEGIN
			 ON EXCEPTION
			 END EXCEPTION
			 INSERT INTO pago_dup
			 VALUES (_numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion, _cod_ramo);
			 END
			  			   
		--	  return _numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion with resume;
			  --exit foreach;
		end foreach
		
	end if

	if _cant > 0 and _numrecla[1,2] = '16' then
		foreach
			select transaccion, 
			       monto,
				   user_added,
				   cod_tipopago,
				   cod_cliente,
				   pagado,
				   no_requis
			  into _transaccion,
			       _monto2,
				   _user_added,
				   _cod_tipopago,
				   _cod_cliente2,
				   _pagado,
				   _requisicion
			  from rectrmae
			 where no_tranrec <> _no_tranrec
			   and no_reclamo = _no_reclamo
		       and cod_cliente = _cod_cliente
			   and actualizado = 1
			   and cod_tipotran = _cod_tipotran
			   and anular_nt is null
			   and monto = _monto
			--   and pagado = 1

	        if _requisicion is null then
				let _requisicion = "";
			end if
			
			select nombre
			  into _pago
			  from rectipag
			 where cod_tipopago = _cod_tipopago;
			 
			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente2;
			   
			 BEGIN
			 ON EXCEPTION
			 END EXCEPTION
			 INSERT INTO pago_dup
			 VALUES (_numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion, _cod_ramo);
			 END
--			  return _numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion with resume;
			  --exit foreach;
		end foreach
	end if
	
	if _cant > 0 and _numrecla[1,2] not in ('18','16') then
		foreach
			select transaccion, 
			       monto,
				   user_added,
				   cod_tipopago,
				   cod_cliente,
				   pagado,
				   no_requis
			  into _transaccion,
			       _monto2,
				   _user_added,
				   _cod_tipopago,
				   _cod_cliente2,
				   _pagado,
				   _requisicion
			  from rectrmae
			 where no_tranrec <> _no_tranrec
			   and no_reclamo = _no_reclamo
			   and actualizado = 1
			   and cod_tipotran = _cod_tipotran
			   and anular_nt is null
			   and monto = _monto
			 --  and pagado = 1

	        if _requisicion is null then
				let _requisicion = "";
			end if
			 
			select nombre
			  into _pago
			  from rectipag
			 where cod_tipopago = _cod_tipopago;
			 
			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente2;
			   
			 BEGIN
			 ON EXCEPTION
			 END EXCEPTION
			 INSERT INTO pago_dup
			 VALUES (_numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion, _cod_ramo);
			 END
			--  return _numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado, _requisicion with resume;
			  --exit foreach;
		end foreach
		
	end if
	
	end foreach
end foreach

foreach with hold
	select 	numrecla, 
	        transaccion, 
	        pago, 
	        nombre, 
	        monto2, 
	        user_added, 
	        pagado, 
	        requisicion,
			cod_ramo
	  into  _numrecla, 
	        _transaccion, 
			_pago, 
			_nombre, 
			_monto2, 
			_user_added, 
			_pagado, 
			_requisicion,
			_cod_ramo
	  from  pago_dup
	  
	  select nombre
	    into _ramo
		from prdramo
	   where cod_ramo = _cod_ramo;
	  
	  if _pagado = 1 then
	     let _pagado_s = "Si";
      else
	     let _pagado_s = "No";
	  end if
	  
	  return _numrecla, _transaccion, _pago, _nombre, _monto2, _user_added, _pagado_s, _requisicion, _cod_ramo, _ramo with resume;

end foreach
--return 0,"";
drop table pago_dup;
END PROCEDURE
