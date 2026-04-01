

DROP PROCEDURE sp_sis21adm;
CREATE PROCEDURE sp_sis21adm(a_no_documento CHAR(20))
RETURNING CHAR(10);

DEFINE _no_poliza,_no_poliza2		CHAR(10);
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;
define _saldo           dec(16,2);

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _fecha_hoy = today;
let _saldo = 0.00;
let _no_poliza2 = null;

FOREACH
	select no_poliza,
		   vigencia_inic,
		   saldo
	  into _no_poliza,
		   _vigencia_inic,
		   _saldo
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_final desc

	if _saldo <> 0 then
		FOREACH
			select no_poliza,
				   saldo
			  into _no_poliza2,
				   _saldo
			  from emipomae
			 where no_documento = a_no_documento
			   and actualizado = 1
			   and no_poliza <> _no_poliza
			 order by vigencia_final desc
			EXIT FOREACH;
		END FOREACH
		if _no_poliza2 is null then
			RETURN _no_poliza;
		end if
		if _saldo <> 0 then
			return _no_poliza2;
			exit FOREACH;
		end if
	else
		continue foreach;	
	end if
END FOREACH
RETURN _no_poliza;
END PROCEDURE 
