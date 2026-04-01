
DROP PROCEDURE sp_sis265;
CREATE PROCEDURE sp_sis265(a_no_documento CHAR(20))
RETURNING smallint;

DEFINE _no_documento		CHAR(20);

SET ISOLATION TO DIRTY READ;

let _no_documento = null;

FOREACH
	select l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and e.no_documento = a_no_documento
	   and l.no_letra = 1
	   and l.pagada = 0
	   and l.monto_letra <> 0
	   and l.monto_pag = 0
	 group by l.no_documento
	 
	exit foreach;
END FOREACH

if _no_documento is not null then
	return 1;	--Significa que es apta para Nulidad, NO debe entrar a la estructura de avisos
else
	return 0;	--Es apta para entrar a la estructura de avisos.
end if
END PROCEDURE;