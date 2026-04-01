-- Cheques pagados y sin anulados

drop procedure sp_rec291;
create procedure sp_rec291(a_periodo char(7))
RETURNING CHAR(255);
		   
define _numrecla        char(18);
define _no_reclamo      char(10);
define _monto			dec(16,2);
	   
create temp table tmp_sinis(
numrecla            char(18), 
no_reclamo			char(10),
pagado_banco	    dec(16,2) default 0,
seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
PRIMARY KEY (no_reclamo)
) WITH NO LOG;

set isolation to dirty read;

-- Cheques Anulados

foreach
     Select t.no_reclamo,
	        sum(t.monto)
       into _no_reclamo,
            _monto			
	   FROM chqchmae c, chqchrec r, rectrmae t
	  WHERE c.no_requis        = r.no_requis
	    and r.transaccion      = t.transaccion
	    and c.pagado           = 1	    
	    AND c.anulado          = 0
        and c.periodo = a_periodo

	 group by 1  
	 
	select numrecla
	  into _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;	 
		 
		insert into tmp_sinis (numrecla,no_reclamo, pagado_banco)
		values (_numrecla, _no_reclamo, _monto);
	 
end foreach


return 0;

end procedure
