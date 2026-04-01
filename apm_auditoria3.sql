-- Procedure que retorna reclamos del 2011 que han sido cerrados de forma automatica por el proceso despues de los 3 meses sin movimiento.
-- Esto es para Auditoria

--drop procedure apm_auditoria3;

create procedure apm_auditoria3()
returning CHAR(18),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

DEFINE _no_tranrec CHAR(10);
DEFINE _no_reclamo CHAR(10);
DEFINE _numrecla   CHAR(18);
DEFINE _no_documento CHAR(20);
DEFINE _cant smallint;
DEFINE _variacion DEC(16,2);
define _periodo		char(7);
define _pagos		dec(16,2);
define _incurrido	dec(16,2);
define _monto   	dec(16,2);
define _pago_solo 	dec(16,2);
DEFINE _variacion2  DEC(16,2);
define _pagos2		dec(16,2);
define _incurrido2	dec(16,2);
define _pago_solo2 	dec(16,2);

create temp table tmp_incurrid(
no_reclamo	char(10),
pagos		dec(16,2),
variacion	dec(16,2),
pago_solo	dec(16,2),
pagos2		dec(16,2),
variacion2	dec(16,2),
pago_solo2	dec(16,2)
) with no log;

set isolation to dirty read;

FOREACH
  SELECT a.no_tranrec,   
         a.no_reclamo,   
         a.numrecla,
		 a.monto
    INTO _no_tranrec,
    	 _no_reclamo,
    	 _numrecla,
    	 _monto  
    FROM rectrmae a 
   WHERE (a.user_added = 'informix' ) 
     AND (a.actualizado = 1 ) 
     AND (a.cod_tipotran = '011')	--transaccion de cierre
	 AND (a.numrecla[6,7] = '11')      
     AND (a.periodo >= '2011-01') 
     AND (a.periodo <= '2011-12') 
     AND (a.numrecla[1,2] in ('02','20'))

  LET _cant = 1;

  IF _cant > 0 THEN
    SELECT no_documento
	  INTO _no_documento
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;    

	--Variacion 2011
	foreach
	 select	periodo,
	        variacion
	   into _periodo,
	        _variacion
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
	    and periodo < '2012-01'

     if _variacion Is Null then
     	let _variacion = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, _variacion, 0, 0, 0, 0);

	end foreach

	--Pagos para el incurrido 2011
	foreach
	 select	periodo,
	        monto
	   into _periodo,
	        _pagos
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
		and cod_tipotran in ("004", "005", "006", "007")
	    and periodo < '2012-01'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, _pagos, 0, 0, 0, 0, 0);

	end foreach

	--Solo Pagos 2011
	foreach
	 select	periodo,
	        monto
	   into _periodo,
	        _pagos
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
		and cod_tipotran in ("004")
	    and periodo < '2012-01'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, 0, _pagos, 0, 0, 0);

	end foreach

---Variacion 2012
	foreach
	 select	periodo,
	        variacion
	   into _periodo,
	        _variacion
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
	    and periodo >= '2012-01'

     if _variacion Is Null then
     	let _variacion = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, 0, 0,  0, _variacion, 0);

	end foreach

	--Pagos para incurrido 2012
	foreach
	 select	periodo,
	        monto
	   into _periodo,
	        _pagos
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
		and cod_tipotran in ("004", "005", "006", "007")
	    and periodo >= '2012-01'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, 0, 0, _pagos, 0, 0);

	end foreach

	--Solo pagos 2012
	foreach
	 select	periodo,
	        monto
	   into _periodo,
	        _pagos
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and cod_tipotran <> '001'
	    and no_tranrec   <> _no_tranrec
		and actualizado  = 1
		and cod_tipotran in ("004")
	    and periodo >= '2012-01'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, 0, 0, 0, 0, _pagos);

	end foreach

    let _incurrido = 0;
    let _pagos = 0;
    let _variacion = 0;

	foreach
	 select sum(pagos),
			sum(variacion),
			sum(pago_solo),
			sum(pagos2),
			sum(variacion2),
			sum(pago_solo2)
	   into _pagos,
			_variacion,
			_pago_solo,
			_pagos2,
			_variacion2,
			_pago_solo2
	   from tmp_incurrid

	 let _incurrido = _pagos + _variacion;
	 let _incurrido2 = _pagos2 + _variacion2;

    end foreach
	if _pago_solo is null then
		let _pago_solo = 0;
	end if
	if _incurrido is null then
		let _incurrido = 0;
	end if
	if _pago_solo2 is null then
		let _pago_solo2 = 0;
	end if
	if _incurrido2 is null then
		let _incurrido2 = 0;
	end if

    RETURN _numrecla, _no_documento, _monto, _pago_solo, _incurrido, _pago_solo2, _incurrido2 with resume;

  END IF
   
  delete from tmp_incurrid;

END FOREACH

drop table tmp_incurrid;

end procedure
