--Procedure que retorna prima y nombre en suspenso a partir del numero de recibo

--Armando Moreno 26/10/2010

DROP PROCEDURE sp_sis138a;		

CREATE PROCEDURE "informix".sp_sis138a(a_no_recibo CHAR(30))
RETURNING VARCHAR(50);

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
		return _doc_remesa;
	end if
	
end foreach
return 'no';
end
end procedure