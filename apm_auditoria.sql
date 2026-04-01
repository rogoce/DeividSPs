-- Procedure que retorna reclamos con movimiento despues de haber sido cerrados de forma automatica des pues de los 3 meses sin movimiento

drop procedure apm_auditoria;

create procedure apm_auditoria()
returning CHAR(18),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2);

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

create temp table tmp_incurrid(
no_reclamo	char(10),
pagos		dec(16,2),
variacion	dec(16,2),
pago_solo	dec(16,2)
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
     AND (a.cod_tipotran = '011')
	 AND (a.numrecla[6,7] = '11')
     AND (a.periodo >= '2011-01') 
     AND (a.periodo <= '2011-12') 
     AND (a.numrecla[1,2] in ('02','20'))

  LET _cant = 0;

  SELECT COUNT(*)
    INTO _cant
	FROM rectrmae
   WHERE no_reclamo = _no_reclamo
     AND cod_tipotran <> '001'
	 and no_tranrec   <> _no_tranrec
	 and periodo <= '2011-12'
	 AND actualizado = 1;

  IF _cant > 0 THEN
    SELECT no_documento
	  INTO _no_documento
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;    

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
		and periodo <= '2011-12'

     if _variacion Is Null then
     	let _variacion = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, _variacion, 0);

	end foreach

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
		and periodo <= '2011-12'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, _pagos, 0, 0);

	end foreach

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
		and periodo <= '2011-12'

     if _pagos Is Null then
     	let _pagos = 0;
     end if	 

		insert into tmp_incurrid
		values (_no_reclamo, 0, 0, _pagos);

	end foreach

    let _incurrido = 0;
    let _pagos     = 0;
    let _variacion = 0;

	foreach
	 select sum(pagos),
			sum(variacion),
			sum(pago_solo)
	   into _pagos,
			_variacion,
			_pago_solo
	   from tmp_incurrid

	 let _incurrido = _pagos + _variacion;

    end foreach

	if _pago_solo = 0 and _incurrido = 0 then
	else
	    RETURN _numrecla, _no_documento, _monto, _pago_solo, _incurrido with resume;
	end if


  END IF
   
  delete from tmp_incurrid;
END FOREACH

drop table tmp_incurrid;

end procedure
