--Procedure que retorna prima y nombre en suspenso a partir del numero de recibo

--Armando Moreno 26/10/2010

DROP PROCEDURE sp_sis138b;		

CREATE PROCEDURE "informix".sp_sis138b(a_no_recibo CHAR(30))
RETURNING VARCHAR(50),DEC(16,2),integer,date,char(30);

define _doc_remesa   char(30);
define _cnt          smallint;
define _asegurado    varchar(50);
define _monto        decimal(16,2);
define _fecha        date;

SET ISOLATION TO DIRTY READ;


BEGIN

--set debug file to "sp_sis138.trc";
--trace on;                         

let _doc_remesa = null;

let a_no_recibo = trim(a_no_recibo);

foreach

	SELECT doc_remesa
	  INTO _doc_remesa
	  FROM cobredet
	 WHERE no_recibo = a_no_recibo
	   and tipo_mov  = "E"

	let _doc_remesa = trim(_doc_remesa);
	
	if _doc_remesa = a_no_recibo then
		exit foreach;
	else
		let _doc_remesa = null;	
	end if
		
end foreach

let _asegurado = '';
let _monto     = 0.00;
let _fecha     = '01/01/1900';

IF _doc_remesa is not null then

	let _doc_remesa = trim(_doc_remesa);

	SELECT count(*)
	  INTO _cnt
	  FROM cobsuspe
	 WHERE doc_suspenso = _doc_remesa;

	if _cnt = 0 then

		RETURN 'No se encontro la prima en suspenso.',0, 1,'01/01/1900','';
	else

		SELECT asegurado,
		       monto,
			   fecha
		  INTO _asegurado,
		       _monto,
			   _fecha
		  FROM cobsuspe
		 WHERE doc_suspenso = _doc_remesa;

	end if
	
else

    let _doc_remesa = a_no_recibo;

	SELECT count(*)
	  INTO _cnt
	  FROM cobsuspe
	 WHERE doc_suspenso = _doc_remesa;

	if _cnt = 0 then

		RETURN 'No se encontro la prima en suspenso.',0, 1,'01/01/1900','';

	end if

	foreach
		SELECT asegurado,
               monto,
	           fecha
		  INTO _asegurado,
		       _monto,
			   _fecha
		  FROM cobsuspe
		 WHERE doc_suspenso = _doc_remesa

		exit foreach;

	end foreach


END IF

RETURN _asegurado,_monto,0,_fecha,_doc_remesa;

END

END PROCEDURE;
