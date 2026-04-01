-- Requisiciones Pendientes de Pagar para los Reclamos de Auto
-- Para poder agregar mas transacciones de reclamos a una misma 
-- requisicion

-- Creado    : 15/01/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 15/01/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/10/2003 - Autor: Demetrio Hurtado Almanza
--			   Se elimino la parte de buscar que sea el mismo reclamo, para que sean
--			   todas las transacciones de pago del mismo cliente
-- Modificado  05/04/2006 - Autor: Amado Perez 
--             Se valida que solo sean requisiciones de reclamos de salud
-- Modificado  24/03/2010 - Autor: Amado Perez
--             Se agrupara si es Auto y concepto legal
-- Modificado  25/03/2019 - Autor: Amado Perez
--             Se agrupara si es Auto y concepto 058 TRAMITES MUNICIPALES

-- SIS v.2.0 - d_recl_tra_ayuda_requis2 - DEIVID, S.A.

drop procedure sp_rec184;

create procedure sp_rec184(a_cod_cliente char(10), a_no_tranrec char(10)
) returning char(10);

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
define _cant, _cant2    smallint;
define _en_firma     	smallint;
define _tipo_requis     char(1);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rec184.trc";
--trace on;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;

select count(*) --Legal
  into _cant
  from rectrcon
 where no_tranrec = a_no_tranrec
   and cod_concepto = "012";

select count(*)
  into _cant2 --Municipal
  from rectrcon
 where no_tranrec = a_no_tranrec
   and cod_concepto = "058";
   
if _cant > 0 or _cant2 > 0 then
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
	 order by 1 --desc

	--    and autorizado    = 1	se quito para que unifique cuando se acaba el disponible.
	let _cant = 0;

	 select count(*)	  
	   into _cant
	   from chqchrec
	  where no_requis = _no_requis;

	 if _cant = 0 then
		continue foreach;
	 end if

	 foreach
		select numrecla,
		       transaccion
		  into _numrecla,
		       _transaccion
		  from chqchrec
		 where no_requis = _no_requis

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where numrecla = _numrecla;

	    select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

	    select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis <> 1 then
			exit foreach;
		end if

	    if _ramo_sis = 1 and _cant > 0 then --> Verificando si es de legal y de automovil
		    select no_tranrec
			  into _no_tranrec
			  from rectrmae
			 where transaccion = _transaccion;

	        let _cant = 0;

		    select count(*)
			  into _cant
			  from rectrcon
			 where no_tranrec = _no_tranrec
			   and cod_concepto = "012";

	        if _cant = 0 then
			   exit foreach;
			end if
		end if
	    if _ramo_sis = 1 and _cant2 > 0 then --> Verificando si es de tramite municipal y de automovil
		    select no_tranrec
			  into _no_tranrec
			  from rectrmae
			 where transaccion = _transaccion;

	        let _cant = 0;

		    select count(*)
			  into _cant
			  from rectrcon
			 where no_tranrec = _no_tranrec
			   and cod_concepto = "058";

	        if _cant = 0 then
			   exit foreach;
			end if
		end if
	 end foreach

	 if _ramo_sis <> 1 then
		continue foreach;
	 end if

	 if _ramo_sis = 1 and _cant = 0 then
		continue foreach;
	 end if

	 if _ramo_sis = 1 and _en_firma <> 4 and _en_firma <> 5 then
		continue foreach;
	 end if

	 if _ramo_sis = 1 and _monto < 0.00 then
		continue foreach;
	 end if

	 select cod_banco,
	        cod_chequera
	   into _cod_banco,
		    _cod_chequera
	   from chqbanch
	  where cod_ramo = _cod_ramo
	    and cod_banco = '001';


	 if _cod_banco <> _cod_banco_r or _cod_chequera <> _cod_chequera_r then
		continue foreach;
	 end if

	 return _no_requis;

	 exit foreach;

	end foreach
 else
    return null;
 end if

end procedure
