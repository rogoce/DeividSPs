--Buscar no. recuper si es el caso
-- Armando Moreno 11/11/2010


--drop procedure sp_pro199;

create procedure sp_pro199(a_numrecla char(18))
RETURNING CHAR(5);

define _no_recupero char(5);

set isolation to dirty read;

let _no_recupero = "";

begin

foreach

	select no_recupero
	  into _no_recupero
	  from recrecup
	 where numrecla = a_numrecla

exit foreach;
end foreach

if _no_recupero is null then
	let _no_recupero = "";
end if

RETURN _no_recupero;

END
end procedure