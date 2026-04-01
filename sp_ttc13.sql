-- Procedure que determina si el modelo Ancon es igual al modelo inma

-- Creado    : 02/09/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc13;

create procedure sp_ttc13(
a_modelo_ancon 	char(50),
a_modelo_inma	char(50)
) returning smallint;

define _largo	smallint;
define _match	smallint;

let _largo = length(a_modelo_inma);

let _match = 0;

if _largo = 1 then
	if a_modelo_ancon[1,1] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 2 then
	if a_modelo_ancon[1,2] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 3 then
	if a_modelo_ancon[1,3] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 4 then
	if a_modelo_ancon[1,4] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 5 then
	if a_modelo_ancon[1,5] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 6 then
	if a_modelo_ancon[1,6] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 7 then
	if a_modelo_ancon[1,7] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 8 then
	if a_modelo_ancon[1,8] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 9 then
	if a_modelo_ancon[1,9] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 10 then
	if a_modelo_ancon[1,10] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 11 then
	if a_modelo_ancon[1,11] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 12 then
	if a_modelo_ancon[1,12] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 13 then
	if a_modelo_ancon[1,13] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 14 then
	if a_modelo_ancon[1,14] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 15 then
	if a_modelo_ancon[1,15] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 16 then
	if a_modelo_ancon[1,16] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 17 then
	if a_modelo_ancon[1,17] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 18 then
	if a_modelo_ancon[1,18] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 19 then
	if a_modelo_ancon[1,19] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 20 then
	if a_modelo_ancon[1,20] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 21 then
	if a_modelo_ancon[1,21] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 22 then
	if a_modelo_ancon[1,22] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 23 then
	if a_modelo_ancon[1,23] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 24 then
	if a_modelo_ancon[1,24] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 25 then
	if a_modelo_ancon[1,25] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 26 then
	if a_modelo_ancon[1,26] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 27 then
	if a_modelo_ancon[1,27] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 28 then
	if a_modelo_ancon[1,28] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 29 then
	if a_modelo_ancon[1,29] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 30 then
	if a_modelo_ancon[1,30] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 31 then
	if a_modelo_ancon[1,31] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 32 then
	if a_modelo_ancon[1,32] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 33 then
	if a_modelo_ancon[1,33] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 34 then
	if a_modelo_ancon[1,34] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 35 then
	if a_modelo_ancon[1,35] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 36 then
	if a_modelo_ancon[1,36] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 37 then
	if a_modelo_ancon[1,37] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 38 then
	if a_modelo_ancon[1,38] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 39 then
	if a_modelo_ancon[1,39] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 40 then
	if a_modelo_ancon[1,40] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 41 then
	if a_modelo_ancon[1,41] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 42 then
	if a_modelo_ancon[1,42] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 43 then
	if a_modelo_ancon[1,43] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 44 then
	if a_modelo_ancon[1,44] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 45 then
	if a_modelo_ancon[1,45] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 46 then
	if a_modelo_ancon[1,46] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 47 then
	if a_modelo_ancon[1,47] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 48 then
	if a_modelo_ancon[1,48] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 49 then
	if a_modelo_ancon[1,49] = a_modelo_inma then
		let _match = 1;
	end if
elif _largo = 50 then
	if a_modelo_ancon[1,50] = a_modelo_inma then
		let _match = 1;
	end if
end if

return _match;

end procedure
