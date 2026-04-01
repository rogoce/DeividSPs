-- Procedure que retorna reclamos con movimieno despues de haber sido cerrados de forma automatica des pues de los 3 meses sin movimiento

drop procedure amm_auditoria;

create procedure amm_auditoria()
returning CHAR(18),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2);

DEFINE _no_tranrec CHAR(10);
DEFINE _no_reclamo CHAR(10);
DEFINE _numrecla   CHAR(18);
DEFINE _no_documento CHAR(20);
DEFINE _cant smallint;
DEFINE _variacion	 DEC(16,2);
DEFINE _monto_cierre DEC(16,2);
define _pagado  	 DEC(16,2);
define _incurrido    DEC(16,2);
define _pagos        DEC(16,2);

set isolation to dirty read;

create temp table tmp_incurrid(
no_reclamo  char(10),
pagos		dec(16,2),
variacion	dec(16,2),
monto_cierre dec(16,2),
pagado       dec(16,2) 
) with no log;


FOREACH
  SELECT no_tranrec,   
         no_reclamo,   
         numrecla,
		 monto
    INTO _no_tranrec,
    	 _no_reclamo,
    	 _numrecla,
		 _monto_cierre
    FROM rectrmae  
   WHERE (rectrmae.user_added = 'informix') 
     AND (rectrmae.actualizado = 1 ) 
     AND (rectrmae.cod_tipotran = '011') 
     AND (rectrmae.periodo >= '2011-01') 
     AND (rectrmae.periodo <= '2011-12') 
     AND (rectrmae.numrecla[1,2] in ('02','20'))
     --AND (rectrmae.numrecla in('02-0111-00001-02','02-0111-00001-06','02-0111-00002-11'))
   order by no_reclamo

  LET _cant = 0;

  SELECT COUNT(*)
    INTO _cant
	FROM rectrmae
   WHERE no_reclamo  = _no_reclamo
     AND cod_tipotran NOT IN ('001','011')
	 AND actualizado = 1;

  IF _cant > 0 THEN

	insert into tmp_incurrid
	values (_no_reclamo,0,0,_monto_cierre,0);


	--Pagado
	foreach

	    SELECT monto
		  INTO _pagado
		  FROM rectrmae
		 WHERE no_reclamo   = _no_reclamo
		   AND cod_tipotran ="004"
	       AND periodo[1,4] = '2011'
		   AND actualizado  = 1

			insert into tmp_incurrid
			values (_no_reclamo,0,0,0,_pagado);


	end foreach

	--Pago , ded, salv etc para sacar incurrido
	foreach

	    SELECT monto
		  INTO _pagado
		  FROM rectrmae
		 WHERE no_reclamo   = _no_reclamo
		   AND cod_tipotran IN ("004", "005", "006", "007")
	       AND periodo[1,4] = '2011'
		   AND actualizado  = 1

			insert into tmp_incurrid
			values (_no_reclamo,_pagado,0,0,0);


	end foreach

	--Variacion
	foreach

		 select	variacion
		   into _variacion
		   from rectrmae
		  WHERE no_reclamo   = _no_reclamo
		    AND periodo[1,4] = '2011'
		    AND actualizado  = 1

			insert into tmp_incurrid
			values (_no_reclamo, 0, _variacion,0,0);

	end foreach
  end if

END FOREACH

let _incurrido = 0;

foreach
	 select sum(pagos),
			sum(variacion),
			sum(monto_cierre),
			sum(pagado),
			no_reclamo
	   into _pagado,
			_variacion,
			_monto_cierre,
			_pagos,
			_no_reclamo
	   from tmp_incurrid
	  group by no_reclamo
	  order by no_reclamo

		let _incurrido = _pagado + _variacion;

	    SELECT no_documento,numrecla
		  INTO _no_documento,_numrecla
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;    

		return _numrecla,
		       _no_documento,
			   _monto_cierre,
			   _pagos,
			   _incurrido
			   with resume;
end foreach
   
end procedure
