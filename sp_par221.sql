-- Poliza de Ducruet para buscar poliza en Ancon

drop procedure sp_par221;

create procedure "informix".sp_par221(a_poliza_ducruet char(50))
returning char(20);

define _no_documento	char(20);

let _no_documento = null;

if a_poliza_ducruet = "0202-020163-51" then

	let _no_documento = "0202-02163-51";

elif a_poliza_ducruet = "0202-0550-01" then

	let _no_documento = "0202-02550-01";

elif a_poliza_ducruet = "0204-02-00150-01" then

	let _no_documento = "0204-02150-01";

elif a_poliza_ducruet = "0204-0284-56" then

	let _no_documento = "0204-00284-56";

elif a_poliza_ducruet = "0205-02-0001-56" then

	let _no_documento = "0205-02001-56";

elif a_poliza_ducruet = "0205-02-0002-56" then

	let _no_documento = "0205-02002-56";

elif a_poliza_ducruet = "0205-02-0003-56" then

	let _no_documento = "0205-02003-56";

elif a_poliza_ducruet = "0205-02-0004-56" then

	let _no_documento = "0205-02004-56";

elif a_poliza_ducruet = "0205-02-0005-56" then

	let _no_documento = "0205-02005-56";

elif a_poliza_ducruet = "0205-02-0006-56" then

	let _no_documento = "0205-02006-56";

elif a_poliza_ducruet = "0205-02-0007-56" then

	let _no_documento = "0205-02007-56";

elif a_poliza_ducruet = "0205-02-0030-56" then

	let _no_documento = "0205-02030-56";

elif a_poliza_ducruet = "0205-0553-01" then

	let _no_documento = "0205-00553-01";

elif a_poliza_ducruet = "0205-9005-47" then

	let _no_documento = "0205-90005-47";

elif a_poliza_ducruet = "0296-2617" then

	let _no_documento = "0296-2617-01";

elif a_poliza_ducruet[14,15] = "56" then
	
	if a_poliza_ducruet[3,4] >= "05" then

		let _no_documento = a_poliza_ducruet[1,5] || a_poliza_ducruet[7,7] || a_poliza_ducruet[9,50];

	else

		let _no_documento = a_poliza_ducruet[1,7] || a_poliza_ducruet[10,50];

	end if

elif a_poliza_ducruet[14,15] = "51" then
	
	let _no_documento = a_poliza_ducruet[1,7] || a_poliza_ducruet[10,50];

elif a_poliza_ducruet[11] = " " then

	let _no_documento = a_poliza_ducruet[1,10] || "-01";

elif a_poliza_ducruet[14] = " " then

	if a_poliza_ducruet[15] <> " " then
		
		let _no_documento = a_poliza_ducruet[1,13];

	end if

else

	let _no_documento = a_poliza_ducruet;

end if

return _no_documento;

end procedure